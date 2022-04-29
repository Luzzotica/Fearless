extends Spatial

onready var sterling = $Sterling
onready var interactor = $Interactor
onready var anim_player = $AnimationPlayer
onready var russian_doll: Spatial = $RussianDoll
onready var sound_player = $AudioStreamPlayer
onready var lindy_position = $LindyPosition
onready var lindy_position_2 = $LindyPosition2
onready var ring = $Ring

var current_chest = 0
var chest_count = 12

var turn_to_face_sterling = false
var turn_to_sterling_time = 1.0
var anim_time = 0

var lindy_head_start: Quat
var lindy_head_end: Quat = Quat.IDENTITY

func _ready():
	pass


func _process(delta):
	if turn_to_face_sterling:
		var time = anim_time / turn_to_sterling_time
		if time > 1:
			turn_to_face_sterling = false
			time = 1
		Globals.lindy.global_transform.origin = lindy_position.global_transform.origin.slerp(lindy_position_2.global_transform.origin, time)
		Globals.lindy.global_transform.basis = Basis(lindy_position.global_transform.basis.get_rotation_quat().slerp(lindy_position_2.global_transform.basis.get_rotation_quat(), time))
		Globals.lindy.camera_holder.transform.basis = Basis(lindy_head_start.slerp(lindy_head_end, time))
		anim_time += delta


func lindy_face_sterling():
	print("Swag")
	lindy_head_start = Globals.lindy.camera_holder.transform.basis.get_rotation_quat()
	turn_to_face_sterling = true


func begin_animation_sequence():
	# Play the sound, and being our animations
	sound_player.play()
	anim_player.play("FinalCutscene")
	Globals.lindy.set_active(false)
	Globals.lindy.global_transform.origin = lindy_position.global_transform.origin
	Globals.lindy.camera_holder.look_at(ring.global_transform.origin + Vector3(0, 2, 0), Vector3.UP)
	
	sterling.stop_idle()
	sterling.should_look_at_lindy = false


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
