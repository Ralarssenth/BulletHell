extends Area2D

var max_health = 100.0
var current_health = 100.0

var players = []

var is_targeted: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.target_boss.connect(targeted)
	
	$CollisionShape2D/TextureProgressBar.max_value = max_health
	$CollisionShape2D/TextureProgressBar.value = current_health
	players = get_tree().get_nodes_in_group("player")
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
	
	if is_targeted:
		Globals.emit_signal("boss_damaged", current_health, max_health)
	
	if current_health <= 0:
		queue_free()


func targeted(peer_id, boss, on):
	if boss != self:
		return
		
	# Execute on the client side of the calling player
	if multiplayer.get_unique_id() == peer_id:
		is_targeted = on
	# Set the color based on the player
	for player in players:
		if player.player == peer_id:
			$BossSprite2D/TargetCircle.set_modulate(player.color)
	$BossSprite2D/TargetCircle.set_visible(on)
	if on:
		$AnimationPlayer.play("targeted")
	else:
		$AnimationPlayer.stop()


func _on_tree_exiting():
	Globals.bosses.erase(self)
	print("size of boss array now: " + str(Globals.bosses.size()))
