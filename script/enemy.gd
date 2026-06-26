extends CharacterBody2D

@onready var animate := $AnimatedSprite2D
@onready var Hp_bar := $HUD/HpBar
@onready var Label_Hp := $HUD/LabelHp


var speed := 50.0

var max_hp := 10
var hp := 10

var damage := 10

var start_x: float
var target_x: float

var player_in_range := false
var player_area: Area2D = null

var dead := false
var can_attack := true

var hp_bg: Panel
var hp_fill: Panel

func _ready() -> void:
	randomize()
	start_x = position.x
	pick_new_target()
	animate.play("move")
	
	# Thiết lập thanh máu bằng Panel tùy chỉnh (tránh hoàn toàn lỗi kích thước của ProgressBar)
	if Hp_bar:
		Hp_bar.visible = false
		
		# Nền thanh máu (màu xám tối có viền)
		#hp_bg = Panel.new()
		#$HUD.add_child(hp_bg)
		#hp_bg.position = Vector2(-15, -28)
		#hp_bg.size = Vector2(30, 7)
		
		var style_bg = StyleBoxFlat.new()
		style_bg.bg_color = Color(0.1, 0.1, 0.1, 0.8) # Màu nền tối
		style_bg.border_width_left = 1
		style_bg.border_width_top = 1
		style_bg.border_width_right = 1
		style_bg.border_width_bottom = 1
		style_bg.border_color = Color(0, 0, 0, 0.95) # Viền đen
		style_bg.corner_radius_top_left = 2
		style_bg.corner_radius_top_right = 2
		style_bg.corner_radius_bottom_left = 2
		style_bg.corner_radius_bottom_right = 2
		#hp_bg.add_theme_stylebox_override("panel", style_bg)
		
		# Phần thanh máu màu đỏ
		
		
		
		
		
		hp_fill = Panel.new()
		$HUD.add_child(hp_fill)
		hp_fill.position = Vector2(-14, -27) # Nhích vào trong 1px để không đè viền đen
		hp_fill.size = Vector2(28, 5)
		
		var style_fill = StyleBoxFlat.new()
		style_fill.bg_color = Color(0.85, 0.15, 0.15) # Đỏ rực
		style_fill.corner_radius_top_left = 1
		style_fill.corner_radius_top_right = 1
		style_fill.corner_radius_bottom_left = 1
		style_fill.corner_radius_bottom_right = 1
		hp_fill.add_theme_stylebox_override("panel", style_fill)
		
	# Đặt nhãn HP vào giữa bên trong thanh máu
	#if Label_Hp:
		# Đảm bảo nhãn HP luôn nằm trên cùng (được vẽ sau các Panel)
		#$HUD.move_child(Label_Hp, -1)
		
		#Label_Hp.position = Vector2(-15, -29)
		#Label_Hp.size = Vector2(30, 7)
		#Label_Hp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		#Label_Hp.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		
		#if Label_Hp.label_settings == null:
			#Label_Hp.label_settings = LabelSettings.new()
		#Label_Hp.label_settings.font_size = 5
		#Label_Hp.label_settings.outline_size = 3
		#Label_Hp.label_settings.outline_color = Color.BLACK
		#Label_Hp.text = str(hp)


func _physics_process(delta: float) -> void:
	if dead:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# cleanup invalid ref
	if player_area != null and not is_instance_valid(player_area):
		player_area = null
		player_in_range = false

	# ===== ATTACK STATE LOCK =====
	if animate.animation == "attack":
		velocity.x = 0

		if player_area != null and is_instance_valid(player_area):
			var player = player_area.get_parent()
			if player != null:
				var dir = sign(player.global_position.x - global_position.x)
				if dir != 0:
					animate.flip_h = dir < 0

		move_and_slide()
		return

	# ===== MOVE =====
	var dir_move = sign(target_x - position.x)
	velocity.x = dir_move * speed

	if abs(target_x - position.x) < 5:
		pick_new_target()

	if dir_move != 0:
		animate.flip_h = dir_move < 0

	move_and_slide()


func pick_new_target() -> void:
	target_x = start_x + randf_range(-100, 100)


