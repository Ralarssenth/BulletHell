extends Area2D

var max_health = 100.0
var current_health = 100.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _on_area_entered(area):
	if area.is_in_group("player_hitbox"):
		damaged(area.damage_amount)
	if area.is_in_group("player_bullet"):
		area.hit_target()


func damaged(_amount):
	print("boss damaged")
	current_health -= _amount
	Globals.emit_signal("boss_damaged", current_health, max_health)
	
	if current_health <= 0:
		queue_free()


func targeted(on):
	$BossSprite2D/TargetCircle.set_visible(on)
