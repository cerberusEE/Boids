# ============================================
# PREY CLASS (Prey.gd)
# ============================================
# Attach to a Sprite2D or Area2D node

class_name Prey
extends Boid

# Visual settings
@export var color: Color = Color(0.2, 0.8, 0.3)

var neighbors: Array = []
var prey_list: Array = []
var predator_list: Array = []


func _ready() -> void:
	$Sprite2D.modulate = color
	$CollisionShape2D.shape.radius = 2


func _physics_process(delta: float) -> void:
	# Find nearby prey (same species)
	neighbors = get_neighbors_in_range(prey_list, perception_radius)
		
	# Apply Boids rules
	var separation = separate() * separation_weight
	var alignment = align() * alignment_weight
	var cohesion = cohere() * cohesion_weight
	
	# Combine forces
	var steering = separation + alignment + cohesion
	
	# Avoid predators
	var predator_avoidance = avoid_predators() * 2.0
	steering += predator_avoidance
	
	
	if steering.length() < 1 && randf() < 0.02:  # 2% chance per frame to change direction
		steering = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * speed
	
	# Apply steering with limit
	if steering.length() > 0:
		steering = steering.normalized() * max_force
	apply_force(steering)
	
	super(delta)


func get_neighbors_in_range(targets: Array, radius: float) -> Array:
	var result: Array = []
	for target in targets:
		if target == self:
			continue
		if global_position.distance_to(target.global_position) < radius:
			result.append(target)
	return result


func separate() -> Vector2:
	var steering: Vector2 = Vector2.ZERO
	var total: int = 0
	
	for neighbor in neighbors:
		var diff: Vector2 = global_position - neighbor.global_position
		var distance: float = diff.length()
		if distance > 0:
			steering += diff.normalized() / distance
			total += 1
	
	if total > 0:
		steering = steering / total
		steering = steering.normalized() * speed - velocity
	return steering


func align() -> Vector2:
	var steering: Vector2 = Vector2.ZERO
	var total: int = 0
	
	for neighbor in neighbors:
		steering += neighbor.velocity.normalized()
		total += 1
	
	if total > 0:
		steering = steering / total
		steering = steering.normalized() * speed - velocity
	return steering


func cohere() -> Vector2:
	var steering: Vector2 = Vector2.ZERO
	var center: Vector2 = Vector2.ZERO
	var total: int = 0
	
	for neighbor in neighbors:
		center += neighbor.global_position
		total += 1
	
	if total > 0:
		center = center / total
		steering = (center - global_position).normalized() * speed - velocity
	return steering


func avoid_predators() -> Vector2:
	var steering: Vector2 = Vector2.ZERO
	var total: int = 0
	
	for predator in predator_list:
		var diff: Vector2 = global_position - predator.global_position
		var distance: float = diff.length()
		if distance < perception_radius * 1.5 and distance > 0:
			steering += diff.normalized() / distance
			total += 1
	
	if total > 0:
		steering = steering / total
		steering = steering.normalized() * speed
	return steering
