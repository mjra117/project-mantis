extends Node2D

# ─── Map constants ─────────────────────────────────────────────────────────────
const T   := 32        # tile size in pixels
const MAP_W := 72      # map width in tiles
const MAP_H := 78      # map height in tiles

# ─── Room definitions ──────────────────────────────────────────────────────────
# Each room: id, tx, ty, tw, th, level_start (0-based), theme_key, name
const ROOMS: Array = [
	{"id": "vault",    "tx": 1,  "ty": 1,  "tw": 70, "th": 10, "level_start": 90, "theme": "black",  "name": "SERVER VAULT",   "unlockAt": 80},
	{"id": "rd",       "tx": 1,  "ty": 13, "tw": 22, "th": 14, "level_start": 60, "theme": "dark",   "name": "R&D LAB",        "unlockAt": 50},
	{"id": "design",   "tx": 25, "ty": 13, "tw": 22, "th": 14, "level_start": 70, "theme": "dark",   "name": "DESIGN STUDIO",  "unlockAt": 60},
	{"id": "exec",     "tx": 49, "ty": 13, "tw": 22, "th": 14, "level_start": 80, "theme": "darker", "name": "EXEC FLOOR",     "unlockAt": 70},
	{"id": "security", "tx": 1,  "ty": 29, "tw": 22, "th": 14, "level_start": 50, "theme": "dark",   "name": "SECURITY OPS",   "unlockAt": 40},
	{"id": "noc",      "tx": 25, "ty": 29, "tw": 22, "th": 14, "level_start": 40, "theme": "dim",    "name": "NOC",            "unlockAt": 30},
	{"id": "mgmt",     "tx": 49, "ty": 29, "tw": 22, "th": 14, "level_start": 30, "theme": "dim",    "name": "MANAGEMENT",     "unlockAt": 20},
	{"id": "office",   "tx": 1,  "ty": 45, "tw": 22, "th": 14, "level_start": 0,  "theme": "normal", "name": "OPEN OFFICE",    "unlockAt": 0},
	{"id": "it",       "tx": 25, "ty": 45, "tw": 22, "th": 14, "level_start": 10, "theme": "normal", "name": "IT DEPT",        "unlockAt": 5},
	{"id": "server",   "tx": 49, "ty": 45, "tw": 22, "th": 14, "level_start": 20, "theme": "dim",    "name": "SERVER ROOM",    "unlockAt": 10},
	{"id": "lobby",    "tx": 25, "ty": 61, "tw": 22, "th": 14, "level_start": -1, "theme": "lobby",  "name": "LOBBY",          "unlockAt": 0},
]

# ─── Room openings (wall gaps for corridors) ───────────────────────────────────
const OPENINGS: Dictionary = {
	"vault":    [{"wall": "S", "start": 9,  "len": 4}, {"wall": "S", "start": 33, "len": 4}, {"wall": "S", "start": 57, "len": 4}],
	"rd":       [{"wall": "N", "start": 9,  "len": 4}, {"wall": "S", "start": 9,  "len": 4}, {"wall": "E", "start": 5,  "len": 4}],
	"design":   [{"wall": "N", "start": 9,  "len": 4}, {"wall": "S", "start": 9,  "len": 4}, {"wall": "W", "start": 5,  "len": 4}, {"wall": "E", "start": 5, "len": 4}],
	"exec":     [{"wall": "N", "start": 9,  "len": 4}, {"wall": "S", "start": 9,  "len": 4}, {"wall": "W", "start": 5,  "len": 4}],
	"security": [{"wall": "N", "start": 9,  "len": 4}, {"wall": "S", "start": 9,  "len": 4}, {"wall": "E", "start": 5,  "len": 4}],
	"noc":      [{"wall": "N", "start": 9,  "len": 4}, {"wall": "S", "start": 9,  "len": 4}, {"wall": "W", "start": 5,  "len": 4}, {"wall": "E", "start": 5, "len": 4}],
	"mgmt":     [{"wall": "N", "start": 9,  "len": 4}, {"wall": "S", "start": 9,  "len": 4}, {"wall": "W", "start": 5,  "len": 4}],
	"office":   [{"wall": "N", "start": 9,  "len": 4}, {"wall": "E", "start": 5,  "len": 4}],
	"it":       [{"wall": "N", "start": 9,  "len": 4}, {"wall": "S", "start": 9,  "len": 4}, {"wall": "W", "start": 5,  "len": 4}, {"wall": "E", "start": 5, "len": 4}],
	"server":   [{"wall": "N", "start": 9,  "len": 4}, {"wall": "W", "start": 5,  "len": 4}],
	"lobby":    [{"wall": "N", "start": 9,  "len": 4}],
}

