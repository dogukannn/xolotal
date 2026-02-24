import type { APIRoute } from 'astro';
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';

const voteStore = resolve(process.cwd(), 'data', 'votes.json');
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

const emptyVoteFile: VoteFile = { votes: [] };

async function readVoteFile(): Promise<VoteFile> {
  try {
    const raw = await readFile(voteStore, 'utf8');
    return JSON.parse(raw) as VoteFile;
  } catch {
    return emptyVoteFile;
  }
}

async function writeVoteFile(payload: VoteFile): Promise<void> {
  await mkdir(dirname(voteStore), { recursive: true });
  await writeFile(voteStore, JSON.stringify(payload, null, 2), 'utf8');
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
  const file = await readVoteFile();
  return new Response(JSON.stringify({ totals: summarize(file.votes), votes: file.votes.length }), {
    headers: { 'Content-Type': 'application/json' }
  });
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

  const file = await readVoteFile();
  const idx = file.votes.findIndex((vote) => vote.actionId === actionId && vote.player.toLowerCase() === player.toLowerCase());
  const entry: VoteRecord = { actionId, player, choice, updatedAt: new Date().toISOString() };

  if (idx >= 0) {
    file.votes[idx] = entry;
  } else {
    file.votes.push(entry);
  }

  await writeVoteFile(file);

  return new Response(JSON.stringify({ totals: summarize(file.votes) }), {
    headers: { 'Content-Type': 'application/json' }
  });
};
