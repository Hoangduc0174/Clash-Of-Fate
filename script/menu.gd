extends CanvasLayer

@onready var Self := $Control
@onready var Play := $Control/Menu/Play
@onready var Settings := $Control/Menu/Settings
@onready var Quit := $Control/Menu/Quit

var lock_button := false

func _on_settings_pressed() -> void:
	effect(Settings)


func _on_quit_pressed() -> void:
	effect(Quit)
	if not lock_button:
		effect(Quit)
		await get_tree().create_timer(0.5).timeout
		get_tree().quit()



func _on_play_pressed() -> void:
	effect(Play)
	
	lock_button = true
	Game_state.current_map = 0
	
	#disappear lobby
	await fade_out(1.5)
	
	#appear story
	get_tree().change_scene_to_file("res://scence/story.tscn")



func fade_out(Duration):
	var tween = create_tween()

	tween.tween_property(
		Self,
		"modulate:a",
		0.0,
		Duration
	)

	await tween.finished
	
	
func effect(Name):
		Name.scale = Vector2.ONE

		var tween = create_tween()
		tween.set_parallel(true)

		# Phóng to
		tween.tween_property(Name, "scale", Vector2(1.15, 1.15), 0.15)

		# Di chuyển nhẹ sang phải
		tween.tween_property(Name, "position:x", Play.position.x + 10, 0.15)
