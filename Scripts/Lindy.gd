extends KinematicBody


export var active: bool = false
export var receives_input: bool = false
export var has_camera: bool = false
export(String, "Idle", "Ready", "Display") var animation_state = "Ready"
export var has_left_weapon = false
export var has_right_weapon = false
export var interaction_range = 5

export var move_speed = 10
export var mouse_sensitivity = 0.3

export var health_max = 100
export var health = 100

var health_regen_delay = 2.0
var last_damage_taken = 0
var invulnerable_period = 0.3

onready var camera_holder: Spatial = $Mesh/Torso/CameraPosition
onready var camera: Spatial = $Mesh/Torso/CameraPosition/Camera
onready var head: MeshInstance = $Mesh/Torso/LindyHead
onready var torso: MeshInstance = $Mesh/Torso/LindyTorso
onready var right_hand_fire: Spatial = $Mesh/Torso/CameraPosition/Hands/HandR/FireGauntlet
onready var animations: AnimationPlayer = $Mesh/Animations
onready var ui_animations: AnimationPlayer = $Mesh/UIAnimations
onready var hand_l_animations: AnimationPlayer = $Mesh/HandLAnimations
onready var hand_r_animations: AnimationPlayer = $Mesh/HandRAnimations

# Sounds
onready var sound_melee_hit = $Mesh/Torso/CameraPosition/Hands/HandL/MeleeHit
onready var sound_melee_miss = $Mesh/Torso/CameraPosition/Hands/HandL/MeleeMiss
onready var sound_ranged_attack = $Mesh/Torso/CameraPosition/Hands/HandR/RangedAttack

# UI
onready var base_ui: Control = $CanvasLayer/Base
onready var cursor_text: Label = $CanvasLayer/Base/CursorText
onready var reward_popup: Panel = $CanvasLayer/Base/RewardPopup
onready var reward_name: Label = $CanvasLayer/Base/RewardPopup/Align/Name
onready var reward_description: Label = $CanvasLayer/Base/RewardPopup/Align/Description
onready var black_vignette: Panel = $CanvasLayer/BlackVignette
onready var vignette_label: Label = $CanvasLayer/BlackVignette/VignetteLabel
onready var health_bar: ProgressBar = $CanvasLayer/Base/HealthBar

onready var weapon_left: Spatial = $Mesh/Torso/CameraPosition/Hands/HandL/LindyWeapon/Mesh/WomanSelfDefenseWeapon
onready var weapon_right: Spatial = $Mesh/Torso/CameraPosition/Hands/HandR/FireGauntlet

var current_y_movement: float = 0
var camera_angle_max = PI / 3
var gravity = 9.8
var jump_speed = 6
var max_wall_fall_speed = -1.5
var floor_normal = Vector3(0, 1, 0)
var mouse_pos = Vector2.ZERO

var hand_left_hit_timer = 0.5
var hand_left_last_hit = 0
var hand_right_hit_timer = 0.5
var hand_right_last_hit = 0

# Rewards
var heart_count = 0
var has_chump = false
var has_week_contract = false
var has_mawiage_contract = false

var current_target

signal reward_acquired(reward_type)
signal lindy_death()

func _ready():
	Globals.lindy = self
	
	set_animation_state(animation_state)
	set_active(active)
	set_receives_input(receives_input)
	set_camera_current(has_camera)
	set_has_left_weapon(has_left_weapon)
	set_has_right_weapon(has_right_weapon)


""" INPUT AND PROCESSES """

