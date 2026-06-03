# chenxiaoyu233/homebrew-tap

Homebrew tap providing the Safari build of [ai-chat-speed-booster](https://github.com/Noah4ever/ai-chat-speed-booster) — a browser extension that keeps long AI chats (ChatGPT, Claude, Gemini, ...) fast by lazy-loading old messages.

The upstream project does not ship a prebuilt Safari `.app`; Safari users have to build it themselves with Xcode. This tap wraps that whole pipeline (Node build → `safari-web-extension-converter` → `xcodebuild`) inside a single `brew install`.

## Install

```bash
brew tap chenxiaoyu233/tap
brew install ai-chat-speed-booster
```

Or as a single command (auto-taps if needed):

```bash
brew install chenxiaoyu233/tap/ai-chat-speed-booster
```

The formula will:

1. Pull the upstream source for the current release tag.
2. Verify Xcode and Node are present (it depends on both at build time).
3. Run `npm ci && npm run safari:setup && xcodebuild` to produce the Safari host app.
4. Register the host app with Launch Services and launch it once (hidden) so Safari discovers the bundled extension.

## One-time Safari setup

The build is unsigned, so Safari hides it until you enable the developer toggle once:

1. `Safari → Settings → Advanced` → tick **Show Develop menu in menu bar**.
2. `Develop → Developer Settings` → tick **Allow unsigned extensions**.
3. `Safari → Settings → Extensions` → tick **AI Chat Speed Booster**.
4. Click the extension's toolbar icon and grant access to the AI chat sites you use.

This toggle persists across reboots; you only do it once per Mac.

## Upgrade

```bash
brew upgrade ai-chat-speed-booster
```

This tap's CI bumps the formula automatically when upstream tags a new release (see `.github/workflows/auto-bump.yml`), so `brew upgrade` picks up new versions without any manual intervention.

## Uninstall

```bash
brew uninstall ai-chat-speed-booster
```

Then restart Safari once so it drops the now-orphaned entry from `Settings → Extensions`.

## Requirements

- macOS
- Full Xcode (not just Command Line Tools) — `safari-web-extension-converter` and `xcodebuild` only ship with Xcode.app
- Node.js 18+ (installed automatically by Homebrew at build time if missing)

## How updates work

A daily GitHub Action runs `brew livecheck` against the upstream releases page. When a new release tag is detected it:

1. Opens a PR updating `url` + `sha256` in the formula.
2. CI builds the formula end-to-end on a `macos-latest` runner.
3. Auto-merges the PR when the build is green.

So `brew update && brew upgrade` is enough to stay current — no manual formula edits required.

## License

MIT — same as upstream.
