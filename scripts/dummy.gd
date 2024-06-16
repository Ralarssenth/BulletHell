extends Area2D

var max_health = 100.0
var current_health = 100.0

var dps:float
var dps_health:float
var dps_remainder:float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(990.0, 550.0)
	
	Globals.bosses.append(self) # Fill the bosses array
	
	$CollisionShape2D/TextureProgressBar.max_value = max_health
	$CollisionShape2D/TextureProgressBar.value = current_health
	dps_health = max_health


func _on_area_entered(area):
	if area.is_in_group("player_hitbox"):
		damaged(area.damage_amount)
	if area.is_in_group("player_bullet"):
		area.hit_target()


func damaged(_amount):
	print("boss damaged")
	current_health -= _amount
	$CollisionShape2D/TextureProgressBar.value = current_health
	Globals.emit_signal("boss_damaged", current_health, max_health)
	
	if current_health <= 0:
		dps_remainder = (dps_health - current_health) / 5.0
		dps_health = max_health
		
		current_health = max_health
		$CollisionShape2D/TextureProgressBar.value = current_health
	

func targeted(on):
	$BossSprite2D/TargetCircle.set_visible(on)
	if on:
		$AnimationPlayer.play("targeted")
	else:
		$AnimationPlayer.stop()


func _on_dps_timer_timeout():
	dps = (dps_health - current_health) / (5.0)
	dps_health = current_health
	
	if dps_remainder != 0.0:
		dps += dps_remainder
		dps_remainder = 0.0
		
	$DPSLabel.text = "DPS: " + str(dps)


func _on_tree_exiting():
	Globals.bosses.erase(self)
	print("size of boss array now: " + str(Globals.bosses.size()))
