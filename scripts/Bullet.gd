extends Area2D


var speed:float = 100.0
var direction = Vector2.RIGHT

func _physics_process(delta):
	position += direction * speed * delta

func hit_target():
	var tween = create_tween()
	await tween.tween_property($Sprite2D,"modulate", Color("red"), 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(queue_free)


func _on_screen_exited():
	queue_free()
