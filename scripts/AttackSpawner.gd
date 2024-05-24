extends Node2D


var theta: float = 0.0
@export_range(0,2*PI) var alpha: float = 0.0

@onready var bullet_node: PackedScene = preload("res://scenes/bullet.tscn")
@onready var pointBlank_node: PackedScene = preload("res://scenes/point_blank.tscn")
@onready var donut_node: PackedScene = preload("res://scenes/donut.tscn")
@onready var line_attack_node: PackedScene = preload("res://scenes/line_attack.tscn")
@onready var spinning_ray_node: PackedScene = preload("res://scenes/spinning_ray.tscn")

# This next section is directional constants for quick reference
const HORIZONTAL_E = 0.0
const HORIZONTAL_W = PI
const VERTICAL_N = PI / 2.0
const VERTICAL_S = -PI / 2.0
const DIAGONAL_NE = PI / 4.0
const DIAGONAL_SE = - PI / 4.0
const DIAGONAL_NW = 3.0 * PI / 4.0
const DIAGONAL_SW = -3.0 * PI / 4.0


func _ready():
	pass



# Everything in this next section is about spawning various attack types

# Helper function to translate an angle (theta) plus some adjustment (alpha) to a Vector2
# All angles are in rads. We like rads here :) 
func get_vector(angle):
	theta = angle + alpha
	return Vector2(cos(theta), sin(theta))


# Shoots a bullet at an angle
func shoot(_position, angle):
	var bullet = bullet_node.instantiate()
	
	bullet.position = _position
	bullet.direction = get_vector(angle)
	
	get_tree().current_scene.call_deferred("add_child", bullet)


# Spawns a circle that activates after a brief delay
func spawn_pointBlank(_position:Vector2, _size:float, _timer:float, _linger:float, _parent:Node):
	var pointBlank = pointBlank_node.instantiate()
	
	pointBlank.init(_position, _size, _timer, _linger)
	
	_parent.call_deferred("add_child", pointBlank)
	#print("pointBlank added to scene with params size: " + str(_size) + " and timer: " + str(_timer))


# Spawns a ring of bullets after a brief delay 
# Telegraphs the bullet ring during the delay with a donut sprite
func spawn_donut(_position:Vector2, _size:float, _density:int, _timer:float, _parent:Node):
	var donut = donut_node.instantiate()
	
	donut.init(_position, _size, _density, _timer)
	
	_parent.call_deferred("add_child", donut)


# Spawns a line at an angle that activates after a short delay
# The line draws in both directions at the angle, so north will also give you south etc.
func spawn_line_attack(_position:Vector2, _angle:float, _timer:float, _linger:float, _parent:Node):
	var line_attack = line_attack_node.instantiate()
	line_attack.init(_position, _angle, _timer, _linger)
	_parent.call_deferred("add_child", line_attack)
	


# Spawns a ray at an angle that rotates on its end
# The ray only draws in one direction from the endpoint, so N will only draw N and not also S
func spawn_spinning_ray(_position:Vector2, _angle:float, _timer:float, _linger:float, _counter:int, _parent:Node):
	var spinning_ray = spinning_ray_node.instantiate()
	spinning_ray.init(_position, _angle, _timer, _linger, _counter)
	_parent.call_deferred("add_child", spinning_ray)


# Spawns four spinning rays in an x pattern (on the diagonals)
func spawn_spinning_x(_position:Vector2, _timer:float, _linger:float, _counter:int, _parent):
	spawn_spinning_ray(_position, DIAGONAL_NE, _timer, _linger, _counter, _parent)
	spawn_spinning_ray(_position, DIAGONAL_NW, _timer, _linger, _counter, _parent)
	spawn_spinning_ray(_position, DIAGONAL_SE, _timer, _linger, _counter, _parent)
	spawn_spinning_ray(_position, DIAGONAL_SW, _timer, _linger, _counter, _parent)


# Spawns four spinning rays in a + pattern (on the cardinals)
func spawn_spinning_plus(_position:Vector2, _timer:float, _linger:float, _counter:int, _parent:Node):
	spawn_spinning_ray(_position, VERTICAL_N, _timer, _linger, _counter, _parent)
	spawn_spinning_ray(_position, VERTICAL_S, _timer, _linger, _counter, _parent)
	spawn_spinning_ray(_position, HORIZONTAL_E, _timer, _linger, _counter, _parent)
	spawn_spinning_ray(_position, HORIZONTAL_W, _timer, _linger, _counter, _parent)


