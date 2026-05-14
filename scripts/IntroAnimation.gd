extends Node2D

const CHAR_PATH := "res://assets/characters/lpc_character_bases/LPC Character Bases/Human/Male/"
const SCREEN_W  := 900.0
const SCREEN_H  := 560.0
const GROUND_Y  := 370.0
const JOB_DUR   := 2.8

enum Phase {
	BURGER_SHOP, TAXI, STRIP_CLUB, PANHANDLING, SIGN_SPINNER,
	FARM_WALKING, FARM_SUNSET, FARM_STOPPED, IDEA_FLASH,
	TEXT_1, TEXT_2, TEXT_3, TEXT_4, FADE_OUT, DONE
}

var _phase      := Phase.BURGER_SHOP
var _phase_time := 0.0
var _done       := false

var _sky_color    := Color(0.4, 0.72, 1.0)
var _ground_color := Color(0.35, 0.55, 0.2)
var _sun_pos      := Vector2(680.0, 130.0)
var _sun_color    := Color(1.0, 0.95, 0.6)

var _sprite: AnimatedSprite2D
var _player_x  := 700.0
var _walk_speed := 65.0
var _taxi_x     := SCREEN_W + 150.0

var _flash_alpha   := 0.0
var _fade_alpha    := 0.0
var _exclaim_vis   := false
var _exclaim_color := Color.YELLOW

var _canvas:     CanvasLayer
var _text_card:  ColorRect
var _text_label: Label

# ─── Setup ────────────────────────────────────────────────────────────────────

func _ready() -> void:
	_build_sprite()
	_build_ui()
	_enter_phase(Phase.BURGER_SHOP)

func _build_sprite() -> void:
	_sprite = AnimatedSprite2D.new()
	_sprite.scale = Vector2(1.35, 1.35)

	var frames   := SpriteFrames.new()
	var walk_tex: Texture2D = load(CHAR_PATH + "Walk.png")
	var idle_tex: Texture2D = load(CHAR_PATH + "Idle.png")

	for d in [["s", 0], ["w", 1], ["e", 2], ["n", 3]]:
		var key: String = d[0]
		var row: int    = d[1]
		frames.add_animation("walk_" + key)
		frames.set_animation_speed("walk_" + key, 6.0)
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
	add_child(_sprite)

func _build_ui() -> void:
	_canvas = CanvasLayer.new()
	_canvas.layer = 10
	add_child(_canvas)

	_text_card          = ColorRect.new()
	_text_card.color    = Color.BLACK
	_text_card.size     = Vector2(SCREEN_W, SCREEN_H)
	_text_card.position = Vector2.ZERO
	_text_card.visible  = false
	_canvas.add_child(_text_card)

	_text_label          = Label.new()
	_text_label.size     = Vector2(SCREEN_W, SCREEN_H)
	_text_label.position = Vector2.ZERO
	_text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_text_label.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	_text_label.autowrap_mode        = TextServer.AUTOWRAP_WORD_SMART
	_text_label.add_theme_font_size_override("font_size", 34)
	_text_label.add_theme_color_override("font_color", Color.WHITE)
	_text_card.add_child(_text_label)

# ─── Phase control ────────────────────────────────────────────────────────────

