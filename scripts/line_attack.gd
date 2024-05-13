extends Area2D

var theta:float = 0.0 
var timer:float = 0.5
var linger:float = 3.0
var type:String = "spin"
var spin_counter:int = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	init()

func init(_position=position, _angle=theta, _timer=timer, _linger=linger, _type=type, _counter=spin_counter):
	position = _position
	theta = _angle
	timer = _timer
	linger = _linger
	type = _type
	spin_counter = _counter
	
	# Set the unique collision shape
	$CollisionShape2D.shape = $CollisionShape2D.shape.duplicate() # Make this shape unique
	# Set the rotation of the line's collision shape and sprite together
	$CollisionShape2D.set_rotation(theta)
	$Sprite2D.set_rotation(theta)
	#call the function to execute the type of line attack 
	call_deferred(type)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func burst():
	var tween = create_tween()
	tween.tween_property($Sprite2D,"modulate:a", 1, timer).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(enable_collision_shape)

func enable_collision_shape():
	$CollisionShape2D.set_deferred("disabled", false)
	$LingeringTimer.set_wait_time(linger)
	$LingeringTimer.start()

func _on_lingering_timer_timeout():
	queue_free()

func spin():
	var tween = create_tween()
	await tween.tween_property($Sprite2D,"modulate:a", 1, timer).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(enable_collision_shape)
	tween.tween_property(self,"rotation", PI * spin_counter, linger).set_trans(Tween.TRANS_LINEAR)