func _physics_process(delta):
	if not active or Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
	
	# Handle movement
	var lateral = 0
	var forward = 0
	if Input.is_action_pressed("w"):
		forward += 1
	if Input.is_action_pressed("s"):
		forward -= 1
	if Input.is_action_pressed("a"):
		lateral += 1
	if Input.is_action_pressed("d"):
		lateral -= 1
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var move_vector = (transform.basis.z * forward + transform.basis.x * lateral).normalized() * move_speed
	
	# Gravity and wall sliding
	if not is_on_floor():
		# Fall normally
		current_y_movement -= gravity * delta * 2
		# Slide down walls
		if is_on_wall() and move_vector.y < max_wall_fall_speed:
			current_y_movement = max_wall_fall_speed
	else:
		current_y_movement = -1
	
	# Jump!
	if Input.is_action_just_pressed("jump") and (is_on_floor() or is_on_wall()):
		current_y_movement = jump_speed
	
	move_vector.y = current_y_movement
	move_and_slide(move_vector, floor_normal)
	
	# Clicking
	hand_left_last_hit += delta
	hand_right_last_hit += delta
	if Input.is_action_just_pressed("left_mouse"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if hand_left_last_hit > hand_left_hit_timer:
			hand_left_last_hit = 0
			hand_l_animations.play("HitLeft")
			if has_left_weapon:
				if (current_target 
					and current_target.has_method("death")):
					current_target.death()
					current_target = null
					cursor_text.text = ""
					sound_melee_hit.play()
				else:
					sound_melee_miss.play()
	if Input.is_action_just_pressed("right_mouse") and hand_right_last_hit > hand_right_hit_timer:
		hand_right_last_hit = 0
		hand_r_animations.play("ShootRight")
		if has_right_weapon:
			sound_ranged_attack.play()
			var f = Globals.fireball.instance()
			get_parent().add_child(f)
			f.start(right_hand_fire.global_transform.origin, -camera_holder.global_transform.basis.z)
	
	# Handle ray tracing to get targets within interactable range
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * interaction_range
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(from, to, [self])
	if (result.has("collider")
		and current_target != result["collider"]):
		if (result["collider"].has_method("is_interactable")
			and result["collider"].is_interactable()):
			current_target = result["collider"]
			cursor_text.text = "Press F to interact."
		elif result["collider"].has_method("death"):
			print(str(current_target) + " " + str(result["collider"]))
			current_target = result["collider"]
			cursor_text.text = current_target.get_name()
	elif (not result.has("collider") 
		or (result.has("collider") 
		and not result["collider"].has_method("interact")
		and not result["collider"].has_method("death"))):
		current_target = null
		cursor_text.text = ""
		
	# Handle interaction
	if (Input.is_action_just_pressed("interact") 
		and current_target != null
		and current_target.has_method("interact")):
		current_target.interact()
		current_target = null
		cursor_text.text = ""
	
	# Handle health process
	check_regen(delta)
	update_health_ui()


func _input(event):
	if not active: 
		return
	
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		mouse_pos = event.position
		rotate_object_local(floor_normal, deg2rad(-event.relative.x * mouse_sensitivity))
		var change = deg2rad(-event.relative.y * mouse_sensitivity)
		var current_angle = camera_holder.transform.basis.get_euler().x
		if current_angle + change > -camera_angle_max and current_angle + change < camera_angle_max:
			camera_holder.rotate_x(change)


""" HEALTH """

func take_damage(amount: float):
	# If we are in our invulnerable period, stop
	if last_damage_taken < invulnerable_period:
		return
	
	last_damage_taken = 0
	health -= amount
	
	if health < 0:
		emit_signal("lindy_death")
		health = health_max


func check_regen(delta):
	last_damage_taken += delta
	if health < health_max and last_damage_taken > health_regen_delay:
		health += 2
		if health > health_max:
			health = health_max


func update_health_ui():
	health_bar.value = health / health_max * 100


func show_reward_info(reward):
	reward_popup.set_reward(reward)
	reward_popup.set_visibility(true)


""" GETTERS AND SETTERS """

func set_active(value: bool):
	active = value
	base_ui.visible = value
	set_body_visible(not value)
	
	set_receives_input(value)
#	set_camera_current(value)


func set_receives_input(value: bool):
	receives_input = value
	if receives_input:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func set_camera_current(value: bool):
	has_camera = value
	camera.current = value


func set_animation_state(state: String):
	animation_state = state
	animations.play(animation_state)
	hand_l_animations.play(animation_state)
	hand_r_animations.play(animation_state)


func set_body_visible(visible: bool):
	# Hide the head
	head.visible = visible
	torso.visible = visible


func set_has_left_weapon(value: bool):
	has_left_weapon = value
	weapon_left.visible = value


func set_has_right_weapon(value: bool):
	has_right_weapon = value
	weapon_right.visible = value


func set_owned_weapon_visibility(value: bool):
	if value:
		weapon_left.visible = has_left_weapon
		# weapon_right.visible = has_right_weapon
	else:
		weapon_left.visible = false
#		weapon_right.visible = false


func fade_vignette_in(text: String = ""):
	black_vignette.visible = true
	ui_animations.play("FadeVignetteIn")
	vignette_label.text = text


func fade_vignette_out():
	ui_animations.play("FadeVignetteOut")


func reset_all_flags():
	heart_count = 0
	has_chump = false
	set_has_left_weapon(false)
	set_has_right_weapon(false)
	has_mawiage_contract = false
	has_week_contract = false
	current_target = null
	
	set_active(false)


""" SIGNAL HANDLING """

func _on_reward_received(reward):
	show_reward_info(reward)


func _on_RewardPopup_handle_reward(reward_type):
	emit_signal("reward_acquired", reward_type)
	if reward_type == Rewards.ItemTypes.WEAPON_LEFT:
		set_has_left_weapon(true)
	elif reward_type == Rewards.ItemTypes.WEAPON_RIGHT:
		set_has_right_weapon(true)
	elif reward_type == Rewards.ItemTypes.HEART:
		heart_count += 1
	elif reward_type == Rewards.ItemTypes.MAWIAGE_CONTRACT:
		has_mawiage_contract = true
	elif reward_type == Rewards.ItemTypes.WEEK_CONTRACT:
		has_week_contract = true
	elif reward_type == Rewards.ItemTypes.CHUMP:
		has_chump = true


func _on_Animations_animation_finished(anim_name):
	if anim_name == "FadeVignetteOut":
		black_vignette.visible = false
