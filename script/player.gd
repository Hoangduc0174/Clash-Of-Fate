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
var max_hp := 10
var hp := 10

var can_move := true
#ngan animtion khac chen vao
var can_change_animation := true
var enemy_in_range = []
var	is_dead = false
var is_hurt := false

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

	# Jump
	if Input.is_action_pressed("jump") and is_on_floor() and can_change_animation:
		velocity.y = JUMP_VELOCITY

	#lay input move
	var direction := Input.get_axis("ui_left", "ui_right")

	# Attack
	if can_change_animation:

		if !is_attacking:
			if Input.is_action_pressed("attack"):

				# Trên không chỉ cho full attack 1
				if !is_on_floor() and count_combo >= 1:
					pass
				else:
					start_attack()

		elif Input.is_action_just_pressed("attack"):
			combo_attack = true

	# neu dang tan cong
	if is_attacking:
		#ko di chuyen
		velocity.x = 0
		
		#neu dang tan cong tren khong cung ko di chuyen
		if air_attack:
			velocity.y = 0
	else:
		#xoay animation run
		if direction != 0 and can_change_animation:
			velocity.x = direction * SPEED
			animate.flip_h = direction < 0
			if animate.flip_h:
				hitbox.scale.x = -1
			else:
				hitbox.scale.x = 1
		else:
			velocity.x = move_toward(velocity.x, 0.0, SPEED)

	# Animation
	if can_change_animation and !is_hurt:
		#neu bi gay damage
		if is_hurt:
			if animate.animation != "hurt":
				animate.play("hurt")
		#neu dang attack
		elif is_attacking:
			#chua bat animation attack thi bat len
			if animate.animation != "attack":
				animate.play("attack")
		
		#neu dang nhay
		elif !is_on_floor():
			#chua bat animation jump thi bat len
			if animate.animation != "jump":
				animate.play("jump")
		
		#neu di chuyen
		elif direction != 0:
			#chua bat animation run thi bat len
			if animate.animation != "run":
				animate.play("run")

		#ko lam j ca
		else:
			#chua bat animation idle thi bat len
			if animate.animation != "idle":
				animate.play("idle")

#xu li va cham
	move_and_slide()


func start_attack() -> void:

	is_attacking = true
	combo_attack = false

	# Attack trên không
	if !is_on_floor():
		air_attack = true

	animate.play("attack")
	
	# Gây sát thương
	for enemy in enemy_in_range:
		if is_instance_valid(enemy):
			enemy.take_damage(damage)

	#cho toi frame thu 3 thi bat dau doi de noi combo
	while animate.frame < 3:
		await get_tree().process_frame

	# Full attack combk
	if Input.is_action_pressed("attack") or combo_attack:

		# Đếm số lần full attack trên không
		if !is_on_floor():
			count_combo += 1

		await animate.animation_finished

	is_attacking = false
	air_attack = false


func take_damage(amount: int) -> void:
	if is_dead:
		return
	
	hp -= amount
	hp = clamp(hp, 0, max_hp)

	if hp <= 0:
		die()
		return
	
	start_hurt()

func start_hurt() -> void:
	is_hurt = true
	can_change_animation = false
	can_move = false
	is_attacking = false

	animate.play("hurt")
	await animate.animation_finished

	can_change_animation = true
	can_move = true
	is_hurt = false

func die() -> void:
	if is_dead:
		return
	
	can_move = false
	is_attacking = false
	can_change_animation =false
	
	animate.play("death")
	await animate.animation_finished
	is_dead = true

func _on_hitbox_body_entered(body):
	if body.has_method("take_damage"):
		enemy_in_range.append(body)

func _on_hitbox_body_exited(body):
	enemy_in_range.erase(body)