# ─── Door definitions ──────────────────────────────────────────────────────────
const DOOR_DEFS: Array = [
	{"id": "d-it",      "dest": "it",       "tx": 34, "ty": 59, "tw": 4, "th": 2, "unlockAt": 0},
	{"id": "d-sec",     "dest": "security", "tx": 10, "ty": 43, "tw": 4, "th": 2, "unlockAt": 40},
	{"id": "d-noc",     "dest": "noc",      "tx": 34, "ty": 43, "tw": 4, "th": 2, "unlockAt": 30},
	{"id": "d-mgmt",    "dest": "mgmt",     "tx": 58, "ty": 43, "tw": 4, "th": 2, "unlockAt": 20},
	{"id": "d-rd",      "dest": "rd",       "tx": 10, "ty": 27, "tw": 4, "th": 2, "unlockAt": 50},
	{"id": "d-design",  "dest": "design",   "tx": 34, "ty": 27, "tw": 4, "th": 2, "unlockAt": 60},
	{"id": "d-exec",    "dest": "exec",     "tx": 58, "ty": 27, "tw": 4, "th": 2, "unlockAt": 70},
	{"id": "d-vault1",  "dest": "vault",    "tx": 10, "ty": 11, "tw": 4, "th": 2, "unlockAt": 80},
	{"id": "d-vault2",  "dest": "vault",    "tx": 34, "ty": 11, "tw": 4, "th": 2, "unlockAt": 80},
	{"id": "d-vault3",  "dest": "vault",    "tx": 58, "ty": 11, "tw": 4, "th": 2, "unlockAt": 80},
	{"id": "d-server",  "dest": "server",   "tx": 47, "ty": 46, "tw": 2, "th": 12, "unlockAt": 10},
]

# ─── NPC definitions ──────────────────────────────────────────────────────────
# tx/ty in tiles; dialog is what they say when talked to.
const NPC_DEFS: Array = [
	{"name": "Receptionist",      "tx": 30.0, "ty": 66.0,
	 "shirt": Color(0.72, 0.22, 0.22), "skin": Color(0.92, 0.78, 0.62),
	 "dialog": "Welcome to DuckCorp! The Open Office is just up the hall — the computers there are free to practise on."},
	{"name": "Intern Mike",        "tx": 5.0,  "ty": 52.0,
	 "shirt": Color(0.25, 0.45, 0.80), "skin": Color(0.95, 0.80, 0.65),
	 "dialog": "Psst — STRING types text on the target machine. ENTER submits it. That's basically 90% of what the Duck does."},
	{"name": "Office Analyst",     "tx": 14.0, "ty": 49.0,
	 "shirt": Color(0.30, 0.58, 0.35), "skin": Color(0.92, 0.78, 0.60),
	 "dialog": "GUI R opens the Run dialog instantly. From there you can launch anything without ever touching the mouse."},
	{"name": "Sysadmin Dave",      "tx": 30.0, "ty": 50.0,
	 "shirt": Color(0.22, 0.50, 0.55), "skin": Color(0.88, 0.72, 0.55),
	 "dialog": "First thing on any new box: whoami, then ipconfig. Know your environment before you touch anything else."},
	{"name": "Server Tech",        "tx": 52.0, "ty": 49.0,
	 "shirt": Color(0.58, 0.28, 0.62), "skin": Color(0.90, 0.76, 0.60),
	 "dialog": "PowerShell is just CMD with a college degree. And ExecutionPolicy? That's a speed bump, not a wall."},
	{"name": "Manager",            "tx": 52.0, "ty": 34.0,
	 "shirt": Color(0.48, 0.18, 0.18), "skin": Color(0.95, 0.82, 0.68),
	 "dialog": "I asked IT to lock down the Startup folder weeks ago. Still hasn't happened. Shocking, really."},
	{"name": "NOC Lead",           "tx": 30.0, "ty": 34.0,
	 "shirt": Color(0.20, 0.28, 0.65), "skin": Color(0.92, 0.78, 0.62),
	 "dialog": "We monitor all outbound traffic. Well... except DNS queries. Everybody forgets about DNS. Funny that."},
	{"name": "Security Researcher","tx": 10.0, "ty": 34.0,
	 "shirt": Color(0.65, 0.25, 0.25), "skin": Color(0.80, 0.60, 0.45),
	 "dialog": "AMSI hooks itself into PowerShell's memory at runtime. But memory can always be written to — just saying."},
]
const NPC_INTERACT_DIST := 55.0

