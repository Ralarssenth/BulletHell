extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func _on_area_entered(area):
	if area.is_in_group("player_hitbox"):
		damaged()
	if area.is_in_group("player_bullet"):
		area.hit_target()


func damaged():
	print("boss damaged")


func targeted(on):
	$Sprite2D/TargetCircle.set_visible(on)
