# PupilBot plugin for Claude Code, Codex and ChatGPT

One plugin package, `pupilbot/`, serves three places: Claude Code, Codex and the OpenAI plugin directory (ChatGPT and Codex). It connects the student's own AI to their PupilBot account and does two things:

- It adds the PupilBot MCP server (`https://www.pupilbot.com/mcp`). The agent can then read the student's studies, topics, answers, mistakes, due reviews and progress, and create a study from text.
- It adds 3 skills that use those tools.

| Skill | What it does |
|---|---|
| `study-report` | Reads progress, weak spots, due reviews and recent wrong answers. Writes a short report and says what to practice next. |
| `due-today` | Shows the reviews due now and in the next 24 hours, per study. |
| `make-study` | Sends a file or pasted text (plain text or Markdown) to `create_study`. It asks for confirmation first. |

Practice itself stays in the PupilBot web app, the iPhone app and the Telegram bot. The read tools cost PupilBot no LLM money.

The first tool call opens a PupilBot page. The student signs in and approves access (OAuth 2.1 with dynamic client registration). The student can disconnect the app at any time in PupilBot under Settings → Connected AI apps.

## Layout

This folder is a marketplace root for both agents. It is self-contained, so it can be copied to its own public repository.

| Path | Used by |
|---|---|
| `.claude-plugin/marketplace.json` | Claude Code marketplace |
| `.agents/plugins/marketplace.json` | Codex repo marketplace |
| `pupilbot/.claude-plugin/plugin.json` | Claude Code plugin manifest |
| `pupilbot/.mcp.json` | Claude Code MCP config (`type: http`) |
| `pupilbot/plugin.json` | Agent Plugins manifest, with the OpenAI listing and review cases |
| `pupilbot/mcp.json` | Agent Plugins MCP config (`type: streamable-http`) |
| `pupilbot/skills/<name>/` | Shared skills; `agents/openai.yaml` declares the MCP dependency for Codex |
| `pupilbot/assets/` | Logo 512 px, composer icon 128 px |
| `scripts/build-openai-zip.sh` | Builds `dist/pupilbot-openai.zip` for the OpenAI portal |

The marketplace name and the plugin name are both `pupilbot`. The install id is therefore `pupilbot@pupilbot` in both agents.

## Install

