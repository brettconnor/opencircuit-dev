#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";

const packagePath = path.resolve(process.cwd(), "package.json");
const lockPath = path.resolve(process.cwd(), "package-lock.json");
const packageJson = JSON.parse(fs.readFileSync(packagePath, "utf8"));
const lockJson = JSON.parse(fs.readFileSync(lockPath, "utf8"));
const errors = [];
const dependencySections = [
  "dependencies",
  "devDependencies",
  "optionalDependencies",
  "peerDependencies",
];
const exactScriptKey =
  /^(?:[^@/]+|@[^/]+\/[^@]+)@\d+\.\d+\.\d+(?:[-+][0-9A-Za-z.-]+)?$/;

for (const section of dependencySections) {
  for (const dependencyName of Object.keys(packageJson[section] ?? {})) {
    if (dependencyName.startsWith("@continuedev/")) {
      errors.push(
        `${section} contains pre-rename package ${dependencyName}; use @opencircuit/*`,
      );
    }
  }
}

for (const [packageName, allowed] of Object.entries(
  packageJson.allowScripts ?? {},
)) {
  if (allowed !== true || !exactScriptKey.test(packageName)) {
    errors.push(
      `allowScripts entry ${packageName} must be true and exact version-pinned`,
    );
  }
}

if (packageJson.name === "@opencircuit/core") {
  const override = packageJson.overrides?.["@tootallnate/once"];
  const lockEntry =
    lockJson.packages?.["node_modules/@tootallnate/once"]?.version;
  if (override !== "2.0.1") {
    errors.push(
      `Core @tootallnate/once override must remain exact 2.0.1; found ${override ?? "missing"}`,
    );
  }
  if (lockEntry !== "2.0.1") {
    errors.push(
      `Core lockfile must resolve @tootallnate/once to 2.0.1; found ${lockEntry ?? "missing"}`,
    );
  }
  console.log(
    "Temporary upstream-chain workaround monitored: @tootallnate/once 2.0.1.",
  );
}

if (errors.length > 0) {
  console.error("Dependency policy check failed:");
  for (const error of errors) console.error(`- ${error}`);
  process.exitCode = 1;
} else {
  console.log(`Dependency policy passed for ${packageJson.name}.`);
}
