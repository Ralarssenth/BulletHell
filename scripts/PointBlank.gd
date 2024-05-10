extends Area2D

var size:float = 1.0
var timer:float = 1.0

func _ready():
	$Timer.set_wait_time(timer)
	print("pointBlank ready")

func _on_timer_timeout():
	print("pointBlank deleted")
	queue_free()
