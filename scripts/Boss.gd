extends Node2D

var theta: float = 0.0
@export_range(0,2*PI) var alpha: float = 0.0

@export var bullet_node: PackedScene
@export var pointBlank_node: PackedScene

func get_vector(angle):
	theta = angle + alpha
	return Vector2(cos(theta), sin(theta))

func shoot(angle):
	var bullet = bullet_node.instantiate()
	
	bullet.position = global_position
	bullet.direction = get_vector(angle)
	
	get_tree().current_scene.call_deferred("add_child", bullet)

func spawnPointBlank(_size:float, _timer:float):
	var pointBlank = pointBlank_node.instantiate()
	
	pointBlank.init(position, _size, _timer)
	
	get_tree().current_scene.call_deferred("add_child", pointBlank)
	print("pointBlank added to scene with params size: " + str(_size) + " and timer: " + str(_timer))

func _on_speed_timeout():
	shoot(theta)


func _on_point_blank_timeout():
	var recast_timer = 3.0
	spawnPointBlank(100.0, recast_timer)
	$PointBlank.set_wait_time(recast_timer)
	$PointBlank.start()
