extends Area2D

var theta:float = 0.0 
var timer:float = 0.5
var linger:float = 3.0


# Called when the node enters the scene tree for the first time.
func _ready():
	burst()

func init(_position=position, _angle=theta, _timer=timer, _linger=linger):
	position = _position
	theta = _angle
	timer = _timer
	linger = _linger
	
	# Set the initial angle of the attack
	set_rotation(theta)
	
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

