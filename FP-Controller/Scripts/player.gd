class_name Player extends CharacterBody3D

# ---- node references ----
#Camera Nodes
@onready var head = $Head
@onready var camera: Camera3D = $Head/Neck/Camera
@onready var neck: Node3D = $Head/Neck

#Crouching Nodes
@onready var crouching_col: CollisionShape3D = $Crouching_col
@onready var standing_col: CollisionShape3D = $Standing_col
@onready var crouch_check_ray: RayCast3D = $crouchCheckRay

#Interact Nodes
@onready var interactray: RayCast3D = $Head/Neck/Camera/Rays/InteractRay

# ---- variables -----

#SPEEDS
@export var player_speed = 10.0

#CAMERA SENSITIVITY
@export var cameraSensitivity = 0.2
@export var cameraFOV = 75.0

#Headleaning
@export var leftLeanDepth: float = 0.08
@export var rightLeanDepth: float = -0.08
@export var LeanSpeed: float = 2.0

var leanState

enum {
	leftLean,
	rightLean,
	idleLean,
}

#PLAYER GRAVITY
var gravity = 9.8

#STATE TRANSITION SPEED
var lerp_speed = 10.0

#MOVEMENT VARIABLES
var direction = Vector3.ZERO
const JUMP_VELOCITY = 4.5

#CROUCH VARIABLES
@export var CrouchHeadSpeed: int = 10
@export var crouch_depth = -0.8
var crouchState

enum {
	is_crouching,
	not_crouching,
}

# ---- bruh momment ----

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.fov = cameraFOV


func headLean(delta):
	
	if Input.is_action_pressed("left") and is_on_floor():
		leanState = leftLean
	elif Input.is_action_pressed("right") and is_on_floor():
		leanState = rightLean
	else:
		leanState = idleLean
	
	match leanState:
		leftLean:
			neck.rotation.z = lerp(neck.rotation.z, leftLeanDepth, delta * LeanSpeed)
		rightLean:
			neck.rotation.z = lerp(neck.rotation.z, rightLeanDepth, delta * LeanSpeed)
		idleLean:
			neck.rotation.z = lerp(neck.rotation.z, 0.0, delta * LeanSpeed)


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

func mouseMovement(event):
	if event is InputEventMouseMotion:
		head.rotate_y(deg_to_rad(-event.relative.x) * cameraSensitivity)
		camera.rotate_x(deg_to_rad( -event.relative.y) * cameraSensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func _input(event):
	mouseMovement(event)


func _process(delta: float) -> void:
	objectInteraction()
	headLean(delta)
	crouchSystem(delta)

func _physics_process(delta):

	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction,(head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*lerp_speed)
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * player_speed
			velocity.z = direction.z * player_speed
		else:
			velocity.x = move_toward(velocity.x, 0, player_speed)
			velocity.z = move_toward(velocity.z, 0, player_speed)
	else:
		velocity.x = lerp(velocity.x, direction.x * player_speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * player_speed, delta * 3.0)
		
	move_and_slide()
