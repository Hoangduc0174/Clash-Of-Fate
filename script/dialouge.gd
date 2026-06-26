extends Control

@onready var Speak := $Speak

var Player_talk := [
	"Sao mình lại ở đây?",
	"Mọi thứ thật mơ hồ...",
	"Mọi người đâu cả rồi? Mình phải mau chóng tìm họ...",
	"Nó là thứ quái quỷ gì vậy?",
]

var panel: Panel
var arrow: Control
var is_active := false

func _ready() -> void:
	hide()
	
	# Cấu hình Label Speak
	Speak.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	Speak.clip_text = false
	Speak.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	Speak.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	if Speak.label_settings == null:
		Speak.label_settings = LabelSettings.new()
	Speak.label_settings.font_size = 14
	Speak.label_settings.outline_size = 3
	Speak.label_settings.outline_color = Color.BLACK
	
	# Tạo Panel nền cho khung thoại bong bóng (speech bubble)
	panel = Panel.new()
	add_child(panel)
	move_child(panel, 0) # Đặt phía sau chữ Speak
	
	var style_box = StyleBoxFlat.new()
	style_box.bg_color = Color(0.08, 0.08, 0.1, 0.85) # Nền tối mờ sang trọng
	style_box.border_width_left = 2
	style_box.border_width_top = 2
	style_box.border_width_right = 2
	style_box.border_width_bottom = 2
	style_box.border_color = Color(0.9, 0.7, 0.2, 0.95) # Viền vàng kim tinh tế
	style_box.corner_radius_top_left = 10
	style_box.corner_radius_top_right = 10
	style_box.corner_radius_bottom_left = 10
	style_box.corner_radius_bottom_right = 10
	style_box.content_margin_left = 12
	style_box.content_margin_right = 12
	style_box.content_margin_top = 8
	style_box.content_margin_bottom = 8
	panel.add_theme_stylebox_override("panel", style_box)
	
	# Tạo phần mũi tên chỉ xuống phía dưới bong bóng
	arrow = Control.new()
	arrow.draw.connect(_draw_arrow)
	panel.add_child(arrow)

func _draw_arrow() -> void:
	# Vẽ tam giác chỉ xuống
	var points = PackedVector2Array([
		Vector2(-8, -1),
		Vector2(8, -1),
		Vector2(0, 7)
	])
	var colors = PackedColorArray([
		Color(0.08, 0.08, 0.1, 0.85),
		Color(0.08, 0.08, 0.1, 0.85),
		Color(0.08, 0.08, 0.1, 0.85)
	])
	arrow.draw_polygon(points, colors)
	
	# Vẽ viền vàng cho tam giác
	arrow.draw_line(Vector2(-8, -1), Vector2(0, 7), Color(0.9, 0.7, 0.2, 0.95), 2.0)
	arrow.draw_line(Vector2(8, -1), Vector2(0, 7), Color(0.9, 0.7, 0.2, 0.95), 2.0)

func update_layout() -> void:
	var bubble_width = 240.0
	Speak.custom_minimum_size = Vector2(bubble_width - 24, 0)
	Speak.size = Vector2(bubble_width - 24, 0)
	
	# Chờ Godot cập nhật kích thước chữ tự động xuống hàng
	await get_tree().process_frame
	
	var final_height = Speak.size.y + 16
	panel.size = Vector2(bubble_width, final_height)
	
	# Căn giữa và đặt phía trên đầu nhân vật
	panel.position = Vector2(-bubble_width / 2.0, -final_height - 15)
	
	# Đặt lại vị trí chữ Speak nằm trong Panel
	Speak.position = panel.position + Vector2(12, 8)
	
	# Cập nhật vị trí mũi tên ở giữa đáy của Panel
	arrow.position = Vector2(bubble_width / 2.0, final_height)
	arrow.queue_redraw()

func Talk(Name: Array, from_index: int, to_index: int) -> void:
	show()
	is_active = true
	
	await get_tree().process_frame
	
	for i in range(from_index, to_index + 1):
		var raw_text = Name[i]
		var clean_text = raw_text
		
		# Tính toán trước kích thước khung thoại bằng cách đặt toàn bộ chữ trước
		Speak.text = clean_text
		await update_layout()
		
		# Bắt đầu hiệu ứng chạy chữ (Typewriter)
		Speak.text = ""
		var current_text = ""
		var skip_typing = false
		
		for char_idx in range(clean_text.length()):
			if skip_typing:
				break
				
			current_text += clean_text[char_idx]
			Speak.text = current_text
			
			# Đợi một khoảng thời gian nhỏ giữa các chữ
			var timer = 0.0
			var delay = 0.03
			while timer < delay:
				await get_tree().process_frame
				timer += get_process_delta_time()
				if Input.is_action_just_pressed("touch"):
					skip_typing = true
					break
		
		# Đảm bảo hiển thị toàn bộ chữ khi gõ xong hoặc bỏ qua hiệu ứng
		Speak.text = clean_text
		
		# Tránh việc vừa bấm bỏ qua chữ chạy đã chuyển tiếp ngay sang câu sau
		await get_tree().create_timer(0.15).timeout
		
		# Đợi người chơi bấm chạm màn hình tiếp theo
		while true:
			await get_tree().process_frame
			if Input.is_action_just_pressed("touch"):
				break
				
	Speak.text = ""
	hide()
	is_active = false
