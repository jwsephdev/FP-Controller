extends Node3D
@onready var gunpos: Node3D = $"../Head/neck/Camera/gunpos"
var gunsway = 50.0

func _process(delta: float) -> void:
	global_transform = global_transform.interpolate_with(gunpos.global_transform, 40  * delta)
