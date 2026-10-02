extends Control


func _ready() -> void:
	var spawner := $EnemyGridSpawner as EnemyGridSpawner
	spawner.spawn_root = $EnemyRoot
	spawner.spawn_grid(EnemyGridSpawner.Difficulty.NORMAL)
