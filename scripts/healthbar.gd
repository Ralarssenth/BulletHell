extends Node2D
const MAX_HEALTH:int = 4
var current_health:int = 4

@onready var pips = [$HealthPip, $HealthPip2, $HealthPip3, $HealthPip4]

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.player_damaged.connect(_on_player_damaged)
	Globals.player_healed.connect(_on_player_healed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_damaged():
	current_health -= 1
	update_ui()
	if current_health <= 0:
		emit_signal("player_died")
	


func update_ui():
	for i in range(pips.size()):
		if i >= current_health:
			pips[i].set_visible(false)
		else:
			pips[i].set_visible(true)
		


func _on_player_healed():
	current_health = MAX_HEALTH
	update_ui()
