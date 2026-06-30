extends CanvasLayer

@onready var player := get_parent().get_node("Player")
@onready var hp_bar: TextureProgressBar = $HUD/Hp_bar
@onready var hud := $HUD
@onready var avarta = $HUD/Avarta

var hud_pos: Vector2
var current_hp := -1

func _ready() -> void:
	hud_pos = hud.position
	current_hp = player.hp
	hp_bar.max_value = player.max_hp
	hp_bar.value = player.hp

	setting_for_pc()


func _process(_delta):
	if current_hp != player.hp:
		current_hp = player.hp
		update_hp()
		shake_hud()
		flash_avarta()


func update_hp():
	var tween = create_tween()
	tween.tween_property(hp_bar, "value", player.hp, 0.25)


func shake_hud():
	var tween = create_tween()

	for i in 8:
		tween.tween_property(
			hud,
			"position",
			hud_pos + Vector2(randf_range(-10, 10), randf_range(-3, 3)),
			0.015
		)

	tween.tween_property(hud, "position", hud_pos, 0.02)

func flash_avarta():
	var tween = create_tween()

	# Đổi sang đỏ
	avarta.modulate = Color(1, 0.2, 0.2, 1)

	# Từ từ trở lại màu trắng
	tween.tween_property(
		avarta,
		"modulate",
		Color(1, 1, 1, 1),
		0.3
	)

func setting_for_pc():
	if !DisplayServer.is_touchscreen_available():
		if has_node("AttackButon"):
			$AttackButon.visible = false

		if has_node("JumpButton2"):
			$JumpButton2.visible = false

		if has_node("Virtual Joystick"):
			$"Virtual Joystick".visible = false
