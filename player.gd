extends CharacterBody3D

@onready var neck = $neck
@onready var head = $neck/head
@onready var standing_collision_shape = $standing_collision_shape
@onready var crouching_collision_shape = $crouching_collision_shape
@onready var ray_cast_3d = $RayCast3D

var current_speed = 5.0
const WALKING_SPEED = 5.0
const SPRINTING_SPEED = 8.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.30
const CROUCHING_SPEED = 2.5
const CROUCH_DEPTH = -0.5
#const PRONE_SPEED = 1.0
#const PRONE_DEPTH = 0.1

#player states 
var walking = false
var sprinting = false 
var crouching = false 
var free_looking = false 
var sliding = false 
#var prone = false

#lerp_speed effects how snappy the speed and movement is, can be removed to make movement more snappy 
var lerp_speed = 10.0
var direction = Vector3.ZERO

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion: 
		if free_looking:
			neck.rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		else:
			rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
			head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))
			head.rotation.x = clamp(head.rotation.x,deg_to_rad(-89),deg_to_rad(89))
func _physics_process(delta):
	#crouching functionality, includes speed and depth reduction
	if Input.is_action_pressed("crouch"):
		current_speed = CROUCHING_SPEED
		head.position.y = lerp(head.position.y,CROUCH_DEPTH, delta * lerp_speed)
		standing_collision_shape.disabled = true
		crouching_collision_shape.disabled = false
		
		walking = false
		sprinting = false 
		crouching = true
		
	elif !ray_cast_3d.is_colliding():
		crouching_collision_shape.disabled = true
		standing_collision_shape.disabled = false
		head.position.y = lerp(head.position.y, 0.0, delta * lerp_speed)
	#prone functionality
	#if Input.is_action_pressed("prone"):
	#	current_speed = PRONE_SPEED
	#	head.position.y = PRONE_DEPTH
	#else: 
	#	head.position.y = 1.8
	
	#sprinting fucntionality, current speed in increased when the button maps to sprint is pressed
	if Input.is_action_pressed("sprint"):
		current_speed = SPRINTING_SPEED
		walking = false
		sprinting = true
		crouching = false
	else: 
		current_speed = WALKING_SPEED
		walking = true
		sprinting = false 
		crouching = false
		
	#free looking functionality 
	if Input.is_action_pressed("free_look"): 
		free_looking = true
	else:
		free_looking = false
		neck.rotation.y = lerp(neck.rotation.y, 0.0, delta * lerp_speed)
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
