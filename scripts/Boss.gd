extends Node2D

var theta: float = 0.0
@export_range(0,2*PI) var alpha: float = 0.0

@export var bullet_node: PackedScene
@export var pointBlank_node: PackedScene
@export var donut_node: PackedScene
@export var line_attack_node: PackedScene


func get_vector(angle):
	theta = angle + alpha
	return Vector2(cos(theta), sin(theta))

func shoot(angle):
	var bullet = bullet_node.instantiate()
	
	bullet.position = global_position
	bullet.direction = get_vector(angle)
	
	get_tree().current_scene.call_deferred("add_child", bullet)

func spawn_pointBlank(_size:float, _timer:float, _linger:float):
	var pointBlank = pointBlank_node.instantiate()
	
	pointBlank.init(position, _size, _timer, _linger)
	
	get_tree().current_scene.call_deferred("add_child", pointBlank)
	#print("pointBlank added to scene with params size: " + str(_size) + " and timer: " + str(_timer))

func spawn_donut(_size:float, _density:int, _timer:float):
	var donut = donut_node.instantiate()
	
	donut.init(position, _size, _density, _timer)
	
	get_tree().current_scene.call_deferred("add_child", donut)
	


func spawn_line_attack(_angle:float, _timer:float, _linger:float, _type:String):
	var line_attack = line_attack_node.instantiate()
	
	get_tree().current_scene.call_deferred("add_child", line_attack)
	line_attack.init(position, _angle, _timer, _linger, _type)

func _on_speed_timeout():
	shoot(theta)


func _on_point_blank_timeout():
	var recast_timer = 3.0
	spawn_pointBlank(100.0, recast_timer, 0.5)
	$DonutTimer.set_wait_time(recast_timer)
	$DonutTimer.start()


func _on_donut_timer_timeout():
	var recast_timer = 3.0
	spawn_donut(100.0, 32, recast_timer)
	$LineTimer.set_wait_time(recast_timer)
	$LineTimer.start()


func _on_line_timer_timeout():
	var recast_timer = 3.0
	spawn_line_attack(Globals.VERTICAL, 0.5, 2.5, "spin")
	$PointBlank.set_wait_time(recast_timer)
	$PointBlank.start()
	
