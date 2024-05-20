extends Area2D

var timer_counter:int = 3

# Called when the node enters the scene tree for the first time.
func _ready():
	$TimerLabel.text = str(timer_counter)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_entered(area):
	if area.is_in_group("player"):
		$TimerLabel.set_visible(true)
		$Timer.start(1.0)



func _on_area_exited(area):
	if area.is_in_group("player"):
		$TimerLabel.set_visible(false)
		$Timer.stop()
		timer_counter = 3
		$TimerLabel.text = str(timer_counter)


func _on_timer_timeout():
	timer_counter -= 1
	if timer_counter >= 0:
		$TimerLabel.text = str(timer_counter)
		$Timer.start(1.0)
	else:
		Globals.change_scene()