func _enter_phase(p: Phase) -> void:
	_phase      = p
	_phase_time = 0.0

	match p:
		Phase.BURGER_SHOP:
			_flash_alpha = 1.0
			_sprite.position = Vector2(450.0, 272.0)
			_sprite.play("idle_s")

		Phase.TAXI:
			_flash_alpha = 1.0
			_taxi_x = SCREEN_W + 150.0
			_sprite.position = Vector2(400.0, 345.0)
			_sprite.play("idle_s")

		Phase.STRIP_CLUB:
			_flash_alpha = 1.0
			_sprite.position = Vector2(450.0, 288.0)
			_sprite.play("walk_e")

		Phase.PANHANDLING:
			_flash_alpha = 1.0
			_sprite.position = Vector2(300.0, 368.0)
			_sprite.play("idle_s")

		Phase.SIGN_SPINNER:
			_flash_alpha = 1.0
			_sprite.position = Vector2(450.0, 342.0)
			_sprite.play("walk_e")

		Phase.FARM_WALKING:
			_flash_alpha  = 1.0
			_sky_color    = Color(0.4, 0.72, 1.0)
			_ground_color = Color(0.35, 0.55, 0.2)
			_sun_color    = Color(1.0, 0.95, 0.6)
			_sun_pos      = Vector2(680.0, 130.0)
			_walk_speed   = 65.0
			_player_x     = 700.0
			_sprite.position = Vector2(_player_x, GROUND_Y - 10.0)
			_sprite.play("walk_w")
			_set_walk_spd(4.0)

		Phase.FARM_SUNSET:
			_walk_speed = 35.0
			_set_walk_spd(2.5)

		Phase.FARM_STOPPED:
			_sprite.play("idle_w")

		Phase.IDEA_FLASH:
			_exclaim_vis = true

		Phase.TEXT_1:
			_exclaim_vis       = false
			_text_card.visible = true
			_text_label.text   = "Every job.\nEvery hustle."
			_text_label.add_theme_font_size_override("font_size", 34)
			_text_label.add_theme_color_override("font_color", Color.WHITE)

		Phase.TEXT_2:
			_text_label.text = "Never.\nEnough."

		Phase.TEXT_3:
			_text_label.text = "Then one night...\nan idea."

		Phase.TEXT_4:
			_text_label.text = "Hack CorpSec.\nGet   R I C H."
			_text_label.add_theme_font_size_override("font_size", 52)
			_text_label.add_theme_color_override("font_color", Color.GOLD)

		Phase.FADE_OUT:
			_text_card.visible = false

func _set_walk_spd(spd: float) -> void:
	if not _sprite or not _sprite.sprite_frames:
		return
	for d in ["s", "w", "e", "n"]:
		_sprite.sprite_frames.set_animation_speed("walk_" + d, spd)

func _play_dir(dir: String) -> void:
	if _sprite.animation != "walk_" + dir:
		_sprite.play("walk_" + dir)

# ─── Main loop ────────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	_phase_time  += delta
	_flash_alpha  = maxf(_flash_alpha - delta * 3.5, 0.0)

	if Input.is_anything_pressed():
		_load_main()
		return

	_update_phase(delta)
	queue_redraw()

