extends MultiplayerSynchronizer

@export var direction := Vector2()

@export var attack1 := false
@export var attack2 := false
@export var attack3 := false
@export var defensive := false

@onready var player = get_parent()

signal toggle_tight(state)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Only process for the local player.
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

@rpc("call_local")
func set_attack1_state(state):
	attack1 = state

@rpc("call_local")
func set_attack2_state(state):
	attack2 = state

@rpc("call_local")
func set_attack3_state(state):
	attack3 = state
	
@rpc("call_local")
func set_defensive_state(state):
	defensive = state

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	direction.x = Input.get_axis("left", "right")
	direction.y = Input.get_axis("up", "down")
	
	if Input.is_action_pressed("attack_1"):
		set_attack1_state.rpc(true)
	else:
		set_attack1_state.rpc(false)
	
	if Input.is_action_pressed("attack_2"):
		set_attack2_state.rpc(true)
	else:
		set_attack2_state.rpc(false)
		
	if Input.is_action_pressed("attack_3"):
		set_attack3_state.rpc(true)
	else:
		set_attack3_state.rpc(false)
	
	if Input.is_action_pressed("defensive"):
		set_defensive_state.rpc(true)
	else:
		set_defensive_state.rpc(false)

func _input(event):
	if event.is_action_pressed("shift"):
		toggle_tight.emit(true)
	if event.is_action_released("shift"):
		toggle_tight.emit(false)
		Globals.iterate_target.emit()
	if event.is_action_pressed("select"):
		Globals.player_select.emit(player.player_array_id)
