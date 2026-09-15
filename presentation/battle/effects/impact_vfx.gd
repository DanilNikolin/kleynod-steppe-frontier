extends Node2D

var progress: float = 0.0


func _ready() -> void:
	var tween := create_tween()
	tween.tween_property(self, "progress", 1.0, 0.3)
	tween.tween_callback(queue_free)


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var color := Color(1, 0.84, 0.45, 1.0 - progress)
	draw_arc(Vector2.ZERO, 8 + progress * 28, 0, TAU, 32, color, 3.0, true)
	for index in range(6):
		var direction := Vector2.from_angle(TAU * index / 6)
		draw_line(direction * (12 + progress * 12), direction * (22 + progress * 28), color, 2.0, true)
