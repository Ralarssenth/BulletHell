extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.update_room.emit("waiting_room")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


