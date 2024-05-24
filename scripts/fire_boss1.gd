extends "res://scripts/boss.gd"

var cycle_count: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var tween = create_tween()
	tween.tween_property(self,"position", Vector2(500.0, 250.0), 1.0).set_trans(Tween.TRANS_SINE)
	
	Globals.update_room.emit("fire_boss1")
	
	$AttackTimer.start(1.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# This boss spawns a point blank aoe 
# under each player in order and then under themselves, in a loop
func _on_attack_timer_timeout():
	if cycle_count < Globals.players.size():
		AttackSpawner.spawn_pointBlank(Globals.players[cycle_count].position, 100.0, 3.0, 1.0)
		cycle_count += 1
	else:
		AttackSpawner.spawn_pointBlank(self.position, 200.0, 3.0, 1.0)
		cycle_count = 0
	
	$AttackTimer.start(3.0)
	
