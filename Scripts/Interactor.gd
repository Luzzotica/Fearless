extends StaticBody

var interactable = true

signal interacted()


func interact():
	emit_signal("interacted")


func is_interactable() -> bool:
	return interactable
