extends Area2D


var speed:float = 100.0
var direction = Vector2.RIGHT
var damage_amount = 1.0
var color = Color(1.0, 1.0, 1.0, 1.0)

func _ready():
	# set the bullet color
	set_modulate(color)

func _physics_process(delta):
	position += direction * speed * delta

func hit_target():
	var tween = create_tween()
	tween.tween_property($Sprite2D,"modulate", Color("red"), 0.2).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(queue_free)


func _on_screen_exited():
	queue_free()
