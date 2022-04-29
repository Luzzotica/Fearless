extends Spatial

onready var area: Area = $Area

signal portal_entered()

func _on_Area_body_entered(body):
	# Only trigger if lindy enters
	if Globals.lindy == body:
		emit_signal("portal_entered")