func _update_phase(delta: float) -> void:
	match _phase:

		Phase.BURGER_SHOP:
			if _phase_time > JOB_DUR: _enter_phase(Phase.TAXI)

		Phase.TAXI:
			_taxi_x -= 130.0 * delta
			if _taxi_x < -220.0:
				_taxi_x = SCREEN_W + 150.0
			if _phase_time > JOB_DUR: _enter_phase(Phase.STRIP_CLUB)

		Phase.STRIP_CLUB:
			var pace := sin(_phase_time * 2.2) * 60.0
			_play_dir("e" if pace > 0.0 else "w")
			_sprite.position.x = 450.0 + pace
			if _phase_time > JOB_DUR: _enter_phase(Phase.PANHANDLING)

		Phase.PANHANDLING:
			if _phase_time > JOB_DUR: _enter_phase(Phase.SIGN_SPINNER)

		Phase.SIGN_SPINNER:
			_sprite.position.x = 450.0 + sin(_phase_time * 1.4) * 16.0
			if _phase_time > JOB_DUR: _enter_phase(Phase.FARM_WALKING)

		Phase.FARM_WALKING:
			_player_x -= _walk_speed * delta
			if _player_x < -80.0: _player_x = SCREEN_W + 80.0
			_sprite.position.x = _player_x
			if _phase_time > 4.0: _enter_phase(Phase.FARM_SUNSET)

		Phase.FARM_SUNSET:
			var t := clampf(_phase_time / 5.0, 0.0, 1.0)
			_sky_color    = Color(0.4, 0.72, 1.0).lerp(Color(0.85, 0.35, 0.1), t)
			_ground_color = Color(0.35, 0.55, 0.2).lerp(Color(0.2, 0.12, 0.04), t)
			_sun_color    = Color(1.0, 0.95, 0.6).lerp(Color(1.0, 0.4, 0.1), t)
			_sun_pos      = Vector2(680.0, 130.0).lerp(Vector2(920.0, GROUND_Y + 5.0), t)
			_walk_speed   = lerpf(35.0, 12.0, t)
			_set_walk_spd(lerpf(2.5, 1.2, t))
			_player_x -= _walk_speed * delta
			if _player_x < -80.0: _player_x = SCREEN_W + 80.0
			_sprite.position.x = _player_x
			if _phase_time > 5.0: _enter_phase(Phase.FARM_STOPPED)

		Phase.FARM_STOPPED:
			var t := clampf(_phase_time / 2.0, 0.0, 1.0)
			_sky_color = Color(0.85, 0.35, 0.1).lerp(Color(0.04, 0.04, 0.18), t)
			_sun_pos   = Vector2(920.0, GROUND_Y + 5.0).lerp(Vector2(970.0, GROUND_Y + 60.0), t)
			if _phase_time > 2.5: _enter_phase(Phase.IDEA_FLASH)

		Phase.IDEA_FLASH:
			var blink := (sin(_phase_time * 10.0) + 1.0) * 0.5
			_exclaim_color = Color(1.0, blink * 0.6 + 0.4, 0.0)
			if _phase_time > 2.2: _enter_phase(Phase.TEXT_1)

		Phase.TEXT_1:
			if _phase_time > 2.8: _enter_phase(Phase.TEXT_2)
		Phase.TEXT_2:
			if _phase_time > 2.8: _enter_phase(Phase.TEXT_3)
		Phase.TEXT_3:
			if _phase_time > 3.2: _enter_phase(Phase.TEXT_4)
		Phase.TEXT_4:
			if _phase_time > 3.2: _enter_phase(Phase.FADE_OUT)

		Phase.FADE_OUT:
			_fade_alpha = clampf(_phase_time / 1.8, 0.0, 1.0)
			if _phase_time > 2.2: _load_main()

# ─── Drawing ──────────────────────────────────────────────────────────────────

func _draw() -> void:
	var in_text := _phase in [Phase.TEXT_1, Phase.TEXT_2, Phase.TEXT_3, Phase.TEXT_4]
	if in_text or _phase == Phase.DONE:
		return

	match _phase:
		Phase.BURGER_SHOP:  _draw_burger()
		Phase.TAXI:         _draw_taxi()
		Phase.STRIP_CLUB:   _draw_club()
		Phase.PANHANDLING:  _draw_panhandling()
		Phase.SIGN_SPINNER: _draw_sign_spinner()
		_:                  _draw_farm()

	if _exclaim_vis:
		draw_string(ThemeDB.fallback_font,
			Vector2(_sprite.position.x - 6.0, _sprite.position.y - 82.0),
			"!", HORIZONTAL_ALIGNMENT_LEFT, -1, 52, _exclaim_color)

	if _flash_alpha > 0.0:
		draw_rect(Rect2(0, 0, SCREEN_W, SCREEN_H), Color(1, 1, 1, _flash_alpha))

	if _fade_alpha > 0.0:
		draw_rect(Rect2(0, 0, SCREEN_W, SCREEN_H), Color(0, 0, 0, _fade_alpha))


func _draw_job_label(text: String) -> void:
	var a := clampf(minf(_phase_time * 4.0, 1.0) * (1.0 - maxf((_phase_time - JOB_DUR + 0.5) * 4.0, 0.0)), 0.0, 1.0)
	if a <= 0.01:
		return
	var lw := text.length() * 15.0 + 24.0
	draw_rect(Rect2(16, SCREEN_H - 56, lw, 40), Color(0, 0, 0, 0.55 * a))
	draw_string(ThemeDB.fallback_font, Vector2(26, SCREEN_H - 26), text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color(1.0, 1.0, 0.5, a))


