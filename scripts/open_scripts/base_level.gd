extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var debug_panel = $Camera3D/DebugPanel
	
	debug_panel.setup_parameters({
		"Cube Y Position": Callable($Cube, "get_y_position")
	})


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
