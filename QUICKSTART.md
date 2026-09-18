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

The validated 1.0.0 package is currently a locally staged tarball rather than a
published npm package. From an Open Circuit repository checkout, create it with:

```bash
npm --prefix extensions/cli run release:artifact
npm install --global release-artifacts/v1.0.0/opencircuit-cli-1.0.0.tgz
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

## 3. Download a GitHub Release asset

For a published GitHub Release, download both assets from the `v1.0.0` release:

- `opencircuit-cli-1.0.0.tgz`
- `opencircuit-cli-1.0.0.tgz.sha256`

Verify the checksum from the directory containing the tarball:

```bash
shasum -a 256 -c opencircuit-cli-1.0.0.tgz.sha256
```

Then install it:

```bash
npm install --global ./opencircuit-cli-1.0.0.tgz
```

## 4. See the available commands

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

## 5. Try a first task

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

## 6. Use a configuration file

You can point Open Circuit at a specific configuration:

```bash
oc --config ./config.yaml
```

Open Circuit stores user-owned configuration and session data under the
`.ocircuit` convention. Keep API keys and other secrets in environment
variables or approved secret storage; do not commit them to a repository.

## 7. Run without an interactive terminal

This is useful for scripts and CI:

```bash
oc -p "Summarize the current git diff" --format json
```

You can also pipe input:

```bash
echo "Review the current working tree" | oc -p
```

## 8. Use your own model provider

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
environment variable:

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
		model: claude-3-5-sonnet-20241022
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

## 9. Troubleshooting

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
npm install --global release-artifacts/v1.0.0/opencircuit-cli-1.0.0.tgz
```

### You need to develop Open Circuit

Return to the repository [README](README.md) and use its **Build from source**
section. The source-development path builds Core and the CLI in dependency
order before running the CLI smoke tests.