func _draw_burger() -> void:
	draw_rect(Rect2(0, 0, SCREEN_W, SCREEN_H), Color(0.9, 0.7, 0.4))
	draw_rect(Rect2(0, SCREEN_H * 0.62, SCREEN_W, SCREEN_H * 0.38), Color(0.52, 0.36, 0.18))
	for i in range(6):
		draw_rect(Rect2(i * 160.0, SCREEN_H * 0.62, 2, SCREEN_H * 0.38), Color(0.42, 0.28, 0.14))
	# Menu board
	draw_rect(Rect2(38, 28, 335, 215), Color(0.1, 0.1, 0.1))
	var mc := [Color(1, 0.55, 0.1), Color(0.9, 0.22, 0.12), Color(0.2, 0.75, 0.28), Color(1, 0.9, 0.12)]
	for r in range(2):
		for c in range(4):
			draw_rect(Rect2(52.0 + c * 80, 44.0 + r * 94, 68, 76), mc[(r * 4 + c) % 4])
	# Counter
	draw_rect(Rect2(0, SCREEN_H * 0.52, SCREEN_W, 18), Color(0.82, 0.62, 0.38))
	draw_rect(Rect2(0, SCREEN_H * 0.52 + 18, SCREEN_W, 110), Color(0.6, 0.4, 0.2))
	# Burger on counter
	var bx := 680.0; var by := SCREEN_H * 0.52 - 16.0
	draw_circle(Vector2(bx, by - 22), 24.0, Color(0.85, 0.58, 0.22))
	draw_rect(Rect2(bx - 22, by - 9, 44, 12), Color(0.45, 0.22, 0.06))
	draw_rect(Rect2(bx - 20, by + 1, 40, 8), Color(0.16, 0.68, 0.16))
	draw_circle(Vector2(bx, by + 12), 22.0, Color(0.88, 0.7, 0.28))
	# Cash register
	draw_rect(Rect2(192, SCREEN_H * 0.52 - 56, 78, 56), Color(0.26, 0.26, 0.26))
	draw_rect(Rect2(200, SCREEN_H * 0.52 - 48, 62, 34), Color(0.08, 0.78, 0.08))
	_draw_job_label("Burger Flipper")


func _draw_taxi() -> void:
	draw_rect(Rect2(0, 0, SCREEN_W, SCREEN_H * 0.52), Color(0.5, 0.6, 0.76))
	# Buildings
	var bw := [92, 72, 112, 82, 98, 78, 102, 88]
	var bh := [188, 228, 162, 208, 172, 212, 152, 198]
	var bc := [Color(0.46, 0.46, 0.5), Color(0.4, 0.43, 0.48), Color(0.5, 0.48, 0.46)]
	var bx := 0
	for i in range(bw.size()):
		draw_rect(Rect2(bx, SCREEN_H * 0.52 - bh[i], bw[i] - 3, bh[i]), bc[i % 3])
		for wr in range(int(bh[i] / 36.0)):
			for wc in range(int((bw[i] - 3) / 24.0)):
				var lit := (i + wr + wc) % 4 != 0
				draw_rect(Rect2(bx + 4 + wc * 24, SCREEN_H * 0.52 - bh[i] + 8 + wr * 36, 16, 22),
					Color(0.95, 0.9, 0.5, 0.9) if lit else Color(0.18, 0.18, 0.24, 0.6))
		bx += bw[i]
	draw_rect(Rect2(0, SCREEN_H * 0.52, SCREEN_W, SCREEN_H * 0.48), Color(0.26, 0.26, 0.26))
	draw_rect(Rect2(0, SCREEN_H * 0.52, SCREEN_W, 10), Color(0.65, 0.65, 0.65))
	for i in range(8):
		draw_rect(Rect2(i * 118.0, SCREEN_H * 0.72, 82, 9), Color(0.9, 0.82, 0.1))
	# Taxi car
	var ty := SCREEN_H * 0.535
	var tx := _taxi_x
	draw_rect(Rect2(tx, ty + 28, 165, 58), Color(0.95, 0.82, 0.0))
	draw_rect(Rect2(tx + 22, ty + 6, 112, 30), Color(0.95, 0.82, 0.0))
	draw_rect(Rect2(tx + 28, ty + 10, 48, 23), Color(0.55, 0.8, 0.92, 0.75))
	draw_rect(Rect2(tx + 82, ty + 10, 44, 23), Color(0.55, 0.8, 0.92, 0.75))
	draw_circle(Vector2(tx + 32, ty + 88), 17.0, Color(0.1, 0.1, 0.1))
	draw_circle(Vector2(tx + 133, ty + 88), 17.0, Color(0.1, 0.1, 0.1))
	draw_circle(Vector2(tx + 32, ty + 88), 7.0, Color(0.42, 0.42, 0.42))
	draw_circle(Vector2(tx + 133, ty + 88), 7.0, Color(0.42, 0.42, 0.42))
	draw_rect(Rect2(tx + 58, ty - 2, 50, 14), Color(0.95, 0.82, 0.0))
	draw_string(ThemeDB.fallback_font, Vector2(tx + 62, ty + 10),
		"TAXI", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color.BLACK)
	_draw_job_label("Taxi Driver")


