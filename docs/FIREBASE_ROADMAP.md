# Firebase setup roadmap for multiplayer voting

This roadmap shows how to move vote persistence from local files to Firebase so players on different computers can vote reliably.

## 1) Create Firebase project

1. Go to [Firebase Console](https://console.firebase.google.com/), click **Add project**.
2. Name it (example: `arrakis-votes`).
3. Enable Google Analytics only if you need it.

## 2) Add a Web app

1. In Project Overview, click **</> Web** and register an app (example: `dune-ledger-web`).
2. Copy the Firebase config snippet values (`apiKey`, `authDomain`, `projectId`, etc.).

## 3) Choose data store

Use **Cloud Firestore** (recommended for this use case).

1. In Firebase Console, open **Firestore Database**.
2. Click **Create database**.
3. Start in **production mode**.
4. Pick a region close to your players.

## 4) Install Firebase client SDK in this Astro app

Run in project root:

```bash
npm install firebase
```

Create `src/lib/firebase.ts` with your environment-based config:

```ts
import { initializeApp } from 'firebase/app';
import { getFirestore } from 'firebase/firestore';

const firebaseConfig = {
  apiKey: import.meta.env.PUBLIC_FIREBASE_API_KEY,
  authDomain: import.meta.env.PUBLIC_FIREBASE_AUTH_DOMAIN,
  projectId: import.meta.env.PUBLIC_FIREBASE_PROJECT_ID,
  appId: import.meta.env.PUBLIC_FIREBASE_APP_ID
};

const app = initializeApp(firebaseConfig);
export const db = getFirestore(app);
```

Add `.env` values:

```env
PUBLIC_FIREBASE_API_KEY=...
PUBLIC_FIREBASE_AUTH_DOMAIN=...
PUBLIC_FIREBASE_PROJECT_ID=...
PUBLIC_FIREBASE_APP_ID=...
```

## 5) Data model for votes

Use one document per action and player:

- Collection: `votes`
- Document ID: `${actionId}__${normalizedPlayer}`
- Fields:
  - `actionId: string`
  - `player: string`
  - `choice: 'support' | 'oppose' | 'abstain'`
  - `updatedAt: serverTimestamp()`

This naturally enforces one vote per player per action.

## 6) Replace local file API with Firestore API

Update `src/pages/api/votes.json.ts`:

- **POST**:
  - Validate payload (same as now).
  - Build normalized key from `actionId + player`.
  - `setDoc` into `votes/{docId}` with `merge: true`.
  - Return fresh tallies grouped by action.
- **GET**:
  - Read all vote documents (or query by action).
  - Build tally response exactly like current frontend expects.

## 7) Security rules (minimum baseline)

In Firestore Rules, start with:

```txt
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /votes/{voteId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

Then choose one auth approach:

- **Fastest:** Anonymous Auth for players.
- **Stronger:** Custom Auth and game/session checks.

If you need no-login voting, keep writes open only behind a server endpoint and use Admin SDK there.

## 8) Authentication options

### Option A: Anonymous Auth (quick)

1. Enable **Authentication → Sign-in method → Anonymous**.
2. Sign players in anonymously on page load.
3. Firestore rules require `request.auth != null`.

### Option B: Server-only writes (safer for abuse)

1. Keep client read-only.
2. Use Astro server endpoint with Firebase Admin SDK to write votes.
3. Store Admin service account credentials as server env vars.

## 9) Real-time updates (optional)

To show live tallies without refresh:

- Subscribe with Firestore `onSnapshot` on `votes` collection.
- Recompute tally in browser whenever snapshots change.

## 10) Deploy plan

Recommended choices:

- **Firebase Hosting + Cloud Functions** (all-in Firebase).
- **Vercel/Netlify + Firestore** (Astro hosted elsewhere).

If keeping Astro API routes, ensure deployment target supports server runtime (not static-only).

## 11) Cost and abuse controls

1. Add App Check if using client SDK directly.
2. Add rate limiting in server endpoint (IP/session based).
3. Add simple profanity/length checks for player names.
4. Add TTL/cleanup for stale vote sessions if needed.

## 12) Migration checklist

- [ ] Firebase project created
- [ ] Firestore enabled
- [ ] Auth method selected and enabled
- [ ] SDK installed and configured with env vars
- [ ] `src/pages/api/votes.json.ts` switched to Firestore
- [ ] Rules deployed and tested
- [ ] Multi-device vote test completed
- [ ] Production deploy completed

---

## External actions you must do

1. Create the Firebase project and Firestore in console.
2. Enable auth method (anonymous or chosen alternative).
3. Provide env vars in your hosting provider.
4. Deploy updated app to a server-capable target.

Once these are done, your players can vote from separate computers with shared persistent tallies.
