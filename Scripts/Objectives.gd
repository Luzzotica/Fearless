extends Panel


onready var objectives_label = $VBoxContainer/Objectives


func _ready():
	Globals.lindy_objectives = self


func _on_objectives_update(objectives: String):
	objectives_label.text = objectives
