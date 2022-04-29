extends StaticBody

enum SterlingState { SILENT, SPOKEN }

var state = SterlingState.SILENT
var should_look_at_lindy = true
var cameraOffset = Vector3(0, 2.2, 0)

func _ready():
	$AnimationPlayer.play("Idle")
#	cameraOffset = Globals.lindy.camera.transform.origin

func stop_idle():
	$AnimationPlayer.stop()


func _physics_process(delta):
	if should_look_at_lindy:
		var origin = Globals.lindy.global_transform.origin
		var lindy_xz = Vector3.ZERO
		lindy_xz.x = origin.x
		lindy_xz.z = origin.z
		lindy_xz.y = global_transform.origin.y
		look_at(lindy_xz, Vector3.UP)
	
	$Mesh/Torso/SterlingHead.look_at(Globals.lindy.global_transform.origin + cameraOffset, Vector3.UP)


func interact():
	state = SterlingState.SPOKEN
	Globals.sterling_interaction.set_visibility(true)


func is_interactable() -> bool:
	return true