# ─── N-S Corridors ─────────────────────────────────────────────────────────────
const NS_CORRIDORS: Array = [
	{"cx": 34, "ty": 59, "th": 2, "theme": "lobby"},
	{"cx": 10, "ty": 43, "th": 2, "theme": "normal"},
	{"cx": 34, "ty": 43, "th": 2, "theme": "normal"},
	{"cx": 58, "ty": 43, "th": 2, "theme": "dim"},
	{"cx": 10, "ty": 27, "th": 2, "theme": "dark"},
	{"cx": 34, "ty": 27, "th": 2, "theme": "dark"},
	{"cx": 58, "ty": 27, "th": 2, "theme": "darker"},
	{"cx": 10, "ty": 11, "th": 2, "theme": "dark"},
	{"cx": 34, "ty": 11, "th": 2, "theme": "dark"},
	{"cx": 58, "ty": 11, "th": 2, "theme": "darker"},
]

# ─── E-W Corridors ─────────────────────────────────────────────────────────────
const EW_CORRIDORS: Array = [
	{"tx": 23, "ty": 46, "tw": 2, "th": 12, "theme": "normal"},
	{"tx": 47, "ty": 46, "tw": 2, "th": 12, "theme": "dim"},
	{"tx": 23, "ty": 30, "tw": 2, "th": 12, "theme": "dark"},
	{"tx": 47, "ty": 30, "tw": 2, "th": 12, "theme": "dim"},
	{"tx": 23, "ty": 14, "tw": 2, "th": 12, "theme": "dark"},
	{"tx": 47, "ty": 14, "tw": 2, "th": 12, "theme": "dark"},
]

# ─── State ─────────────────────────────────────────────────────────────────────
var _player  # CharacterBody2D with Player.gd script
var _mission_ui  # CanvasLayer with MissionUI.gd script
var _interact_label: Label
var _interact_canvas: CanvasLayer
var _door_bodies: Dictionary = {}   # door_id -> StaticBody2D
var _workstation_positions: Array[Vector2] = []

var _floor_layer: TileMapLayer
var _walls_layer: TileMapLayer
var _furniture_layer: TileMapLayer

var _npc_sprites: Array = []   # AnimatedSprite2D per NPC, same order as NPC_DEFS

var _near_ws_idx: int = -1
var _near_npc_idx: int = -1
var _npc_dialog_open: bool = false
var _npc_canvas: CanvasLayer
var _npc_panel: PanelContainer
var _npc_name_lbl: Label
var _npc_text_lbl: Label
const INTERACT_DIST := 72.0
const WALL_T := 1

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color(0.52, 0.48, 0.42))

	_floor_layer     = get_node_or_null("FloorLayer") as TileMapLayer
	_walls_layer     = get_node_or_null("WallsLayer") as TileMapLayer
	_furniture_layer = get_node_or_null("FurnitureLayer") as TileMapLayer
	_setup_tileset()
	_paint_tilemap()

	_build_workstation_positions()
	_build_walls()
	_build_door_bodies()
	_build_player()
	_build_npcs()
	_build_interact_ui()
	_build_mission_ui()
	_build_npc_ui()

	GameState.state_changed.connect(_on_state_changed)

# ─── Workstation positions ─────────────────────────────────────────────────────

func _build_workstation_positions() -> void:
	_workstation_positions.clear()
	# Must iterate in the SAME order as _get_ordered_rooms() so physical
	# positions and room-lookup indices stay in sync.
	for room in _get_ordered_rooms():
		var positions := _get_workstation_positions_for_room(room)
		for pos in positions:
			_workstation_positions.append(pos)

func _get_workstation_positions_for_room(room: Dictionary) -> Array:
	var positions: Array = []
	var tx: int = room["tx"]
	var ty: int = room["ty"]
	var tw: int = room["tw"]
	var th: int = room["th"]

	if room["id"] == "vault":
		# 5x2 grid across 70-tile-wide room
		var x_offsets := []
		var inner_w := (tw - 2) * T
		for i in range(5):
			x_offsets.append(int((float(i + 1) / 6.0) * inner_w))
		var y_offsets := [3 * T, (th - 5) * T]
		var inner_x := (tx + 1) * T
		var inner_y := (ty + 1) * T
		for yo in y_offsets:
			for xo in x_offsets:
				positions.append(Vector2(inner_x + xo, inner_y + yo))
	else:
		# Standard 22x14 room: 5 workstations in 2 rows
		var x_offsets := [2 * T, 6 * T, 10 * T, 14 * T, 18 * T]
		var y_offsets := [3 * T, 8 * T]
		var inner_x := (tx + 1) * T
		var inner_y := (ty + 1) * T
		for yo in y_offsets:
			for xo in x_offsets:
				positions.append(Vector2(inner_x + xo, inner_y + yo))

	return positions

