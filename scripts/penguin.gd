extends KinematicBody

const GRAVITY = -100
var vel = Vector3()
const MAX_SPEED = 30
const JUMP_SPEED = 40
const ACCEL = 4.5

var dir = Vector3()

const DEACCEL= 2.5
const AIR_DEACCEL = 0.1
const MAX_SLOPE_ANGLE = 40

const ANIMATION_SCALE = 3

func _physics_process(delta):
	process_input()
	process_movement(delta)
	process_animation()

func process_input():

	# ----------------------------------
	# Walking
	dir = Vector3()

	var input_movement_vector = Vector3()

	if Input.is_action_pressed("movement_forward"):
		input_movement_vector.z -= 1
	if Input.is_action_pressed("movement_backward"):
		input_movement_vector.z += 1
	if Input.is_action_pressed("movement_left"):
		input_movement_vector.x -= 1
	if Input.is_action_pressed("movement_right"):
		input_movement_vector.x += 1

	input_movement_vector = input_movement_vector.normalized()
	if input_movement_vector.length() > 0:
		look_at(global_transform.origin + input_movement_vector, Vector3.UP)

	# Basis vectors are already normalized.
	dir += input_movement_vector
	# ----------------------------------

	# ----------------------------------
	# Jumping
	if is_on_floor():
		if Input.is_action_just_pressed("movement_jump"):
			vel.y = JUMP_SPEED
	# ----------------------------------

	# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# ----------------------------------

func process_movement(delta):
	vel.y += delta * GRAVITY
	
	var hvel = vel
	hvel.y = 0

	if !is_on_floor():
		hvel = hvel.linear_interpolate(Vector3.ZERO, AIR_DEACCEL * delta)
		vel.x = hvel.x
		vel.z = hvel.z
		vel = move_and_slide(vel, Vector3.UP, 0.05, 4, deg2rad(MAX_SLOPE_ANGLE), false)
		return

	dir.y = 0
	dir = dir.normalized()

	var target = dir
	target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:
		accel = ACCEL
	else:
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3.UP, 0.05, 4, deg2rad(MAX_SLOPE_ANGLE), false)

func process_animation():
	if dir.length() > 0:
		$penguin/AnimationPlayer.play("walk")
	else:
		$penguin/AnimationPlayer.stop()

	var hvel = vel
	hvel.y = 0
	$penguin/AnimationPlayer.set_speed_scale((ANIMATION_SCALE * hvel.length() / MAX_SPEED) + 1)
