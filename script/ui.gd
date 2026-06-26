extends CanvasLayer

#@onready var Game_over := $GameOver

func _ready() -> void:
	# Hide touch controls on PC (non-touchscreen devices)
	if not DisplayServer.is_touchscreen_available():
		if has_node("AttackButon"):
			get_node("AttackButon").visible = false
		if has_node("JumpButton2"):
			get_node("JumpButton2").visible = false
		if has_node("Virtual Joystick"):
			get_node("Virtual Joystick").visible = false
#	Game_over.visible = false

#func show_game_over():
	#Game_over.visible = true
	#Game_over.get_node("Panel/DayMessage").text = "DAY: " + str(Game_state.Current_level)
	#get_tree().paused = true
