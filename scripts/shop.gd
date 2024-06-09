extends Node2D

var peer_id := 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$ShopScreen.set_visible(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_input()

func get_input():
	if Input.is_action_just_pressed("select"):
		open_shop.rpc()
		


@rpc("any_peer", "call_local")
func open_shop():
	peer_id = multiplayer.get_remote_sender_id()
	print("player peer id is: " + str(peer_id))
	
	Globals.move_player.emit(peer_id, Vector2(960, 540))
	Globals.toggle_player_inputs.emit(peer_id, false)
	
	# only toggle the shop screen locally, even when hosting
	if peer_id == multiplayer.get_unique_id():
		$ShopScreen.set_visible(true)
		$ShopScreen/MarginContainer/GridContainer/LeaveShopButton.grab_focus()



func _on_leave_shop_button_pressed():
	leave_shop.rpc()
	
	
@rpc("any_peer", "call_local")
func leave_shop():
	peer_id = multiplayer.get_remote_sender_id()
	
	Globals.toggle_player_inputs.emit(peer_id, true)
	
	# only toggle the shop screen locally, even when hosting
	if peer_id == multiplayer.get_unique_id():
		$ShopScreen.set_visible(false)


func _on_heal_pressed():
	Globals.player_healed.emit(peer_id)



