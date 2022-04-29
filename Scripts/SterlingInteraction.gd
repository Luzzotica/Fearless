extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var sterling = $Align/Sterling
onready var correct = $Align/Correct
onready var incorrect = $Align/Incorrect

signal correct_response()

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.sterling_interaction = self


func set_interaction_text(text: String, correctT: String, incorrectT: String):
	sterling.text = "Sterling: " + text
	correct.text = correctT
	incorrect.text = incorrectT


func set_visibility(value: bool):
	visible = value
	if visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_Correct_pressed():
	# Hide ourselves
	set_visibility(false)
	emit_signal("correct_response")


func _on_Incorrect_pressed():
	# Hide ourselves
	set_visibility(false)
