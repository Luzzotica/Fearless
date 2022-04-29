extends KinematicBody

export var speed = 1
export var damage = 25.0

onready var death_nodes = $DeathNodes
onready var spawn_sound = $SpawnSound

var target: Spatial
var target_offset: Vector3 = Vector3(0, 3.2, 0)

var dead = false

signal death()

func _ready():
	spawn_sound.play()
#	var rand = randi() % 2
#	if rand == 0:
#		$Growl1.play()
#	else:
#		$Growl2.play()


func _physics_process(delta):
	if dead or target == null:
		return
	
	# Look at the target
	look_at(target.transform.origin + target_offset, Vector3.UP)
	
	# Move forward and deal damange if we hit our target
	var collision := move_and_collide(-transform.basis.z * speed * delta)
	if collision and collision.collider.has_method("take_damage"):
		collision.collider.take_damage(damage)


func death():
	if dead:
		return
	
	dead = true
	
	# Move our death nodes to the parent and run them
	remove_child(death_nodes)
	get_parent().add_child(death_nodes)
	death_nodes.transform.origin = transform.origin
	death_nodes.run()
	
	emit_signal("death")
	
	# Free ourselves
	queue_free()
	


func set_target(t: Spatial):
	target = t


func set_target_offset(o: Vector3):
	target_offset = o


func get_name() -> String:
	return "Shadow Monster"

