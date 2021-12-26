# Code by Guillaume Roy, 2019
# A basic 3rd person camera. No input interaction (except for the mouse) is implemented for now.
# The origin variable is the point around which the camera turns, while the dist is the distance between the camera and this point

extends Camera

export (bool) var movEnabled = true
export (float) var mouseSensitivity = 0.1

var yaw : float = 0.0
var pitch : float = 0.0
var origin : Vector3 = Vector3()
var dist : float = 20.0

onready var player = get_node("/root/Spatial/Player")

func _ready():
	yaw = -1.5
	pitch = -1.0
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(_delta):
	origin = player.global_transform.origin
	self.set_translation(origin - dist * self.project_ray_normal(get_viewport().get_visible_rect().size * 0.5))
	
func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event is InputEventMouseMotion and movEnabled:
		var mouseVec : Vector2 = event.get_relative()
		
		yaw = fmod(yaw  - mouseVec.x * mouseSensitivity , 360.0)
		pitch = max(min(pitch - mouseVec.y * mouseSensitivity , 90.0), -90.0)
		
		self.set_rotation(Vector3(deg2rad(pitch), deg2rad(yaw), 0.0))
		self.set_translation(origin - dist * self.project_ray_normal(get_viewport().get_visible_rect().size * 0.5))
		
func get_center_ray_normal():
	#This function returns the normal vector at the center of the screen. 
	#In many games this vector is used to guide the player relative to the camera
	return self.project_ray_normal(get_viewport().get_visible_rect().size * 0.5)
