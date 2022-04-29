extends Level

var has_left_weapon = false
var has_spoken_with_sterling = false

func _ready():
	._ready()
	
	Globals.sterling_interaction.set_interaction_text("Hey, I like your glasses.", "Hip replacements and kneecaps!", "...")


func _on_reward_acquired(reward_type):
	if reward_type == Rewards.ItemTypes.WEAPON_LEFT:
		has_left_weapon = true
	
	._on_reward_acquired(reward_type)


func _on_correct_response():
	has_spoken_with_sterling = true
	Globals.sterling_interaction.set_interaction_text("You're hawt", "I know.", "So are you.")
	
	._on_correct_response()


""" Level Handling """

func check_level_complete() -> bool:
	return (has_left_weapon 
		and has_spoken_with_sterling)


func get_level_objectives() -> String:
	var objectives = ""
	if has_left_weapon:
		objectives +=  "DONE. "
	objectives += "Obtain a weapon.\n"
	
	if has_spoken_with_sterling:
		objectives +=  "DONE. "
	objectives += "Speak with Sterling and say something saucy.\n"
	
	objectives += str(opened_chest_count) + "/" + str(chest_count) + " chests opened."
	
	if check_level_complete():
		create_portal()
		objectives += "\nFind the portal to level 2!"
	
	return objectives


