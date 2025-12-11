class_name BulletStats
extends Object

# Movimento
var move_speed: float

func load_from_barrel(barrel: CannonBarrel) -> void:
	move_speed = barrel.bullet_speed
