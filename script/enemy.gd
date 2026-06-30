class_name Enemy
extends CharacterBody2D

@onready var player: Player = get_parent().get_node("Player")
@onready var animate: AnimatedSprite2D = $Graphics/AnimatedSprite2D
@onready var hp_bar :=$HUD/HpBar
@onready var number_hp := $HUD/LabelHp


var target: Player = null

var player_in_range := false
var can_move := false
var is_attacking := false
var dead := false

var speed := 100.0
var max_hp := 10
var hp := 10
var damage := 1


func _ready() -> void:
	animate.frame_changed.connect(_on_frame_changed)


func _physics_process(delta: float) -> void:
	if dead:
		return

	if hp <= 0:
		die()
		return

	# Tấn công
	if player_in_range and !is_attacking:
		start_attack()
		return

	# Di chuyển
	if target != null and !is_attacking:
		var dis = target.global_position.x - global_position.x

		if abs(dis) > 55:
			can_move = true
			velocity.x = sign(dis) * speed
			animate.play("move")
		else:
			can_move = false
			velocity.x = 0
			animate.play("idle")

		move_and_slide()
	else:
		velocity.x = 0
		if !is_attacking:
			animate.play("idle")


func start_attack() -> void:
	if is_attacking or dead:
		return

	is_attacking = true
	can_move = false
	velocity.x = 0

	animate.play("attack")

	await animate.animation_finished

	is_attacking = false
	can_move = true


func _on_frame_changed() -> void:
	if dead:
		return

	if animate.animation == "attack" and animate.frame == 3:
		if player_in_range:
			player.take_damage(damage)


func _on_hit_box_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_range = true

func _on_hit_box_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false


func take_damage(amount: int) -> void:
	if dead:
		return

	hp -= amount

	# Hiệu ứng bị trúng đòn
	hit_effect()
	show_damage(player.damage)
	hp_bar.value = hp
	number_hp.text = str(hp)


	if hp <= 0:
		die()


func die() -> void:
	if dead:
		return

	dead = true
	is_attacking = false
	can_move = false
	velocity = Vector2.ZERO

	animate.play("death")
	await animate.animation_finished

	queue_free()

func hit_effect():
	animate.modulate = Color(1, 0.3, 0.3) # Đỏ nhạt
	await get_tree().create_timer(0.1).timeout
	animate.modulate = Color.WHITE

func show_damage(amount: int) -> void:
	var label := Label.new()

	label.text = str(amount)
	label.position = Vector2(randf_range(-8, 8), -35)

	# Chữ
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.8, 0.0, 0.0))

	# Viền đen
	label.add_theme_constant_override("outline_size", 2)
	label.add_theme_color_override("font_outline_color", Color.BLACK)

	add_child(label)

	# Hiệu ứng
	label.scale = Vector2(1.3, 1.3)

	var tween = create_tween()
	tween.set_parallel(true)

	# Thu nhỏ về kích thước bình thường
	tween.tween_property(label, "scale", Vector2.ONE, 0.15)

	# Bay lên
	tween.tween_property(label, "position:y", label.position.y - 28, 0.6)

	# Mờ dần
	tween.tween_property(label, "modulate:a", 0.0, 0.6)

	await tween.finished
	label.queue_free()
