# Open Circuit Quickstart

This guide gets a beginner from zero to a working `oc` command.

## 1. Check Node.js

Open Circuit 1.0.0 expects Node.js `24.19.0`.

```bash
node --version
```

You should see `v24.19.0`. If you use `nvm`, run:

```bash
nvm install 24.19.0
nvm use 24.19.0
```

## 2. Install the CLI

The validated 1.0.0 package is currently a local tarball rather than a
published npm package.

```bash
npm install --global /tmp/open-circuit-release/opencircuit-cli-1.0.0.tgz
```

Check the installation:

```bash
oc --version
```

Expected output:

```text
1.0.0
```

When the package is published, the equivalent registry install will be:

```bash
npm install --global @opencircuit/cli@1.0.0
```

## 3. See the available commands

```bash
oc --help
```

The most useful first commands are:

```bash
oc                       # Start an interactive session
oc -p "Review this code" # Run one prompt and exit
oc ls                    # List saved sessions
oc --resume              # Resume the previous session
```

## 4. Try a first task

Open a terminal in a project directory and run:

```bash
oc
```

Then ask for a concrete task, such as:

```text
Review the current git changes and summarize the three most important risks.
Do not edit files.
```

For a one-shot command:

```bash
oc -p "Explain the structure of this project and suggest where tests live."
```

## 5. Use a configuration file

You can point Open Circuit at a specific configuration:

```bash
oc --config ./config.yaml
```

Open Circuit stores user-owned configuration and session data under the
`.ocircuit` convention. Keep API keys and other secrets in environment
variables or approved secret storage; do not commit them to a repository.

## 6. Run without an interactive terminal

This is useful for scripts and CI:

```bash
oc -p "Summarize the current git diff" --format json
```

You can also pipe input:

```bash
echo "Review the current working tree" | oc -p
```

## 7. Troubleshooting

### `oc: command not found`

The global npm binary directory may not be on your `PATH`. Find it with:

```bash
npm bin -g
```

Add the reported directory to your shell `PATH`, then open a new terminal.

### The version is wrong

Check which executable is being used:

```bash
command -v oc
oc --version
```

Reinstall the package if it points to an older installation:

```bash
npm install --global /tmp/open-circuit-release/opencircuit-cli-1.0.0.tgz
```

### You need to develop Open Circuit

Return to the repository [README](README.md) and use its **Build from source**
section. The source-development path builds Core and the CLI in dependency
order before running the CLI smoke tests.
