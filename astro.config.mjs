import { defineConfig } from 'astro/config';

const repoName = process.env.GITHUB_REPOSITORY?.split('/')[1] ?? '';
const isGitHubActions = process.env.GITHUB_ACTIONS === 'true';

export default defineConfig({
  site: process.env.SITE_URL || 'https://example.com',
  base: isGitHubActions && repoName ? `/${repoName}` : '/',
  output: 'static'
});
