# ============================================
# PREY CLASS (Prey.gd)
# ============================================
# Attach to a CharacterBody2D node with:
# - Sprite2D
# - CollisionShape2D (radius = prey_size)
# - Area2D (for collision detection)

class_name Prey
extends Boid

# Visual settings
@export var color: Color = Color(0.2, 0.8, 0.3)

var neighbors: Array = []
var prey_list: Array = []
var predator_list: Array = []

# Collision signal
signal prey_eaten(prey)


func _ready() -> void:
	$Sprite2D.modulate = color
	# Setup collision detection with predators
	$Area2D/CollisionShape2D2.shape.radius = size*1.1
	$Area2D.connect("body_entered", Callable(self, "_on_body_entered"))
	$Area2D.monitoring = true
	$Area2D.monitorable = true


func _physics_process(delta: float) -> void:
	# Find nearby prey (same species)
	neighbors = get_neighbors_in_range(prey_list, perception_radius)
	
	# Apply Boids rules
	var separation = separate() * separation_weight
	var alignment = align() * alignment_weight
	var cohesion = cohere() * cohesion_weight
	
	# Combine forces
	var steering = separation + alignment + cohesion
		
	if steering.length() < 1 && randf() < 0.02:  # 2% chance per frame to change direction
		steering = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * speed

	# Avoid predators - STRONGER WEIGHT
	var predator_avoidance = avoid_predators() * 3.0
	steering += predator_avoidance
	
	# Apply steering with limit
	if steering.length() > 0:
		steering = steering.normalized() * max_force
	apply_force(steering)
	
	super(delta)


# Collision detection
func _on_body_entered(body: Node2D) -> void:
	if body is Predator:
		prey_eaten.emit(self)


func get_neighbors_in_range(targets: Array, radius: float) -> Array:
	var result: Array = []
	for target in targets:
		if target == self:
			continue
		if target == null:  # Skip null entries (removed prey)
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
			# STRONGER separation at close range
			steering += diff * cos(min(distance/10,1))
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
		# Smoother cohesion with distance scaling
		var distance_to_center = (center - global_position).length()
		steering = (center - global_position).normalized() * speed * min(distance_to_center / 50.0, 1.0) - velocity
	return steering


func avoid_predators() -> Vector2:
	var steering: Vector2 = Vector2.ZERO
	var total: int = 0
	
	for predator in predator_list:
		if predator == null:
			continue
		var diff: Vector2 = global_position - predator.global_position
		var distance: float = diff.length()
		if distance < perception_radius * 2.0 and distance > 0:
			# STRONGER avoidance when predator is very close
			var avoidance_strength = 1.0 / max(distance, 1.0)
			steering += diff.normalized() * avoidance_strength
			total += 1
	
	if total > 0:
		steering = steering / total
		steering = steering.normalized() * speed
	return steering
