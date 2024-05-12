extends Area2D

var speed = 300.0
var velocity = Vector2.ZERO

enum MOVE_STATE {IDLE, FORWARD, BACKWARD}
var current_move_state = MOVE_STATE.IDLE


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.player_died.connect(_on_player_died)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	velocity.x = Input.get_axis("ui_left", "ui_right")
	velocity.y = Input.get_axis("ui_up", "ui_down")
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


func _on_area_entered(area):
	if area.is_in_group("enemy_hitbox"):
		damaged()


func damaged():
	print("player took damage")
	Globals.player_damaged.emit()
	
	

func _on_player_died():
	queue_free()
