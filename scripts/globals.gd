extends Node

const BOSS_START_SPOT = Vector2(2250, 650)

var players = []
var bosses = []
var current_route: String = ""
var next_route: String = ""

signal player_damaged
signal player_healed
signal player_died
signal update_player_target
signal boss_damaged(current_health, max_health)

#Steam vars
var steam_id: int = 0
var steam_username: String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	initialize_steam()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Steam.run_callbacks()

func initialize_steam():
	var initialize_response: Dictionary = Steam.steamInitEx()
	print("Did Steam initialize?: %s " % initialize_response)
	
#	status
#0 - Successfully initialized
#1 - Some other failure
#2 - We cannot connect to Steam, steam probably isn't running
#3 - Steam client appears to be out of date
	
	if initialize_response['status'] > 0:
		print("Failed to initialize Steam, shutting down: %s" % initialize_response)
		get_tree().quit()
	
	# Gather additional data
	steam_id = Steam.getSteamID()
	steam_username = Steam.getPersonaName()
	print("logged in to steam as: " + steam_username)
