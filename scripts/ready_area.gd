extends Area2D

var timer_counter:int = 3
var players_ready: int = 0

signal change_room_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	$TimerLabel.text = "Ready!"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_entered(area):
	if area.is_in_group("player"):
		$TimerLabel.set_visible(true)
		players_ready += 1
		
		if players_ready >= Globals.players.size():
			$TimerLabel.text = str(timer_counter) + "...!"
			$Timer.start(1.0)


func _on_area_exited(area):
	if area.is_in_group("player"):
		$Timer.stop()
		timer_counter = 3
		$TimerLabel.text = "Ready!"
		players_ready -= 1
		
		if players_ready <= 0:
			$TimerLabel.set_visible(false)
			


func _on_timer_timeout():
	timer_counter -= 1
	if timer_counter > 0:
		$TimerLabel.text = str(timer_counter) + "..."
		$Timer.start(1.0)
	else:
		emit_signal("change_room_scene")
	


func activate(_on):
	set_visible(_on)
	$CollisionShape2D.set_deferred("disabled", not _on)
