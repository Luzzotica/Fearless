extends Level

export(PackedScene) var chest

onready var spawn_point_holder: Spatial = $SpawnPoints
onready var chest_spawn_point: Spatial = $ChestSpawnPoint

var spawn_points: Array = []

var has_right_weapon = false
var has_chump = false
var has_spoken_with_sterling = false

func _ready():
	._ready()
	
	Globals.sterling_interaction.set_interaction_text("Do you wanna be my three week girlfriend?", "Yes", "...")
	
	var children = spawn_point_holder.get_children()
	for child in children:
		spawn_points.append(child.transform.origin)


func _on_reward_acquired(reward_type):
	if reward_type == Rewards.ItemTypes.CHUMP:
		has_chump = true
	elif reward_type == Rewards.ItemTypes.WEAPON_RIGHT:
		has_right_weapon = true
	
	._on_reward_acquired(reward_type)


func _on_correct_response():
	# Don't run this twice, it will make another chest
	if has_spoken_with_sterling:
		return
	
	has_spoken_with_sterling = true
	
	Globals.sterling_interaction.set_interaction_text("How many biological deficiencies do I have?\nAlso, you're gonna need a fire gauntlet for this next bit.", "3", "7")
	
	# Create a new chest
	chest_count += 1
	var c = chest.instance()
	chest_spawn_point.add_child(c)
	c.connect("recieve_reward", Globals.lindy, "_on_reward_received")
	
	._on_correct_response()
	


""" Level Handling """

func reset():
	kill_enemies()


func kill_enemies():
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for e in enemies:
		e.death()


func check_level_complete() -> bool:
	return (has_right_weapon 
		and has_chump 
		and has_spoken_with_sterling)


func get_level_objectives() -> String:
	var objectives = ""
	if has_spoken_with_sterling:
		objectives +=  "DONE. "
	objectives += "Speak with Sterling accept his gorgeous invitiation.\n"
	
	# Only show this bit if she has spoken with me
	if has_spoken_with_sterling:
		if has_chump:
			objectives +=  "DONE. "
		objectives += "Obtain the chump.\n"
	
	# Right weapon!!
	if has_right_weapon:
		objectives +=  "DONE. "
	objectives += "Obtain the fire gauntlet of POWER.\n"
	
	objectives += str(opened_chest_count) + "/" + str(chest_count) + " chests opened."
	
	if check_level_complete():
		create_portal()
		objectives += "\nFind the portal to level 3!"
	
	return objectives


func _on_KillEnemies_body_entered(body):
	# Only do it if Lindy is the one that enter
	if Globals.lindy != body:
		return
	
	# Stop the timer
	$EnemySpawnTimer.stop()
	
	kill_enemies()


func _on_Timer_timeout():
	# Put a cap on the number of monsters
	if len(get_tree().get_nodes_in_group("Enemies")) > 10:
		return
	
	var enemy = Globals.shadow_monster.instance()
	enemy.set_target(Globals.lindy)
	
	var rand = randi() % len(spawn_points)
	add_child(enemy)
	enemy.transform.origin = spawn_points[rand]
	
	
