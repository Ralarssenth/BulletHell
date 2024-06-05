extends "res://scripts/boss.gd"

var cycle_count: int = 0

# Called from superclass's ready function.
# Used to add to the ready function instead of overload/replace it
func setup():
	var tween = create_tween()
	tween.tween_property(self,"position", Vector2(960.0, 540.0), 1.0).set_trans(Tween.TRANS_SINE)
	
	$AttackTimer.start(2.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# This boss moves to the same y value as the player and then 
# spawns a lingering horizontal line attack
func _on_attack_timer_timeout():
	# tween the position between attacks
	var tween = create_tween()
	var movement_timer = 1.0
	var buffer_timer = 0.5
	
	#print("cycle count: " + str(cycle_count))
	#print("players array size: " + str(Globals.players.size()))
	
	tween.tween_property(self,"position:y", Globals.players[cycle_count].position.y, movement_timer).set_trans(Tween.TRANS_SINE)
	await get_tree().create_timer(movement_timer).timeout
	AttackSpawner.spawn_line_attack(self.position, AttackSpawner.HORIZONTAL_E, 2.0, 2.0, get_tree().root)

	cycle_count += 1
	if cycle_count >= Globals.players.size():
		cycle_count = 0
		
	$AttackTimer.start(2.0)
	
	
