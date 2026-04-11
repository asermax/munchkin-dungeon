---
name: wasm-export
description: Build and serve the WebAssembly export. Use when the user asks to export, build, test in browser, or deploy the web version.
---

# WASM Export

## Build

```bash
# Debug export (faster build, larger file)
godot --headless --path /home/agus/workspace/asermax/munchkin-dungeon --export-debug "Web" build/index.html

# Release export (slower build, smaller file, optimized)
godot --headless --path /home/agus/workspace/asermax/munchkin-dungeon --export-release "Web" build/index.html
```

## Serve

```bash
cd /home/agus/workspace/asermax/munchkin-dungeon/build && python3 -m http.server 8000
```

Then open `http://localhost:8000` in a browser.

## Gotchas

- **Dotfiles aren't exported**: Godot skips files starting with `.` in `.pck`. Use `config.env` (not `.env`) for API keys. Add to `export_presets.cfg`: `include_filter="config.env"`.
- **Renderer must be GL Compatibility**: Required for WASM. Set in project.godot: `rendering/renderer/rendering_method="gl_compatibility"`.
- **MIME types**: Server must serve `.wasm` as `application/wasm` and `.pck` as `application/octet-stream`. Python's http.server handles this correctly.
- **Export templates**: Must be installed via Editor → Manage Export Templates before exporting. One-time setup per Godot version.
- **HTTPRequest works from WASM**: Godot's HTTPRequest node makes real HTTP calls from the browser. CORS depends on the target API.
- **API key in client**: The `config.env` file with the z.ai API key gets packed into the WASM build. Acceptable for a demo/event. Rotate the key after.

## Config Files

- `export_presets.cfg` — export preset definition (Web platform)
- `config.env` — API key file (included in export via include_filter)
- `.gitignore` — `build/` and `config.env` excluded from git
