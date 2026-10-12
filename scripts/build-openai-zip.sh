#!/usr/bin/env bash
# Build the ZIP for the OpenAI plugin directory (ChatGPT + Codex).
# The ZIP holds the portable package only: plugin.json, mcp.json, skills/, assets/.
# The Claude Code files (.claude-plugin/, .mcp.json) stay out of it.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
out="$root/dist/pupilbot-openai.zip"
mkdir -p "$root/dist"
rm -f "$out"
cd "$root/pupilbot"
zip -qr "$out" plugin.json mcp.json skills assets -x '*.DS_Store'
echo "$out"
unzip -l "$out"
