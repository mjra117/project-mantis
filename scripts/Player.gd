extends CharacterBody2D

const SPEED := 200.0
const MAP_W := 72
const MAP_H := 78
const T := 32

const CHAR_PATH := "res://assets/characters/lpc_character_bases/LPC Character Bases/Human/Male/"
# Walk.png: 512x256 = 8 cols x 4 rows, 64x64 per frame
# Idle.png:  64x256 = 1 col  x 4 rows, 64x64 per frame
# Row order: 0=south, 1=west, 2=east, 3=north

var mission_open: bool = false
var _camera: Camera2D
var _sprite: AnimatedSprite2D
var _facing := "s"

func _ready() -> void:
	_camera = Camera2D.new()
	_camera.zoom = Vector2(1.8, 1.8)
	_camera.limit_left = 0
	_camera.limit_top = 0
	_camera.limit_right = MAP_W * T
	_camera.limit_bottom = MAP_H * T
	_camera.position_smoothing_enabled = true
	_camera.position_smoothing_speed = 8.0
	add_child(_camera)
	_setup_sprite()

func _setup_sprite() -> void:
	_sprite = AnimatedSprite2D.new()
	_sprite.scale = Vector2(0.54, 0.54)
	_sprite.offset = Vector2(0, -16)    # shift up so feet sit at body centre

	var frames := SpriteFrames.new()
	var walk_tex: Texture2D = load(CHAR_PATH + "Walk.png")
	var idle_tex: Texture2D = load(CHAR_PATH + "Idle.png")

	var dirs := [["s", 0], ["w", 1], ["e", 2], ["n", 3]]
	for d in dirs:
		var key: String = d[0]
		var row: int    = d[1]

		frames.add_animation("walk_" + key)
		frames.set_animation_speed("walk_" + key, 10.0)
		frames.set_animation_loop("walk_" + key, true)
		for f in range(8):
			var at := AtlasTexture.new()
			at.atlas = walk_tex
			at.region = Rect2(f * 64, row * 64, 64, 64)
			frames.add_frame("walk_" + key, at)

		frames.add_animation("idle_" + key)
		frames.set_animation_speed("idle_" + key, 1.0)
		frames.set_animation_loop("idle_" + key, false)
		var at2 := AtlasTexture.new()
		at2.atlas = idle_tex
		at2.region = Rect2(0, row * 64, 64, 64)
		frames.add_frame("idle_" + key, at2)

	_sprite.sprite_frames = frames
	_sprite.play("idle_s")
	add_child(_sprite)

func _physics_process(_delta: float) -> void:
	if mission_open:
		velocity = Vector2.ZERO
		if _sprite:
			_sprite.play("idle_" + _facing)
		return

	var dir := Vector2.ZERO
	if Input.is_action_pressed("move_up"):    dir.y -= 1.0
	if Input.is_action_pressed("move_down"):  dir.y += 1.0
	if Input.is_action_pressed("move_left"):  dir.x -= 1.0
	if Input.is_action_pressed("move_right"): dir.x += 1.0

	if dir.length_squared() > 0.0:
		dir = dir.normalized()

	velocity = dir * SPEED
	move_and_slide()
	position.x = clampf(position.x, 16.0, MAP_W * T - 16.0)
	position.y = clampf(position.y, 16.0, MAP_H * T - 16.0)

	if _sprite:
		if dir.length_squared() > 0.0:
			if abs(dir.x) > abs(dir.y):
				_facing = "e" if dir.x > 0.0 else "w"
			else:
				_facing = "s" if dir.y > 0.0 else "n"
			if _sprite.animation != "walk_" + _facing:
				_sprite.play("walk_" + _facing)
		else:
			var idle_anim := "idle_" + _facing
			if _sprite.animation != idle_anim:
				_sprite.play(idle_anim)
