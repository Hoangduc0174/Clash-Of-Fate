extends Control

@onready var label_coin = $LabelCoin

var coin_count := 0

func _ready():
	for child in get_node("/root/Game/Map").get_children():
		if child.has_signal("picked"):
			child.picked.connect(_on_coin_picked)

func _on_coin_picked(value):
	coin_count += value
	label_coin.text = str(coin_count)
