class_name BaseBullet
extends Area2D

var move_speed: float = 300.0
var velocity: Vector2
var direction: Vector2


func load_stats(stats: BulletStats) -> void:
	move_speed = stats.move_speed

func calculate_stats() -> void:
	velocity = move_speed * direction

func _ready() -> void:
	calculate_stats.call_deferred()

func _physics_process(delta: float) -> void:
	position += velocity * delta
	
	# Destruindo se sair da viewport
	var view_rect = get_viewport_rect()
	if not view_rect.grow(20).has_point(global_position):
		queue_free()
