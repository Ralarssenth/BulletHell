extends Area2D

# multiplayer id 
# Set by the authority, synchronized on spawn.
@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)
var player_array_id : int

# The player's sprite options, 
# by "color" as listed in the match/case in the change color function
var head_sprites = {
	"default": load("res://assets/player/head.png"), 
	"red": load("res://assets/player/head_red.png")
}

# the player's attack node locations
@export var player_aoe_attack_node: PackedScene
@export var player_bullet_node: PackedScene

# Player movement
@onready var input = $PlayerInput
const BASE_SPEED = 300.0
var current_speed = 300.0
var speed = 300.0
var velocity = Vector2.ZERO

#Player states
enum MOVE_STATE {IDLE, FORWARD, BACKWARD}
var current_move_state = MOVE_STATE.IDLE
@export var can_attack = false
@export var can_move = false

# Targeting
var current_target = self


# Attack stats
var attack_1 = {"speed": 500.0, "GCD": 1.5, "damage": 15.0}
var attack_2 = {"size": 200.0, "timer": 0.5, "linger": 0.5, "GCD": 1.5, "damage": 3.0}
var attack_3 = {"size": 300.0, "timer": 0.5, "linger": 0.5, "GCD": 1.5, "damage": 10.0}
var defensive_stats = {"duration": 2.0, "speed_multiplier": 2.0, "cooldown": 10.0}

# Attack cd tweens
var attack1_tween
var attack2_tween
var attack3_tween
var defensive_tween
var tweens = [attack1_tween, attack2_tween, attack3_tween, defensive_tween]

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.player_died.connect(_on_player_died)
	Globals.toggle_player_inputs.connect(_toggle_player_inputs)
	Globals.set_player_color.connect(_change_color)
	
	# Add the client's unique multiplayer id to the peers list
	Globals.peers.append(player)
	
	#logging the id setups
	print("player array id is: " + str(player_array_id))
	print("player unique id is: " + str(player))
	print("current content of peers array is: ")
	for peer in Globals.peers:
		print(str(peer))
	
	
		
	# set the input state to true
	can_attack = true
	can_move = true
	#set the initial target
	current_target = self
	Globals.players_changed.emit()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# movement input
	if can_move == true:
		move_and_animate(delta)
	
	# attack input
	if can_attack == true:
		if input.attack1:
			attack1_shoot_bullet()
		if input.attack2:
			attack2_aoe_ranged()
		if input.attack3:
			attack3_aoe_self()
		if input.defensive:
			defensive()


# Get the input direction and handle the movement/deceleration.
func move_and_animate(delta):
	velocity.x = input.direction.x
	velocity.y = input.direction.y
	
	# set the animation based on x movement
	if velocity.x == 0:
		set_move_state(MOVE_STATE.IDLE)
	elif velocity.x > 0:
		set_move_state(MOVE_STATE.FORWARD)
	elif velocity.x < 0: 
		set_move_state(MOVE_STATE.BACKWARD)
	
	# Check for tight toggle BEFORE calculating velocity
	toggle_tight(input.tight)
	
	# Normalize the velocity vector so that diagonal movement is not faster
	# and multiply it by the speed
	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
	
	# move to the new position based on the velocity
	position += velocity * delta
	position.x = clamp(position.x, 10, 1910)
	position.y = clamp(position.y, 10, 1070)

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

func _toggle_player_inputs(_id, state):
	if _id == player:
		can_attack = state
		can_move = state

func _change_color(_id, color):
	if _id == player:
		$Parts/Head.set_texture(head_sprites[color])


func _on_area_entered(area):
	print("player area entered")
	if area.is_in_group("enemy_hitbox"):
		damaged()
	if area.is_in_group("enemy_bullet"):
		area.queue_free()


func damaged():
	if $InvulnTimer.is_stopped():
		print("player took damage")
		Globals.player_damaged.emit(player_array_id)
	
		# give the player 1.0s of invuln
		invuln(1.0, "damaged")


func invuln(duration:float, animation:String):
	if $InvulnTimer.is_stopped() or animation == "defensive":
		$InvulnTimer.set_wait_time(duration)
		$InvulnTimer.start()
		$ColorAnimationPlayer.play(animation)

# This is currently a stub for the player death logic
func _on_player_died():
	queue_free()



# Gets the array of bosses and assigns target to the first entry. 
func get_target_position():
	var target_position
	if is_instance_valid(current_target): #check that target is still valid
		target_position = current_target.get_global_position()
	else:
		emit_signal("update_target")
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
		attack1_cooldown_animation(attack_1["GCD"])
		attack2_cooldown_animation(attack_1["GCD"])
		attack3_cooldown_animation(attack_1["GCD"])


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
		attack1_cooldown_animation(attack_2["GCD"])
		attack2_cooldown_animation(attack_2["GCD"])
		attack3_cooldown_animation(attack_2["GCD"])

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
		attack1_cooldown_animation(attack_3["GCD"])
		attack2_cooldown_animation(attack_3["GCD"])
		attack3_cooldown_animation(attack_3["GCD"])
	
func defensive():
	if $DefensiveCDTimer.is_stopped():
		speed = BASE_SPEED * defensive_stats["speed_multiplier"]
		current_speed = speed
		$DefensiveCDTimer.set_wait_time(defensive_stats["cooldown"])
		$DefensiveCDTimer.start()
		invuln(defensive_stats["duration"], "defensive")
		defensive_cooldown_animation()


func _on_invuln_timer_timeout():
	$ColorAnimationPlayer.stop()
	speed = BASE_SPEED
	current_speed = BASE_SPEED
	

func attack1_cooldown_animation(_duration):
	$Attack1ProgressBar.value = 100
	tweens[0] = create_tween()
	tweens[0].tween_property($Attack1ProgressBar, "value", 0.0, _duration)

func attack2_cooldown_animation(_duration):
	$Attack2ProgressBar.value = 100
	tweens[1] = create_tween()
	tweens[1].tween_property($Attack2ProgressBar, "value", 0.0, _duration)

func attack3_cooldown_animation(_duration):
	$Attack3ProgressBar.value = 100
	tweens[2] = create_tween()
	tweens[2].tween_property($Attack3ProgressBar, "value", 0.0, _duration)

func defensive_cooldown_animation():
	$DefensiveProgressBar.value = 100
	tweens[3] = create_tween()
	tweens[3].tween_property($DefensiveProgressBar, "value", 0.0, defensive_stats["cooldown"])

func reset_cooldowns():
	# reset the button visuals
	for tween in tweens:
		if is_instance_valid(tween):
			tween.stop()
	
	$Attack1ProgressBar.value = 0
	$Attack2ProgressBar.value = 0
	$Attack3ProgressBar.value = 0
	$DefensiveProgressBar.value = 0
	
	# stop the timers
	$InvulnTimer.stop()
	$GCDTimer.stop()
	$DefensiveCDTimer.stop()


func _on_tree_exiting():
	Globals.players_changed.emit()
