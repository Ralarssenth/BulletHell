extends Node

signal player_damaged
signal player_died
signal update_player_target
signal boss_damaged(current_health, max_health)

const HORIZONTAL_E = 0.0
const HORIZONTAL_W = PI
const VERTICAL_N = PI / 2.0
const VERTICAL_S = -PI / 2.0

const DIAGONAL_NE = PI / 4.0
const DIAGONAL_SE = - PI / 4.0
const DIAGONAL_NW = 3.0 * PI / 4.0
const DIAGONAL_SW = -3.0 * PI / 4.0

var rooms = {
	"waiting_room": "res://scenes/waiting_room.tscn", 
	"boss_room": "res://scenes/boss_room.tscn"
}
var current_room:String
var bosses = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass





# This is a stub for the ready area scene
func change_scene():
	print("all players ready, scene changing...")
	match current_room:
		"boss_room":
			get_tree().change_scene_to_file(rooms["waiting_room"])
		"waiting_room":
			get_tree().change_scene_to_file(rooms["boss_room"])
