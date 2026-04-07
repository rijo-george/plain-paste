# Plain Paste

**Never paste formatting again.**

A tiny macOS menu bar app that forces Cmd+V to always paste as plain text, system-wide. Toggle it on, and every paste strips RTF, HTML, fonts, colors — leaving only clean plain text.

## Download

**[Download for Mac](https://github.com/rijo-george/plain-paste/releases/latest)** — Signed & notarized. Works on Apple Silicon and Intel.

## Features

- **One-toggle simplicity** — Flip the switch in the menu bar. That's it.
- **System-wide** — Works in every app: Mail, Slack, Notion, browsers, everything.
- **Strips RTF & HTML** — Rich text, markup, font styles, colors — all gone.
- **Preserves plain text** — Already plain? Stays exactly as-is.
- **Stats tracking** — See how many times formatting has been stripped (lifetime + session).
- **Launch at login** — Starts silently with your Mac.

## Building from Source

```bash
bash build-app.sh        # Build + sign
bash build-dmg.sh        # Build + sign + notarize DMG
```

Requires Xcode 15+ and macOS 14+.

## License

MIT
