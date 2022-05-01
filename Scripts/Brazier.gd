extends Spatial

onready var lit: Spatial = $Sizer/Lit
onready var sound = $Sizer/Lit/FlameSound

var is_lit = false

signal brazier_lit()

func light():
	if is_lit:
		return
	
	is_lit = true
	lit.visible = true
	sound.play()
	emit_signal("brazier_lit")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
