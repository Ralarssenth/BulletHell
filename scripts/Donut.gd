extends Node2D

@export var bullet_node: PackedScene

var bullet_density:int = 32
var timer:float = 3.0
var radius = 100

var theta:float = 0.0
var delta:float


# Called when the node enters the scene tree for the first time.
func _ready():
	delta = (2.0 * PI) / bullet_density
	$DelayTimer.set_wait_time(timer)
	$DelayTimer.start()
	var tween = create_tween()
	tween.tween_property($Sprite2D,"modulate:a", 1, timer).set_trans(Tween.TRANS_SINE)


func init(_position=position, _size=radius, _density=bullet_density, _timer=timer):
	position = _position
	bullet_density = _density
	timer = _timer
	radius = _size
	
	# Scales the sprite based on img_size and radius
	var img_size = $Sprite2D.texture.get_size().x / 2 # Set from the size of the texture / 2
	$Sprite2D.scale = Vector2(1, 1) * radius / img_size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func burst():
	for i in range(0, bullet_density):
		shoot(theta)
	queue_free()


func get_vector(angle):
	theta = angle + delta
	return Vector2(cos(theta), sin(theta))


func shoot(angle):
	var bullet = bullet_node.instantiate()
	
	bullet.position = global_position + get_vector(angle) * radius
	bullet.direction = get_vector(angle)
	
	get_tree().root.call_deferred("add_child", bullet)



func _on_delay_timer_timeout():
	burst()
