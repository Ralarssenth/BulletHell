extends "res://scripts/boss.gd"

var cycle_count: int = 0

# Called from superclass's ready function.
# Used to add to the ready function instead of overload/replace it
func setup():
	var tween = create_tween()
	tween.tween_property(self,"position", Vector2(1310.0, 540.0), 1.0).set_trans(Tween.TRANS_SINE)
	
	$AttackTimer.start(2.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# This boss spawns a point blank aoe 
# under each player in order and then under themselves, in a loop
# while moving back and forth between each attack
func _on_attack_timer_timeout():
	# tween the position between attacks
	var tween = create_tween()
	var movement_timer = 1.0
	var buffer_timer = 0.5
	if cycle_count % 2 == 0: # go left 500
		tween.tween_property(self,"position", self.position - Vector2(700.0, 0.0), movement_timer).set_trans(Tween.TRANS_SINE)
	else: # go right 500
		tween.tween_property(self,"position", self.position + Vector2(700.0, 0.0), movement_timer).set_trans(Tween.TRANS_SINE)
	await get_tree().create_timer(movement_timer + buffer_timer).timeout
	
	#print("cycle count: " + str(cycle_count))
	#print("players array size: " + str(Globals.players.size()))
	
	if cycle_count < Globals.players.size():
		for i in range(0,4):
			#print("i: " + str(i))
			AttackSpawner.spawn_pointBlank(Globals.players[cycle_count].position, 200.0, 2.0, 1.0, get_tree().root)
			await get_tree().create_timer(0.5).timeout
			i += 1
		cycle_count += 1
		$AttackTimer.start(2.5)
	else:
		AttackSpawner.spawn_pointBlank(Vector2(0.0, 0.0), 250.0, 3.0, 1.0, self)
		cycle_count += 1
		$AttackTimer.start(4.5)
	
	
