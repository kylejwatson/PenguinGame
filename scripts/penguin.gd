extends RigidBody

const MAX_SPEED = 30
const JUMP_SPEED = 800
const ACCEL = 50

var dir = Vector3()

const ANIMATION_SCALE = 3

const TURN_SCALE = 10

onready var camera = get_viewport().get_camera()

func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	process_grab()
	process_animation()


func process_grab():
	if Input.is_action_pressed("action_grab") && $ConeTwistJoint.get_node_b().is_empty():
		var bodies = $Hands.get_overlapping_bodies()
		if bodies.size() == 0:
			return
		$ConeTwistJoint.set_node_a(get_path())
		$ConeTwistJoint.set_node_b(bodies[0].get_path())
	elif Input.is_action_just_released("action_grab"):
		$ConeTwistJoint.set_node_a(NodePath(""))
		$ConeTwistJoint.set_node_b(NodePath(""))

		
func look_follow(state, current_transform, target_dir):
	var cur_dir = current_transform.basis.xform(Vector3(0, 0, 1))
	var rotation_angle = signed_angle_to(cur_dir, target_dir, Vector3.UP)

	state.set_angular_velocity( Vector3.UP * (rotation_angle / state.get_step()) / TURN_SCALE)

func signed_angle_to(vec_from, vec_to, axis):
	var cross_to = vec_from.cross(vec_to);
	var unsigned_angle = atan2(cross_to.length(), vec_from.dot(vec_to))
	var sign_to = cross_to.dot(axis)

	return  -unsigned_angle if (sign_to < 0) else unsigned_angle

func _integrate_forces(state):
	look_follow(state, get_global_transform(), dir)

func process_input(_delta):
	dir = Vector3()

	if Input.is_action_pressed("movement_forward"):
		dir.z -= 1
	if Input.is_action_pressed("movement_backward"):
		dir.z += 1
	if Input.is_action_pressed("movement_left"):
		dir.x -= 1
	if Input.is_action_pressed("movement_right"):
		dir.x += 1

	dir = dir.normalized()

	dir = camera.global_transform.basis.xform(dir)
	dir.y = 0
	dir = dir.normalized()
		
	if is_on_floor() && Input.is_action_just_pressed("movement_jump"):
		add_central_force (Vector3.UP * JUMP_SPEED)

func is_on_floor():
	return $RayCast.is_colliding()

func process_movement(_delta):
	if !is_on_floor():
		return

	if get_linear_velocity().length() < MAX_SPEED:
		add_central_force (dir * ACCEL)
		
func process_animation():
	if dir.length() > 0:
		$penguin_rotator/penguin/AnimationPlayer.play("walk")
	else:
		$penguin_rotator/penguin/AnimationPlayer.stop()

	var hvel = get_linear_velocity()
	hvel.y = 0
	$penguin_rotator/penguin/AnimationPlayer.set_speed_scale((ANIMATION_SCALE * hvel.length() / MAX_SPEED) + 1)
