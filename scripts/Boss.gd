extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_area_entered(area):
	if area.is_in_group("player_hitbox"):
		damaged()
	if area.is_in_group("player_bullet"):
		area.hit_target()


func damaged():
	print("boss damaged")
