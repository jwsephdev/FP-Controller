class_name Player extends CharacterBody3D
@onready var head = $Head
@onready var camera = $Head/Camera3D


const SPEED = 5.0
const JUMP_VELOCITY = 3.5

var sens = 0.05
var gravity = 9.8

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func MouseMove(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x) * sens)
		camera.rotate_x(deg_to_rad( -event.relative.y) * sens)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))
func _input(event):
	MouseMove(event)
	
	
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta


	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY


	var input_dir = Input.get_vector("A", "D", "W", "S")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
