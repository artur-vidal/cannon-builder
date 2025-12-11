class_name BarrelGroup
extends Node

var current_barrel: CannonBarrel = null
var current_barrel_index: int
@onready var barrels: Array = get_children()

func is_empty() -> bool:
	return barrels.size() == 0

func set_barrel() -> void:
	current_barrel = barrels[current_barrel_index] if barrels.size() > 0 else null

func next_barrel() -> void:
	current_barrel_index += 1
	current_barrel_index = wrap(current_barrel_index, 0, barrels.size())
	set_barrel()

func _ready() -> void:
	current_barrel_index = 0
	set_barrel()