func _get_room_for_workstation(ws_idx: int) -> Dictionary:
	# Given a 0-based workstation index (0-99), find the room
	var ordered_rooms := _get_ordered_rooms()
	var offset := 0
	for room in ordered_rooms:
		var count := 10
		if ws_idx < offset + count:
			return room
		offset += count
	return {}

func _get_ordered_rooms() -> Array:
	var result: Array = []
	for room in ROOMS:
		if room["id"] != "lobby":
			result.append(room)
	result.sort_custom(func(a, b): return a["level_start"] < b["level_start"])
	return result

# ─── Wall building ─────────────────────────────────────────────────────────────

func _build_walls() -> void:
	var walls_node := Node2D.new()
	walls_node.name = "Walls"
	add_child(walls_node)

	# Build walls for each room
	for room in ROOMS:
		_build_room_walls(walls_node, room)

func _build_room_walls(parent: Node, room: Dictionary) -> void:
	var tx: int = room["tx"]
	var ty: int = room["ty"]
	var tw: int = room["tw"]
	var th: int = room["th"]
	var rid: String = room["id"]
	var openings: Array = OPENINGS.get(rid, [])

	# North wall (y = ty, x from tx to tx+tw)
	_build_wall_segment_horizontal(parent, tx, ty, tw, WALL_T, "N", openings, rid)
	# South wall (y = ty+th-WALL_T)
	_build_wall_segment_horizontal(parent, tx, ty + th - WALL_T, tw, WALL_T, "S", openings, rid)
	# West wall (x = tx, y from ty+WALL_T to ty+th-WALL_T)
	_build_wall_segment_vertical(parent, tx, ty + WALL_T, WALL_T, th - 2 * WALL_T, "W", openings, rid)
	# East wall (x = tx+tw-WALL_T)
	_build_wall_segment_vertical(parent, tx + tw - WALL_T, ty + WALL_T, WALL_T, th - 2 * WALL_T, "E", openings, rid)

func _build_wall_segment_horizontal(parent: Node, tx: int, ty: int, tw: int, th: int,
		wall_dir: String, openings: Array, room_id: String) -> void:
	# Get openings for this wall direction
	var wall_openings: Array = []
	for op in openings:
		if op["wall"] == wall_dir:
			wall_openings.append(op)
	wall_openings.sort_custom(func(a, b): return a["start"] < b["start"])

	# Build segments around openings
	var segments := _get_segments(0, tw, wall_openings)
	for seg in segments:
		var seg_tx: int = tx + int(seg[0])
		var seg_len: int = int(seg[1])
		_create_wall_body(parent, seg_tx * T, ty * T, seg_len * T, th * T)

func _build_wall_segment_vertical(parent: Node, tx: int, ty: int, tw: int, th: int,
		wall_dir: String, openings: Array, room_id: String) -> void:
	var wall_openings: Array = []
	for op in openings:
		if op["wall"] == wall_dir:
			wall_openings.append(op)
	wall_openings.sort_custom(func(a, b): return a["start"] < b["start"])

	var segments := _get_segments(0, th, wall_openings)
	for seg in segments:
		var seg_ty: int = ty + int(seg[0])
		var seg_len: int = int(seg[1])
		_create_wall_body(parent, tx * T, seg_ty * T, tw * T, seg_len * T)

func _get_segments(start: int, length: int, openings: Array) -> Array:
	# Returns array of [offset, length] segments not covered by openings
	var result: Array = []
	var cursor := start
	for op in openings:
		var op_start: int = op["start"]
		var op_len: int = op["len"]
		if op_start > cursor:
			result.append([cursor, op_start - cursor])
		cursor = op_start + op_len
	if cursor < start + length:
		result.append([cursor, (start + length) - cursor])
	return result

func _create_wall_body(parent: Node, px: float, py: float, w: float, h: float) -> void:
	if w <= 0.0 or h <= 0.0:
		return
	var body := StaticBody2D.new()
	body.position = Vector2(px + w * 0.5, py + h * 0.5)
	var shape := CollisionShape2D.new()
	var rect_shape := RectangleShape2D.new()
	rect_shape.size = Vector2(w, h)
	shape.shape = rect_shape
	body.add_child(shape)
	parent.add_child(body)

# ─── Door bodies ───────────────────────────────────────────────────────────────

