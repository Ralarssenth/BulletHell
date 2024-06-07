extends CanvasLayer

@onready var player_healthbars = [$Healthbar, $Healthbar2, $Healthbar3, $Healthbar4]

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.boss_damaged.connect(update_boss_healthbar)
	Globals.players_changed.connect(_on_player_count_updated)
	for i in range(player_healthbars.size()):
		player_healthbars[i].player = i
		i += 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func update_boss_healthbar(_value, _max):
	$BossProgressBar.value = _value
	$BossProgressBar.max_value = _max
	if _value <= 0:
		$BossProgressBar.set_visible(false)
	else:
		$BossProgressBar.set_visible(true)

func hide_boss_healthbar():
	$BossProgressBar.set_visible(false)

func _on_player_count_updated():
	for bar in player_healthbars:
		bar.set_visible(false)
	for i in range(Globals.players.size()):
		player_healthbars[i].set_visible(true)

