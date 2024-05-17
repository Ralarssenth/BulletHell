extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.boss_damaged.connect(update_boss_healthbar)


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
