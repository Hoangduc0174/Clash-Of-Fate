extends Node2D



func _ready() -> void:
	if Game_state.current_map == 0 :
		get_tree().change_scene_to_file("res://scence/map_boot.tscn")
