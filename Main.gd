# Boids 2D Game with Prey and Predators
# Godot 4.x GDScript Implementation

# ============================================
# MAIN SCENE SETUP (Main.tscn)
# ============================================
# Create a Node2D root node and attach this script

extends Node2D

# Prey settings
@export var prey_count: int = 200
@export var prey_speed: float = 20.0
@export var prey_perception: float = 100

# Predator settings
@export var predator_count: int = 5
@export var predator_speed: float = 20.0
@export var predator_perception: float = 150

# Boids weights
@export var separation_weight: float = 0.5
@export var alignment_weight: float = 1.0
@export var cohesion_weight: float = 1.0

# World bounds
@export var world_bounds: Rect2 = Rect2(0, 0, 1000, 800)

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
		prey.position = Vector2(rng.randi_range(0, 1000), rng.randi_range(0, 1000))
		prey.speed = prey_speed
		prey.separation_weight = separation_weight
		prey.alignment_weight = alignment_weight
		prey.cohesion_weight = cohesion_weight
		prey.world_bounds = world_bounds
		prey.perception_radius = prey_perception
		prey_list.append(prey)
		add_child(prey)
	
	# Spawn predators
	for i in range(predator_count):
		var predator = predator_scene.instantiate()
		predator.position = Vector2(rng.randi_range(0, 1000), rng.randi_range(0, 1000))
		predator.speed = predator_speed
		predator.world_bounds = world_bounds
		predator.prey_list = prey_list
		predator.perception_radius = predator_perception
		predator_list.append(predator)
		add_child(predator)
