extends Area2D

signal picked(value)

@export var coin_value := 1

func _on_body_entered(body):
	if body is Player:
		picked.emit(coin_value)
		queue_free()
