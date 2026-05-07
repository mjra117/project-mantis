extends CharacterBody2D

const SPEED := 200.0
const MAP_W := 72
const MAP_H := 78
const T := 32

var mission_open: bool = false
var _camera: Camera2D

func _ready() -> void:
	# Set up camera
	_camera = Camera2D.new()
	_camera.zoom = Vector2(1.8, 1.8)
	_camera.limit_left = 0
	_camera.limit_top = 0
	_camera.limit_right = MAP_W * T
	_camera.limit_bottom = MAP_H * T
	_camera.position_smoothing_enabled = true
	_camera.position_smoothing_speed = 8.0
	add_child(_camera)

func _physics_process(_delta: float) -> void:
	if mission_open:
		velocity = Vector2.ZERO
		return

	var dir := Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		dir.y -= 1.0
	if Input.is_action_pressed("move_down"):
		dir.y += 1.0
	if Input.is_action_pressed("move_left"):
		dir.x -= 1.0
	if Input.is_action_pressed("move_right"):
		dir.x += 1.0

	if dir.length_squared() > 0.0:
		dir = dir.normalized()

	velocity = dir * SPEED
	move_and_slide()
	# Clamp to map bounds (give small margin)
	position.x = clampf(position.x, 16.0, MAP_W * T - 16.0)
	position.y = clampf(position.y, 16.0, MAP_H * T - 16.0)

func _draw() -> void:
	# Hacker in hoodie - simple pixel character
	# Body / hoodie (dark green)
	draw_rect(Rect2(-8, -6, 16, 14), Color(0.05, 0.25, 0.08))
	# Hood
	draw_circle(Vector2(0, -10), 7, Color(0.04, 0.2, 0.06))
	# Face (slightly lighter)
	draw_circle(Vector2(0, -10), 5, Color(0.1, 0.12, 0.1))
	# Glowing eyes
	draw_circle(Vector2(-2, -11), 1.5, Color(0.0, 1.0, 0.5))
	draw_circle(Vector2(2, -11), 1.5, Color(0.0, 1.0, 0.5))
	# Small glow halo
	draw_circle(Vector2(-2, -11), 2.5, Color(0.0, 1.0, 0.5, 0.3))
	draw_circle(Vector2(2, -11), 2.5, Color(0.0, 1.0, 0.5, 0.3))
	# Legs
	draw_rect(Rect2(-7, 8, 6, 8), Color(0.05, 0.25, 0.08))
	draw_rect(Rect2(1, 8, 6, 8), Color(0.05, 0.25, 0.08))
	# Shoes
	draw_rect(Rect2(-8, 14, 7, 4), Color(0.15, 0.15, 0.15))
	draw_rect(Rect2(1, 14, 7, 4), Color(0.15, 0.15, 0.15))
	# Rubber duck in hand
	draw_circle(Vector2(10, 2), 4, Color(1.0, 0.85, 0.0))
	draw_circle(Vector2(12, -1), 2, Color(1.0, 0.85, 0.0))
	# Duck beak
	draw_rect(Rect2(13, -2, 3, 1), Color(1.0, 0.5, 0.0))
	# Duck eye
	draw_circle(Vector2(12, -2), 0.7, Color(0.0, 0.0, 0.0))