func _build_door_bodies() -> void:
	var doors_node := Node2D.new()
	doors_node.name = "Doors"
	add_child(doors_node)

	for door_def in DOOR_DEFS:
		var body := StaticBody2D.new()
		body.name = door_def["id"]
		var px: int = int(door_def["tx"]) * T
		var py: int = int(door_def["ty"]) * T
		var w: int = int(door_def["tw"]) * T
		var h: int = int(door_def["th"]) * T
		body.position = Vector2(px + w * 0.5, py + h * 0.5)

		var shape := CollisionShape2D.new()
		var rect_shape := RectangleShape2D.new()
		rect_shape.size = Vector2(float(w), float(h))
		shape.shape = rect_shape
		body.add_child(shape)

		doors_node.add_child(body)
		_door_bodies[door_def["id"]] = body

	refresh_doors()

func refresh_doors() -> void:
	var solved_count := GameState.get_solved_count()
	for door_def in DOOR_DEFS:
		var door_id: String = door_def["id"]
		var unlock_at: int = door_def["unlockAt"]
		var body := _door_bodies.get(door_id) as StaticBody2D
		if body == null:
			continue
		# Door is disabled (open) if solved_count >= unlockAt
		var is_locked := solved_count < unlock_at
		body.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT if is_locked else Node.PROCESS_MODE_DISABLED)
		# Also disable collision
		for child in body.get_children():
			if child is CollisionShape2D:
				child.set_deferred("disabled", not is_locked)

# ─── Player ────────────────────────────────────────────────────────────────────

func _build_player() -> void:
	var player_scene_script := load("res://scripts/Player.gd")
	_player = CharacterBody2D.new()
	_player.name = "Player"
	_player.script = player_scene_script
	_player.z_index = 5

	# CollisionShape for player
	var shape := CollisionShape2D.new()
	var capsule := CapsuleShape2D.new()
	capsule.radius = 8.0
	capsule.height = 20.0
	shape.shape = capsule
	_player.add_child(shape)

	add_child(_player)

	# Set starting position from saved state
	_player.position = GameState.player_pos

# ─── NPC sprites ───────────────────────────────────────────────────────────────

# Which sprite sheet to use per NPC index (Male/Female/Teen for variety).
const NPC_SPRITE_TYPES: Array = ["Female","Male","Female","Male","Male","Male","Male","Female"]

func _build_npcs() -> void:
	var char_base := "res://assets/characters/lpc_character_bases/LPC Character Bases/Human/"
	# Cache textures per type to avoid reloading for each NPC.
	var walk_cache: Dictionary = {}
	var idle_cache: Dictionary = {}
	for t in NPC_SPRITE_TYPES:
		if not walk_cache.has(t):
			walk_cache[t] = load(char_base + t + "/Walk.png") as Texture2D
			idle_cache[t] = load(char_base + t + "/Idle.png") as Texture2D

	for i in range(NPC_DEFS.size()):
		var npc: Dictionary = NPC_DEFS[i]
		var type: String = NPC_SPRITE_TYPES[i % NPC_SPRITE_TYPES.size()]
		var walk_tex: Texture2D = walk_cache[type]
		var idle_tex: Texture2D = idle_cache[type]

		var frames := SpriteFrames.new()
		var dirs := [["s", 0], ["w", 1], ["e", 2], ["n", 3]]
		for d in dirs:
			var key: String = d[0]
			var row: int    = d[1]

			frames.add_animation("walk_" + key)
			frames.set_animation_speed("walk_" + key, 8.0)
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

		var sprite := AnimatedSprite2D.new()
		sprite.sprite_frames = frames
		sprite.scale = Vector2(0.54, 0.54)
		sprite.offset = Vector2(0, -16)
		sprite.z_index = 4
		sprite.position = Vector2(npc["tx"] * T, npc["ty"] * T)
		sprite.play("idle_s")
		add_child(sprite)
		_npc_sprites.append(sprite)

# ─── Interact UI ───────────────────────────────────────────────────────────────

func _build_interact_ui() -> void:
	_interact_canvas = CanvasLayer.new()
	_interact_canvas.name = "InteractCanvas"
	_interact_canvas.layer = 5
	add_child(_interact_canvas)

	_interact_label = Label.new()
	_interact_label.text = "[E] Use Computer"
	_interact_label.add_theme_color_override("font_color", Color(0.12, 0.10, 0.06))
	_interact_label.add_theme_color_override("font_shadow_color", Color(1.0, 1.0, 1.0, 0.9))
	_interact_label.add_theme_constant_override("shadow_offset_x", 0)
	_interact_label.add_theme_constant_override("shadow_offset_y", 1)
	_interact_label.add_theme_font_size_override("font_size", 13)
	_interact_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_interact_label.visible = false
	_interact_canvas.add_child(_interact_label)

# ─── Mission UI ────────────────────────────────────────────────────────────────

