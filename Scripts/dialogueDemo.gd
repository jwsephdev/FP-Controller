extends StaticBody3D

@onready var anims: AnimationPlayer = $"../anims"
@onready var interaction_area: Area3D = $"../interactionArea"
var target :CharacterBody3D

func interaction():
	if Input.is_action_just_pressed("Interact"):
		anims.play("open")
		interaction_area.monitoring = true
		await get_tree().create_timer(0.1).timeout
	
	if target != null:
		var target_position = target.global_transform.origin
		target_position.y = global_transform.origin.y # Match Y-coordinates
		get_parent().look_at(target_position, Vector3.UP)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body:
		if body is Player:
			anims.play("RESET")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		target = body
