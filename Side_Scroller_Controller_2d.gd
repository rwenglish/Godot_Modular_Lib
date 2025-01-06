extends CharacterBody2D


const WALKING_SPEED = 300.0
const SPRINTING_SPEED = 650.0
const JUMP_VELOCITY = -600.0
const MAX_JUMP_COUNT = 2 
const COUCH_HEIGHT = 0.5 

var jump_count = 0

#player states 
var walking = false 
var sprinting = false 
var crouching = false 

@onready var animated_sprite_2d = $AnimatedSprite2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta):


	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump includes double jump functionality
	if jump_count < MAX_JUMP_COUNT and Input.is_action_just_pressed("jump"):
		animated_sprite_2d.play("jump")
		velocity.y = JUMP_VELOCITY
		jump_count += 1
	elif is_on_floor(): 
			animated_sprite_2d.play("on_ground")
			jump_count = 0

	#crouching function
	if Input.is_action_pressed("crouch"):
		animated_sprite_2d.play("crouch")
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("left", "right")

	# Add the gravity.
	if direction:
		velocity.x = direction * WALKING_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, WALKING_SPEED)
	if Input.is_action_pressed("sprint"): 
		velocity.x = direction * SPRINTING_SPEED
		walking = false 
		crouching = false 
		sprinting = true 
	else: 
		velocity.x = direction * WALKING_SPEED
		walking = true
		crouching = false 
		sprinting = false
	#handle audio 
	if $AudioStreamPlayer.playing == false:
		$AudioStreamPlayer.play()
	move_and_slide()