# ===== ENTER RANGE =====
func _on_hitbox_area_entered(area: Area2D) -> void:
	if dead:
		return

	player_in_range = true
	player_area = area

	if animate.animation != "attack":
		animate.play("attack")


# ===== EXIT RANGE =====
func _on_hitbox_area_exited(area: Area2D) -> void:
	if dead:
		return

	if area == player_area:
		player_in_range = false
		player_area = null


# ===== ANIMATION LOOP =====
func _on_animated_sprite_2d_animation_finished() -> void:
	if dead:
		return

	if animate.animation == "attack":
		if player_in_range and player_area != null and is_instance_valid(player_area):

			var player = player_area.get_parent()

			if player == null or not player.has_method("take_damage"):
				player_in_range = false
				player_area = null
				animate.play("move")
				return

			if can_attack:
				player.take_damage(damage)

				can_attack = false
				get_tree().create_timer(0.5).timeout.connect(func():
					can_attack = true
				)

			animate.play("attack")

		else:
			player_in_range = false
			player_area = null
			animate.play("move")


# ===== HP SYSTEM =====
func take_damage(amount: int) -> void:
	if dead:
		return

	hp -= amount
	hp = clamp(hp, 0, max_hp)
	
	# Cập nhật số máu
	Label_Hp.text = str(hp)
	
	# Tween thanh máu mượt mà
	if hp_fill:
		var target_width = (float(hp) / max_hp) * 28.0
		if hp <= 0:
			target_width = 0.0
		var hp_tween = create_tween()
		hp_tween.tween_property(hp_fill, "size:x", target_width, 0.2)
		
	# 1. Hiệu ứng nháy đỏ khi trúng đòn (modulate flash)
	var flash_tween = create_tween()
	animate.modulate = Color(5.0, 1.0, 1.0, 1.0) # Nháy đỏ phát sáng
	flash_tween.tween_property(animate, "modulate", Color.WHITE, 0.15)
	
	# 2. Hiệu ứng rung giật (sprite shake)
	var orig_pos = animate.position
	var shake_tween = create_tween()
	shake_tween.tween_property(animate, "position", orig_pos + Vector2(-4, 0), 0.04)
	shake_tween.tween_property(animate, "position", orig_pos + Vector2(4, 0), 0.04)
	shake_tween.tween_property(animate, "position", orig_pos + Vector2(-2, 0), 0.04)
	shake_tween.tween_property(animate, "position", orig_pos + Vector2(2, 0), 0.04)
	shake_tween.tween_property(animate, "position", orig_pos, 0.04)
	
	# 3. Hiệu ứng nảy số sát thương (damage popups)
	spawn_damage_number(amount)
		
	if hp <= 0:
		die()

func spawn_damage_number(amount: int) -> void:
	var label = Label.new()
	label.text = str(amount)
	
	# Định dạng chữ số sát thương
	var settings = LabelSettings.new()
	settings.font = load("res://assets/flappyfont.TTF")
	settings.font_size = 11
	settings.font_color = Color(1.0, 0.25, 0.25) # Đỏ cam tươi
	settings.outline_size = 3
	settings.outline_color = Color.BLACK
	label.label_settings = settings
	
	$HUD.add_child(label)
	label.position = Vector2(randf_range(-12, 12), -50)
	
	# Tween bay lên và mờ dần
	var num_tween = create_tween()
	num_tween.set_parallel(true)
	num_tween.tween_property(label, "position:y", label.position.y - 25.0, 0.5)
	num_tween.tween_property(label, "modulate:a", 0.0, 0.5)
	
	# Tự động xóa sau khi bay xong
	await num_tween.finished
	label.queue_free()


# ===== DEATH (FIX CHẮC CHẮN) =====
func die() -> void:
	if dead:
		return

	dead = true
	player_in_range = false
	player_area = null
	can_attack = false

	velocity = Vector2.ZERO

	animate.stop()
	animate.play("death")

	# GUARANTEED REMOVE (không phụ thuộc signal)
	await get_tree().create_timer(1.3).timeout
	queue_free()
