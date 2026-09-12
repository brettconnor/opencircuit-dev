#!/usr/bin/env node

import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDirectory, "../..");
const cliDirectory = path.join(repoRoot, "extensions/cli");
const loaderPath = path.join(scriptDirectory, "runtime-boundary-loader.mjs");
const temporaryDirectory = fs.mkdtempSync(
  path.join(os.tmpdir(), "phase0-boundary-"),
);
const loaderReportPath = path.join(temporaryDirectory, "runtime-loader.json");

const child = spawnSync(
  process.execPath,
  [
    "--no-warnings",
    "--experimental-loader",
    loaderPath,
    "dist/cn.js",
    "--version",
  ],
  {
    cwd: cliDirectory,
    encoding: "utf8",
    env: {
      ...process.env,
      CONTINUE_CLI_TEST: "true",
      FORCE_NO_TTY: "true",
      HOME: temporaryDirectory,
      USERPROFILE: temporaryDirectory,
      PHASE0_RUNTIME_BOUNDARY_REPORT: loaderReportPath,
    },
  },
);

let loaderReport = {
  check: "phase0-runtime-module-resolution",
  status: "fail",
  violations: [],
  error: "Runtime loader did not produce a report.",
};
if (fs.existsSync(loaderReportPath)) {
  loaderReport = JSON.parse(fs.readFileSync(loaderReportPath, "utf8"));
}

const passed =
  child.status === 0 &&
  loaderReport.status === "pass" &&
  loaderReport.violations.length === 0;

const report = {
  check: "phase0-runtime-boundary",
  status: passed ? "pass" : "fail",
  command: `${process.execPath} --experimental-loader ${loaderPath} dist/cn.js --version`,
  workingDirectory: path.relative(repoRoot, cliDirectory),
  child: {
    exitCode: child.status,
    signal: child.signal,
    stdout: child.stdout.trim(),
    stderr: child.stderr.trim(),
  },
  moduleResolution: loaderReport,
};

console.log(JSON.stringify(report, null, 2));
fs.rmSync(temporaryDirectory, { recursive: true, force: true });
process.exitCode = passed ? 0 : 1;
