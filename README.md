# Dune Imperium Campaign Site

Static website template for tracking your Imperium TTRPG campaign, ready for GitHub Pages deployment.

## Included sections

- Imperium events timeline
- House assets
- Senate/Landsraad standings
- Important figures
- Published votings
- Daily rotating religious saying/litany

## Local preview

```bash
python3 -m http.server 8000
```

Open `http://localhost:8000` in your browser.

## Deploy on GitHub Pages

1. Push this repository to GitHub.
2. Go to **Settings → Pages**.
3. Under **Build and deployment**, set:
   - **Source:** `Deploy from a branch`
   - **Branch:** `main` (or your preferred branch), `/root`
4. Save and wait for GitHub to publish.

Your site will be hosted at:

`https://<your-username>.github.io/<repository-name>/`

## Updating campaign data

Edit `index.html` for events, assets, standings, figures, and votes. The daily litany is controlled in `script.js` via the `sayings` array.
