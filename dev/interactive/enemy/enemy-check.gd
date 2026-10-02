extends Control

const ENEMY_SCENE: PackedScene = preload("res://systems/enemies/enemy.tscn")
const PLAYER_BULLET_SCENE: PackedScene = preload("res://systems/projectiles/player_bullet.tscn")

@onready var _enemy_parent: Node = $EnemyParent
var _enemy: Enemy


func _ready() -> void:
	_respawn_enemy()


func _on_hit_enemy_button_pressed() -> void:
	if not is_instance_valid(_enemy):
		return

	var bullet := PLAYER_BULLET_SCENE.instantiate() as PlayerBullet
	if bullet == null:
		return

	_enemy_parent.add_child(bullet)
	bullet.global_position = Vector2(_enemy.global_position.x, _enemy.global_position.y + 280.0)


func _on_respawn_enemy_button_pressed() -> void:
	_respawn_enemy()


func _respawn_enemy() -> void:
	if is_instance_valid(_enemy):
		_enemy.despawn()

	_enemy = ENEMY_SCENE.instantiate() as Enemy
	if _enemy == null:
		return

	_enemy_parent.add_child(_enemy)
	_enemy.position = Vector2(960.0, 440.0)
