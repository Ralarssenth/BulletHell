extends Node2D

var theta: float = 0.0
@export_range(0,2*PI) var alpha: float = 0.0

@export var bullet_node: PackedScene
@export var pointBlank_node: PackedScene
@export var donut_node: PackedScene
@export var line_attack_node: PackedScene
@export var spinning_ray_node: PackedScene

var bosses = []
var current_target
var next_target

func _ready():
	bosses = get_tree().get_nodes_in_group("boss")
	connect_boss_signals()
	
	$Player.connect("changed_target", update_player_target)
	
	current_target = $Player.current_target
	update_player_target(current_target)
	
	$HUD.update_boss_healthbar(current_target.current_health, current_target.max_health)


func connect_boss_signals():
	for boss in bosses:
		boss.connect("tree_exited", _on_boss_tree_exited)

func _on_boss_tree_exited():
	var i = bosses.find(current_target)
	bosses.remove_at(i)
	$HUD.hide_boss_healthbar()
	$Player.update_target()
	


func update_player_target(_target):
	next_target = _target
	
	if next_target != $Player: #check for self targeting (no boss present)
		if current_target: #check if target is valid before changing sprite
			if current_target != next_target:
				current_target.targeted(false)
				print(str(current_target) + ": untargeted")
			next_target.targeted(true) 
			current_target = next_target
			print(str(current_target) + ": targeted")
			$HUD.update_boss_healthbar(current_target.current_health, current_target.max_health)
		else:
			print("same target")
	else:
		print("Player targeted")



func get_vector(angle):
	theta = angle + alpha
	return Vector2(cos(theta), sin(theta))

func shoot(_position, angle):
	var bullet = bullet_node.instantiate()
	
	bullet.position = _position
	bullet.direction = get_vector(angle)
	
	get_tree().current_scene.call_deferred("add_child", bullet)

func spawn_pointBlank(_position:Vector2, _size:float, _timer:float, _linger:float):
	var pointBlank = pointBlank_node.instantiate()
	
	pointBlank.init(_position, _size, _timer, _linger)
	
	get_tree().current_scene.call_deferred("add_child", pointBlank)
	#print("pointBlank added to scene with params size: " + str(_size) + " and timer: " + str(_timer))

func spawn_donut(_position:Vector2, _size:float, _density:int, _timer:float):
	var donut = donut_node.instantiate()
	
	donut.init(_position, _size, _density, _timer)
	
	get_tree().current_scene.call_deferred("add_child", donut)


func spawn_line_attack(_position:Vector2, _angle:float, _timer:float, _linger:float):
	var line_attack = line_attack_node.instantiate()
	line_attack.init(_position, _angle, _timer, _linger)
	get_tree().current_scene.call_deferred("add_child", line_attack)
	

func spawn_spinning_ray(_position:Vector2, _angle:float, _timer:float, _linger:float, _counter:int):
	var spinning_ray = spinning_ray_node.instantiate()
	spinning_ray.init(_position, _angle, _timer, _linger, _counter)
	get_tree().current_scene.call_deferred("add_child", spinning_ray)


func spawn_spinning_x(_position:Vector2, _timer:float, _linger:float, _counter:int):
	spawn_spinning_ray(_position, Globals.DIAGONAL_NE, _timer, _linger, _counter)
	spawn_spinning_ray(_position, Globals.DIAGONAL_NW, _timer, _linger, _counter)
	spawn_spinning_ray(_position, Globals.DIAGONAL_SE, _timer, _linger, _counter)
	spawn_spinning_ray(_position, Globals.DIAGONAL_SW, _timer, _linger, _counter)


func spawn_spinning_plus(_position:Vector2, _timer:float, _linger:float, _counter:int):
	spawn_spinning_ray(_position, Globals.VERTICAL_N, _timer, _linger, _counter)
	spawn_spinning_ray(_position, Globals.VERTICAL_S, _timer, _linger, _counter)
	spawn_spinning_ray(_position, Globals.HORIZONTAL_E, _timer, _linger, _counter)
	spawn_spinning_ray(_position, Globals.HORIZONTAL_W, _timer, _linger, _counter)


# Everything below this point is the functional timeline of the room

func _on_bullet_shoot_speed_timeout():
	shoot($Boss.position, theta)


func _on_point_blank_timeout():
	var recast_timer = 3.0
	spawn_pointBlank($Player.position, 100.0, recast_timer, 0.5)
	$DonutTimer.set_wait_time(recast_timer)
	$DonutTimer.start()

func _on_donut_timer_timeout():
	var recast_timer = 3.0
	spawn_donut($Player.position, 100.0, 32, recast_timer)
	$LineTimer.set_wait_time(recast_timer)
	$LineTimer.start()


func _on_line_timer_timeout():
	var recast_timer = 5.0
	spawn_line_attack($Player.position, Globals.VERTICAL_N, 3.5, 0.5)
	spawn_line_attack($Player.position, Globals.HORIZONTAL_E, 3.5, 0.5)
	$SpinTimer.set_wait_time(recast_timer)
	$SpinTimer.start()


func _on_spin_timer_timeout():
	var recast_timer = 9.0
	if not bosses.is_empty():
		spawn_spinning_x(bosses[0].position, 1.0, 8.0, 1)
	
		$PointBlank.set_wait_time(recast_timer)
		$PointBlank.start()
	


