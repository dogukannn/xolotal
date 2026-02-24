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

## Update JSON content with one interactive script

All update scripts are merged into a single interactive PowerShell command:

```powershell
npm run manage:data
```

When launched, the script asks what to update, then asks only the relevant fields.

Available actions:
- Add saying
- Add vote action
- Add House Minor briefing note
- Add settlement
- Add senate party
- Add power standing
- Add session
- Update ruler
- Add notable character

## Notable character image rules

- `portraitUrl` for both notable characters and ruler must point to a file under `public/images` using `/images/...` paths.
- The image file must already exist in the repo.
- Notable character entries and the ruler entry use `width` and `height` in JSON to control rendered image size without cropping.

Example entry:

```json
{
  "name": "Example",
  "title": "Speaker",
  "portraitUrl": "/images/notable-characters/example.jpg",
  "portraitAlt": "Example portrait",
  "notes": "Optional notes",
  "width": 480,
  "height": 640
}
```


Images are rendered from the GitHub Pages subpath base: `https://dogukannn.github.io/xolotal` (for `/images/...` assets).
