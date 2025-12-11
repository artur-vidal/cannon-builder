class_name CannonBarrel
extends Node2D

var bullet_scene = preload("res://scenes/cannons/bullet.tscn")

@onready var marker: Marker2D = $Marker2D
@onready var sprite: Sprite2D = $Sprite2D

@onready var original_scale: Vector2 = sprite.scale
var scale_tween: Tween

@export_category("Barrel")
@export var reload_time: float = 1.0
@export var initial_delay: float = 0.5
@export var knockback_force: float = 0.0

@export_category("Bullet Stats")
@export var bullet_speed: float = 300.0

@onready var reload_current: float = initial_delay

var cannon: BaseCannon

func _ready() -> void:
	cannon = get_tree().get_first_node_in_group("Cannons")

func shoot_effect() -> void:
	sprite.scale = original_scale * Vector2(.5, 1.25)
	
	if scale_tween:
		scale_tween.kill()
	
	scale_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	scale_tween.tween_property(sprite, "scale", original_scale, .75)
