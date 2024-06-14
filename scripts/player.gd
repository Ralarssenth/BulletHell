extends Area2D

# multiplayer id 
# Set by the authority, synchronized on spawn.
@export var player := 1 :
	set(id):
		player = id
		# Give authority over the player input to the appropriate peer.
		$PlayerInput.set_multiplayer_authority(id)
@export var player_array_id : int

# The vec4 color to modulate to
var color = Color(0.0, 0.0, 1.0, 1.0)
# The player's sprite options 
# by "color" for now
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
var next_target = self
var previous_target = self
var current_boss_index:int = 0


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
	Globals.move_player.connect(_get_moved)
	Globals.set_player_color.connect(_change_color)
	
	
	#logging the id setups
	print("player array id is: " + str(player_array_id))
	print("player unique id is: " + str(player))
	
	#set default color
	color = Globals.COLORS["default"]
	$CollisionShape2D.set_modulate(color)
	
	# set the input state to true
	can_attack = true
	can_move = true
	
	#set the initial target
	update_player_target()
	
	# activate client-side always-draw-on-top for player character
	draw_in_front(true)
	
	# emit signal when number of players changes
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
	
	# The toggle tight function changes the speed variable
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
# ---------------------------------------------------------------


# ---------------------------------------------------------------
# This section is for logic that is called on one specific player
# ----------------------------------------------------------------

# Toggle the attack and move booleans to allow or disallow inputs
# Used to turn off attacks in menus etc.
func _toggle_player_inputs(_id, state):
	if _id == player:
		can_attack = state
		can_move = state

# Move a player to a position
func _get_moved(_id, _position):
	if _id == player:
		var move_tween = create_tween()
		# find variable duration based on how far you are moving
		var duration = abs((position - _position).length()/1000.0) #1920/1000 = 1.92s to cross the full screen
		move_tween.tween_property(self, "position", _position, duration)

# Change a player's color scheme
func _change_color(_id, _color):
	if _id == player:
		$Parts/Head.set_texture(head_sprites[_color])
		color = Globals.COLORS[_color]
		$CollisionShape2D.set_modulate(color)
		update_player_hud()

# Draw self on top client side
# (A player should always be drawn on the top on their own screen)
func draw_in_front(state):
	var peer_id = multiplayer.get_unique_id()
	if peer_id == player:
		top_level = state
		print(str(peer_id) + "called to draw player" + str(player) + "in front")
# --------------------------------------------------------


# ---------------------------------------------------------
# This section deals with player taking damage logic
# --------------------------------------------------------

# Check for attack hitboxes
func _on_area_entered(area):
	print("player area entered")
	if area.is_in_group("enemy_hitbox"):
		damaged()
	if area.is_in_group("enemy_bullet"):
		area.queue_free()


# Take damage
func damaged():
	if $InvulnTimer.is_stopped():
		print("player took damage")
		Globals.player_damaged.emit(player_array_id)
	
		# give the player 1.0s of invuln
		player_invuln(1.0, "damaged")


# Apply an invuln 
func player_invuln(duration:float, animation:String):
	# only using a defensive should interrupt an existing invuln
	if $InvulnTimer.is_stopped() or animation == "defensive": 
		$InvulnTimer.set_wait_time(duration)
		$InvulnTimer.start()
		$ColorAnimationPlayer.play(animation)
# ------------------------------------------------------------


# ------------------------------------------------------------
# This is currently a stub for the player death logic
# ------------------------------------------------------------

func _on_player_died():
	queue_free()
	
func _on_tree_exiting():
	# emit signal when number of players changes
	Globals.players_changed.emit()
# --------------------------------------------------------------


# ---------------------------------------------------------------
# This section is for targeting logic
# ---------------------------------------------------------------

# Checks if the target is still valid, then returns its position
# If it is not valid, updates the target, then returns that target's position 
func get_target_position():
	var target_position
	if is_instance_valid(current_target): #check that target is still valid
		target_position = current_target.get_global_position()
	else:
		update_player_target()
		target_position = current_target.get_global_position()
	return target_position

# Updates the current target, including checking for validity
func update_player_target():
	previous_target = current_target
	# If targeting self, but there are bosses, target the first boss instead, 
	# Otherwise keep targeting self
	if current_target == self: 
		if not Globals.bosses.is_empty():
			current_boss_index = 0
			next_target = Globals.bosses[current_boss_index]
		
		else:
			next_target = self
		
	# If targeting a boss...
	else:
		# but there are no bosses, retarget self
		if Globals.bosses.is_empty():
			next_target = self
		# and there is one or more bosses, target the boss at current_boss_index
		else:
			# check if the current_boss_index is in range first, and if not, set it back to 0
			if current_boss_index >= (Globals.bosses.size()): #wrap back to 0
				current_boss_index = 0
			
			next_target = Globals.bosses[current_boss_index]
	
	current_target = next_target
	# Update the client side hud
	update_player_hud()

# Updates the hud client-side to indicate the local player's target
func update_player_hud():
	# Only update boss huds when the boss is targeted
	if current_target != self:
		# Check to be sure next target is still valid (in cases of multikills)
		if is_instance_valid(current_target):
			# Always target the new target
			# Pass the player unique id for client-side reticle on the boss sprite
			Globals.target_boss.emit(player, current_target, true)
			# Signal the hud to update the healthbar to the new boss'
			Globals.update_player_target.emit(player, current_target.current_health, current_target.max_health)
	
	# when the player is the target, send the hide huds signal
	else:
		Globals.hide_player_target.emit(player)
		
	# Tell the previous boss to turn off its targeted sprite
	# Don't turn off if target is the same, or if the previous target was the player
	if (previous_target != current_target) and (previous_target != self):
		# Check if current target still exists before changing sprite
		if is_instance_valid(previous_target): 
			Globals.target_boss.emit(player, previous_target, false)
	
	# tracking print
	print(str(current_target) + ": targeted")
	
# Iterates through multiple targets, if any
func iterate_target():
	# Check if a boss exists, and set the boss index
	if not Globals.bosses.is_empty():
		if current_target == self:
			current_boss_index = 0
		else:
			current_boss_index += 1
		
		# Check if the new index is in range and wrap to 0
		if current_boss_index >= (Globals.bosses.size()): 
			current_boss_index = 0 #wrap back to 0
		
		update_player_target()

	# NOTE: All these checks also exist in update_player_target, this function -could- just be:
	# current_boss_index += 1
	# update_player_target()
	# but it would be less predictable
# ------------------------------------------------------------------------


# ------------------------------------------------------------------------
# Everything in this next section is about player attacks (and defensive)
# Might relocate once classes exist to the class script
# -------------------------------------------------------------------------

# Helper function for spawning circle attacks
func spawn_aoe_attack(_position:Vector2, _size:float, _timer:float, _linger:float, _damage:float):
	var player_aoe_attack = player_aoe_attack_node.instantiate()
	
	player_aoe_attack.init(_position, _size, _timer, _linger, _damage, color)
	
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
		player_bullet.color = color
		
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

# An invulnerability buff
func defensive():
	if $DefensiveCDTimer.is_stopped():
		speed = BASE_SPEED * defensive_stats["speed_multiplier"]
		current_speed = speed
		$DefensiveCDTimer.set_wait_time(defensive_stats["cooldown"])
		$DefensiveCDTimer.start()
		player_invuln(defensive_stats["duration"], "defensive")
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

# Resets all the player cooldowns
# Called between rooms/ screens/ bosses
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

# ------------------------------------------------------------------

