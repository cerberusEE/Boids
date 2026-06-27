# ============================================
# PREDATOR CLASS (Predator.gd)
# ============================================
# Attach to a Sprite2D or Area2D node

class_name Predator
extends Boid

# Visual settings
@export var color: Color = Color(0.8, 0.2, 0.2)

# Hunting settings
@export var chase_radius: float = 200.0

var prey_list: Array = []
var target_prey: Prey


func _ready() -> void:
	$Sprite2D.modulate = color
	$CollisionShape2D.shape.radius = 2


func _physics_process(delta: float) -> void:
	# Find closest prey within chase radius
	target_prey = find_closest_prey()
	
	if target_prey:
		# Chase the prey
		var direction: Vector2 = (target_prey.global_position - global_position).normalized()
		velocity = direction * speed
	else:
		# Random wandering when no prey is near
		if randf() < 0.02:  # 2% chance per frame to change direction
			velocity = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * speed
	
	super(delta)


func find_closest_prey() -> Prey:
	var closest: Prey = null
	var min_distance: float = INF
	
	for prey in prey_list:
		var distance: float = global_position.distance_to(prey.global_position)
		if distance < chase_radius and distance < min_distance:
			min_distance = distance
			closest = prey
	
	return closest
