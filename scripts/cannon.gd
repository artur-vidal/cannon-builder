class_name BaseCannon
extends Area2D

@export var move_speed: float = 400.0
@export var move_smoothness : float = 10.0
@export var knockback_force: float = 0.0

@onready var barrel_group: BarrelGroup = $BarrelGroup

var bullet_scene = preload("res://scenes/cannons/bullet.tscn")

var velocity: Vector2
var can_shoot: bool = true

func apply_knockback(barrel: CannonBarrel) -> void:
	var shoot_direction = Vector2.from_angle(barrel.global_rotation)
	velocity -= shoot_direction * barrel.knockback_force

func create_shoot_effect(barrel: CannonBarrel) -> void:
	barrel.shoot_effect()

func create_bullet(barrel: CannonBarrel) -> void:
	# Criando informações do(s) tiro(s), definidas depois para cada CannonBarrel
	var bullet_stats = BulletStats.new()
	bullet_stats.load_from_barrel(barrel)
	
	var marker_pos = barrel.marker.global_position
	var bullet_pos = marker_pos
	var bullet_direction = (marker_pos - barrel.global_position).normalized()
	
	var new_bullet: BaseBullet = bullet_scene.instantiate()
	new_bullet.position = bullet_pos
	new_bullet.direction = bullet_direction
	new_bullet.load_stats(bullet_stats)
	new_bullet.scale = Vector2(barrel.scale.y, barrel.scale.y) * 1.2
	
	get_tree().root.add_child(new_bullet)

func shoot(barrel: CannonBarrel) -> void:
	create_shoot_effect(barrel)
	create_bullet(barrel)

func _physics_process(delta: float) -> void:
	
	# Movimento
	var input_dir: Vector2 = Input.get_vector("left", "right", "up", "down")
	
	var target_velocity = input_dir * move_speed
	velocity = velocity.lerp(target_velocity, move_smoothness * delta)
	
	position += velocity * delta
	
	# Rotação (olhar pro mouse)
	var rot_direction = get_global_mouse_position() - global_position
	rotation = atan2(rot_direction.y, rot_direction.x) + PI / 2
	
	# Diminuindo cada timer
	for barrel: CannonBarrel in barrel_group.barrels:
		if barrel.reload_current > 0:
			barrel.reload_current -= delta
		
		while can_shoot  and barrel.reload_current <= 0:
			apply_knockback(barrel)
			shoot(barrel)
			barrel_group.next_barrel()
			barrel.reload_current += barrel.reload_time
