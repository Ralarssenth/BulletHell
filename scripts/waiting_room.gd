extends Node2D

var current_target
var next_target

# Called when the node enters the scene tree for the first time.
func _ready():
	$Player.connect("changed_target", update_player_target)
	current_target = $Player.current_target
	update_player_target(current_target)
	$HUD.update_boss_healthbar(current_target.current_health, current_target.max_health)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func update_player_target(_target):
	next_target = _target
	
	if next_target != $Player: #check for self targeting (no boss present)
		next_target.targeted(true) #always target the new target
		if current_target != next_target:#only change if target is different
			if current_target: #check if current target exists before changing sprite
				current_target.targeted(false)
				print(str(current_target) + ": untargeted")
				
			current_target = next_target #set new current target
			print(str(current_target) + ": targeted")
			$HUD.update_boss_healthbar(current_target.current_health, current_target.max_health)
			
		else:
			print("same target")
	else:
		print("Player targeted")
