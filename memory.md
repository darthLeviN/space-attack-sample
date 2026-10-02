## Project layout

- `dev/interactive/` is for previews and test harnesses that instance systems. Put reusable game implementations in `systems/` or `ui/`.

## Environment limitation (2026-10-02)

- Godot visual preview is unavailable in this environment: X11 `:0` and Wayland are unavailable, and headless movie capture crashes Godot 4.7.2's dummy renderer in `texture_2d_get` (SIGSEGV). A headless editor scan also reports a socket-listen failure and cannot save `/home/levi/.config/godot/editor_settings-4.7.tres`; these are environment issues, not project errors.

## Parallax background tuning (2026-10-03)

- The user found the 256px repeated star tile too dense. Keep the existing 64px star textures at 8× scale (512px tile spacing) unless asked to retune density.
- Keep the parallax implementation under `systems/background/`; `dev/interactive/parallax-background/` only instances it and provides preview controls.
