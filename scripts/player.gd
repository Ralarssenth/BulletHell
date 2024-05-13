extends Area2D

@export var player_aoe_attack_node: PackedScene
@export var player_bullet_node: PackedScene

const BASE_SPEED = 300.0
var speed = 300.0
var velocity = Vector2.ZERO

enum MOVE_STATE {IDLE, FORWARD, BACKWARD}
var current_move_state = MOVE_STATE.IDLE

var attack_1 = {"target": "boss"}
var attack_2 = {"target": "boss", "size": 200.0, "timer": 0.5, "linger": 0.5}
var attack_3 = {"target": self, "size": 300.0, "timer": 0.5, "linger": 0.5}

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
	if event.is_action_pressed("attack_1"):
		attack_shoot_bullet()
	if event.is_action_pressed("attack_2"):
		attack_aoe_ranged()
	if event.is_action_pressed("attack_3"):
		attack_aoe_self()

# Get the input direction and handle the movement/deceleration.
func move_and_animate(delta):
	velocity.x = Input.get_axis("left", "right")
	velocity.y = Input.get_axis("up", "down")
	
	# set the animation based on x movement
	if velocity.x == 0:
		set_move_state(MOVE_STATE.IDLE)
	elif velocity.x > 0:
		set_move_state(MOVE_STATE.FORWARD)
	elif velocity.x < 0: 
		set_move_state(MOVE_STATE.BACKWARD)
	
	# Normalize the velocity vector so that diagonal movement is not faster
	# and multiply it by the speed
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	
	# move to the new position based on the velocity
	position += velocity * delta


# Checks the current animation and plays a new one if it has changed
func set_move_state(state):
	if state != current_move_state:
		current_move_state = state
		match state:
			MOVE_STATE.IDLE:
				$MovementAnimationPlayer.play("idle")
			MOVE_STATE.FORWARD:
				$MovementAnimationPlayer.play("move_forward")
			MOVE_STATE.BACKWARD:
				$MovementAnimationPlayer.play("move_backward")
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
	print("player area entered")
	if area.is_in_group("enemy_hitbox"):
		damaged()
	if area.is_in_group("enemy_bullet"):
		area.queue_free()


func damaged():
	if $InvulnTimer.is_stopped():
		print("player took damage")
		Globals.player_damaged.emit()
	
		# give the player 1.0s of invuln
		invuln(1.0, "damaged")


func invuln(duration:float, animation:String):
	$InvulnTimer.set_wait_time(duration)
	$InvulnTimer.start()
	$ColorAnimationPlayer.play(animation)


func _on_player_died():
	queue_free()


func spawn_aoe_attack(_position:Vector2, _size:float, _timer:float, _linger:float):
	var aoe_attack = player_aoe_attack_node.instantiate()
	
	aoe_attack.init(_position, _size, _timer, _linger)
	
	get_tree().current_scene.call_deferred("add_child", aoe_attack)

func attack_shoot_bullet():
	var boss = get_tree().get_nodes_in_group(attack_2["target"])
	var target_position = boss[0].get_global_position()
	var start_position:Vector2 = self.get_global_position()
	var angle = start_position.direction_to(target_position)
	
	var bullet = player_bullet_node.instantiate()
	
	bullet.position = position
	bullet.direction = angle
	
	get_tree().current_scene.call_deferred("add_child", bullet)

func attack_aoe_ranged():
	var boss = get_tree().get_nodes_in_group(attack_2["target"])
	var target_position = boss[0].get_global_position()
	
	spawn_aoe_attack(target_position, attack_2["size"], attack_2["timer"], attack_2["linger"])

func attack_aoe_self():
	spawn_aoe_attack(attack_3["target"].position, attack_3["size"], attack_3["timer"], attack_3["linger"])
	
	
