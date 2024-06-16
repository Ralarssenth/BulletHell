extends Node

const BOSS_START_SPOT = Vector2(2250, 650)
const COLORS = {
	"default": Color(0.0, 0.0, 1.0, 1.0), 
	"red": Color(1.0, 0.0, 0.0, 1.0)
}

var bosses = []
var current_route: String = ""
var next_route: String = ""

signal players_changed
signal set_player_color(peer_id, color)
signal toggle_player_inputs(peer_id, state)
signal move_player(peer_id, _position)

signal player_damaged(array_id)
signal player_healed(array_id)
signal player_died
signal update_player_target
signal boss_damaged(current_health, max_health)
signal no_bosses_left()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



