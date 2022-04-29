extends StaticBody

enum ChestState { CLOSED, OPENING, OPEN }

enum ItemTypes { 
	WEAPON_RIGHT = 0, 
	WEAPON_LEFT, 
	WEEK_CONTRACT, 
	MAWIAGE_CONTRACT,
	LAPTOP,
	PETALS,
	CHUMP,
	RING,
	HEART
}
export (ItemTypes) var type

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var object_position: Spatial = $ObjectPosition
onready var camera_position: Spatial = $CameraPosition
onready var sound_open = $Open

var open_time = 0.4
var counter = 0.0
var state = ChestState.CLOSED

var object

signal recieve_reward(object)

func _ready():
	object = Rewards.RewardObjects[type].instance()
	object_position.add_child(object)
	object.transform.origin = Vector3.ZERO
	object.transform.basis = Basis(Quat.IDENTITY)
	object.transform.origin = object.get_reward_offset()# + object_position.transform.origin
	object.transform.basis = Basis(object.get_reward_rotation())# * object_position.transform.basis
	object.transform.scaled(object.get_reward_scale())
#	object.transform.scale = object.get_reward_scale()


func _process(delta):
	if state == ChestState.OPENING:
		counter += delta
		if counter > open_time:
			state = ChestState.OPEN
			emit_signal("recieve_reward", object)


func interact():
	state = ChestState.OPENING
	anim_player.play("Open")
	sound_open.play()


func is_interactable() -> bool:
	return state == ChestState.CLOSED


func get_camera_position() -> Vector3:
	return camera_position.transform.origin
