extends Node2D
class_name PlayerShip

const PLAYER_BULLET_SCENE: PackedScene = preload("res://systems/projectiles/player_bullet.tscn")
const SFX_PLAYER_SCENE: PackedScene = preload("res://systems/audio/sfx_player.tscn")
const PLAYER_SHOOT_SOUND: AudioStream = preload("res://assets/audio/game/player-shoot.ogg")
const MOVE_SPEED := 450.0
const MOVEMENT_MIN := Vector2(32.0, 720.0)
const MOVEMENT_MAX := Vector2(1888.0, 1016.0)
const SHOOT_ACTION := &"shoot"
const MOVEMENT_ACTIONS: Array[StringName] = [
	&"move_left",
	&"move_right",
	&"move_up",
	&"move_down",
]

var _held_actions := {
	&"move_left": false,
	&"move_right": false,
	&"move_up": false,
	&"move_down": false,
}

@export_range(0.0, 2000.0, 25.0, "or_greater") var bullet_speed := 900.0
@export_range(1.0, 20.0, 0.5, "or_greater") var shots_per_second := 5.0

var _shoot_held := false
var _shot_cooldown := 0.0

@onready var _sprite: Sprite2D = $Sprite


func _enter_tree() -> void:
	if is_instance_valid(Globals.game_state):
		Globals.game_state.player_ship = self


func _ready() -> void:
	set_process_unhandled_key_input(true)
	global_position = global_position.clamp(MOVEMENT_MIN, MOVEMENT_MAX)


func _unhandled_key_input(event: InputEvent) -> void:
	for action in MOVEMENT_ACTIONS:
		if event.is_action_pressed(action):
			_held_actions[action] = true
		elif event.is_action_released(action):
			_held_actions[action] = false

	if event.is_action_pressed(SHOOT_ACTION) and not _shoot_held:
		_shoot_held = true
		_shot_cooldown = 0.0
	elif event.is_action_released(SHOOT_ACTION):
		_shoot_held = false
		_shot_cooldown = 0.0

	get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	var direction := Vector2(
		float(_held_actions[&"move_right"]) - float(_held_actions[&"move_left"]),
		float(_held_actions[&"move_down"]) - float(_held_actions[&"move_up"]),
	)
	if not direction.is_zero_approx():
		global_position = (
			global_position + direction.normalized() * MOVE_SPEED * delta
		).clamp(MOVEMENT_MIN, MOVEMENT_MAX)

	if not _shoot_held:
		return

	_shot_cooldown -= delta
	if _shot_cooldown > 0.0:
		return

	_fire_bullet()
	_shot_cooldown = 1.0 / maxf(shots_per_second, 0.1)


func _fire_bullet() -> void:
	var bullet := PLAYER_BULLET_SCENE.instantiate() as PlayerBullet
	if bullet == null:
		return

	bullet.speed = bullet_speed
	bullet.top_level = true
	var bullet_parent := get_tree().current_scene
	if bullet_parent == null:
		bullet_parent = get_tree().root
	bullet_parent.add_child(bullet)
	bullet.global_position = _sprite.to_global(Vector2(0.0, -_sprite.texture.get_height() / 2.0))

	var shoot_sfx := SFX_PLAYER_SCENE.instantiate() as AudioStreamPlayer
	shoot_sfx.stream = PLAYER_SHOOT_SOUND
	bullet_parent.add_child(shoot_sfx)
