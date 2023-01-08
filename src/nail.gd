extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	var target_effect = RandomUtils.choice_one(["res://assets/sounds/nail_hit1.wav", "res://assets/sounds/nail_hit2.wav"])
	$AudioStreamPlayer.stream = ResourceManager.load_file(target_effect)
	$AudioStreamPlayer.play()
	self.modulate = Color(2.0,2.0,2.0,2.0)	
#	self.modulate = Color(1.5,1.5,1.5,1.5)


func _on_area_2d_body_exited(body):
	self.modulate = Color("ffffff")
