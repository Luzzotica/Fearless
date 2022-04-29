extends Spatial

onready var sizer = $Sizer
onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var explosion: CPUParticles = $Explosion
onready var physics_body = $Sizer/RigidBody
onready var mesh = $Sizer/BlackVoid
onready var timer = $Timer


func _ready():
	anim_player.play("Pulse")


func set_sizer_scale(scale: Vector3):
	sizer.scale = scale


func explode():
	sizer.queue_free()
	explosion.emitting = true
	timer.start()


func _on_Timer_timeout():
	queue_free()
