extends StaticBody3D
@onready var dialogueanims: AnimationPlayer = $"../dialogueanims"
@onready var area_3d: Area3D = $"../Area3D"
@onready var character: Node3D = $".."

var target

func interaction():
	
	if Input.is_action_just_pressed("Interact"):
		dialogueanims.play("open")
		area_3d.monitoring = true
		await get_tree().create_timer(0.1).timeout
	
	if target != null:
		var target_position = target.global_transform.origin
		target_position.y = global_transform.origin.y # Match Y-coordinates
		character.look_at(target_position, Vector3.UP)
	

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		dialogueanims.play("RESET")
		area_3d.monitoring = false


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		target = body
