class_name Player extends CharacterBody3D

@onready var head = $Head
@onready var crouching_col: CollisionShape3D = $Crouching_col
@onready var standing_col: CollisionShape3D = $Standing_col
@onready var crouch_check_ray: RayCast3D = $CrouchCheckCast
@onready var camera: Camera3D = $Head/neck/Camera
@onready var neck: Node3D = $Head/neck
@onready var interactray: RayCast3D = $Head/neck/Camera/Rays/InteractRay
@onready var hand: Marker3D = $Head/neck/Camera/Rays/InteractRay/Hand


#SPEEDS
var speed_current = 6.0
var crouch_Speed = 3.0
var walk_speed = 6.0

#CAMERA SENSITIVITY
@export var sens = 0.2
@export var FOV = 75

#PLAYER GRAVITY
var gravity = 9.8
#STATE TRANSITION SPEED
var lerp_speed = 10.0

#MOVEMENT VARIABLES
var direction = Vector3.ZERO
const JUMP_VELOCITY = 4.5
var input_dir

#Headleaning
@export var LeanDepth: float = 0.04
@export var LeanSpeed: float = 8.0

#CROUCH VARIABLES
@export var CrouchHeadSpeed: int = 10
@export var crouch_depth = -0.8
var crouchState

enum {
	is_crouching,
	not_crouching,
}

# ------ 

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.fov = FOV

func camera_tilt(input_x, delta):
	neck.rotation.z = lerp(neck.rotation.z, -input_x * LeanDepth, LeanSpeed * delta)

func crouchSystem(delta):
	if Input.is_action_pressed("crouch"):
		crouchState = is_crouching
		
	elif !crouch_check_ray.is_colliding():
		crouchState = not_crouching
		
	match crouchState:
		is_crouching:
			head.position.y = lerp(head.position.y, 0.5 + crouch_depth, delta*CrouchHeadSpeed)
			standing_col.disabled = true
			crouching_col.disabled = false
			
		not_crouching:
			standing_col.disabled = false
			crouching_col.disabled = true
			head.position.y = lerp(head.position.y, 0.5, delta*15)
	

func objectInteraction():
	var object = interactray.get_collider()
	
	if interactray.is_colliding():
		if Input.is_action_just_pressed("Interact"):
			if object.is_in_group("interact"):
				object.interaction()

func mouseMovent(event):
	if event is InputEventMouseMotion:
		head.rotate_y(deg_to_rad(-event.relative.x) * sens)
		camera.rotate_x(deg_to_rad( -event.relative.y) * sens)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _input(event):
	mouseMovent(event)

func _process(delta: float) -> void:
	objectInteraction()
	crouchSystem(delta)
	camera_tilt(input_dir.x , delta)

func _physics_process(delta):

	input_dir = Input.get_vector("left", "right", "forward", "backward")
	if not is_on_floor():
		velocity.y -= gravity * delta
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	direction = lerp(direction,(head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*lerp_speed)
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed_current
			velocity.z = direction.z * speed_current
		else:
			velocity.x = move_toward(velocity.x, 0, speed_current)
			velocity.z = move_toward(velocity.z, 0, speed_current)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed_current, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed_current, delta * 3.0)
	
	move_and_slide()