The public repository is [gabrielpolyy/pupilbot-plugins](https://github.com/gabrielpolyy/pupilbot-plugins). The package uses the ISC license.

### Claude Code

Run in a terminal:

```bash
claude plugin marketplace add gabrielpolyy/pupilbot-plugins
claude plugin install pupilbot@pupilbot
```

Or, inside a session: `/plugin marketplace add gabrielpolyy/pupilbot-plugins`, then `/plugin install pupilbot@pupilbot`.

Users who have no GitHub SSH key must set `CLAUDE_CODE_PLUGIN_PREFER_HTTPS=1` before they add the marketplace.

The skills run as `/pupilbot:study-report`, `/pupilbot:due-today` and `/pupilbot:make-study`. Claude also picks them when a request matches.

Without the plugin, this command adds only the MCP server:

```bash
claude mcp add --transport http pupilbot https://www.pupilbot.com/mcp
```

### Codex

Run in a terminal:

```bash
codex plugin marketplace add gabrielpolyy/pupilbot-plugins
codex plugin add pupilbot@pupilbot
```

Directory listings require separate approval. A public GitHub repository does not make the plugin appear in a directory.

Without the plugin, these commands add only the MCP server. The second command starts the sign-in:

```bash
codex mcp add pupilbot --url https://www.pupilbot.com/mcp
codex mcp login pupilbot
```

### Test from this checkout

```bash
claude plugin marketplace add ./plugins
claude plugin install pupilbot@pupilbot

codex plugin marketplace add ./plugins
codex plugin add pupilbot@pupilbot
```

To keep your own settings clean, set `CLAUDE_CONFIG_DIR` or `CODEX_HOME` to an empty folder first.

## Validate

```bash
claude plugin validate --strict ./plugins/pupilbot   # plugin, skills, MCP entry
claude plugin validate --strict ./plugins            # marketplace
```

Codex has no validator command. Check `pupilbot/plugin.json` against `https://agent-plugins.org/schemas/1.0.0/plugin.schema.json` and `pupilbot/mcp.json` against `https://agent-plugins.org/schemas/1.0.0/mcp.schema.json`. Then install from the local marketplace and run `codex plugin list` and `codex mcp list`.

## Publish

### 1. Public marketplace repository (do first)

1. Create a public GitHub repository, for example `gabrielpolyy/pupilbot-plugins`.
2. Copy the contents of this folder to the root of that repository. Keep `.claude-plugin/` and `.agents/`.
3. Push. Users can then run the install commands above.
4. For each release, increase `version` in both `pupilbot/.claude-plugin/plugin.json` and `pupilbot/plugin.json`. Users get a new copy only when the version changes.

A private marketplace repository also works, but only for users who have git access to it.

### 2. Claude Connectors Directory and plugin directory

A connector listing needs no files from this folder. Anthropic requires the connector listing for a plugin that references a remote server.

1. Open claude.ai/directory/manage on a paid account. Select **Submit new**, then **MCP connector**.
2. Enter the server URL `https://www.pupilbot.com/mcp`, the privacy URL `https://www.pupilbot.com/privacy`, the docs URL `https://www.pupilbot.com/mcp` and `support@pupilbot.com`.
3. Upload `pupilbot/assets/logo.png`.
4. Give reviewers a test account with practice data.
5. Then submit a **Plugin bundle** from the same page and pick the public repository.

### 3. OpenAI plugin directory (ChatGPT and Codex)

1. Verify your identity at platform.openai.com.
2. Record a demo video of the 5 positive review cases in `pupilbot/plugin.json`. Add its URL as `extensions.com.openai.review.demo_recording_url`.
3. Run `./scripts/build-openai-zip.sh` and upload `dist/pupilbot-openai.zip` at platform.openai.com/plugins.
4. Open **MCPs**, connect the server and resolve the scan findings. The portal can ask for a domain challenge at `/.well-known/openai-apps-challenge`; PupilBot does not serve that path yet.
5. Enter the reviewer test account under **Review details**. It must sign in without MFA or email codes.
6. Submit for review and accept the attestations. Publish after approval.

OpenAI rules to keep in mind: no pricing or upgrade promotion in tool output or links. The `create_study` limit errors mention Premium, so check them against the review rules before you submit.

## One package for both agents

The skills are shared. Their frontmatter has only `name` and `description`, because Codex does not read Claude-only keys such as `allowed-tools`. As a result, Claude Code asks once before each PupilBot tool; the user can allow the read tools for the session.

In Claude Code, the plugin's MCP server is named `plugin:pupilbot:pupilbot`, so its tools are `mcp__plugin_pupilbot_pupilbot__<tool>`.

## Sources

The formats follow these documents (read 2026-10-12):

- Claude Code plugin manifest: https://code.claude.com/docs/en/plugins-reference
- Claude Code marketplaces: https://code.claude.com/docs/en/plugin-marketplaces and https://code.claude.com/docs/en/plugins/host-marketplace
- Claude Code skills frontmatter: https://code.claude.com/docs/en/skills
- Codex and ChatGPT plugin packaging (portable `plugin.json`, `mcp.json`, marketplace file, `codex plugin marketplace add`): https://developers.openai.com/plugins/build/plugins
- Codex skills and `agents/openai.yaml` MCP dependencies: https://developers.openai.com/plugins/build/skills
- Codex listing fields and limits: https://developers.openai.com/plugins/deploy/submission

The Codex `mcp.json` declares no `extensions["com.openai"].auth` block. The Agent Plugins MCP schema does not allow extra keys on a server entry, and the PupilBot server publishes its OAuth metadata for discovery, so the client finds the sign-in on its own.
