extends Level

export(PackedScene) var chest

onready var spawn_point_holder: Spatial = $SpawnPoints
onready var spawn_timer: Timer = $EnemySpawnTimer
onready var black_void = $BlackVoid
onready var heaven = $Heaven
onready var end_game_chest_interactor = $Heaven/Interactor

var spawn_points: Array = []

var has_ring = false
var has_spoken_with_sterling = false

var enemy_kill_count = 0
var brazier_light_count = 0
var braziers_lit = 0

func _ready():
	._ready()
	
	Globals.sterling_interaction.set_interaction_text("It's been so hard not to tell you about this...\nWere you surprised?", "No", "No.")
	
	var children = spawn_point_holder.get_children()
	for child in children:
		spawn_points.append(child.transform.origin)
	
	children = get_tree().get_nodes_in_group("Braziers")
	brazier_light_count = len(children)
	for child in children:
		child.connect("brazier_lit", self, "_on_brazier_lit")
	
	emit_signal("objectives_update", get_level_objectives())


func _on_reward_acquired(reward_type):
	if reward_type == Rewards.ItemTypes.RING:
		has_ring = true
	
	._on_reward_acquired(reward_type)


func _on_correct_response():
	# Don't run this twice, it will make another chest
	if has_spoken_with_sterling:
		return
	
	has_spoken_with_sterling = true
	
	Globals.sterling_interaction.set_interaction_text("Open the chest, it will all be worth it =)", "=D", "=O")
	
	end_game_chest_interactor.interactable = true
	
	._on_correct_response()
	


""" Level Handling """

func reset():
	kill_enemies()


func kill_enemies():
	var enemies = get_tree().get_nodes_in_group("Enemies")
	for e in enemies:
		e.death()


func check_level_complete() -> bool:
	return (has_ring 
		and braziers_lit >= brazier_light_count
		and has_spoken_with_sterling)


func get_level_objectives() -> String:
	var objectives = ""
	if has_spoken_with_sterling:
		objectives +=  "DONE. "
	objectives += "Sterling has something he would like to share.\n"
	
	if has_spoken_with_sterling:
		if has_ring:
			objectives +=  "DONE. "
		objectives += "Acquire the ring.\n"
	else:
		objectives += str(braziers_lit) + "/" + str(brazier_light_count) + " braziers lit.\n"
		objectives += str(opened_chest_count) + "/" + str(chest_count) + " chests opened.\n"
		objectives += str(enemy_kill_count) + " enemies killed."
	
	if check_level_complete():
		# TODO: Show winning screen
		pass
	
	return objectives


func _on_enemy_death():
	enemy_kill_count += 1
	emit_signal("objectives_update", get_level_objectives())


func _on_brazier_lit():
	braziers_lit += 1
	var reducer = 3
	var new_scale = float(brazier_light_count * reducer - braziers_lit) / float(brazier_light_count * reducer)
	
	black_void.scale_object_local(Vector3(new_scale, new_scale, new_scale))
	if braziers_lit == brazier_light_count:
		black_void.explode()
	emit_signal("objectives_update", get_level_objectives())


func _on_EnemySpawnTimer_timeout():
	spawn_timer.wait_time = 0.8
	# Put a cap on the number of monsters
	if len(get_tree().get_nodes_in_group("Enemies")) > 15:
		return
	
	var enemy = Globals.shadow_monster.instance()
	enemy.set_target(Globals.lindy)
	enemy.connect("death", self, "_on_enemy_death")
	
	var rand = randi() % len(spawn_points)
	add_child(enemy)
	enemy.transform.origin = spawn_points[rand]


func _on_KillEnemies_body_entered(body):
	if Globals.lindy == body:
		emit_signal("stop_music")
		spawn_timer.stop()
		kill_enemies()
