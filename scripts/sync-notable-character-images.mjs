import { mkdir, readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..');
const dataPath = path.join(repoRoot, 'src/data/notable-characters.json');
const outputDir = path.join(repoRoot, 'public/images/notable-characters');

const isUrl = (value) => {
  try {
    const parsed = new URL(value);
    return parsed.protocol === 'http:' || parsed.protocol === 'https:';
  } catch {
    return false;
  }
};

const slugify = (value) =>
  value
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/(^-|-$)/g, '');

const resizeUrl = (sourceUrl, width, height) => {
  const normalized = sourceUrl.replace(/^https?:\/\//, '');
  const url = new URL('https://images.weserv.nl/');
  url.searchParams.set('url', normalized);
  url.searchParams.set('w', String(width));
  url.searchParams.set('h', String(height));
  url.searchParams.set('fit', 'cover');
  url.searchParams.set('output', 'jpg');
  url.searchParams.set('q', '90');
  return url;
};

const fileExistsOrFail = (entry, sourceUrl) => {
  if (!isUrl(sourceUrl)) {
    throw new Error(`Entry "${entry.name}" has invalid image.sourceUrl. Only HTTP/HTTPS URLs are supported.`);
  }
};

const run = async () => {
  const raw = await readFile(dataPath, 'utf8');
  const entries = JSON.parse(raw);

  await mkdir(outputDir, { recursive: true });

  for (const entry of entries) {
    if (!entry.image) continue;

    const { sourceUrl, width, height } = entry.image;
    if (!sourceUrl || !width || !height) {
      throw new Error(`Entry "${entry.name}" is missing image.sourceUrl, image.width, or image.height.`);
    }

    fileExistsOrFail(entry, sourceUrl);

    const targetName = `${slugify(entry.name)}-${width}x${height}.jpg`;
    const targetPath = path.join(outputDir, targetName);
    const relativePath = `/images/notable-characters/${targetName}`;

    const response = await fetch(resizeUrl(sourceUrl, width, height));
    if (!response.ok) {
      throw new Error(`Could not resize image for "${entry.name}". HTTP ${response.status}`);
    }

    const bytes = Buffer.from(await response.arrayBuffer());
    await writeFile(targetPath, bytes);

    entry.portraitUrl = relativePath;
    if (!entry.portraitAlt) entry.portraitAlt = `${entry.name} portrait`;
  }

  await writeFile(dataPath, `${JSON.stringify(entries, null, 2)}\n`, 'utf8');
  console.log(`Processed ${entries.filter((entry) => entry.image).length} notable character image(s).`);
};

run().catch((error) => {
  console.error(error.message);
  process.exitCode = 1;
});
