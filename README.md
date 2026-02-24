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

