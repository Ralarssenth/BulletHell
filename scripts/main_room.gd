extends Node2D

# Menu Scenes
@export var waiting_room: PackedScene 
@export var shop_node: PackedScene

# Fire Boss scenes
@export var fire_boss1_node: PackedScene
@export var fire_boss2_node: PackedScene
@export var fire_boss3_node: PackedScene

var current_target
var next_target
var current_boss_index:int = 0
var room_counter:int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect signals
	$ReadyArea.connect("change_room_scene", change_room_scene)
	
	# Initialize variables
	
	Globals.current_route = "waiting" #default route
	Globals.next_route = "fire"
	Globals.bosses = get_tree().get_nodes_in_group("boss") #initialize the bosses array.
	
	
	# We only need to spawn players on the server.
	if not multiplayer.is_server():
		return
	
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)

	# Spawn already connected players.
	for id in multiplayer.get_peers():
		add_player(id)

	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		add_player(1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# This section is multiplayer functions 
# from https://godotengine.org/article/multiplayer-in-godot-4-0-scene-replication/
func add_player(id: int):
	# Set the player's controller character
	var character = preload("res://scenes/player.tscn").instantiate()
	# Set player id.
	character.player = id
	# Set starting character position.
	character.position = Vector2(660.0, 540.0)
	character.name = str(id)
	$Players.add_child(character, true)
	
	$Players.players[id] = character
	character.player_array_id = $Players.players.size() - 1
	Globals.players_changed.emit()

func del_player(id: int):
	if not $Players.has_node(str(id)):
		return
	$Players.get_node(str(id)).queue_free()
	
	$Players.players.erase(id)
	Globals.players_changed.emit()
	

func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)



# Connects all the bosses in the array to _on_boss_tree_exiting below
func connect_boss_signals():
	for boss in Globals.bosses:
		print("connecting: " + str(Globals.bosses))
		boss.connect("tree_exited", _on_boss_tree_exited.bind(boss))


# When a boss despawns on kill
# Updates the player target to new valid target and updates the HUD
func _on_boss_tree_exited(_boss):
	$HUD.hide_boss_healthbar()
	
	if Globals.bosses.is_empty():
		print("last boss removed")
		$ReadyArea.activate(true)
	
		# Free any remaining boss attacks
		var enemy_attacks = get_tree().get_nodes_in_group("enemy_hitbox")
		for attack in enemy_attacks:
			attack.queue_free()
		


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
	
	
	# Tween the player's position back to the left side and reset their cd's
	for player_id in $Players.players:
		var player = $Players.get_node(str(player_id))
		var tween = create_tween()
		tween.tween_property(player,"position", (player.position - Vector2(1700.0, 0.0)), transition_timer).set_trans(Tween.TRANS_SINE)
		player.reset_cooldowns()
		player.can_attack = false #disallow inputs during transition
	
	# Catch the waiting room before the match/case below so that the first route starts there
	if Globals.current_route == "waiting":
		Globals.current_route = Globals.next_route
	
	# Spawn the next room
	var next_boss_instance
	match Globals.current_route:
		"fire":
			match room_counter:
				0:
					next_boss_instance = shop_node.instantiate()
					room_counter += 1
					# Wait for the player transition and then add the next boss instance to the scene tree
					# (May have to adjust where this goes for multibosses)
					
					await get_tree().create_timer(transition_timer + 1.0).timeout
					get_tree().current_scene.call_deferred("add_child", next_boss_instance)
					$ReadyArea.activate(true) # Reactivate the ready area
					
				1:
					next_boss_instance = fire_boss2_node.instantiate()
					room_counter += 1
					# Wait for the player transition and then add the next boss instance to the scene tree
					# (May have to adjust where this goes for multibosses)
					next_boss_instance.position = Globals.BOSS_START_SPOT #put the boss in the starting position
					await get_tree().create_timer(transition_timer + 1.0).timeout
					get_tree().current_scene.call_deferred("add_child", next_boss_instance)
					Globals.bosses.append(next_boss_instance) # Fill the bosses array
				
				2:
					next_boss_instance = fire_boss3_node.instantiate()
					room_counter += 1
					# Wait for the player transition and then add the next boss instance to the scene tree
					# (May have to adjust where this goes for multibosses)
					next_boss_instance.position = Globals.BOSS_START_SPOT #put the boss in the starting position
					await get_tree().create_timer(transition_timer + 1.0).timeout
					get_tree().current_scene.call_deferred("add_child", next_boss_instance)
					Globals.bosses.append(next_boss_instance) # Fill the bosses array
					
				3:
					next_boss_instance = fire_boss1_node.instantiate()
					room_counter += 1
					
					Globals.next_route = "waiting"
					
					# Wait for the player transition and then add the next boss instance to the scene tree
					# (May have to adjust where this goes for multibosses)
					next_boss_instance.position = Globals.BOSS_START_SPOT #put the boss in the starting position
					await get_tree().create_timer(transition_timer + 1.0).timeout
					get_tree().current_scene.call_deferred("add_child", next_boss_instance)
					Globals.bosses.append(next_boss_instance) # Fill the bosses array
					
				4:
					next_boss_instance = waiting_room.instantiate()
					
					Globals.current_route = Globals.next_route # Advance the route
					Globals.next_route = "fire"
					room_counter = 0
					
					# Wait for the player transition and then add the next boss instance to the scene tree
					# (May have to adjust where this goes for multibosses)
					next_boss_instance.position = Globals.BOSS_START_SPOT #put the boss in the starting position
					await get_tree().create_timer(transition_timer + 1.0).timeout
					get_tree().current_scene.call_deferred("add_child", next_boss_instance)
					Globals.bosses.append(next_boss_instance) # Fill the bosses array
				_:
					print("change_boss defaulted in fire route")
					
		_:
			print("change_boss defaulted at route choice")
	
	for player_id in $Players.players:
		var player = $Players.get_node(str(player_id))
		player.can_attack = true #reallow player inputs
	
	# Check if we have returned to the waiting room and if so, reactivate the ready area
	# this logic can move later when we add the player drop in/ drop out so that the 
	# ready area becomes visible when there is an active player 
	if Globals.current_route == "waiting":
		$ReadyArea.activate(true) # Reactivate the ready area
	else:
		connect_boss_signals()
