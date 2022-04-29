extends Spatial

export var speed = 10

onready var root: Spatial = $Root
onready var area: Area = $Root/Area
onready var trail: CPUParticles = $Flames
onready var explosion: CPUParticles = $Explosion
onready var timer: Timer = $Timer
onready var sound = $ExplosionSound

var dir: Vector3 = Vector3.ZERO
var dead: bool = false


func start(origin: Vector3, dir: Vector3):
	global_transform.origin = origin
	self.dir = dir
	look_at(origin + dir, Vector3.UP)


func _physics_process(delta):
	transform.origin += dir * speed * delta


func death():
	if dead:
		return
	
	dead = true
	set_physics_process(false)
	root.queue_free()
	trail.emitting = false
	explosion.emitting = true
	sound.play()
	timer.start()


func _on_Area_body_entered(body):
	if body == Globals.lindy:
		return
	
	if body.has_method("death"):
		body.death()
	
	death()


func _on_Area_area_entered(area):
	if area.get_parent().has_method("light"):
		area.get_parent().light()
	
	death()


func _on_Timer_timeout():
	queue_free()


func _on_Lifetime_timeout():
	queue_free()


