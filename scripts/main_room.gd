extends Node2D

@export var waiting_room: PackedScene 

# Fire Boss scenes
@export var fire_boss1_node: PackedScene
@export var fire_boss2_node: PackedScene

var current_target
var next_target
var current_boss_index:int = 0
var fight_counter:int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect signals
	$Player.connect("update_target", update_player_target)
	$Player.connect("iterate_target", iterate_target)
	$ReadyArea.connect("change_room_scene", change_room_scene)
	Globals.update_room.connect(update_room)
	
	# Initialize variables
	Globals.current_room = "waiting_room"
	Globals.current_route = "fire" #default route
	Globals.bosses = get_tree().get_nodes_in_group("boss") #initialize the bosses array.
	Globals.players = get_tree().get_nodes_in_group("player") #initialize the players array. This may move (again)
	update_player_target()
	connect_boss_signals()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func update_player_target():
	# Set next target
	if current_target == $Player:
		if Globals.bosses.is_empty():
			next_target = $Player
		else:
			current_boss_index = 0
			next_target = Globals.bosses[current_boss_index]
	else:
		if Globals.bosses.is_empty():
			next_target = $Player
		else:
			next_target = Globals.bosses[current_boss_index]
	
	# Pass next_target to Player for attack tracking
	$Player.current_target = next_target
	
	# Update the HUD based on the next_target
	if next_target != $Player: #check for self targeting (no boss present)
		
		if is_instance_valid(next_target):#check to be sure next target is still valid (in cases of multikills)
			next_target.targeted(true) #always target the new target
			$HUD.update_boss_healthbar(next_target.current_health, next_target.max_health)
		
		if current_target != next_target:#only change if target is different
			if is_instance_valid(current_target): #check if current target exists before changing sprite
				current_target.targeted(false)
				print(str(current_target) + ": untargeted")
				
			current_target = next_target #set new current target
			print(str(current_target) + ": targeted")
			
		else:
			print("same target")
	else:
		print("Player targeted")
		

# iterates through multiple targets, if any
func iterate_target():
	if not Globals.bosses.is_empty():
		if current_target == $Player:
			current_boss_index = 0
		else:
			current_boss_index += 1
			
		if current_boss_index > (Globals.bosses.size()  - 1): #wrap back to 0
			current_boss_index = 0
			
		next_target = Globals.bosses[current_boss_index]
	
	else:
		next_target = $Player
		
	update_player_target()


# Connects all the bosses in the array to _on_boss_tree_exiting below
func connect_boss_signals():
	for boss in Globals.bosses:
		print("connecting: " + str(Globals.bosses))
		boss.connect("tree_exiting", _on_boss_tree_exiting.bind(boss))


# When a boss despawns on kill
# Updates the player target to new valid target and updates the HUD
func _on_boss_tree_exiting(_boss):
	$HUD.hide_boss_healthbar()
	
	Globals.bosses.erase(_boss)
	print("size of boss array now: " + str(Globals.bosses.size()))
	
	if Globals.bosses.is_empty() and Globals.current_room != "waiting_room":
		$ReadyArea.activate(true)
		print("last boss removed")
		
	iterate_target()


# Changes rooms
func change_room_scene():
	print("all players ready, scene changing...")
	# Deactivate the ready area
	$ReadyArea.activate(false)
	
	var transition_timer = 3.0
	
	# Free the old room and all attacks
	var _room = get_tree().get_nodes_in_group("room")
	for r in _room:
		r.queue_free()
	
	var player_attacks = get_tree().get_nodes_in_group("player_hitbox")
	for attack in player_attacks:
		attack.queue_free()
		
	var enemy_attacks = get_tree().get_nodes_in_group("enemy_hitbox")
	for attack in enemy_attacks:
		attack.queue_free()
	
	
	# Tween the player's position back to the left side
	var tween = create_tween()
	tween.tween_property($Player,"position", ($Player.position - Vector2(950.0, 0.0)), transition_timer).set_trans(Tween.TRANS_SINE)
	
	# Spawn the next room
	var next_boss_instance
	match Globals.current_route:
		"fire":
			match fight_counter:
				0:
					next_boss_instance = fire_boss1_node.instantiate()
					fight_counter += 1
				1:
					next_boss_instance = fire_boss2_node.instantiate()
					fight_counter += 1
				2:
					next_boss_instance = waiting_room.instantiate()
					fight_counter = 0
				_:
					print("change_boss defaulted in fire route")
					
		_:
			print("change_boss defaulted at route choice")
			
	await get_tree().create_timer(transition_timer + 1.0).timeout
	get_tree().current_scene.call_deferred("add_child", next_boss_instance)
	Globals.bosses.append(next_boss_instance) # Fill the bosses array
	update_player_target() # Update the player target with the new bosses
	connect_boss_signals()


# Updates the current_room variable
# Is called from a global signal emitted from each room's ready function 
# that passes the room's name as a string
# Used for functionality that has to wait until the room is ready
func update_room(_room):
	Globals.current_room = _room
	print("room updated to: " + str(Globals.current_room))
	
	
	
	# Execute room-specific logic to the HUD, UI, or Player
	if Globals.current_room == "waiting_room":
			# Reactivate the ready area
			$ReadyArea.activate(true)
