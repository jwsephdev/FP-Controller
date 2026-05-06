class_name Player extends CharacterBody3D

# @JwsephDev on Github/Itch.io/Youtube

@onready var head = $Head
@onready var crouch_check_ray: RayCast3D = $CrouchCheckCast
@onready var camera: Camera3D = $Head/neck/Camera
@onready var neck: Node3D = $Head/neck
@onready var interactray: RayCast3D = $Head/neck/Camera/Rays/InteractRay
@onready var player_collision: CollisionShape3D = $player_collision

@export_category("FP-Controller")

@export_subgroup("camera")
@export var sensitivity = 0.2
@export var FOV = 75
@export var head_lean :bool = true
@export var leanDepth: float = 0.04
@export var leanSpeed: float = 8.0

@export_subgroup("crouching")
@export var crouching :bool = true
@export var crouch_transition_speed:float=10.0
@export var standing_size :float= 2.0
@export var standing_headpos:float=0.7
@export var crouching_headpos:float=0.3
@export var crouching_size :float= 1.2

@export_subgroup("movement")
@export var directional_lerp_speed = 10.0
@export var speed_current :float
@export var crouch_speed = 3.0
@export var walk_speed = 6.0
@export var JUMP_VELOCITY = 4.8
var input_dir
var direction = Vector3.ZERO
@export var gravity = 9.8

@export_subgroup("Object Interaction")
@export var Objectinteraction:bool = true

# ------------------------------

func crouch(delta):
	if Input.is_action_pressed("crouch"):
		player_collision.shape.height = lerp(player_collision.shape.height,crouching_size,delta*crouch_transition_speed)
		head.position.y = lerp(head.position.y,crouching_headpos, delta*crouch_transition_speed)
		if is_on_floor():
			speed_current = crouch_speed
	elif !Input.is_action_pressed("crouch") and !crouch_check_ray.is_colliding():
		player_collision.shape.height = lerp(player_collision.shape.height,standing_size,delta*crouch_transition_speed)
		head.position.y = lerp(head.position.y,standing_headpos, delta*crouch_transition_speed)
		speed_current = walk_speed

func objInteraction():
	var object = interactray.get_collider()
	if interactray.is_colliding():
		if Input.is_action_just_pressed("Interact"):
			if object.is_in_group("interact"):
				object.interaction()

func mouseMovent(event):
	if event is InputEventMouseMotion:
		head.rotate_y(deg_to_rad(-event.relative.x) * sensitivity)
		camera.rotate_x(deg_to_rad( -event.relative.y) * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func camera_tilt(input_x, delta):
	neck.rotation.z = lerp(neck.rotation.z, -input_x * leanDepth, leanSpeed * delta)

# ------------------------------

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.fov = FOV

func _input(event):
	mouseMovent(event)

func _process(delta: float) -> void:
	if Objectinteraction:
		objInteraction()
	if crouching:
		crouch(delta)
	if head_lean:
		camera_tilt(input_dir.x , delta)

func _physics_process(delta):
	input_dir = Input.get_vector("left", "right", "forward", "backward")
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity = direction * 4.5
		velocity.y = JUMP_VELOCITY
		move_and_slide()
		
	direction = lerp(direction,(head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*directional_lerp_speed)
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
