extends Area2D
const BASE_SPEED = 300.0
var speed = 300.0
var velocity = Vector2.ZERO

enum MOVE_STATE {IDLE, FORWARD, BACKWARD}
var current_move_state = MOVE_STATE.IDLE


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.player_died.connect(_on_player_died)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_and_animate(delta)
	

func _input(event):
	if event.is_action_pressed("shift"):
		toggle_tight(true)
	if event.is_action_released("shift"):
		toggle_tight(false)


# Get the input direction and handle the movement/deceleration.
func move_and_animate(delta):
	velocity.x = Input.get_axis("left", "right")
	velocity.y = Input.get_axis("up", "down")
	if velocity.x == 0:
		set_move_state(MOVE_STATE.IDLE)
	elif velocity.x > 0:
		set_move_state(MOVE_STATE.FORWARD)
	elif velocity.x < 0: 
		set_move_state(MOVE_STATE.BACKWARD)
	
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	
	position += velocity * delta


# Checks the current animation and plays a new one if it has changed
func set_move_state(state):
	if state != current_move_state:
		current_move_state = state
		match state:
			MOVE_STATE.IDLE:
				$AnimationPlayer.play("idle")
			MOVE_STATE.FORWARD:
				$AnimationPlayer.play("move_forward")
			MOVE_STATE.BACKWARD:
				$AnimationPlayer.play("move_backward")
			_:
				print("set_move_state defaulted")


func toggle_tight(on):
		$CollisionShape2D/Normal.set_visible(not on)
		$CollisionShape2D/Tight.set_visible(on)
		if on:
			speed = BASE_SPEED / 2
		else:
			speed = BASE_SPEED



func _on_area_entered(area):
	if area.is_in_group("enemy_hitbox"):
		damaged()
	if area.is_in_group("bullet"):
		area.queue_free()


func damaged():
	print("player took damage")
	Globals.player_damaged.emit()
	
	# give the player 1s of invuln
	$CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(1.0).timeout
	$CollisionShape2D.set_deferred("disabled", false)
	

func _on_player_died():
	queue_free()

