extends Node

enum ItemTypes { 
	WEAPON_RIGHT = 0, 
	WEAPON_LEFT = 1, 
	WEEK_CONTRACT, 
	MAWIAGE_CONTRACT,
	LAPTOP,
	PETALS,
	CHUMP,
	RING,
	HEART
}

const RewardObjects = {
	ItemTypes.WEAPON_LEFT: preload("res://Assets/Rewards/LindyWeapon.tscn"),
	ItemTypes.WEEK_CONTRACT: preload("res://Assets/Rewards/WeekContract.tscn"),
	ItemTypes.CHUMP: preload("res://Assets/Rewards/SterlingReward.tscn"),
	ItemTypes.HEART: preload("res://Assets/Rewards/Heart.tscn"),
	ItemTypes.WEAPON_RIGHT: preload("res://Assets/Rewards/FireGauntlet.tscn")
}
