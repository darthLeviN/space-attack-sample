extends Node2D
class_name PlayerShip

const PLAYER_BULLET_SCENE: PackedScene = preload("res://systems/projectiles/player_bullet.tscn")
const SFX_PLAYER_SCENE: PackedScene = preload("res://systems/audio/sfx_player.tscn")
const PLAYER_EXPLOSION_SCENE: PackedScene = preload("res://systems/effects/player_ship_explosion.tscn")
const PLAYER_SHOOT_SOUND: AudioStream = preload("res://assets/audio/game/player-shoot.ogg")
const PLAYER_HIT_SOUND: AudioStream = preload("res://assets/audio/game/player-hit.ogg")
const PLAYER_DEATH_SOUND: AudioStream = preload("res://assets/audio/game/enemy-destroyed.ogg")
const MOVE_SPEED := 450.0
const MOVEMENT_MIN := Vector2(32.0, 720.0)
const MOVEMENT_MAX := Vector2(1888.0, 1016.0)
const DEATH_EFFECT_DURATION := 0.75
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
var hp: int = 100

var _shoot_held := false
var _shot_cooldown := 0.0
var _is_dead := false

@onready var _sprite: Sprite2D = $Sprite


func _enter_tree() -> void:
	if is_instance_valid(Globals.game_state):
		Globals.game_state.player_ship = self


static func damage_ship(amount: int) -> void:
	if amount <= 0:
		return
	var scene_tree := Engine.get_main_loop() as SceneTree
	if scene_tree == null:
		return
	var player_ship := scene_tree.get_first_node_in_group(&"player_ship") as PlayerShip
	if player_ship == null:
		return
	var new_hp := maxi(0, player_ship.hp - amount)
	if new_hp == player_ship.hp:
		return
	player_ship.hp = new_hp
	if new_hp == 0:
		player_ship._die()
	else:
		player_ship._play_sfx(PLAYER_HIT_SOUND)


func _ready() -> void:
	set_process_unhandled_key_input(true)
	global_position = global_position.clamp(MOVEMENT_MIN, MOVEMENT_MAX)


func _exit_tree() -> void:
	if is_instance_valid(Globals.game_state) and Globals.game_state.player_ship == self:
		Globals.game_state.player_ship = null


func _unhandled_key_input(event: InputEvent) -> void:
	if _is_dead:
		return

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
	if _is_dead:
		return

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

	_play_sfx(PLAYER_SHOOT_SOUND)


func _die() -> void:
	if _is_dead:
		return

	_is_dead = true
	for action in _held_actions:
		_held_actions[action] = false
	_shoot_held = false
	set_process(false)
	set_process_unhandled_key_input(false)
	remove_from_group(&"player_ship")
	if is_instance_valid(Globals.game_state) and Globals.game_state.player_ship == self:
		Globals.game_state.player_ship = null
	if is_instance_valid(_sprite):
		_sprite.hide()

	var explosion := PLAYER_EXPLOSION_SCENE.instantiate() as Node2D
	if explosion != null:
		var effect_parent := _get_effect_parent()
		effect_parent.add_child(explosion)
		explosion.global_position = global_position

	_play_sfx(PLAYER_DEATH_SOUND)
	Globals.player_ship_died.emit()
	get_tree().create_timer(DEATH_EFFECT_DURATION).timeout.connect(queue_free)


func _play_sfx(stream: AudioStream) -> void:
	var sfx_player := SFX_PLAYER_SCENE.instantiate() as AudioStreamPlayer
	sfx_player.stream = stream
	var sfx_parent := _get_effect_parent()
	sfx_parent.add_child(sfx_player)


func _get_effect_parent() -> Node:
	var effect_parent: Node = get_tree().current_scene
	if effect_parent == null or effect_parent == self or is_ancestor_of(effect_parent):
		return get_tree().root
	return effect_parent
