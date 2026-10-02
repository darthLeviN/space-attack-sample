extends Control

var _random := RandomNumberGenerator.new()
@onready var _enemy_root: Node = $EnemyRoot


func _ready() -> void:
	_random.randomize()
	var spawner := $EnemyGridSpawner as EnemyGridSpawner
	spawner.spawn_root = $EnemyRoot
	spawner.spawn_grid(EnemyGridSpawner.Difficulty.NORMAL)


func _on_attack_next_button_pressed() -> void:
	var idle_enemies: Array[Enemy] = []
	for node in _enemy_root.get_children():
		var enemy := node as Enemy
		if is_instance_valid(enemy) and enemy.movement_mode == Enemy.MovementMode.IDLE:
			idle_enemies.append(enemy)

	if idle_enemies.is_empty():
		return

	var random_index := _random.randi_range(0, idle_enemies.size() - 1)
	idle_enemies[random_index].start_attack()
