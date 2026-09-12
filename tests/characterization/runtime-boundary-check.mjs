#!/usr/bin/env node

import fs from "node:fs";
import http from "node:http";
import os from "node:os";
import path from "node:path";
import { spawn } from "node:child_process";
import { fileURLToPath } from "node:url";

const scriptDirectory = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(scriptDirectory, "../..");
const cliDirectory = path.join(repoRoot, "extensions/cli");
const loaderPath = path.join(scriptDirectory, "runtime-boundary-loader.mjs");
const expectedNodeVersion = `v${fs
  .readFileSync(path.join(repoRoot, ".node-version"), "utf8")
  .trim()}`;
const nodeVersionMatches = process.version === expectedNodeVersion;
const temporaryDirectory = fs.mkdtempSync(
  path.join(os.tmpdir(), "phase0-boundary-"),
);
const loaderReportPath = path.join(temporaryDirectory, "runtime-loader.json");
const configPath = path.join(temporaryDirectory, "config.yaml");
const onboardingPath = path.join(
  temporaryDirectory,
  ".continue",
  ".onboarding_complete",
);

const requests = [];
const server = http.createServer((request, response) => {
  let body = "";
  request.on("data", (chunk) => {
    body += chunk.toString();
  });
  request.on("end", () => {
    requests.push({
      method: request.method,
      url: request.url,
      body: body ? JSON.parse(body) : null,
    });
    response.writeHead(200, {
      "Content-Type": "text/event-stream",
      "Cache-Control": "no-cache",
      Connection: "keep-alive",
    });
    response.write(
      'data: {"choices":[{"delta":{"content":"Hello World!"},"index":0}]}\n\n',
    );
    response.end("data: [DONE]\n\n");
  });
});

await new Promise((resolve, reject) => {
  server.once("error", reject);
  server.listen(0, "127.0.0.1", resolve);
});

const address = server.address();
if (!address || typeof address === "string") {
  throw new Error("Unable to determine the mock server address.");
}

fs.mkdirSync(path.dirname(onboardingPath), { recursive: true });
fs.writeFileSync(onboardingPath, new Date(0).toISOString());
fs.writeFileSync(
  configPath,
  `name: Phase 0 Runtime Boundary
version: 1.0.0
schema: v1
models:
  - name: test-openai
    model: gpt-4
    provider: openai
    apiKey: test-key
    apiBase: http://127.0.0.1:${address.port}
    roles:
      - chat
`,
);

const childResult = await new Promise((resolve) => {
  const child = spawn(
    process.execPath,
    [
      "--no-warnings",
      "--experimental-loader",
      loaderPath,
      "dist/cn.js",
      "-p",
      "--config",
      configPath,
      "Hi",
    ],
    {
      cwd: cliDirectory,
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
  let stdout = "";
  let stderr = "";
  let timedOut = false;
  const timeout = setTimeout(() => {
    timedOut = true;
    child.kill("SIGKILL");
  }, 15_000);

  child.stdout.on("data", (chunk) => {
    stdout += chunk.toString();
  });
  child.stderr.on("data", (chunk) => {
    stderr += chunk.toString();
  });
  child.on("close", (exitCode, signal) => {
    clearTimeout(timeout);
    resolve({ exitCode, signal, stderr, stdout, timedOut });
  });
});

await new Promise((resolve) => server.close(resolve));

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
  nodeVersionMatches &&
  childResult.exitCode === 0 &&
  !childResult.timedOut &&
  childResult.stdout.includes("Hello World!") &&
  requests.length === 1 &&
  loaderReport.status === "pass" &&
  loaderReport.violations.length === 0;

const report = {
  check: "phase0-runtime-boundary",
  status: passed ? "pass" : "fail",
  command: `${process.execPath} --experimental-loader ${loaderPath} dist/cn.js -p --config <temporary-config> Hi`,
  workingDirectory: path.relative(repoRoot, cliDirectory),
  runtime: {
    actualNodeVersion: process.version,
    expectedNodeVersion,
    matchesRepositoryPin: nodeVersionMatches,
  },
  child: {
    exitCode: childResult.exitCode,
    signal: childResult.signal,
    timedOut: childResult.timedOut,
    stdout: childResult.stdout.trim(),
    stderr: childResult.stderr.trim(),
  },
  mockTransport: {
    host: "127.0.0.1",
    requestCount: requests.length,
  },
  moduleResolution: loaderReport,
};

console.log(JSON.stringify(report, null, 2));
fs.rmSync(temporaryDirectory, { recursive: true, force: true });
process.exitCode = passed ? 0 : 1;
