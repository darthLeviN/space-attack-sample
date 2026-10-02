extends Area2D
class_name EnemyBullet

const DESPAWN_MARGIN := 64.0

@export_range(50.0, 1200.0, 1.0) var speed := 166.6667


func _physics_process(delta: float) -> void:
	global_position.y += speed * delta
	var despawn_rect := get_viewport().get_visible_rect().grow(DESPAWN_MARGIN)
	if not despawn_rect.has_point(global_position):
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group(&"player_hurtbox"):
		var player := area.get_parent()
		if player != null and player.has_method("kill_from_enemy_attack"):
			player.call("kill_from_enemy_attack")
	queue_free()
