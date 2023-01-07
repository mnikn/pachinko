extends RigidBody2D
signal finished()

var is_shot = false
var zero_time = 0
var is_finished = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.is_finished:
		return
	
	if self.position.y >= 750:
		self.is_finished = true
		await TweenUtils.hide(self, 0.2, { "scale": false, "modulate": true })
		self.queue_free()
		self.emit_signal("finished")
		return
	if self.is_shot and abs(self.linear_velocity.x) <= 1 and abs(self.linear_velocity.y) <= 1:
		zero_time += delta
	if zero_time >= 1:
		self.is_finished = true
		await TweenUtils.hide(self, 0.2, { "scale": false, "modulate": true })
		self.queue_free()
		self.emit_signal("finished")
		return
