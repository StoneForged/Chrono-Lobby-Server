extends Node


# Called when the node enters the scene tree for the first time.
func _ready():
	OS.create_process("C:/Users/BW201/Documents/CHRONOCCG_Server/CHRONOCCG_Server.exe", [8000])
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