func _draw_club() -> void:
	draw_rect(Rect2(0, 0, SCREEN_W, SCREEN_H), Color(0.07, 0.02, 0.07))
	# Stage
	draw_rect(Rect2(225, 300, 450, 210), Color(0.15, 0.07, 0.12))
	draw_rect(Rect2(225, 293, 450, 12), Color(0.24, 0.14, 0.2))
	# Pole
	draw_rect(Rect2(448, 150, 6, 148), Color(0.72, 0.72, 0.75))
	draw_circle(Vector2(451, 150), 9.0, Color(0.72, 0.72, 0.75))
	draw_circle(Vector2(451, 298), 9.0, Color(0.72, 0.72, 0.75))
	# Spotlights
	var s_origins := [Vector2(170, 0), Vector2(450, 0), Vector2(730, 0)]
	var s_colors  := [Color(1, 0.2, 0.45, 0.14), Color(1, 0.85, 0.22, 0.11), Color(0.4, 0.2, 1.0, 0.14)]
	for i in range(3):
		var cone := PackedVector2Array()
		cone.append(s_origins[i])
		cone.append(Vector2(340, 300))
		cone.append(Vector2(560, 300))
		draw_colored_polygon(cone, s_colors[i])
	# Neon sign
	draw_rect(Rect2(308, 16, 286, 54), Color(0.1, 0.03, 0.09))
	draw_string(ThemeDB.fallback_font, Vector2(328, 55), "CLUB NEON",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 28, Color(1.0, 0.16, 0.52))
	# Audience silhouettes
	for i in range(9):
		var ax := 52.0 + i * 95.0
		draw_circle(Vector2(ax, SCREEN_H - 26), 17.0, Color(0.04, 0.04, 0.04))
		draw_rect(Rect2(ax - 13, SCREEN_H - 76, 26, 52), Color(0.04, 0.04, 0.04))
	_draw_job_label("Club Dancer")