func _build_mission_ui() -> void:
	var mission_script := load("res://scripts/MissionUI.gd")
	_mission_ui = CanvasLayer.new()
	_mission_ui.name = "MissionUI"
	_mission_ui.script = mission_script
	add_child(_mission_ui)

	_mission_ui.mission_closed.connect(_on_mission_closed)

# ─── Process ───────────────────────────────────────────────────────────────────

func _process(_delta: float) -> void:
	if _player == null:
		return

	var player_pos: Vector2 = _player.position

	# ── Nearest workstation ──────────────────────────────────────────────────
	_near_ws_idx = -1
	var best_ws_dist := INTERACT_DIST
	for i in range(_workstation_positions.size()):
		var d := player_pos.distance_to(_workstation_positions[i])
		if d < best_ws_dist:
			best_ws_dist = d
			_near_ws_idx = i

	# ── Nearest NPC (only when no dialog open) ───────────────────────────────
	_near_npc_idx = -1
	if not _npc_dialog_open:
		var best_npc_dist := NPC_INTERACT_DIST
		for i in range(NPC_DEFS.size()):
			var npc_pos := Vector2(NPC_DEFS[i]["tx"] * T, NPC_DEFS[i]["ty"] * T)
			var d := player_pos.distance_to(npc_pos)
			if d < best_npc_dist:
				best_npc_dist = d
				_near_npc_idx = i

	# ── NPC sprite highlights ────────────────────────────────────────────────
	for i in range(_npc_sprites.size()):
		_npc_sprites[i].modulate = Color(1.2, 1.1, 0.6) if i == _near_npc_idx else Color.WHITE

	# ── Interact label ───────────────────────────────────────────────────────
	if _npc_dialog_open:
		_interact_label.visible = false
	elif _near_ws_idx >= 0:
		_interact_label.text = "[E] Use Computer"
		_interact_label.visible = true
		var screen_pos := _world_to_screen(_workstation_positions[_near_ws_idx] - Vector2(0, 30))
		_interact_label.position = screen_pos - Vector2(_interact_label.size.x * 0.5, 0)
	elif _near_npc_idx >= 0:
		_interact_label.text = "[E] Talk"
		_interact_label.visible = true
		var npc_world := Vector2(NPC_DEFS[_near_npc_idx]["tx"] * T, NPC_DEFS[_near_npc_idx]["ty"] * T)
		var screen_pos := _world_to_screen(npc_world - Vector2(0, 36))
		_interact_label.position = screen_pos - Vector2(_interact_label.size.x * 0.5, 0)
	else:
		_interact_label.visible = false

	# ── E key ────────────────────────────────────────────────────────────────
	if Input.is_action_just_pressed("interact"):
		if _npc_dialog_open:
			close_npc_dialog()
		elif _near_ws_idx >= 0 and not _player.mission_open:
			open_mission(_near_ws_idx)
		elif _near_npc_idx >= 0:
			open_npc_dialog(_near_npc_idx)

func _world_to_screen(world_pos: Vector2) -> Vector2:
	var camera := _player.get_node_or_null("Camera2D") as Camera2D
	if camera == null:
		return world_pos
	var viewport_size := get_viewport().get_visible_rect().size
	var cam_pos := camera.get_screen_center_position()
	var zoom := camera.zoom
	var offset := (world_pos - cam_pos) * zoom + viewport_size * 0.5
	return offset

# ─── Open mission ──────────────────────────────────────────────────────────────

func open_mission(ws_idx: int) -> void:
	var level_id := ws_idx + 1  # 1-based
	if level_id < 1 or level_id > 100:
		return

	# Check if room is unlocked
	var room := _get_room_for_workstation(ws_idx)
	if not room.is_empty():
		if not GameState.is_room_unlocked(room["id"]):
			_interact_label.text = "Room locked — solve more levels first"
			return

	_player.mission_open = true
	_mission_ui.open_mission(ws_idx)
	_interact_label.visible = false

func _on_mission_closed() -> void:
	_player.mission_open = false
	_interact_label.text = "[E] Use Computer"
	refresh_doors()

func _on_state_changed() -> void:
	refresh_doors()

# ─── NPC dialog UI ─────────────────────────────────────────────────────────────

