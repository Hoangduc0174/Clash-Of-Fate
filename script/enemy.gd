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
	if target != null:
		var dist = target.global_position.x - global_position.x
		
		#tranh player day lui enemy khi va cham
		if abs(dist) > 40: # khoảng cách dừng
			velocity.x = sign(dist) * speed
		else:
			velocity.x = 0
	move_and_slide()

	#animation
	if not can_move:
		animate.play("idle")
	else:
		animate.play("move")
