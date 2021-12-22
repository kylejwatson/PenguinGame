extends Area

onready var twist_joint = get_node("/root/Spatial/Player/ConeTwistJoint")

func _on_DeathBarrier_body_entered(node):
	if node.has_meta('respawn_point'):
		if twist_joint.get_node_a() == node.get_path() || twist_joint.get_node_b() == node.get_path():
			twist_joint.set_node_a(NodePath(""))
			twist_joint.set_node_b(NodePath(""))
		node.set_mode(RigidBody.MODE_KINEMATIC)
		node.transform.origin = node.get_meta('respawn_point')
		node.set_mode(RigidBody.MODE_RIGID)
