extends AudioStreamPlayer


func _ready() -> void:
	if stream == null:
		push_error("SFXPlayer needs a stream assigned before it is added to the scene tree.")
		queue_free()
		return

	finished.connect(queue_free)
	play()
