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

Open Circuit CLI 1.0.0 is currently distributed as a GitHub Release asset. It
has not been published to npm yet.

Download both assets from the
[Open Circuit v1.0.0 release](https://github.com/open-circuit-dev/open-circuit/releases/tag/v1.0.0):

- `opencircuit-cli-1.0.0.tgz`
- `opencircuit-cli-1.0.0.tgz.sha256`

Verify the checksum from the directory containing both files:

```bash
shasum -a 256 -c opencircuit-cli-1.0.0.tgz.sha256
```

Expected output:

```text
opencircuit-cli-1.0.0.tgz: OK
```

Install the CLI:

```bash
npm install --global ./opencircuit-cli-1.0.0.tgz
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

## 7. Use your own model provider

The hosted Open Circuit API is currently disabled by default. For local or
direct provider use, set the provider key in the shell that launches `oc`:

```bash
export OPENAI_API_KEY="your-openai-key"
export ANTHROPIC_API_KEY="your-anthropic-key"
export GEMINI_API_KEY="your-gemini-key"
```

Only set the keys you actually use. Do not commit them to a repository or put
them in a shared system profile.

Create a local `config.yaml` that selects one provider and references its
environment variable. For OpenAI:

```yaml
name: Local OpenAI
version: 1.0.0
schema: v1
models:
  - name: OpenAI model
    provider: openai
    model: gpt-4o-mini
    apiKey: ${{ secrets.OPENAI_API_KEY }}
    roles:
      - chat
```

For Anthropic, use:

```yaml
name: Local Anthropic
version: 1.0.0
schema: v1
models:
  - name: Anthropic model
    provider: anthropic
    model: claude-sonnet-4-6
    apiKey: ${{ secrets.ANTHROPIC_API_KEY }}
    roles:
      - chat
```

For Gemini, use:

```yaml
name: Local Gemini
version: 1.0.0
schema: v1
models:
  - name: Gemini model
    provider: gemini
    model: gemini-2.0-flash
    apiKey: ${{ secrets.GEMINI_API_KEY }}
    roles:
      - chat
```

Run with the selected configuration:

```bash
oc --config ./config.yaml
```

For a one-shot request:

```bash
oc --config ./config.yaml -p "Summarize the current directory."
```

The CLI currently auto-detects `ANTHROPIC_API_KEY` during headless onboarding,
but explicit `--config` files are the reliable path for OpenAI, Anthropic, and
Gemini provider selection.

## 8. Maintainer: Stage a Local Release Asset

From an Open Circuit source checkout:

```bash
npm --prefix extensions/cli run release:artifact
```

This creates:

```text
release-artifacts/v1.0.0/opencircuit-cli-1.0.0.tgz
release-artifacts/v1.0.0/opencircuit-cli-1.0.0.tgz.sha256
```

The staging directory is ignored by Git and is not required for normal users.

## 9. Troubleshooting

### `oc: command not found`

The global npm binary directory may not be on your `PATH`. Find it with:

```bash
npm prefix --global
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
npm install --global release-artifacts/v1.0.0/opencircuit-cli-1.0.0.tgz
```

### You need to develop Open Circuit

Return to the repository [README](README.md) and use its **Build from source**
section. The source-development path builds Core and the CLI in dependency
order before running the CLI smoke tests.
