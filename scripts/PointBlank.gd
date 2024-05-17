extends Area2D

var radius = 100
var timer:float = 3.0
var linger:float = 0.5
var damage_amount = 1.0

func _ready():
	burst()
	#print("pointBlank ready")
	


func init(_position, _radius=radius, _timer=timer, _linger=linger, _damage = damage_amount):
	position = _position
	radius = _radius
	timer = _timer
	linger = _linger
	damage_amount = _damage
	
	# Set the unique collision shape
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate() # Make this shape unique
	$CollisionShape2D.shape.radius = radius # Set the size of the collision shape based on radius
	
	# Scales the sprite based on img_size and radius
	var img_size = $Sprite2D.texture.get_size().x / 2 # Set from the size of the texture / 2
	$Sprite2D.scale = Vector2(1, 1) * radius / img_size
	

func burst():
	var tween = create_tween()
	tween.tween_property($Sprite2D,"modulate:a", 0.5, timer).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(_on_burst_finished)

func _on_burst_finished():
	$CollisionShape2D.set_deferred("disabled", false)
	$LingeringTimer.set_wait_time(linger)
	$LingeringTimer.start()


func _on_lingering_timer_timeout():
	queue_free()
