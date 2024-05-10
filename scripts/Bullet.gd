extends Area2D


var speed = 100
var direction = Vector2.RIGHT

func _physics_process(delta):
	position += direction * speed * delta



func _on_screen_exited():
	queue_free()
