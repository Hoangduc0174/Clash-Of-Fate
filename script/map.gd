extends Node2D

@onready var player := $Player
@onready var enemy := $Enemy
@onready var Map:= $"."
@onready var Box_talk := $Player/Dialouge
@onready var Camera := $Player/Camera2D
@onready var Announce := $Label
@onready var JumpButon := get_node("UI/JumpButton2")
@onready var Start_combat_zone := $Start_combat


var Level_id := 1
var fixed_y_camera :float

var start_y_announce : float
var time := 0.0

func _ready():
	JumpButon.visible = false
	type_loop(Announce, Announce.text)
	start_y_announce = Announce.position.y
	
	fixed_y_camera = Camera.global_position.y
	
	#off idle animation
	player.can_change_animation = false
	
	#on lay animation
	player.animate.play("lay")
	
	Map.modulate.a = 0.0
	
	var tween = create_tween()

	tween.tween_property(
		Map,
		"modulate:a",
		1.0,
		3.0
	)

	await tween.finished
	
	# Đợi thêm
	await get_tree().create_timer(3.0).timeout
	
	player.can_change_animation = false
	player.animate.play("sit up")
	await player.animate.animation_finished
	
	#talk
	await Box_talk.Talk(Box_talk.Player_talk, 0, 2)
	
	player.can_change_animation = true

func _process(delta: float) -> void:
	Camera_setting()
	hovering(Announce, delta)


func type_loop(label: Label, text_show: String, speed := 0.05):
	while true:
		label.text = ""

		for c in text_show:
			label.text += c
			await get_tree().create_timer(speed).timeout

		await get_tree().create_timer(1.0).timeout


func _on_start_combat_body_entered(body: Node2D) -> void:
	if body is Player:
		#stop Player
		player.can_move = false
		player.animate.play("idle")
		
		#move camera to enemy
		var tween = create_tween()

		tween.tween_property(
		Camera,
		"offset",
		Vector2(500, 0),
		1.0
	)

		#turn back camera
		tween.tween_interval(1.5)

		tween.tween_property(
		Camera,
		"offset",
		Vector2.ZERO,
		1.0
	)
	
		await tween.finished
		
		await Box_talk.Talk(Box_talk.Player_talk, 3, 3)
		
		#tra lai di chuyen cho player
		player.can_move = true
		
		#kich hoat aim. Enemy truy sat player
		enemy.target = player
		enemy.can_move = true

func _on_exit_map_body_entered(body: Node2D) -> void:
	#Exit map
		if body is Player:
			var tween := create_tween()
			tween.tween_property(Map, "modulate:a", 0, 1.0)
			player.can_move = false
			await tween.finished
			Game_state.Story_telling = 1
			get_tree().change_scene_to_file("res://scence/story.tscn")


func _on_start_combat_body_exited(body: Node2D) -> void:
	#Stop receive input
	if body is Player:
		Start_combat_zone.set_deferred("monitoring", false)
	
func Camera_setting():
	if is_instance_valid(Player):
		Camera.global_position.x = lerp(
		Camera.global_position.x,
		Camera.global_position.x, 0.2)
		Camera.global_position.y = fixed_y_camera
		

func hovering(Name, t):
	time += t
	Name.position.y = start_y_announce + sin(time * 2.0) * 5.0
