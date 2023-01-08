extends Node2D

var BallScene = preload("./ball.tscn")
var EndPanelScene = preload("./end_panel.tscn")
var GameOverPanelScene = preload("./game_over_panel.tscn")
var MAX_SPEED = 4000
var strength = 0

var current_marbles = 30
var reward_marables = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	self.create_ball()
	
func create_ball():
	$GUI/Panel/HBoxContainer2/Bet.disabled = (self.current_marbles <= 1)
	$GUI/Panel/HBoxContainer2/End.disabled = false
	var node = self.BallScene.instantiate()
	node.connect("finished", func ():
		var is_reward1 = $AreaRewardX1.get_overlapping_bodies()
		var target_reward = 0
		if is_reward1:
			target_reward = self.current_marbles + reward_marables
			
		var is_reward2 = $AreaRewardX2.get_overlapping_bodies()
		if is_reward2:
			target_reward = self.current_marbles + reward_marables * 2
		var is_reward5 = $AreaRewardX5.get_overlapping_bodies()
		if is_reward5:
			target_reward = self.current_marbles + reward_marables * 5
			
		if target_reward != 0:
			var tween = self.create_tween()
			tween.set_parallel(true)
			var duration = 0.5
			tween.tween_property(self, "current_marbles", target_reward, duration)
			tween.tween_property(self, "reward_marables", 0, duration)
			await tween.finished
			await self.get_tree().create_timer(0.5).timeout
		
		self.current_marbles -= 1
		self.reward_marables += 1
		if self.current_marbles == 0:
			print_debug("Game over")
			self.show_game_over()
			return
		self.create_ball()
	)
	$Balls.add_child(node)
	TweenUtils.show(node, 0.1, { "scale": false, "modulate": true })
	TweenUtils.show($Strength, 0.2)

func _process(delta):
	$GUI/Panel/HBoxContainer2/Panel/HBoxContainer/Current.text = "[center]Current marbles: %s" % str(self.current_marbles) + "[/center]"
	$GUI/Panel/HBoxContainer2/Panel/HBoxContainer/Reward.text = "[center]Reward marbles: %s" % str(self.reward_marables) + "[/center]"

	if $Balls.get_child_count() <= 0:
		return
	if $Balls.get_children()[0].is_shot:
		return
	if $GUI.has_node("EndPanel"):
		return
	if Input.get_action_strength("player_shot") > 0:
		if $GUI/Panel/HBoxContainer2/Bet.has_focus():
			$GUI/Panel/HBoxContainer2/Bet.release_focus()
		if not $GUI/Panel/HBoxContainer2/Bet.disabled:
			$GUI/Panel/HBoxContainer2/Bet.disabled = true
		if not $GUI/Panel/HBoxContainer2/End.disabled:
			$GUI/Panel/HBoxContainer2/End.disabled = true
		strength += delta
		strength = min(strength, 1.0)
	elif Input.is_action_just_released("player_shot"):
		var node = $Balls.get_children()[0]
		node.is_shot = true
		TweenUtils.hide($Strength, 0.3)
		node.linear_velocity.x = MAX_SPEED * strength
		print_debug(node.linear_velocity.x)

		# rewardx2
#		node.linear_velocity.x = 1799.78662109375
		# rewardx1
#		node.linear_velocity.x = 2734.61596679688
		# reward x5
#		node.linear_velocity.x = 2337.10791015625
		strength = 0
	
	$Strength.value = strength * 100


func _on_bet_pressed():
	if self.current_marbles <= 1:
		return
	var transfer_count = 1
	
	if Input.is_key_pressed(KEY_CTRL):
		transfer_count = 5
	elif Input.is_key_pressed(KEY_SHIFT):
		transfer_count = 50
#
#	var final_transfer = transfer_count - self.current_marbles
#	if final_transfer <= 0:
#		final_transfer = transfer_count
	if transfer_count >= self.current_marbles:
		transfer_count = self.current_marbles - 1
		self.current_marbles = 1
	else:
		self.current_marbles -= transfer_count
	self.reward_marables += transfer_count * 2
	
	$GUI/Panel/HBoxContainer2/Bet.disabled = (self.current_marbles <= 1)


func show_game_over():
	var panel = self.GameOverPanelScene.instantiate()
	MaskUtils.show_mask(self)
	$GUI.add_child(panel)
	await TweenUtils.show(panel)
	GameManager.top_points = max(GameManager.top_points, self.current_marbles)
	panel.get_node("MarginContainer/VBoxContainer/Content").text = "Game over! Your final points: %s. Your top rank points: %s." % [self.current_marbles, GameManager.top_points]
	panel.get_node("MarginContainer/VBoxContainer/HBoxContainer/Yes").connect("pressed", func ():
		TweenUtils.hide(panel)
#		TweenUtils.hide($GUI, 0.3, { "modulate": true, "scale": false})
		SceneChanger.change_scene("res://src/main.tscn"))

func _on_end_pressed():
	$GUI/Panel/HBoxContainer2/End.disabled = true
	$GUI/Panel/HBoxContainer2/Bet.disabled = true
	MaskUtils.show_mask(self)
	var node = self.EndPanelScene.instantiate()
	$GUI.add_child(node)
	node.name = "EndPanel"
	await TweenUtils.show(node)
	
	node.get_node("MarginContainer/VBoxContainer/HBoxContainer/Yes").connect("pressed", func ():
		await TweenUtils.hide(node)
		node.queue_free()
		self.show_game_over())
	node.get_node("MarginContainer/VBoxContainer/HBoxContainer/Cancel").connect("pressed", func ():
		MaskUtils.close_mask(self)
		await TweenUtils.hide(node)
		node.queue_free()
		$GUI/Panel/HBoxContainer2/End.disabled = false
		$GUI/Panel/HBoxContainer2/Bet.disabled = self.current_marbles == 1)
