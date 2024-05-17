extends Area2D

@export var player_aoe_attack_node: PackedScene
@export var player_bullet_node: PackedScene

const BASE_SPEED = 300.0
var current_speed = 300.0
var speed = 300.0
var velocity = Vector2.ZERO

enum MOVE_STATE {IDLE, FORWARD, BACKWARD}
var current_move_state = MOVE_STATE.IDLE

var bosses = []
var current_boss_index:int = 0
var current_target = self
signal changed_target(_target)

var attack_1 = {"speed": 200.0, "GCD": 1.5, "damage": 5.0}
var attack_2 = {"size": 200.0, "timer": 0.5, "linger": 0.5, "GCD": 1.5, "damage": 3.0}
var attack_3 = {"size": 300.0, "timer": 0.5, "linger": 0.5, "GCD": 1.5, "damage": 2.0}
var defensive_stats = {"duration": 2.0, "speed_multiplier": 2.0, "cooldown": 10.0}

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.player_died.connect(_on_player_died)
	
	#set the initial target
	bosses = get_tree().get_nodes_in_group("boss")
	if bosses.is_empty():
		current_target = self
	else:
		current_target = bosses[current_boss_index]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	move_and_animate(delta)
	

func _input(event):
	if event.is_action_pressed("shift"):
		toggle_tight(true)
	if event.is_action_released("shift"):
		toggle_tight(false)
		iterate_target()
	if event.is_action_pressed("attack_1"):
		attack1_shoot_bullet()
	if event.is_action_pressed("attack_2"):
		attack2_aoe_ranged()
	if event.is_action_pressed("attack_3"):
		attack3_aoe_self()
	if event.is_action_pressed("defensive"):
		defensive()


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
			speed = current_speed / 2
		else:
			speed = current_speed


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
	if $InvulnTimer.is_stopped():
		$InvulnTimer.set_wait_time(duration)
		$InvulnTimer.start()
		$ColorAnimationPlayer.play(animation)


func _on_player_died():
	queue_free()


#Checks for new bosses and updates the target
func update_target():
	bosses = get_tree().get_nodes_in_group("boss")
	if current_target == self:
		if bosses.is_empty():
			current_target = self
		else:
			current_boss_index = 0
			current_target = bosses[current_boss_index]
	else:
		if bosses.is_empty():
			current_target = self
		else:
			current_target = bosses[current_boss_index]
	emit_signal("changed_target", current_target)


# iterates through multiple targets, if any
func iterate_target():
	bosses = get_tree().get_nodes_in_group("boss")
	if not bosses.is_empty():
		current_boss_index += 1
		if current_boss_index > (bosses.size()  - 1): #wrap back to 0
			current_boss_index = 0
		current_target = bosses[current_boss_index]
		emit_signal("changed_target", current_target)


# Gets the array of bosses and assigns target to the first entry. 
func get_target_position():
	var target_position
	if current_target: #check that target is still valid
		target_position = current_target.get_global_position()
	else:
		update_target()
		target_position = current_target.get_global_position()
	return target_position

# Helper function for spawning circle attacks
func spawn_aoe_attack(_position:Vector2, _size:float, _timer:float, _linger:float, _damage:float):
	var player_aoe_attack = player_aoe_attack_node.instantiate()
	
	player_aoe_attack.init(_position, _size, _timer, _linger, _damage)
	
	get_tree().current_scene.call_deferred("add_child", player_aoe_attack)


# An attack that shoots a bullet at the target's position
func attack1_shoot_bullet():
	if $GCDTimer.is_stopped():
		var target_position = get_target_position()
		if current_target == self:
			target_position += Vector2(100.0, 0.0)
		var start_position:Vector2 = self.get_global_position()
		var angle = start_position.direction_to(target_position)
		
		var player_bullet = player_bullet_node.instantiate()
		
		player_bullet.position = position
		player_bullet.direction = angle
		player_bullet.speed = attack_1["speed"]
		player_bullet.damage_amount = attack_1["damage"]
		
		get_tree().current_scene.call_deferred("add_child", player_bullet)
		
		$GCDTimer.set_wait_time(attack_1["GCD"])
		$GCDTimer.start()


# A circle attack that spawns on the target's position from range
func attack2_aoe_ranged():
	if $GCDTimer.is_stopped():
		var target_position = get_target_position()
		
		spawn_aoe_attack(
			target_position, 
			attack_2["size"], 
			attack_2["timer"], 
			attack_2["linger"], 
			attack_2["damage"]
		)
		
		$GCDTimer.set_wait_time(attack_2["GCD"])
		$GCDTimer.start()

# A circle attack that spawns on the player's position
func attack3_aoe_self():
	if $GCDTimer.is_stopped():
		var target_position = self.get_global_position()
		
		spawn_aoe_attack(
			target_position, 
			attack_3["size"], 
			attack_3["timer"], 
			attack_3["linger"], 
			attack_3["damage"]
		)
		
		$GCDTimer.set_wait_time(attack_3["GCD"])
		$GCDTimer.start()
	
func defensive():
	if $DefensiveCDTimer.is_stopped():
		speed = BASE_SPEED * defensive_stats["speed_multiplier"]
		current_speed = speed
		$DefensiveCDTimer.set_wait_time(defensive_stats["cooldown"])
		$DefensiveCDTimer.start()
		invuln(defensive_stats["duration"], "defensive")


func _on_invuln_timer_timeout():
	$ColorAnimationPlayer.stop()
	speed = BASE_SPEED
	current_speed = BASE_SPEED
	
