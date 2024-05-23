extends Node2D


@export var waiting_room: PackedScene 
@export var boss_room: PackedScene

var current_room:String
var bosses = []


var current_target
var next_target
var current_boss_index:int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.connect("update_target", update_player_target)
	$Player.connect("iterate_target", iterate_target)
	$ReadyArea.connect("change_scene", change_scene)
	Globals.update_room.connect(update_room)
	current_room = "waiting_room"
	bosses = get_tree().get_nodes_in_group("boss")
	update_player_target()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func update_player_target():
	# Set next target
	if current_target == $Player:
		if bosses.is_empty():
			next_target = $Player
		else:
			current_boss_index = 0
			next_target = bosses[current_boss_index]
	else:
		if bosses.is_empty():
			next_target = $Player
		else:
			next_target = bosses[current_boss_index]
	
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
	if not bosses.is_empty():
		if current_target == $Player:
			current_boss_index = 0
		else:
			current_boss_index += 1
			
		if current_boss_index > (bosses.size()  - 1): #wrap back to 0
			current_boss_index = 0
			
		next_target = bosses[current_boss_index]
	
	else:
		next_target = $Player
		
	update_player_target()


# Connects all the bosses in the array to _on_boss_tree_exiting below
func connect_boss_signals():
	for boss in bosses:
		boss.connect("tree_exiting", _on_boss_tree_exiting.bind(boss))


# When a boss despawns on kill
# Updates the player target to new valid target and updates the HUD
func _on_boss_tree_exiting(_boss):
	$HUD.hide_boss_healthbar()
	
	bosses.erase(_boss)
	print("size of boss array now: " + str(bosses.size()))
	
	if bosses.is_empty():
		$ReadyArea.activate(true)
		print("last boss removed")
		
	iterate_target()
	
# This is a stub for the ready area scene
func change_scene():
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
	tween.tween_property($Player,"position:x", 125.0, transition_timer).set_trans(Tween.TRANS_SINE)
	
	# Spawn the next room
	var next_room_instance
	match current_room:
		"boss_room":
			next_room_instance = waiting_room.instantiate()
		"waiting_room":
			next_room_instance = boss_room.instantiate()
		_:
			print("change_scene defaulted")
	await get_tree().create_timer(transition_timer + 1.0).timeout
	get_tree().current_scene.call_deferred("add_child", next_room_instance)
	


func update_room(_room):
	current_room = _room
	print("room updated to: " + str(current_room))
	
	# Initialize the bosses
	bosses = get_tree().get_nodes_in_group("boss")
	connect_boss_signals()
	
	# Update the player target with the new bosses
	update_player_target()
	
