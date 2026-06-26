extends CanvasLayer

@onready var Text_box := $Text_box
@onready var Touch := $Touch
@onready var Story_telling := $Story_telling

#Story_telling
var Story_telling_map_0 = Game_state.Story_telling


func _ready() -> void:
	Text_box.modulate.a = 0.0
	
	#khoi dong map 0
	if Game_state.current_map == 0 and Story_telling_map_0 == 0:
		Text_box.text = "Chương 1: Tỉnh Dậy"

		Touch.modulate.a = 0

		#fade in
		await fade_in(Text_box, 1.5)
		await get_tree().create_timer(2.0).timeout
		
		Touch.modulate.a = 0.5
		blink(Touch, 0.5)
		
		await get_tree().create_timer(0.3).timeout
		
		#cham de tiep tuc
		while not Input.is_action_just_pressed("touch"):
			await get_tree().process_frame
		
		fade_out(Text_box, 1.5)
		await fade_out(Touch, 1.5)
		
		get_tree().change_scene_to_file("res://scence/game.tscn")
	
	#Khoi dong map 1
	if Game_state.current_map == 0 and Story_telling_map_0 == 1:
		Story_telling.modulate.a = 0
		Touch.modulate.a = 0
		Story_telling.text = "Sau khi tìm kiếm khắp lâu đài nhưng không thấy ai\nanh cảm thấy vô cùng hoang mang\nHiệp Sĩ vô danh quyết định ra khỏi lâu đài..."
		await fade_in(Story_telling, 1.5)
		await get_tree().create_timer(2.0).timeout
		
		Touch.modulate.a = 0.5
		blink(Touch, 0.5)
		
		#cham de tiep tuc
		while not Input.is_action_just_pressed("touch"):
			await get_tree().process_frame
		
		fade_out(Story_telling, 1.5)
		await fade_out(Touch, 1.5)

func blink(Name, Duration):
	var tween = create_tween()
	tween.set_loops()

	tween.tween_property(
		Name,
		"modulate:a",
		0.2,
		Duration
	)

	tween.tween_property(
		Name,
		"modulate:a",
		1.0,
		Duration
	)

func fade_out(Name, Duration):
	var tween = create_tween()

	tween.tween_property(
		Name,
		"modulate:a",
		0.0,
		Duration
	)

	await tween.finished

func fade_in(Name, Duration):
	var tween = create_tween()

	tween.tween_property(
		Name,
		"modulate:a",
		1.0,
		Duration
	)

	await tween.finished
