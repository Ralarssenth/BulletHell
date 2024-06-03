extends Node2D

var player
var player_in_shop = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$ShopScreen.set_visible(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed("select") and player_in_shop:
		player.can_move = false
		player.can_attack = false
		$ShopScreen.set_visible(true)
		$ShopScreen/MarginContainer/GridContainer/LeaveShopButton.grab_focus()

func _on_shop_keeper_area_entered(area):
	if area.is_in_group("player"):
		player = area
		player_in_shop = true
		

func _on_shop_keeper_area_exited(area):
	player_in_shop = false


func _on_leave_shop_button_pressed():
	player.can_move = true
	player.can_attack = true
	$ShopScreen.set_visible(false)


func _on_heal_pressed():
	Globals.player_healed.emit()



