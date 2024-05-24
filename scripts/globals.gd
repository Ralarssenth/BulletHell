extends Node

const BOSS_START_SPOT = Vector2(1500, 335)

var players = []
var bosses = []
var current_route: String = ""
var next_route: String = ""

signal player_damaged
signal player_died
signal update_player_target
signal boss_damaged(current_health, max_health)


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



