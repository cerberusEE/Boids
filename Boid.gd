# ============================================
# BOID BASE CLASS (Boid.gd)
# ============================================
# Abstract base class for all boid entities

class_name Boid
extends CharacterBody2D

var speed: float = 100.0
var size: float = 10.0
var max_force: float = 20.0
var perception_radius: float = 100.0
var world_bounds: Rect2

var separation_weight: float = 1.5
var alignment_weight: float = 1.0
var cohesion_weight: float = 1.0


func _physics_process(delta: float) -> void:
	velocity = velocity.limit_length(speed)
	move_and_slide()
	limit_world()


func limit_world() -> void:
	if global_position.x < world_bounds.position.x:
		global_position.x = world_bounds.position.x
	elif global_position.x > world_bounds.end.x:
		global_position.x = world_bounds.end.x
	
	if global_position.y < world_bounds.position.y:
		global_position.y = world_bounds.position.y
	elif global_position.y > world_bounds.end.y:
		global_position.y = world_bounds.end.y


func apply_force(force: Vector2) -> void:
	velocity += force
