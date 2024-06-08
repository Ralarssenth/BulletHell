extends Node2D

var player_id

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.player_select.connect(_on_player_select)
	$ShopScreen.set_visible(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


		
func _on_player_select(_player_id):
	player_id = _player_id
	print("shopping player id now set to: " + str(player_id))
	var player = Globals.players[player_id]
	player.can_move = false
	player.can_attack = false
	$ShopScreen.set_visible(true)
	$ShopScreen/MarginContainer/GridContainer/LeaveShopButton.grab_focus()

func _on_leave_shop_button_pressed():
	var player = Globals.players[player_id]
	$ShopScreen.set_visible(false)
	await get_tree().create_timer(0.5).timeout
	player.can_move = true
	player.can_attack = true
	


func _on_heal_pressed():
	Globals.player_healed.emit(player_id)



