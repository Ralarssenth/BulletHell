extends ColorRect

# Called when the node enters the scene tree for the first time.
func _ready():
	set_visible(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_input()

func get_input():
	if Input.is_action_just_pressed("select"):
		open_menu.rpc()


@rpc("any_peer", "call_local")
func open_menu():
	var peer_id = multiplayer.get_remote_sender_id()
	print("player peer id is: " + str(peer_id))
	
	Globals.move_player.emit(peer_id, Vector2(250, 540))
	Globals.toggle_player_inputs.emit(peer_id, false)
	
	
	# only toggle the shop screen locally, even when hosting
	if peer_id == multiplayer.get_unique_id():
		set_visible(true)
		$MarginContainer/GridContainer/LeaveMenuButton.grab_focus()
		

func _on_leave_menu_button_pressed():
	leave_menu.rpc()
	
@rpc("any_peer", "call_local")
func leave_menu():
	var peer_id = multiplayer.get_remote_sender_id()
	
	Globals.toggle_player_inputs.emit(peer_id, true)
	
	# only toggle the shop screen locally, even when hosting
	if peer_id == multiplayer.get_unique_id():
		set_visible(false)


@rpc("any_peer", "call_local")
func set_player_color(color):
	var peer_id = multiplayer.get_remote_sender_id()
	Globals.set_player_color.emit(peer_id, color)
	

# This section hooks all the buttons up to the set_player_color function

# the top left button
func _on_texture_button_pressed():
	set_player_color.rpc("red")

# the bottom right button
func _on_texture_button_8_pressed():
	set_player_color.rpc("default")
