class_name Player
extends CharacterBody2D

@onready var animate: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox

const SPEED := 400.0
const JUMP_VELOCITY := -1300.0
const GRAVITY := 50.0

var is_attacking := false
var combo_attack := false
var air_attack := false
var count_combo := 0

var damage := 1
var max_hp := 100
var hp := 100

var can_move := true
var can_change_animation := true


@warning_ignore("unused_parameter")
func _physics_process(delta: float) -> void:

	# Reset số lần air attack khi chạm đất
	if is_on_floor():
		count_combo = 0

	# Lock move
	if !can_move:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Gravity
	if !is_on_floor() and !air_attack:
		velocity.y += GRAVITY

	# Out map
	if global_position.y > 1200:
		die()
		return

	# Jump
	if Input.is_action_pressed("jump") and is_on_floor() and can_change_animation:
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")

	# Attack
	if can_change_animation:

		if !is_attacking:

			if Input.is_action_pressed("attack"):

				# Trên không chỉ cho full attack 2 lần
				if !is_on_floor() and count_combo >= 2:
					pass
				else:
					start_attack()

		elif Input.is_action_just_pressed("attack"):
			combo_attack = true

	# Movement
	if is_attacking:

		velocity.x = 0

		if air_attack:
			velocity.y = 0

	else:

		if direction != 0 and can_change_animation:
			velocity.x = direction * SPEED
			animate.flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0.0, SPEED)

	# Animation
	if can_change_animation:

		if is_attacking:

			if animate.animation != "attack":
				animate.play("attack")

		elif !is_on_floor():

			if animate.animation != "jump":
				animate.play("jump")

		elif direction != 0:

			if animate.animation != "run":
				animate.play("run")

		else:

			if animate.animation != "idle":
				animate.play("idle")

	move_and_slide()


func start_attack() -> void:

	is_attacking = true
	combo_attack = false

	# Attack trên không
	if !is_on_floor():
		air_attack = true

	animate.play("attack")

	# Damage
	for area in hitbox.get_overlapping_areas():

		var enemy = area.get_parent()

		if enemy != null and enemy.has_method("take_damage"):
			enemy.take_damage(damage)

	# Chờ tới frame 3
	while animate.frame < 3:
		await get_tree().process_frame

	# Full attack
	if Input.is_action_pressed("attack") or combo_attack:

		# Đếm số lần full attack trên không
		if !is_on_floor():
			count_combo += 1

		await animate.animation_finished

	# Attack thường
	else:

		animate.play("idle")

	is_attacking = false
	air_attack = false


func take_damage(amount: int) -> void:

	hp -= amount
	hp = clamp(hp, 0, max_hp)

	if hp <= 0:
		die()


func die() -> void:
	queue_free()
