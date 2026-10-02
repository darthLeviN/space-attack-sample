## Project layout

- `dev/interactive/` is for previews and test harnesses that instance systems. Put reusable game implementations in `systems/` or `ui/`.

## Environment limitation (2026-10-02)

- Godot visual preview is unavailable in this environment: X11 `:0` and Wayland are unavailable, and headless movie capture crashes Godot 4.7.2's dummy renderer in `texture_2d_get` (SIGSEGV). A headless editor scan also reports a socket-listen failure and cannot save `/home/levi/.config/godot/editor_settings-4.7.tres`; these are environment issues, not project errors.

## Parallax background tuning (2026-10-03)

- The user first found 256px repeated star tiles too dense, then found the 512px version too large and asked to double the tiling. Current preference: 4× scale on 64px star textures (256px tile spacing).
- Keep the parallax implementation under `systems/background/`; `dev/interactive/parallax-background/` only instances it and provides preview controls.
