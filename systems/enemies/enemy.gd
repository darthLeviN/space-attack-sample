extends Area2D
class_name Enemy

enum EnemyType {
	DEBUG,
	NORMAL,
	ELITE,
}

const SFX_PLAYER_SCENE: PackedScene = preload("res://systems/audio/sfx_player.tscn")
const ENEMY_HIT_SOUND: AudioStream = preload("res://assets/audio/game/player-hit.ogg")
const ENEMY_DESTROYED_SOUND: AudioStream = preload("res://assets/audio/game/enemy-destroyed.ogg")

@export var enemy_type: EnemyType = EnemyType.DEBUG
@export_range(1, 10, 1) var max_hp: int = 3

var hp: int = 3
var _defeated := false


func _ready() -> void:
	add_to_group(&"enemies")
	hp = 3 if enemy_type == EnemyType.DEBUG else max_hp


func take_damage(amount: int = 1) -> void:
	if amount <= 0 or _defeated:
		return

	hp = maxi(0, hp - amount)
	if hp > 0:
		_play_sound(ENEMY_HIT_SOUND)
		return

	_defeated = true
	_play_sound(ENEMY_DESTROYED_SOUND)
	_add_score()
	queue_free()


func despawn() -> void:
	_defeated = true
	queue_free()


func _add_score() -> void:
	var game_state: GameState = Globals.game_state
	if not is_instance_valid(game_state):
		game_state = get_tree().get_first_node_in_group(&"game_state") as GameState
	if is_instance_valid(game_state):
		game_state.score += 1


func _play_sound(sound: AudioStream) -> void:
	var sfx := SFX_PLAYER_SCENE.instantiate() as AudioStreamPlayer
	if sfx == null:
		return

	sfx.stream = sound
	var sfx_parent := get_tree().current_scene
	if sfx_parent == null:
		sfx_parent = get_tree().root
	sfx_parent.add_child(sfx)
