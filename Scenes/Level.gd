class_name Level
extends Spatial

var opened_chest_count = 0
var chest_count = 0
var portal_created = false

onready var lindy_spawn_point: Spatial = $LindySpawnPoint
onready var portal_location: Spatial = $PortalLocation

signal objectives_update(objectives)
signal stop_music()

func _ready():
	Globals.lindy.connect("reward_acquired", self, "_on_reward_acquired")
	connect("objectives_update", Globals.lindy_objectives, "_on_objectives_update")
	Globals.sterling_interaction.connect("correct_response", self, "_on_correct_response")
	
	# Get all the chests and link their signal with lindy
	var chests = get_tree().get_nodes_in_group("Chests")
	chest_count = len(chests)
	for chest in chests:
		chest.connect("recieve_reward", Globals.lindy, "_on_reward_received")
	
	emit_signal("objectives_update", get_level_objectives())


func create_portal():
	# Make the portal exactly once
	if not portal_created:
		portal_created = true
		
		var p = Globals.portal.instance()
		# Connect the signal
		portal_location.add_child(p)
		print(p)
		p.connect("portal_entered", get_parent(), "_on_portal_entered")


""" SIGNALS """

func _on_reward_acquired(reward_type):
	opened_chest_count += 1
	emit_signal("objectives_update", get_level_objectives())


func _on_correct_response():
	emit_signal("objectives_update", get_level_objectives())


""" Level Handling """

func reset():
	pass


func check_level_complete() -> bool:
	return false


func get_level_objectives() -> String:
	return ""


