extends Node2D

var player_id: int

const MAX_HEALTH:int = 4
@export var current_health:int = 4

@onready var pips = [$HealthPip, $HealthPip2, $HealthPip3, $HealthPip4]

var head_sprites = {
	"default": load("res://assets/player/head.png"), 
	"red": load("res://assets/player/head_red.png")
}

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.player_damaged.connect(_on_player_damaged)
	Globals.player_healed.connect(_on_player_healed)
	Globals.set_player_color.connect(_on_player_color_changed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func update_pips():
	for i in range(pips.size()):
		if i >= current_health:
			pips[i].set_visible(false)
		else:
			pips[i].set_visible(true)
		


func _on_player_damaged(_player_id):
	if player_id == _player_id:
		current_health -= 1
		update_pips()
		if current_health <= 0:
			emit_signal("player_died")
	


func _on_player_healed(_player_id):
	if player_id == _player_id:
		current_health = MAX_HEALTH
		update_pips()

func _on_player_color_changed(peer_id, color):
	# Translate peer_id into array_id
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		if p.player == peer_id:
			var array_id = p.player_array_id
			if player_id == array_id:
				$Head.set_texture(head_sprites[color])


