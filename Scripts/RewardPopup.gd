extends Panel

onready var rew_name = $Align/Name
onready var rew_description = $Align/Description

var reward

signal handle_reward(reward_type)


#func _input(event):
#	if visible:
#		set_visibility(false)


func set_reward(reward):
	self.reward = reward
	rew_name.text = reward.get_reward_name()
	rew_description.text = reward.get_reward_description()


func set_visibility(value: bool):
	visible = value
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_Button_pressed():
	# Hide ourselves
	set_visibility(false)
	reward.queue_free()
	
	emit_signal("handle_reward", reward.reward_type)
	
	# Have lindy receive the reward
#	Globals.lindy.receive_reward(reward.reward_type)
