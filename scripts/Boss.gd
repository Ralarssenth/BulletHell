extends Area2D

var max_health = 100.0
var current_health = 100.0

# Called when the node enters the scene tree for the first time.
func _ready():
	$CollisionShape2D/TextureProgressBar.max_value = max_health
	$CollisionShape2D/TextureProgressBar.value = current_health
	setup()

func setup():
	pass # overload this to add to the ready function

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
		queue_free()


func targeted(on):
	$BossSprite2D/TargetCircle.set_visible(on)
	if on:
		$AnimationPlayer.play("targeted")
	else:
		$AnimationPlayer.stop()


func _on_tree_exiting():
	Globals.bosses.erase(self)
	print("size of boss array now: " + str(Globals.bosses.size()))
