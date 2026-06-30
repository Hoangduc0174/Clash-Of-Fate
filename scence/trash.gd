extends CharacterBody2D

@onready var animate: AnimatedSprite2D = $AnimatedSprite2D
@onready var Hp_bar = $HUD/HpBar
@onready var Label_Hp = $HUD/LabelHp

# ===== STATS =====
var speed: float = 100.0
var max_hp: int = 10
var hp: int = 10
var damage: int = 10

# ===== MOVE =====
var can_move := true
var can_change_animation := true

# ===== STATE =====
var dead: bool = false
var player_in_range: bool = false
var player_area: Area2D = null
var can_attack: bool = true
var is_attacking: bool = false

#khoa muc tieu
var target = null

func _physics_process(delta: float) -> void:
		#bam theo player(dung rieng cho 1 so tinh huong dac biet)
		#ko muon enemy bam theo nx thi cho target = null
		#neu con song
		if hp > 0:
				if target != null:
						var dist = target.global_position.x - global_position.x

						#tranh player day lui enemy khi va cham
						if abs(dist) > 40: # khoảng cách dừng
								velocity.x = sign(dist) * speed
						else:
								velocity.x = 0
		move_and_slide()

		#animation
		if can_change_animation:
				if not can_move:
						animate.play("idle")
				else:
						animate.play("move")

func take_damage(amount: int) -> void:

		hp -= amount
		hp = clamp(hp, 0, max_hp)

		if hp <= 0:
				die()

func die():
		can_change_animation = false
		animate.play("death")
		await animate.animation_finished
		queue_free()
