extends Area2D
class_name PlayerBullet

const DESPAWN_MARGIN := 64.0

@export_range(0.0, 2000.0, 25.0, "or_greater") var speed := 900.0


func _ready() -> void:
	set_physics_process(true)


func _physics_process(delta: float) -> void:
	global_position.y -= speed * delta
	var despawn_rect := get_viewport().get_visible_rect().grow(DESPAWN_MARGIN)
	if not despawn_rect.has_point(global_position):
		queue_free()


func _on_area_entered(area: Area2D) -> void:
	var enemy := area as Enemy
	if enemy != null:
		enemy.take_damage(1)
	queue_free()


func _on_body_entered(_body: Node2D) -> void:
	queue_free()
