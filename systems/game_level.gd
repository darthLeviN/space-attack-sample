extends Node2D

const GAME_OVER_SCENE := "res://ui/game_over.tscn"
const PLAYER_DEATH_DELAY := 0.9

@onready var _enemy_root: Node2D = $EnemyFormation
@onready var _spawner: EnemyGridSpawner = $EnemyGridSpawner
@onready var _attack_timer: Timer = $AttackTimer

var _random := RandomNumberGenerator.new()
var _remaining_enemy_count := 0
var _is_ending := false


func _ready() -> void:
	_random.randomize()
	if not is_instance_valid(Globals.game_state):
		Globals.game_state = GameState.new()
		Globals.add_child(Globals.game_state)

	Globals.player_ship_died.connect(_on_player_ship_died)
	var difficulty := clampi(Globals.difficulty, 1, 10)
	_spawner.spawn_root = _enemy_root
	var enemies := _spawner.spawn_grid(_spawner_difficulty(difficulty))
	_remaining_enemy_count = enemies.size()
	for enemy in enemies:
		enemy.tree_exited.connect(_on_enemy_tree_exited)

	_attack_timer.timeout.connect(_on_attack_timer_timeout)
	_attack_timer.start(_next_attack_delay(difficulty))
	if _remaining_enemy_count == 0:
		_finish_game(GameState.EndReason.ENEMIES_CLEARED)


func _on_player_ship_died() -> void:
	_finish_game(GameState.EndReason.PLAYER_DIED, PLAYER_DEATH_DELAY)


func _on_enemy_tree_exited() -> void:
	if _is_ending:
		return
	_remaining_enemy_count = maxi(0, _remaining_enemy_count - 1)
	if _remaining_enemy_count == 0:
		_finish_game(GameState.EndReason.ENEMIES_CLEARED)


func _on_attack_timer_timeout() -> void:
	if _is_ending:
		return

	var idle_enemies: Array[Enemy] = []
	for node in get_tree().get_nodes_in_group(&"enemies"):
		var enemy := node as Enemy
		if is_instance_valid(enemy) and enemy.can_start_attack():
			idle_enemies.append(enemy)
	if not idle_enemies.is_empty():
		idle_enemies[_random.randi_range(0, idle_enemies.size() - 1)].start_attack()

	_attack_timer.start(_next_attack_delay(Globals.difficulty))


func _spawner_difficulty(difficulty: int) -> int:
	if difficulty <= 3:
		return EnemyGridSpawner.Difficulty.EASY
	if difficulty >= 8:
		return EnemyGridSpawner.Difficulty.HARD
	return EnemyGridSpawner.Difficulty.NORMAL


func _next_attack_delay(difficulty: int) -> float:
	var progress := float(clampi(difficulty, 1, 10) - 1) / 9.0
	var shortest_delay := lerpf(8.0, 3.0, progress)
	return _random.randf_range(shortest_delay, shortest_delay + 2.0)


func _finish_game(reason: GameState.EndReason, delay: float = 0.0) -> void:
	if _is_ending:
		return
	_is_ending = true
	_attack_timer.stop()
	if is_instance_valid(Globals.game_state):
		Globals.game_state.end_game(reason)

	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	if is_inside_tree():
		get_tree().call_deferred("change_scene_to_file", GAME_OVER_SCENE)