func _build_npc_ui() -> void:
	_npc_canvas = CanvasLayer.new()
	_npc_canvas.layer = 8
	add_child(_npc_canvas)

	_npc_panel = PanelContainer.new()
	_npc_panel.anchor_left   = 0.08
	_npc_panel.anchor_right  = 0.92
	_npc_panel.anchor_top    = 0.74
	_npc_panel.anchor_bottom = 0.96
	_npc_panel.visible = false

	var bg := StyleBoxFlat.new()
	bg.bg_color     = Color(0.12, 0.10, 0.08, 0.94)
	bg.border_color = Color(0.72, 0.58, 0.28)
	bg.set_border_width_all(2)
	bg.set_corner_radius_all(6)
	bg.content_margin_left   = 14.0
	bg.content_margin_right  = 14.0
	bg.content_margin_top    = 10.0
	bg.content_margin_bottom = 10.0
	_npc_panel.add_theme_stylebox_override("panel", bg)
	_npc_canvas.add_child(_npc_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	_npc_panel.add_child(vbox)

	_npc_name_lbl = Label.new()
	_npc_name_lbl.add_theme_color_override("font_color", Color(0.95, 0.80, 0.30))
	_npc_name_lbl.add_theme_font_size_override("font_size", 14)
	vbox.add_child(_npc_name_lbl)

	var sep := HSeparator.new()
	sep.add_theme_color_override("color", Color(0.50, 0.42, 0.20, 0.6))
	vbox.add_child(sep)

	_npc_text_lbl = Label.new()
	_npc_text_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_npc_text_lbl.add_theme_color_override("font_color", Color(0.90, 0.88, 0.82))
	_npc_text_lbl.add_theme_font_size_override("font_size", 13)
	vbox.add_child(_npc_text_lbl)

	var dismiss := Label.new()
	dismiss.text = "[ E ] Dismiss"
	dismiss.add_theme_color_override("font_color", Color(0.50, 0.48, 0.40))
	dismiss.add_theme_font_size_override("font_size", 10)
	dismiss.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vbox.add_child(dismiss)

func open_npc_dialog(npc_idx: int) -> void:
	var npc: Dictionary = NPC_DEFS[npc_idx]
	_npc_name_lbl.text = npc["name"]
	_npc_text_lbl.text = npc["dialog"]
	_npc_panel.visible = true
	_npc_dialog_open = true
	if _player:
		_player.mission_open = true  # freeze movement while talking

func close_npc_dialog() -> void:
	_npc_panel.visible = false
	_npc_dialog_open = false
	if _player:
		_player.mission_open = false

func _unhandled_input(event: InputEvent) -> void:
	if _npc_dialog_open and event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			close_npc_dialog()
			get_viewport().set_input_as_handled()

# ─── TileMap setup ─────────────────────────────────────────────────────────────

func _setup_tileset() -> void:
	if _floor_layer == null:
		return
	var ts := TileSet.new()
	ts.tile_size = Vector2i(T, T)

	var floor_src := TileSetAtlasSource.new()
	floor_src.texture = load("res://assets/tilesets/lpc_floors/lpc-floors/floors.png")
	floor_src.texture_region_size = Vector2i(T, T)
	for coords: Vector2i in FLOOR_TILES.values():
		if not floor_src.has_tile(coords):
			floor_src.create_tile(coords)
	for coords: Vector2i in FLOOR_TILES_WORN.values():
		if coords != Vector2i(-1, -1) and not floor_src.has_tile(coords):
			floor_src.create_tile(coords)
	ts.add_source(floor_src, SRC_FLOOR)

	var wall_src := TileSetAtlasSource.new()
	wall_src.texture = load("res://assets/tilesets/lpc_walls/lpc-walls/walls.png")
	wall_src.texture_region_size = Vector2i(T, T)
	for coords: Vector2i in WALL_TILES.values():
		if not wall_src.has_tile(coords):
			wall_src.create_tile(coords)
	ts.add_source(wall_src, SRC_WALL)

	_floor_layer.tile_set = ts
	_walls_layer.tile_set = ts
	if _furniture_layer:
		_furniture_layer.tile_set = ts

# ─── TileMap painting ──────────────────────────────────────────────────────────
const SRC_FLOOR := 0   # floors.png — 32 cols × 64 rows, 32×32 px per tile
const SRC_WALL  := 1   # walls.png  — 64 cols × 96 rows, 32×32 px per tile

# floors.png is organised in 8-row bands, each band = one carpet/floor colour.
# col 0 of each band is the top-left variant (confirmed distinct across bands).
# Quality improves as level_start increases: lobby < normal < dim < dark < darker < black.
const FLOOR_TILES: Dictionary = {
	"lobby":   Vector2i(0,  0),   # stone/tile entrance (band 0)
	"normal":  Vector2i(0,  16),  # worn carpet – ground floor (band 2)
	"dim":     Vector2i(0,  32),  # basic clean carpet (band 4)
	"dark":    Vector2i(0,  40),  # mid-grade carpet (band 5)
	"darker":  Vector2i(0,  48),  # premium carpet (band 6)
	"black":   Vector2i(0,  56),  # server vault – industrial dark (band 7)
}

# Worn/patch variant tile used randomly in low-quality rooms.
# Same band as FLOOR_TILES but col 2 = adjacent atlas tile (different orientation).
# Vector2i(-1,-1) means no worn variation for that theme.
const FLOOR_TILES_WORN: Dictionary = {
	"lobby":   Vector2i(-1, -1),
	"normal":  Vector2i(2,  16),  # patchy worn tile – 25 % of ground floor interior
	"dim":     Vector2i(2,  32),  # slight scuff – 8 % in server/noc/mgmt
	"dark":    Vector2i(-1, -1),
	"darker":  Vector2i(-1, -1),
	"black":   Vector2i(-1, -1),
}

# Percentage (0–100) chance an interior cell uses the worn variant.
const FLOOR_WORN_PCT: Dictionary = {
	"lobby":   0,
	"normal":  25,
	"dim":     8,
	"dark":    0,
	"darker":  0,
	"black":   0,
}

# Wall fill tiles — open walls.png in the TileSet editor (Source 1) and
# update these Vector2i(col, row) values to match your preferred style.
const WALL_TILES: Dictionary = {
	"lobby":   Vector2i(8,  4),
	"normal":  Vector2i(8,  4),
	"dim":     Vector2i(24, 4),
	"dark":    Vector2i(32, 4),
	"darker":  Vector2i(40, 4),
	"black":   Vector2i(48, 4),
}

func _paint_tilemap() -> void:
	if _floor_layer == null or _walls_layer == null:
		return
	for room in ROOMS:
		_paint_room(room)
	for corr in NS_CORRIDORS:
		_paint_corridor_ns(corr)
	for corr in EW_CORRIDORS:
		_paint_corridor_ew(corr)

func _paint_room(room: Dictionary) -> void:
	var tx: int = room["tx"]
	var ty: int = room["ty"]
	var tw: int = room["tw"]
	var th: int = room["th"]
	var rid: String = room["id"]
	var theme: String = room.get("theme", "normal")
	var ft: Vector2i = FLOOR_TILES.get(theme, FLOOR_TILES["normal"])
	var wt: Vector2i = WALL_TILES.get(theme, WALL_TILES["normal"])
	var ft_worn: Vector2i = FLOOR_TILES_WORN.get(theme, Vector2i(-1, -1))
	var worn_pct: int  = FLOOR_WORN_PCT.get(theme, 0)
	var room_seed: int = rid.hash()

	var open_cells: Dictionary = {}
	for op in OPENINGS.get(rid, []):
		var s: int = op["start"]
		var l: int = op["len"]
		match op["wall"]:
			"N":
				for i in range(l):
					open_cells[Vector2i(tx + s + i, ty)] = true
			"S":
				for i in range(l):
					open_cells[Vector2i(tx + s + i, ty + th - 1)] = true
			"W":
				for i in range(l):
					open_cells[Vector2i(tx, ty + s + i)] = true
			"E":
				for i in range(l):
					open_cells[Vector2i(tx + tw - 1, ty + s + i)] = true

	for x in range(tx, tx + tw):
		for y in range(ty, ty + th):
			var coord := Vector2i(x, y)
			var is_border := (x == tx or x == tx + tw - 1 or y == ty or y == ty + th - 1)
			var tile: Vector2i = ft
			if not is_border and worn_pct > 0 and ft_worn != Vector2i(-1, -1):
				# Deterministic hash per cell — same worn pattern every run
				var h: int = (x * 374761393 + y * 668265263 + room_seed) & 0x7FFFFFFF
				if h % 100 < worn_pct:
					tile = ft_worn
			_floor_layer.set_cell(coord, SRC_FLOOR, tile)
			if is_border and not open_cells.has(coord):
				_walls_layer.set_cell(coord, SRC_WALL, wt)

func _paint_corridor_ns(corr: Dictionary) -> void:
	var ft: Vector2i = FLOOR_TILES.get(corr.get("theme", "normal"), FLOOR_TILES["normal"])
	for x in range(corr["cx"], corr["cx"] + 4):
		for y in range(corr["ty"], corr["ty"] + corr["th"]):
			_floor_layer.set_cell(Vector2i(x, y), SRC_FLOOR, ft)

func _paint_corridor_ew(corr: Dictionary) -> void:
	var ft: Vector2i = FLOOR_TILES.get(corr.get("theme", "normal"), FLOOR_TILES["normal"])
	for x in range(corr["tx"], corr["tx"] + corr["tw"]):
		for y in range(corr["ty"], corr["ty"] + corr["th"]):
			_floor_layer.set_cell(Vector2i(x, y), SRC_FLOOR, ft)