func _draw_panhandling() -> void:
	draw_rect(Rect2(0, 0, SCREEN_W, SCREEN_H * 0.42), Color(0.5, 0.56, 0.62))
	for i in range(6):
		var bx2 := i * 155
		var bh2 := 118 + (i * 43) % 102
		draw_rect(Rect2(bx2, SCREEN_H * 0.42 - bh2, 148, bh2), Color(0.36, 0.38, 0.42))
		for wr in range(int(bh2 / 32.0)):
			for wc in range(4):
				var lit := (i + wr * 2 + wc) % 3 != 0
				draw_rect(Rect2(bx2 + 6 + wc * 34, SCREEN_H * 0.42 - bh2 + 6 + wr * 32, 24, 20),
					Color(0.92, 0.88, 0.45, 0.85) if lit else Color(0.16, 0.16, 0.2, 0.7))
	draw_rect(Rect2(0, SCREEN_H * 0.42, SCREEN_W, SCREEN_H * 0.58), Color(0.58, 0.58, 0.6))
	for i in range(5):
		draw_rect(Rect2(i * 186.0, SCREEN_H * 0.42, 3, SCREEN_H * 0.58), Color(0.46, 0.46, 0.48))
	# Cardboard sign
	draw_rect(Rect2(338, 338, 140, 80), Color(0.72, 0.57, 0.32))
	draw_rect(Rect2(342, 342, 132, 72), Color(0.64, 0.5, 0.28))
	draw_string(ThemeDB.fallback_font, Vector2(356, 368), "NEED WORK",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color(0.16, 0.08, 0.03))
	draw_string(ThemeDB.fallback_font, Vector2(360, 392), "GOD BLESS",
		HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color(0.16, 0.08, 0.03))
	# Cup + coins
	draw_rect(Rect2(488, 388, 30, 38), Color(0.5, 0.44, 0.36))
	for ci in range(4):
		draw_circle(Vector2(494.0 + ci * 8, 386.0), 5.0, Color(0.85, 0.72, 0.18))
	_draw_job_label("Panhandler")


func _draw_sign_spinner() -> void:
	draw_rect(Rect2(0, 0, SCREEN_W, GROUND_Y), Color(0.42, 0.62, 0.88))
	draw_rect(Rect2(0, GROUND_Y, SCREEN_W, SCREEN_H - GROUND_Y), Color(0.36, 0.36, 0.38))
	for i in range(7):
		draw_rect(Rect2(i * 135.0 + 14, GROUND_Y + 20, 92, 9), Color(0.9, 0.85, 0.14))
	# Background cars
	var cpos  := [[78.0, GROUND_Y + 36.0], [578.0, GROUND_Y + 36.0], [738.0, GROUND_Y + 36.0]]
	var ccols := [Color(0.7, 0.18, 0.18), Color(0.18, 0.38, 0.72), Color(0.18, 0.6, 0.2)]
	for i in range(cpos.size()):
		var cx2: float = cpos[i][0]; var cy2: float = cpos[i][1]
		draw_rect(Rect2(cx2, cy2, 115, 48), ccols[i])
		draw_circle(Vector2(cx2 + 22, cy2 + 48), 13.0, Color.BLACK)
		draw_circle(Vector2(cx2 + 93, cy2 + 48), 13.0, Color.BLACK)
	# Rotating sign
	var cx := _sprite.position.x
	var cy := _sprite.position.y - 84.0
	var a  := _phase_time * 3.5
	var sw := 86.0; var sh := 32.0
	var corners := [Vector2(-sw * 0.5, -sh * 0.5), Vector2(sw * 0.5, -sh * 0.5),
					Vector2(sw * 0.5, sh * 0.5),   Vector2(-sw * 0.5, sh * 0.5)]
	var rot := PackedVector2Array()
	for c in corners:
		rot.append(Vector2(c.x * cos(a) - c.y * sin(a) + cx,
						   c.x * sin(a) + c.y * cos(a) + cy))
	draw_colored_polygon(rot, Color(1.0, 0.82, 0.0))
	var outline := PackedVector2Array(rot); outline.append(rot[0])
	draw_polyline(outline, Color(0.72, 0.52, 0.0), 2.0)
	draw_line(Vector2(cx, cy + sh * 0.5 + 2), Vector2(cx, cy + 46),
		Color(0.52, 0.36, 0.16), 4.0)
	_draw_job_label("Sign Spinner")


