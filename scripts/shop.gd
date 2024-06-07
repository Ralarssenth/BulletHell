extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$ShopScreen.set_visible(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed("select"):
		Globals.players[0].can_move = false
		Globals.players[0].can_attack = false
		$ShopScreen.set_visible(true)
		$ShopScreen/MarginContainer/GridContainer/LeaveShopButton.grab_focus()


func _on_leave_shop_button_pressed():
	Globals.players[0].can_move = true
	Globals.players[0].can_attack = true
	$ShopScreen.set_visible(false)


func _on_heal_pressed():
	Globals.player_healed.emit()



