# ============================================
# PREDATOR CLASS (Predator.gd)
# ============================================
# Attach to a CharacterBody2D node with:
# - Sprite2D
# - CollisionShape2D (radius = predator_size)
# - Area2D (for collision detection)

class_name Predator
extends Boid

# Visual settings
@export var color: Color = Color(0.8, 0.2, 0.2)

# Hunting settings
@export var chase_radius: float = 250.0

var prey_list: Array = []
var target_prey: Prey

# Collision signal
signal prey_caught(predator, prey)


func _ready() -> void:
	$Sprite2D.modulate = color
	$CollisionShape2D.shape.radius = 4
	# Setup collision detection
	$Area2D.connect("body_entered", Callable(self, "_on_body_entered"))
	$Area2D.monitoring = true
	$Area2D.monitorable = true


func _physics_process(delta: float) -> void:
	# Find closest prey within chase radius
	target_prey = find_closest_prey()
	
	if target_prey:
		# Chase the prey
		var direction: Vector2 = (target_prey.global_position - global_position).normalized()
		velocity = direction * speed
	else:
		# Random wandering when no prey is near
		if randf() < 0.01:  # Less frequent direction changes
			velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * speed
	
	super(delta)


# Collision detection
func _on_body_entered(body: Node2D) -> void:
	if body is Prey:
		prey_caught.emit(self, body)


func find_closest_prey() -> Prey:
	var closest: Prey = null
	var min_distance: float = INF
	
	for prey in prey_list:
		if prey == null:
			continue
		var distance: float = global_position.distance_to(prey.global_position)
		if distance < chase_radius and distance < min_distance:
			min_distance = distance
			closest = prey
	
	return closest