func _draw_farm() -> void:
	draw_rect(Rect2(0, 0, SCREEN_W, GROUND_Y), _sky_color)

	if _phase in [Phase.FARM_SUNSET, Phase.FARM_STOPPED, Phase.IDEA_FLASH, Phase.FADE_OUT]:
		for i in range(12):
			var gc := _sun_color; gc.a = 0.06 * (1.0 - float(i) / 12.0)
			draw_rect(Rect2(0, GROUND_Y - 90.0 + i * 7.5, SCREEN_W, 7.5), gc)

	var star_fade := 0.0
	if _phase == Phase.FARM_SUNSET:
		star_fade = clampf((_phase_time - 3.5) / 2.5, 0.0, 1.0)
	elif _phase in [Phase.FARM_STOPPED, Phase.IDEA_FLASH, Phase.FADE_OUT]:
		star_fade = 1.0
	if star_fade > 0.0:
		var rng := RandomNumberGenerator.new(); rng.seed = 12345
		for i in range(55):
			draw_circle(Vector2(rng.randf_range(0.0, SCREEN_W), rng.randf_range(0.0, GROUND_Y * 0.75)),
				1.5, Color(1, 1, 1, star_fade * rng.randf_range(0.3, 1.0)))

	draw_rect(Rect2(0, GROUND_Y, SCREEN_W, SCREEN_H - GROUND_Y), _ground_color)

	var soil := _ground_color.darkened(0.3)
	for row in range(5):
		draw_rect(Rect2(0, GROUND_Y + 22.0 + row * 30.0, SCREEN_W, 14.0), soil)

	var farm_t := 0.0
	if _phase == Phase.FARM_SUNSET:
		farm_t = clampf(_phase_time / 5.0, 0.0, 1.0)
	elif _phase in [Phase.FARM_STOPPED, Phase.IDEA_FLASH, Phase.FADE_OUT]:
		farm_t = 1.0
	var crop_c := Color(0.22, 0.62, 0.12).lerp(Color(0.08, 0.22, 0.04), farm_t)
	for row in range(5):
		var ry := GROUND_Y + 16.0 + row * 30.0
		for col in range(22):
			var fcx := 15.0 + col * 42.0
			draw_rect(Rect2(fcx, ry, 4, 14), crop_c)
			draw_rect(Rect2(fcx - 6, ry + 5, 16, 3), crop_c.darkened(0.15))

	var fc := Color(0.45, 0.3, 0.15)
	for i in range(12):
		var fx := float(i) * 80.0 + 10.0
		draw_rect(Rect2(fx, GROUND_Y - 22.0, 6.0, 44.0), fc)
		if i < 11:
			draw_rect(Rect2(fx + 6.0, GROUND_Y - 15.0, 74.0, 5.0), fc)
			draw_rect(Rect2(fx + 6.0, GROUND_Y - 5.0,  74.0, 5.0), fc)

	var glow := _sun_color; glow.a = 0.1
	draw_circle(_sun_pos, 72.0, glow); glow.a = 0.2
	draw_circle(_sun_pos, 56.0, glow)
	draw_circle(_sun_pos, 38.0, _sun_color)

	var barn_c := Color(0.22, 0.12, 0.06).lerp(Color(0.06, 0.04, 0.02), farm_t)
	draw_rect(Rect2(110, GROUND_Y - 115, 105, 115), barn_c)
	var roof := PackedVector2Array()
	roof.append(Vector2(100, GROUND_Y - 115))
	roof.append(Vector2(163, GROUND_Y - 172))
	roof.append(Vector2(226, GROUND_Y - 115))
	draw_colored_polygon(roof, barn_c)
	draw_rect(Rect2(148, GROUND_Y - 58.0, 32.0, 58.0), barn_c.darkened(0.6))
	draw_rect(Rect2(752, GROUND_Y - 88.0, 11.0, 88.0), barn_c)
	draw_circle(Vector2(757, GROUND_Y - 103), 38.0, barn_c)

	if _phase == Phase.FARM_WALKING:
		_draw_job_label("Farm Worker")

# ─── Scene transition ─────────────────────────────────────────────────────────

func _load_main() -> void:
	if _done:
		return
	_done  = true
	_phase = Phase.DONE
	get_tree().change_scene_to_file("res://Main.tscn")
