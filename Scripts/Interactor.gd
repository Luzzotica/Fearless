extends StaticBody

var interactable = false

signal interacted()


func interact():
	emit_signal("interacted")


func is_interactable() -> bool:
	return interactable
