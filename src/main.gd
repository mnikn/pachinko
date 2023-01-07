extends Node2D

var BallScene = preload("./ball.tscn")
var MAX_SPEED = 4000
var strength = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	self.create_ball()
	
func create_ball():
	var node = self.BallScene.instantiate()
	node.connect("finished", self.create_ball)
	$Balls.add_child(node)
	TweenUtils.show(node, 0.1, { "scale": false, "modulate": true })
	TweenUtils.show($Strength, 0.2)

func _process(delta):
	if $Balls.get_child_count() <= 0:
		return
	if $Balls.get_children()[0].is_shot:
		return
	if Input.get_action_strength("player_shot") > 0:
		strength += delta
		strength = min(strength, 1.0)
	elif Input.is_action_just_released("player_shot"):
		var node = $Balls.get_children()[0]
		node.is_shot = true
		TweenUtils.hide($Strength, 0.3)
		node.linear_velocity.x = MAX_SPEED * strength
		print_debug(node.linear_velocity.x)

		# rewardx2
#		node.linear_velocity.x = 1799.609375
		# rewardx1
		node.linear_velocity.x = 3457.474609375

		# reward x5
#		node.linear_velocity.x = 2460.73901367188
		strength = 0
	
	$Strength.value = strength * 100
