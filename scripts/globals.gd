extends Node

signal player_damaged
signal player_died
signal update_player_target
signal boss_damaged(current_health, max_health)
signal update_room(_room)

const HORIZONTAL_E = 0.0
const HORIZONTAL_W = PI
const VERTICAL_N = PI / 2.0
const VERTICAL_S = -PI / 2.0

const DIAGONAL_NE = PI / 4.0
const DIAGONAL_SE = - PI / 4.0
const DIAGONAL_NW = 3.0 * PI / 4.0
const DIAGONAL_SW = -3.0 * PI / 4.0



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



