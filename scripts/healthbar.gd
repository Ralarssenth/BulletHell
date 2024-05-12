extends Node2D
const MAX_HEALTH:int = 4
var current_health:int = 4


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.player_damaged.connect(_on_player_damaged)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_player_damaged():
	current_health -= 1
	
	match current_health:
		3:
			$HealthPip4.set_visible(false)
		2:
			$HealthPip3.set_visible(false)
		1:
			$HealthPip2.set_visible(false)
		0:
			$HealthPip.set_visible(false)
			Globals.player_died.emit()
		_:
			print("on player damaged defaulted")
