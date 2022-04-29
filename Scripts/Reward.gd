extends Spatial

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
export (ItemTypes) var reward_type
export (String, MULTILINE) var reward_name
export (String, MULTILINE) var reward_description
export (Vector3) var in_chest_offset = Vector3.ZERO
export (Vector3) var in_chest_scale = Vector3.ONE
export (Vector3) var in_chest_rotation = Vector3.ZERO

func get_reward_name() -> String:
	return reward_name


func get_reward_description() -> String:
	return reward_description


func get_reward_scale() -> Vector3:
	return in_chest_scale


func get_reward_offset() -> Vector3:
	return in_chest_offset


func get_reward_rotation() -> Vector3:
	return in_chest_rotation


