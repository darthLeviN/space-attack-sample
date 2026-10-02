extends Control

const VISUAL_ASSETS := [
	{"name": "Player ship", "path": "res://assets/sprites/player/player-ship.png", "size": Vector2(120, 120)},
	{"name": "Enemy scout", "path": "res://assets/sprites/enemies/enemy-scout.png", "size": Vector2(120, 120)},
	{"name": "Enemy cruiser", "path": "res://assets/sprites/enemies/enemy-cruiser.png", "size": Vector2(120, 120)},
	{"name": "Player shot", "path": "res://assets/sprites/projectiles/player-shot.png", "size": Vector2(120, 120)},
	{"name": "Enemy shot", "path": "res://assets/sprites/projectiles/enemy-shot.png", "size": Vector2(120, 120)},
	{"name": "Space far stars", "path": "res://assets/backgrounds/space-far-stars.png", "size": Vector2(120, 120)},
	{"name": "Space near stars", "path": "res://assets/backgrounds/space-near-stars.png", "size": Vector2(120, 120)},
]

const AUDIO_ASSETS := [
	{"name": "Button click", "path": "res://assets/audio/ui/button-click.ogg", "note": "UI hover or press"},
	{"name": "Button confirm", "path": "res://assets/audio/ui/button-confirm.ogg", "note": "UI confirmation"},
	{"name": "Player shoot", "path": "res://assets/audio/game/player-shoot.ogg", "note": "Player laser"},
	{"name": "Enemy shoot", "path": "res://assets/audio/game/enemy-shoot.ogg", "note": "Enemy laser"},
	{"name": "Player hit", "path": "res://assets/audio/game/player-hit.ogg", "note": "Player takes damage"},
	{"name": "Enemy destroyed", "path": "res://assets/audio/game/enemy-destroyed.ogg", "note": "Enemy hit / explosion"},
]

var audio_player: AudioStreamPlayer


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_build_page()


func _build_page() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = Color("#07111f")
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 28)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_right", 28)
	margin.add_theme_constant_override("margin_bottom", 22)
	add_child(margin)

	var page := VBoxContainer.new()
	page.add_theme_constant_override("separation", 14)
	margin.add_child(page)

	var title := Label.new()
	title.text = "SPACE ATTACK  /  ASSET CHECK"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("#e7f3ff"))
	page.add_child(title)

	var intro := Label.new()
	intro.text = "CC0 pixel-art sprites, two starfield layers, and sound previews. Scroll to browse."
	intro.add_theme_color_override("font_color", Color("#9fb7d1"))
	page.add_child(intro)

	var scroll := ScrollContainer.new()
	scroll.name = "AssetScroll"
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	page.add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 18)
	scroll.add_child(content)

	_add_visual_section(content)
	_add_audio_section(content)

	audio_player = AudioStreamPlayer.new()
	audio_player.name = "PreviewPlayer"
	add_child(audio_player)


func _add_visual_section(parent: VBoxContainer) -> void:
	_add_section_title(parent, "VISUAL ASSETS")
	var grid := GridContainer.new()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	parent.add_child(grid)

	for asset in VISUAL_ASSETS:
		grid.add_child(_make_visual_card(asset))


func _add_audio_section(parent: VBoxContainer) -> void:
	_add_section_title(parent, "SOUND EFFECTS  /  CLICK TO PREVIEW")
	var grid := GridContainer.new()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	parent.add_child(grid)

	for asset in AUDIO_ASSETS:
		grid.add_child(_make_audio_card(asset))


func _add_section_title(parent: VBoxContainer, text: String) -> void:
	var heading := Label.new()
	heading.text = text
	heading.add_theme_font_size_override("font_size", 17)
	heading.add_theme_color_override("font_color", Color("#75d8ff"))
	parent.add_child(heading)
	parent.add_child(HSeparator.new())


func _make_visual_card(asset: Dictionary) -> PanelContainer:
	var card := _make_card(Vector2(250, 188))
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	card.add_child(stack)

	var name := Label.new()
	name.text = asset.name
	name.add_theme_font_size_override("font_size", 16)
	name.add_theme_color_override("font_color", Color("#e7f3ff"))
	stack.add_child(name)

	var preview_area := CenterContainer.new()
	preview_area.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_area.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.add_child(preview_area)

	var preview := TextureRect.new()
	preview.texture = load(asset.path)
	preview.custom_minimum_size = asset.size
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	preview_area.add_child(preview)

	var path := Label.new()
	path.text = asset.path.trim_prefix("res://")
	path.add_theme_font_size_override("font_size", 10)
	path.add_theme_color_override("font_color", Color("#8aa3bf"))
	stack.add_child(path)
	return card


func _make_audio_card(asset: Dictionary) -> PanelContainer:
	var card := _make_card(Vector2(250, 120))
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 8)
	card.add_child(stack)

	var name := Label.new()
	name.text = asset.name
	name.add_theme_font_size_override("font_size", 16)
	name.add_theme_color_override("font_color", Color("#e7f3ff"))
	stack.add_child(name)

	var note := Label.new()
	note.text = asset.note
	note.add_theme_color_override("font_color", Color("#9fb7d1"))
	stack.add_child(note)

	var button := Button.new()
	button.text = "PLAY"
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(_play_audio.bind(asset.path))
	stack.add_child(button)
	return card


func _make_card(minimum_size: Vector2) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = minimum_size
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#101f32")
	style.border_color = Color("#294461")
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 12.0
	style.content_margin_top = 12.0
	style.content_margin_right = 12.0
	style.content_margin_bottom = 12.0
	card.add_theme_stylebox_override("panel", style)
	return card


func _play_audio(path: String) -> void:
	var stream := load(path) as AudioStream
	if stream == null:
		return
	audio_player.stop()
	audio_player.stream = stream
	audio_player.play()
