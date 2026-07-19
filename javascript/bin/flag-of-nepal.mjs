#!/usr/bin/env node

// Author: Ashok Kumar Pant <asokpant@gmail.com>
// Date: July 19, 2026

import fs from "fs";
import path from "path";
import { construct, toSVG, toHTML, MODES } from "../src/npflag.mjs";

const base = process.argv[2] !== undefined ? parseFloat(process.argv[2]) : 800;
if (Number.isNaN(base)) {
  console.error("invalid base length");
  process.exit(1);
}
const outDir = process.argv[3] ?? "output";

fs.mkdirSync(outDir, { recursive: true });
const g = construct(base);

for (const mode of MODES) {
  const filePath = path.join(outDir, `np_flag_${mode}.svg`);
  fs.writeFileSync(filePath, toSVG(g, mode), { mode: 0o644 });
  console.log(filePath);
}
const htmlPath = path.join(outDir, "np_flag.html");
fs.writeFileSync(htmlPath, toHTML(g), { mode: 0o644 });
console.log(htmlPath);
