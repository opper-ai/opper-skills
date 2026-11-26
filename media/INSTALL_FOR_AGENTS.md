# Install Opper Media, for agents

Steps for an assistant setting up Opper Media for its user. Two parts go in: the connection to the Opper Media tools, and the skills. Do them in order and stop at the first step that fails.

## Step 1: add the connection

Use the server for the host you run in. Signing in happens in the user's browser the first time a tool is called; no API key is involved.

| Host | Server | How |
|---|---|---|
| Claude Code | `https://api.opper.ai/mcp/media` | Install the plugin in step 2: it carries the connection |
| Claude (web, desktop) | `https://api.opper.ai/mcp/media` | The user adds it under Settings, Connectors, Add custom connector. You cannot do this for them |
| Cursor | `https://api.opper.ai/mcp/media` | Add the `opper-media` entry from `media/mcp.json` to `.cursor/mcp.json` |
| ChatGPT and Codex | `https://api.opper.ai/mcp/media-chatgpt` | The package built by `scripts/build-chatgpt-plugin.sh` carries the connection |

## Step 2: install the skills

Claude Code:

```
/plugin marketplace add opper-ai/opper-skills
/plugin install opper-media@opper-ai
```

Any agent that reads Agent Skills (all ten, or one):

```bash
npx skills add opper-ai/opper-skills/media
npx skills add opper-ai/opper-skills/media/product-ad
```

By hand: copy the folders under `media/` that hold a `SKILL.md` into the agent's skills directory.

Someone who only adds the connection still gets the recipes: the server lists them and returns one on request.

## Step 3: check it works

Call `list_media_models`. It answers with the recommended models and makes nothing. If the host asks the user to sign in or approve the connection, tell them to do it and call again.

Then tell the user it is ready and give them one thing to try:

- "Make a 5-second video of a paper boat drifting down a rainy street at night."
- "Turn my product photo into a short vertical ad."
- "Write and voice a 20-second radio ad for a bakery. Let me pick from three voices."

## If something fails

| What you see | What to do |
|---|---|
| The tools are not there | The connection is missing or switched off for this chat: redo step 1, or ask the user to turn it on |
| A sign-in page or an authorization error | The user signs in and approves; then call again |
| A generation is refused because of the account | Tell the user their Opper account needs attention and that the Opper dashboard shows what it needs |
| A model refuses a request | Read the model's `notes` in `list_media_models` and pick another |
