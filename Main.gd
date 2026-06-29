
# ============================================
# MAIN SCENE SETUP (Main.gd)
# ============================================
# Create a Node2D root node and attach this script

extends Node2D

# Prey settings
@export var prey_count: int = 200
@export var prey_speed: float = 50.0
@export var prey_perception: float = 100.0
@export var prey_size: float = 3.0

# Predator settings
@export var predator_count: int = 5
@export var predator_speed: float = 200.0
@export var predator_perception: float = 200.0
@export var predator_size: float = 4.0

# Boids weights - TUNED FOR BETTER FLOCKING
@export var separation_weight: float = 1.2  # Prevent crowding
@export var alignment_weight: float = 1.5  # Stronger direction matching
@export var cohesion_weight: float = 1.3  # Stronger grouping

# World bounds
@export var world_bounds: Rect2 = Rect2(0, 0, 1200, 800)

var prey_scene: PackedScene
var predator_scene: PackedScene
var prey_list: Array = []
var predator_list: Array = []


func _ready():
	prey_scene = preload("res://Prey.tscn")
	predator_scene = preload("res://Predator.tscn")
	var rng = RandomNumberGenerator.new()
	
	# Spawn prey
	for i in range(prey_count):
		var prey = prey_scene.instantiate()
		prey.position = Vector2(rng.randi_range(0, world_bounds.size.x), rng.randi_range(0, world_bounds.size.y))
		prey.speed = prey_speed
		prey.size = prey_size
		prey.separation_weight = separation_weight
		prey.alignment_weight = alignment_weight
		prey.cohesion_weight = cohesion_weight
		prey.world_bounds = world_bounds
		prey.perception_radius = prey_perception
		prey.prey_list = prey_list
		prey.predator_list = predator_list
		prey.connect("prey_eaten", Callable(self, "_on_prey_eaten"))  # Connect collision signal
		prey_list.append(prey)
		add_child(prey)
	
	# Spawn predators
	for i in range(predator_count):
		var predator = predator_scene.instantiate()
		predator.position = Vector2(rng.randi_range(0, world_bounds.size.x), rng.randi_range(0, world_bounds.size.y))
		predator.speed = predator_speed
		predator.size = predator_size
		predator.world_bounds = world_bounds
		predator.prey_list = prey_list
		predator.perception_radius = predator_perception
		predator.connect("prey_caught", Callable(self, "_on_prey_caught"))  # Connect collision signal
		predator_list.append(predator)
		add_child(predator)


# Handle prey eaten by predator
func _on_prey_eaten(prey: Prey):
	if prey_list.has(prey):
		prey_list.erase(prey)
		prey.queue_free()
		
		var rng = RandomNumberGenerator.new()
		# Spawn a new prey to maintain population
		var new_prey = prey_scene.instantiate()
		new_prey.position = Vector2(rng.randi_range(0, world_bounds.size.x), rng.randi_range(0, world_bounds.size.y))
		new_prey.speed = prey_speed
		new_prey.separation_weight = separation_weight
		new_prey.alignment_weight = alignment_weight
		new_prey.cohesion_weight = cohesion_weight
		new_prey.world_bounds = world_bounds
		new_prey.perception_radius = prey_perception
		new_prey.prey_list = prey_list
		new_prey.predator_list = predator_list
		new_prey.connect("prey_eaten", Callable(self, "_on_prey_eaten"))
		prey_list.append(new_prey)
		add_child(new_prey)
