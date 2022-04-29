extends StaticBody

enum ChestState { CLOSED, OPENING, OPEN }

onready var anim_player: AnimationPlayer = $AnimationPlayer

var state = ChestState.CLOSED

signal opened()

func open():
	anim_player.play("Open")


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Open":
		state = ChestState.OPEN
		emit_signal("opened")
