extends CharacterBody3D

@onready var body := $"."
@onready var camera := $head/Camera3D
@onready var hitbox := $CollisionShape3D

const default_speed = 3
const sprint_speed = 10
var SPEED = default_speed
const JUMP_VELOCITY = 7

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			body.rotate_y(-event.relative.x * 0.005)
			camera.rotate_x(-event.relative.y * 0.005)
			camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-30), deg_to_rad(60))


func _physics_process(delta):
	
	var input_dir = Input.get_vector("ui_right", "ui_left", "ui_down", "ui_up")
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	if Input.is_action_pressed("sprint") && input_dir.y == 1:
		SPEED = sprint_speed
	if Input.is_action_just_released("sprint"):
		SPEED = default_speed
	if Input.is_action_just_pressed("crouch"):
		#camera.set_position(Vector3(0,0.5,0))
		hitbox.set_scale(Vector3(0,0.5,0))
		SPEED = 2.5
	if Input.is_action_just_released("crouch"):
		#camera.set_position(Vector3(0,1,0))
		hitbox.set_scale(Vector3(0,1,0))
		SPEED = default_speed

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	$AnimationTree.set("parameters/conditions/idle",input_dir == Vector2.ZERO && is_on_floor())
	$AnimationTree.set("parameters/conditions/walk",input_dir.y == 1 && is_on_floor())
	$AnimationTree.set("parameters/conditions/backwalk",input_dir.y == -1 && is_on_floor())
	$AnimationTree.set("parameters/conditions/sprint",input_dir.y == 1  && Input.is_action_pressed("sprint") && is_on_floor())
	$AnimationTree.set("parameters/conditions/backwalk",input_dir.y == -1 && is_on_floor())
	$AnimationTree.set("parameters/conditions/falling",!is_on_floor())
	$AnimationTree.set("parameters/conditions/landed",is_on_floor())
	$AnimationTree.set("parameters/conditions/left",input_dir.x == 1 && is_on_floor())
	$AnimationTree.set("parameters/conditions/right",input_dir.x == -1 && is_on_floor())
	
	
	
	velocity.normalized()
	move_and_slide()
