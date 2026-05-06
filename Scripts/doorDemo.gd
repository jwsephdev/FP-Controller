extends CSGBox3D

@onready var anims: AnimationPlayer = $"../../anims"

var is_open:bool = false

func interaction():
	if !anims.is_playing():
		if Input.is_action_just_pressed("Interact") and !is_open:
			is_open = true
			await get_tree().create_timer(0.1).timeout
			
		if Input.is_action_just_pressed("Interact") and is_open:
			is_open = false
			await get_tree().create_timer(0.1).timeout
		if is_open:
			anims.play("open")
		if !is_open:
			anims.play("close")
	
