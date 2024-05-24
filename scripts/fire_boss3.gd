extends "res://scripts/boss.gd"

var cycle_count: int = 0

@export var nail_node: PackedScene

# Called from superclass's ready function.
# Used to add to the ready function instead of overload/replace it
func setup():
	var tween = create_tween()
	tween.tween_property(self, "position", Vector2(550.0, 335.0), 1.0).set_trans(Tween.TRANS_SINE)
	
	$AttackTimer.start(2.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


# This boss spawns two "nail"s at set spots in the room
# The "nail"s are also a boss that spawn a very large point blank aoe 
# with a long warmup time unless it is killed first
func _on_attack_timer_timeout():
	var nail1 = nail_node.instantiate()
	nail1.position = Vector2(-450, 0)
	nail1.aoe_size = 1200.0
	nail1. aoe_timer = 15.0
	nail1.aoe_linger = 0.1
	
	var nail2 = nail_node.instantiate()
	nail2.position = Vector2(450, 0)
	nail2.aoe_size = 1200.0
	nail2. aoe_timer = 15.0
	nail2.aoe_linger = 0.1
	
	self.call_deferred("add_child", nail1)
	self.call_deferred("add_child", nail2)
	Globals.bosses.append(nail1)
	Globals.bosses.append(nail2)
	
	$AttackTimer.start(20.0)
	
	
