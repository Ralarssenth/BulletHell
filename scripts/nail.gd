extends "res://scripts/boss.gd"

var aoe_size:float = 500.0
var aoe_timer:float = 10.0
var aoe_linger:float = 0.1

# Called from superclass's ready function.
# Used to add to the ready function instead of overload/replace it
func setup():
	max_health = 25
	current_health = max_health
	
	$CastProgressBar.value = 0.0
	$CastProgressBar.max_value = aoe_timer
	AttackSpawner.spawn_pointBlank(self.position, aoe_size, aoe_timer, aoe_linger, self)
	var tween = create_tween()
	tween.tween_property($CastProgressBar, "value", $CastProgressBar.max_value, aoe_timer)
	await get_tree().create_timer(aoe_timer + (2*aoe_linger)).timeout
	queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


