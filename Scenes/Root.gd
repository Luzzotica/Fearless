extends Spatial

enum LoadState {
	IDLE,
	LOADING,
	FINISH,
	GAME_START_LOAD,
	GAME_START_ACTIVATE
}

enum LevelSelect {
	LEVEL1 = 1,
	LEVEL2 = 2,
	LEVEL3 = 3,
	LEVEL4 = 4
}

var vignette_text = {
	LevelSelect.LEVEL1: "Act 1: The Meeting.",
	LevelSelect.LEVEL2: "Act 2: The Leap.",
	LevelSelect.LEVEL3: "Act 3: The Joy.",
	LevelSelect.LEVEL4: "Act 4: Fearless.",
}

export(PackedScene) var level1
export(PackedScene) var level2
export(PackedScene) var level3
export(PackedScene) var level4
export(LoadState) var current_load_state = LoadState.IDLE
export(LevelSelect) var current_level = LevelSelect.LEVEL1

onready var level_swap_timer: Timer = $LevelSwapTimer
onready var home_screen_ui: Control = $HomeScreen/CanvasLayer/Control
onready var home_screen_camera: Camera = $HomeScreen/Camera
onready var basic_music_player = $HomeScreen/AudioStreamPlayer
onready var haloish_music_player = $HomeScreen/AudioStreamPlayer2

var wait_time_long = 5
var wait_time_short = 1.1

func _ready():
	setup_current_level()
	reset_lindy()


func begin_load_next_level():
	Globals.lindy.fade_vignette_in(vignette_text[current_level + 1])
	Globals.lindy.set_active(false)
	level_swap_timer.wait_time = wait_time_long
	level_swap_timer.start()
	current_load_state = LoadState.LOADING
	
	# Get all the chests and link their signal with lindy
	var chests = get_tree().get_nodes_in_group("Chests")
	for chest in chests:
		chest.queue_free()


func load_next_level():
	# Load the next level after freeing the first one
	Globals.level.queue_free()
	current_level += 1
	
	setup_current_level()
	
	reset_lindy()
	Globals.lindy.fade_vignette_out()
	
	# Wait and do the next thing
	level_swap_timer.wait_time = wait_time_short
	level_swap_timer.start()
	current_load_state = LoadState.FINISH


func finish_load_next_level():
	Globals.lindy.set_active(true)
	current_load_state = LoadState.IDLE


func start_game_load():
	current_load_state = LoadState.GAME_START_ACTIVATE
	
	# Swap cameras and then fade out the vignette
	home_screen_ui.visible = false
	home_screen_camera.visible = false
	home_screen_camera.current = false
	Globals.lindy.set_camera_current(true)
	Globals.lindy.fade_vignette_out()
	Globals.lindy.set_animation_state("Ready")
	level_swap_timer.wait_time = wait_time_short
	level_swap_timer.start()


func start_game_activate():
	current_load_state = LoadState.IDLE
	Globals.lindy.set_active(true)


func reset_lindy():
	var trans = Globals.level.lindy_spawn_point.transform
	Globals.lindy.transform.origin = trans.origin
	Globals.lindy.transform.basis = trans.basis


func setup_current_level():
	if current_level == LevelSelect.LEVEL1:
		basic_music_player.play()
		Globals.level = level1.instance()
	if current_level == LevelSelect.LEVEL2:
		Globals.level = level2.instance()
	if current_level == LevelSelect.LEVEL3:
		basic_music_player.stop()
		haloish_music_player.play()
		Globals.level = level3.instance()
	if current_level == LevelSelect.LEVEL4:
		Globals.level = level4.instance()
	Globals.level.connect("stop_music", self, "_on_stop_music")
	add_child(Globals.level)


func _on_stop_music():
	
	basic_music_player.stop()
	haloish_music_player.stop()


func reset_game():
	# Load level 1 again, resent states
	current_load_state = LoadState.IDLE
	current_level = LevelSelect.LEVEL1
	Globals.level.queue_free()
	setup_current_level()
	
	# Reset Lindy completely
	Globals.lindy.reset_all_flags()
	Globals.lindy.set_camera_current(false)
	reset_lindy()
	
	# Setup home
	home_screen_ui.visible = true
	home_screen_camera.visible = true
	home_screen_camera.current = true


func _on_Area_body_entered(body):
	if body == Globals.lindy:
		reset_lindy()


func _on_portal_entered():
	# If we aren't already loading, load
	if current_load_state == LoadState.IDLE:
		begin_load_next_level()


func _on_Timer_timeout():
	if current_load_state == LoadState.LOADING:
		load_next_level()
	elif current_load_state == LoadState.FINISH:
		finish_load_next_level()
	elif current_load_state == LoadState.GAME_START_LOAD:
		start_game_load()
	elif current_load_state == LoadState.GAME_START_ACTIVATE:
		start_game_activate()


func _on_Lindy_lindy_death():
	reset_lindy()
	Globals.level.reset()


func _on_Start_pressed():
	home_screen_ui.visible = false
	current_load_state = LoadState.GAME_START_LOAD
	Globals.lindy.fade_vignette_in(vignette_text[current_level])
	level_swap_timer.wait_time = wait_time_long
	level_swap_timer.start()


func _on_Quit_pressed():
	get_tree().quit()
