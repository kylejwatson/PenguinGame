extends Spatial

var score = 0

func add_points(points):
	score += points
	$MarginContainer/HBoxContainer/ScoreNumber.text = str(score)

func _on_Goal_body_entered(node):
	if node.is_in_group('Reward'):
		add_points(100)
		node.queue_free()
