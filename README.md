# Dune Campaign Chronicle (Astro)

A Dune-inspired campaign tracker now built with **Astro** and styled with a richer Arrakis theme, including a custom house sigil.

## Why the previous server showed "Bad Request"

This project is now an Astro app (not just plain static files), so use Astro's development server rather than a random static server command.

## Run locally

```bash
npm install
npm run dev
```

Then open `http://localhost:4321`.

## Build for production

```bash
npm run build
npm run preview
```


## Deploy to GitHub Pages

This repo includes `.github/workflows/deploy.yml`, which automatically builds and deploys the site to GitHub Pages every time you push to `main`.

1. In GitHub, go to **Settings → Pages**.
2. Set **Source** to **GitHub Actions**.
3. Push to `main` and the workflow will publish `dist/`.

> Note: votes are now loaded/saved directly from Firebase in the browser, which keeps the site compatible with static hosting on GitHub Pages.


## Add a new session entry (PowerShell)

Run the script and answer the interactive prompts:

```powershell
pwsh ./scripts/add-session.ps1
```

The script asks for:
- session title
- date
- threat points
- momentum
- determination points
- spotlight items (multiple, one per line)
- optional notes

The page renders entries from `src/data/sessions.json` in the **Session Arsivi** section.



## JSON-driven layouts and update scripts

Most page sections now read from JSON files under `src/data` so you can edit campaign notes per session without touching templates.

- Sayings: `src/data/sayings.json` → `pwsh ./scripts/add-saying.ps1`
- Sessions: `src/data/sessions.json` → `pwsh ./scripts/add-session.ps1`
- House Minor briefings: `src/data/house-minor-briefings.json` → `pwsh ./scripts/add-briefing-note.ps1`
- Vote actions: `src/data/vote-actions.json` → `pwsh ./scripts/add-vote-action.ps1`
- Senate parties: `src/data/senate-parties.json` → `pwsh ./scripts/add-senate-party.ps1`
- Settlements: `src/data/settlements.json` → `pwsh ./scripts/add-settlement.ps1`
- Power standings: `src/data/power-standings.json` → `pwsh ./scripts/add-standing.ps1`
- Current ruler section: `src/data/ruler.json` → `pwsh ./scripts/update-ruler.ps1`
- Experimental notable character portraits: `src/data/notable-characters.json` → `pwsh ./scripts/add-notable-character.ps1`

### Sync notable portraits into the repository

If you want portrait images committed into the repo and resized from JSON-defined dimensions:

1. Add an `image` block per character in `src/data/notable-characters.json`:

```json
{
  "name": "Example",
  "portraitUrl": "https://...",
  "image": {
    "sourceUrl": "https://...",
    "width": 480,
    "height": 480
  }
}
```

2. Run:

```bash
npm run sync:portraits
```

This command downloads each `image.sourceUrl`, rescales it to the JSON resolution, saves it under `public/images/notable-characters`, and rewrites `portraitUrl` to the local repo path.

