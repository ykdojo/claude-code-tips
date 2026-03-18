#!/usr/bin/env node
/**
 * Generate table of contents for README.md and README_zh.md
 * Extracts all "## Tip N: Title" headers and creates anchor links
 * Automatically updates each file between <!-- TOC --> markers
 */

const fs = require('fs');
const path = require('path');

const TOC_START = '<!-- TOC -->';
const TOC_END = '<!-- /TOC -->';

const readmeFiles = [
  { path: path.join(__dirname, '..', 'README.md'), tocTitle: '## Table of Contents', skipSections: ['Table of Contents'] },
  { path: path.join(__dirname, '..', 'README_zh.md'), tocTitle: '## 目录', skipSections: ['目录'] },
];

function generateAnchor(title) {
  return title
    .toLowerCase()
    .replace(/[^\w\u4e00-\u9fff\s-]/g, '')
    .replace(/\s+/g, '-');
}

function processFile({ path: filePath, tocTitle, skipSections }) {
  if (!fs.existsSync(filePath)) {
    return;
  }

  const fileName = path.basename(filePath);
  const content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split('\n');

  // Match "## Tip N: Title" pattern and other "## Section" headers
  const tipRegex = /^## (Tip \d+: .+)$/;
  const sectionRegex = /^## (.+)$/;
  const tips = [];
  const sections = [];

  for (const line of lines) {
    const tipMatch = line.match(tipRegex);
    if (tipMatch) {
      const title = tipMatch[1];
      tips.push({ title, anchor: generateAnchor(title) });
    } else {
      const sectionMatch = line.match(sectionRegex);
      if (sectionMatch && !skipSections.includes(sectionMatch[1]) && !sectionMatch[1].startsWith('Tip ')) {
        const title = sectionMatch[1];
        sections.push({ title, anchor: generateAnchor(title) });
      }
    }
  }

  if (tips.length === 0) {
    console.error(`No tips found in ${fileName}`);
    return;
  }

  // Build TOC - tips first, then other sections
  let toc = tocTitle + '\n\n';
  for (const tip of tips) {
    toc += `- [${tip.title}](#${tip.anchor})\n`;
  }
  for (const section of sections) {
    toc += `- [${section.title}](#${section.anchor})\n`;
  }

  // Check for markers
  const startIdx = content.indexOf(TOC_START);
  const endIdx = content.indexOf(TOC_END);

  if (startIdx === -1 || endIdx === -1) {
    console.log(`No TOC markers found in ${fileName}. Add these where you want the TOC:`);
    console.log('  <!-- TOC -->');
    console.log('  <!-- /TOC -->');
    console.log('\nGenerated TOC:\n');
    console.log(toc);
    return;
  }

  // Replace content between markers
  const before = content.slice(0, startIdx + TOC_START.length);
  const after = content.slice(endIdx);
  const newContent = before + '\n' + toc + '\n' + after;

  if (newContent === content) {
    console.log(`${fileName}: TOC is up to date (${tips.length} tips)`);
    return;
  }

  fs.writeFileSync(filePath, newContent);
  console.log(`${fileName}: Updated TOC with ${tips.length} tips`);
}

function main() {
  for (const file of readmeFiles) {
    processFile(file);
  }
}

main();
