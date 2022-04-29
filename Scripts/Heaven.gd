extends Spatial

onready var interactor = $Interactor
onready var anim_player = $AnimationPlayer
onready var russian_doll: Spatial = $RussianDoll
onready var sound_player = $AudioStreamPlayer

#var chests =
var current_chest = 0
var chest_count = 12

func _ready():
	pass


func begin_animation_sequence():
	# Play the sound, and being our animations
	sound_player.play()
	anim_player.play("FinalCutscene")


func open_next_chest():
	# Get the next chest and open it
	var chest = russian_doll.get_children()[current_chest]
	chest.open()
	
	current_chest += 1
	current_chest %= russian_doll.get_child_count()


func set_interactor_interactable(value: bool):
	interactor.interactable = value


func _on_Interactor_interacted():
	begin_animation_sequence()
