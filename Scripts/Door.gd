extends CSGBox3D
@onready var doorbuttonanims: AnimationPlayer = $"../Doorbuttonanims"




var is_open = false

func interaction():
	
	if Input.is_action_just_pressed("Interact") and !is_open:
		is_open = true
		await get_tree().create_timer(0.1).timeout
		
	if Input.is_action_just_pressed("Interact") and is_open:
		is_open = false
		await get_tree().create_timer(0.1).timeout
	
	if is_open:
		doorbuttonanims.play("open")
	if !is_open:
		doorbuttonanims.play("close")
