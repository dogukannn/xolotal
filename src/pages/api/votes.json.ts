import type { APIRoute } from 'astro';

export const prerender = false;
const firebaseBaseUrl = 'https://xolotal-default-rtdb.europe-west1.firebasedatabase.app';
const firebaseVotesEndpoint = `${firebaseBaseUrl}/votes.json`;
const actions = ['Spice Reserve Release', 'Border Skirmish Response', 'Guild Passage Tax'];

type VoteChoice = 'support' | 'oppose' | 'abstain';

type VoteRecord = {
  actionId: string;
  player: string;
  choice: VoteChoice;
  updatedAt: string;
};

type VoteFile = {
  votes: VoteRecord[];
};

async function readVotes(): Promise<VoteRecord[]> {
  const response = await fetch(firebaseVotesEndpoint);

  if (!response.ok) {
    throw new Error(`Failed to load votes from Firebase (${response.status})`);
  }

  const payload = (await response.json()) as Record<string, VoteRecord> | null;
  if (!payload || typeof payload !== 'object') return [];

  return Object.values(payload);
}

function voteKey(actionId: string, player: string): string {
  return `${actionId.toLowerCase().replace(/[^a-z0-9]+/g, '-')}_${player.toLowerCase().replace(/[^a-z0-9]+/g, '-')}`;
}

async function upsertVote(entry: VoteRecord): Promise<void> {
  const key = voteKey(entry.actionId, entry.player);
  const response = await fetch(`${firebaseBaseUrl}/votes/${key}.json`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(entry)
  });

  if (!response.ok) {
    throw new Error(`Failed to save vote to Firebase (${response.status})`);
  }
}

function summarize(votes: VoteRecord[]) {
  return actions.map((actionId) => {
    const tally = { support: 0, oppose: 0, abstain: 0 };
    votes
      .filter((vote) => vote.actionId === actionId)
      .forEach((vote) => {
        tally[vote.choice] += 1;
      });

    return { actionId, tally };
  });
}

export const GET: APIRoute = async () => {
  try {
    const votes = await readVotes();
    return new Response(JSON.stringify({ totals: summarize(votes), votes: votes.length }), {
      headers: { 'Content-Type': 'application/json' }
    });
  } catch {
    return new Response(JSON.stringify({ error: 'Could not load vote totals from Firebase.' }), { status: 502 });
  }
};

export const POST: APIRoute = async ({ request }) => {
  const body = await request.json().catch(() => null);
  if (!body || typeof body !== 'object') {
    return new Response(JSON.stringify({ error: 'Invalid payload.' }), { status: 400 });
  }

  const actionId = typeof body.actionId === 'string' ? body.actionId : '';
  const player = typeof body.player === 'string' ? body.player.trim() : '';
  const choice = body.choice as VoteChoice;

  if (!actions.includes(actionId)) {
    return new Response(JSON.stringify({ error: 'Unknown action.' }), { status: 400 });
  }

  if (!player || player.length > 32) {
    return new Response(JSON.stringify({ error: 'Player name required (1-32 chars).' }), { status: 400 });
  }

  if (!['support', 'oppose', 'abstain'].includes(choice)) {
    return new Response(JSON.stringify({ error: 'Invalid vote option.' }), { status: 400 });
  }

  const entry: VoteRecord = { actionId, player, choice, updatedAt: new Date().toISOString() };
  try {
    await upsertVote(entry);
    const votes = await readVotes();

    return new Response(JSON.stringify({ totals: summarize(votes) }), {
      headers: { 'Content-Type': 'application/json' }
    });
  } catch {
    return new Response(JSON.stringify({ error: 'Could not save vote to Firebase.' }), { status: 502 });
  }
};
