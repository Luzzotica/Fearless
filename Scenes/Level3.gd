extends Level

export(PackedScene) var chest

onready var spawn_point_holder: Spatial = $SpawnPoints
onready var chest_spawn_point: Spatial = $ChestSpawnPoint
onready var spawn_timer: Timer = $EnemySpawnTimer

var spawn_points: Array = []

var has_spoken_with_sterling = false

var enemy_kill_count = 0
var required_enemy_kill_count = 30

func _ready():
	._ready()
	
	Globals.sterling_interaction.set_interaction_text("Isn't fighting shadow monsters with me just the best ever?\nThe hard part is coming!", "Heck yeah!", "...")
	
	var children = spawn_point_holder.get_children()
	for child in children:
		spawn_points.append(child.transform.origin)


func _on_reward_acquired(reward_type):
	
	._on_reward_acquired(reward_type)


func _on_correct_response():
	# Don't run this twice, it will make another chest
	if has_spoken_with_sterling:
		return
	
	has_spoken_with_sterling = true
	
	Globals.sterling_interaction.set_interaction_text("I sure do love you. =)\nThe hard part is coming up.", "=O", "=D")
	
	._on_correct_response()
	


""" Level Handling """

func reset():
	remove_enemies()


func remove_enemies():
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for e in enemies:
		e.queue_free()


func kill_enemies():
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for e in enemies:
		e.death()


func check_level_complete() -> bool:
	return (has_spoken_with_sterling
		and enemy_kill_count >= required_enemy_kill_count)


func get_level_objectives() -> String:
	var objectives = ""
	if has_spoken_with_sterling:
		objectives +=  "DONE. "
	objectives += "Speak with Sterling because why not.\n"
	
	objectives += str(enemy_kill_count) + "/" + str(required_enemy_kill_count) + " enemies killed.\n"
	objectives += str(opened_chest_count) + "/" + str(chest_count) + " chests opened."
	
	if check_level_complete():
		create_portal()
		spawn_timer.stop()
		kill_enemies()
		objectives += "\nTake the portal to level 4!"
	
	return objectives


func _on_enemy_death():
	enemy_kill_count += 1
	emit_signal("objectives_update", get_level_objectives())


func _on_EnemySpawnTimer_timeout():
	spawn_timer.wait_time = 1
	# Put a cap on the number of monsters
	if len(get_tree().get_nodes_in_group("Enemies")) > 15:
		return
	
	var enemy = Globals.shadow_monster.instance()
	enemy.set_target(Globals.lindy)
	enemy.connect("death", self, "_on_enemy_death")
	
	var rand = randi() % len(spawn_points)
	add_child(enemy)
	enemy.transform.origin = spawn_points[rand]
