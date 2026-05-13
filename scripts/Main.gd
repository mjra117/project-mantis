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

# ─── Themes ────────────────────────────────────────────────────────────────────
const THEMES: Dictionary = {
	"lobby":  {"floor": Color(0.94, 0.91, 0.86), "wall": Color(0.68, 0.64, 0.56), "label": Color(0.28, 0.13, 0.02)},
	"normal": {"floor": Color(0.80, 0.73, 0.62), "wall": Color(0.52, 0.46, 0.37), "label": Color(0.22, 0.09, 0.01)},
	"dim":    {"floor": Color(0.62, 0.68, 0.80), "wall": Color(0.40, 0.45, 0.57), "label": Color(0.10, 0.22, 0.60)},
	"dark":   {"floor": Color(0.48, 0.52, 0.65), "wall": Color(0.30, 0.33, 0.46), "label": Color(0.55, 0.72, 1.00)},
	"darker": {"floor": Color(0.34, 0.29, 0.42), "wall": Color(0.21, 0.17, 0.27), "label": Color(0.82, 0.66, 0.96)},
	"black":  {"floor": Color(0.13, 0.08, 0.16), "wall": Color(0.08, 0.04, 0.10), "label": Color(0.95, 0.72, 0.18)},
}

# ─── State ─────────────────────────────────────────────────────────────────────
var _player  # CharacterBody2D with Player.gd script
var _map_renderer: Node2D
var _mission_ui  # CanvasLayer with MissionUI.gd script
var _interact_label: Label
var _interact_canvas: CanvasLayer
var _door_bodies: Dictionary = {}   # door_id -> StaticBody2D
var _workstation_positions: Array[Vector2] = []

var _floor_layer: TileMapLayer
var _walls_layer: TileMapLayer
var _furniture_layer: TileMapLayer

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
	_build_map_renderer()
	_map_renderer.visible = false
	_build_player()
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

# ─── Map renderer ──────────────────────────────────────────────────────────────

func _build_map_renderer() -> void:
	_map_renderer = Node2D.new()
	_map_renderer.name = "MapRenderer"
	_map_renderer.z_index = 0
	add_child(_map_renderer)

	# We attach a script-like approach using a custom draw node
	var draw_node := _DrawNode.new()
	draw_node.name = "DrawNode"
	draw_node.main_ref = self
	_map_renderer.add_child(draw_node)

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

	# Get theme wall color
	var theme_key: String = room.get("theme", "normal")
	var theme: Dictionary = THEMES.get(theme_key, THEMES["normal"])
	var _wall_color: Color = theme["wall"]

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
	refresh_workstations()
	refresh_doors()

func _on_state_changed() -> void:
	refresh_workstations()
	refresh_doors()

# ─── Refresh workstations ──────────────────────────────────────────────────────

func refresh_workstations() -> void:
	var draw_node := _map_renderer.get_node_or_null("DrawNode") as Node2D
	if draw_node:
		draw_node.queue_redraw()

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

# Carpet center tiles are row 3 of floors.png, derived from the LPC wang set.
# "lobby" is a guess at the plain-tile area near the bottom — adjust in editor.
const FLOOR_TILES: Dictionary = {
	"lobby":   Vector2i(0,  56),
	"normal":  Vector2i(25, 3),
	"dim":     Vector2i(7,  3),
	"dark":    Vector2i(10, 3),
	"darker":  Vector2i(19, 3),
	"black":   Vector2i(22, 3),
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
			_floor_layer.set_cell(coord, SRC_FLOOR, ft)
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

# ─── Inner draw class ──────────────────────────────────────────────────────────

class _DrawNode extends Node2D:
	var main_ref  # outer Main node

	func _draw() -> void:
		if main_ref == null:
			return
		_draw_background()
		_draw_corridors()
		_draw_rooms()
		_draw_workstations()
		_draw_door_indicators()
		_draw_npc_dots()

	func _draw_background() -> void:
		# ── Asphalt base ────────────────────────────────────────────────────────
		draw_rect(Rect2(0, 0, MAP_W * T, MAP_H * T), Color(0.28, 0.27, 0.25))

		# ── City street below the building ──────────────────────────────────────
		var sy := 75 * T
		draw_rect(Rect2(0, sy, MAP_W * T, T), Color(0.58, 0.55, 0.50))           # near sidewalk
		draw_rect(Rect2(0, sy + T, MAP_W * T, 2 * T), Color(0.26, 0.25, 0.23))   # road
		for i in range(0, MAP_W, 4):                                               # centre dashes
			draw_rect(Rect2(i * T, sy + T + T / 2 - 2, 2 * T, 4), Color(0.88, 0.78, 0.10, 0.9))
		draw_rect(Rect2(0, sy + 3 * T - 4, MAP_W * T, 4), Color(0.55, 0.52, 0.48))  # far kerb
		# Crosswalk
		for s in range(7):
			draw_rect(Rect2(34 * T + s * 7, sy, 5, T), Color(0.90, 0.90, 0.88, 0.65))
		# Parked cars
		_draw_car(Vector2(2 * T, sy + T - 10), Color(0.82, 0.14, 0.14))
		_draw_car(Vector2(9 * T, sy + T - 10), Color(0.14, 0.28, 0.80))
		_draw_car(Vector2(18 * T, sy + T - 10), Color(0.20, 0.56, 0.22))
		_draw_car(Vector2(30 * T, sy + T - 10), Color(0.22, 0.22, 0.22))
		_draw_car(Vector2(45 * T, sy + T - 10), Color(0.86, 0.72, 0.10))
		_draw_car(Vector2(56 * T, sy + T - 10), Color(0.58, 0.58, 0.62))
		_draw_car(Vector2(64 * T, sy + T - 10), Color(0.55, 0.18, 0.62))
		# Sidewalk trees
		_draw_street_tree(Vector2(6 * T, sy + 14))
		_draw_street_tree(Vector2(15 * T, sy + 14))
		_draw_street_tree(Vector2(27 * T, sy + 14))
		_draw_street_tree(Vector2(41 * T, sy + 14))
		_draw_street_tree(Vector2(53 * T, sy + 14))
		_draw_street_tree(Vector2(63 * T, sy + 14))

		# ── Left adjacent building ───────────────────────────────────────────────
		draw_rect(Rect2(0, 0, T, MAP_H * T), Color(0.42, 0.40, 0.44))
		for row in range(0, MAP_H * T, 9):
			draw_line(Vector2(0, float(row)), Vector2(float(T), float(row)), Color(0.34, 0.32, 0.36), 1.0)
		for wy in range(4 * T, (MAP_H - 4) * T, 4 * T):
			var wc := Color(0.86, 0.82, 0.50, 0.9) if (wy / T) % 8 == 0 else Color(0.28, 0.34, 0.46)
			draw_rect(Rect2(4, wy + 4, T - 8, 2 * T - 8), wc)

		# ── Right adjacent building ──────────────────────────────────────────────
		draw_rect(Rect2((MAP_W - 1) * T, 0, T, MAP_H * T), Color(0.38, 0.36, 0.40))
		for row in range(0, MAP_H * T, 9):
			draw_line(Vector2(float((MAP_W - 1) * T), float(row)), Vector2(float(MAP_W * T), float(row)), Color(0.30, 0.28, 0.32), 1.0)
		for wy in range(3 * T, (MAP_H - 4) * T, 4 * T):
			var wc := Color(0.72, 0.82, 0.92, 0.85) if (wy / T) % 8 != 0 else Color(0.88, 0.82, 0.44, 0.9)
			draw_rect(Rect2((MAP_W - 1) * T + 4, wy + 4, T - 8, 2 * T - 8), wc)

		# ── Rooftop of building overhead (top strip) ─────────────────────────────
		draw_rect(Rect2(0, 0, MAP_W * T, T), Color(0.38, 0.36, 0.42))
		for i in range(7):
			var hx := float((2 + i * 9) * T)
			draw_rect(Rect2(hx, 2, 4 * T, T - 4), Color(0.50, 0.48, 0.54))
			draw_rect(Rect2(hx + 3, 5, 4 * T - 6, T - 10), Color(0.57, 0.55, 0.60))

		# ── Between-floor building interior accent ────────────────────────────────
		for gty in [11, 27, 43]:
			draw_rect(Rect2(T, gty * T, (MAP_W - 2) * T, 2 * T), Color(0.46, 0.44, 0.40))
		draw_rect(Rect2(T, 59 * T, (MAP_W - 2) * T, 2 * T), Color(0.50, 0.47, 0.43))

	func _draw_car(pos: Vector2, col: Color) -> void:
		# Body (top-down)
		draw_rect(Rect2(pos.x, pos.y, 5 * T, T), col)
		draw_rect(Rect2(pos.x + T, pos.y - 8, 3 * T, 9), col)
		# Windshields (blue tint)
		var glass := Color(0.60, 0.80, 0.92, 0.75)
		draw_rect(Rect2(pos.x + T + 2, pos.y - 6, T - 4, 5), glass)
		draw_rect(Rect2(pos.x + 2 * T + 4, pos.y - 6, T - 6, 5), glass)
		# Wheels
		draw_circle(Vector2(pos.x + 10, pos.y + T), 5, Color(0.10, 0.10, 0.10))
		draw_circle(Vector2(pos.x + 4 * T - 10, pos.y + T), 5, Color(0.10, 0.10, 0.10))

	func _draw_street_tree(pos: Vector2) -> void:
		draw_rect(Rect2(pos.x - 3, pos.y - 4, 6, 10), Color(0.38, 0.22, 0.08))
		draw_circle(pos, 13, Color(0.18, 0.52, 0.14))
		draw_circle(pos + Vector2(-5, -5), 8, Color(0.24, 0.60, 0.18))
		draw_circle(pos + Vector2(5, -4), 8, Color(0.16, 0.50, 0.12))
		draw_circle(pos + Vector2(0, 5), 9, Color(0.20, 0.56, 0.16))

	func _draw_corridors() -> void:
		for corr in NS_CORRIDORS:
			var theme: Dictionary = THEMES.get(corr["theme"], THEMES["normal"])
			var floor_col: Color = theme["floor"]
			var wall_col: Color = theme["wall"]
			var cx: int = corr["cx"]
			var ty: int = corr["ty"]
			var th: int = corr["th"]
			draw_rect(Rect2(cx * T, ty * T, 4 * T, th * T), floor_col)
			draw_line(Vector2(cx * T, ty * T), Vector2(cx * T, (ty + th) * T), wall_col, 2.0)
			draw_line(Vector2((cx + 4) * T, ty * T), Vector2((cx + 4) * T, (ty + th) * T), wall_col, 2.0)

		for corr in EW_CORRIDORS:
			var theme: Dictionary = THEMES.get(corr["theme"], THEMES["normal"])
			var floor_col: Color = theme["floor"]
			var wall_col: Color = theme["wall"]
			draw_rect(Rect2(corr["tx"] * T, corr["ty"] * T, corr["tw"] * T, corr["th"] * T), floor_col)
			draw_line(Vector2(corr["tx"] * T, corr["ty"] * T), Vector2((corr["tx"] + corr["tw"]) * T, corr["ty"] * T), wall_col, 2.0)
			draw_line(Vector2(corr["tx"] * T, (corr["ty"] + corr["th"]) * T), Vector2((corr["tx"] + corr["tw"]) * T, (corr["ty"] + corr["th"]) * T), wall_col, 2.0)

	func _draw_rooms() -> void:
		for room in ROOMS:
			var tx: int = room["tx"]
			var ty: int = room["ty"]
			var tw: int = room["tw"]
			var th: int = room["th"]
			var theme_key: String = room.get("theme", "normal")
			var theme: Dictionary = THEMES.get(theme_key, THEMES["normal"])
			var wall_col: Color = theme["wall"]
			var floor_col: Color = theme["floor"]
			var label_col: Color = theme["label"]
			var room_id: String = room["id"]
			var inner_x := (tx + 1) * T
			var inner_y := (ty + 1) * T
			var inner_w := (tw - 2) * T
			var inner_h := (th - 2) * T

			# Wall fill
			draw_rect(Rect2(tx * T, ty * T, tw * T, th * T), wall_col)

			# Floor fill
			draw_rect(Rect2(inner_x, inner_y, inner_w, inner_h), floor_col)

			# Floor tile pattern
			if theme_key == "lobby":
				# Checkerboard marble tiles
				var tile_alt := Color(floor_col.r * 0.92, floor_col.g * 0.92, floor_col.b * 0.90)
				for gx in range(tx + 1, tx + tw - 1):
					for gy in range(ty + 1, ty + th - 1):
						if (gx + gy) % 2 == 0:
							draw_rect(Rect2(gx * T, gy * T, T, T), tile_alt)
			else:
				# Subtle carpet grid
				var grid_col := Color(floor_col.r * 0.88, floor_col.g * 0.88, floor_col.b * 0.86, 0.55)
				for gx in range(tx + 1, tx + tw - 1):
					draw_line(Vector2(gx * T, inner_y), Vector2(gx * T, inner_y + inner_h), grid_col, 0.5)
				for gy in range(ty + 1, ty + th - 1):
					draw_line(Vector2(inner_x, gy * T), Vector2(inner_x + inner_w, gy * T), grid_col, 0.5)

			# Baseboard strip along inner wall edges
			var base_col := Color(wall_col.r * 1.12, wall_col.g * 1.12, wall_col.b * 1.12)
			draw_rect(Rect2(inner_x, inner_y, inner_w, 4), base_col)
			draw_rect(Rect2(inner_x, inner_y + inner_h - 4, inner_w, 4), base_col)
			draw_rect(Rect2(inner_x, inner_y, 4, inner_h), base_col)
			draw_rect(Rect2(inner_x + inner_w - 4, inner_y, 4, inner_h), base_col)

			# Corner plants (office/lobby rooms)
			if theme_key in ["normal", "lobby"]:
				_draw_plant(inner_x + 6, inner_y + inner_h - 20)
				_draw_plant(inner_x + inner_w - 14, inner_y + 4)

			# Filing cabinets on east wall
			if theme_key in ["normal", "dim", "dark"]:
				var cab := Color(0.62, 0.60, 0.56)
				var cab_dk := Color(0.45, 0.43, 0.40)
				for i in range(3):
					var cx2 := inner_x + inner_w - 14
					var cy2 := inner_y + 22 + i * 22
					draw_rect(Rect2(cx2, cy2, 10, 18), cab)
					draw_rect(Rect2(cx2, cy2, 10, 2), cab_dk)
					draw_rect(Rect2(cx2, cy2 + 9, 10, 1), cab_dk)
					draw_rect(Rect2(cx2 + 3, cy2 + 4, 3, 4), cab_dk)
					draw_rect(Rect2(cx2 + 3, cy2 + 12, 3, 4), cab_dk)

			# Room-specific furniture
			_draw_room_extras(room_id, inner_x, inner_y, inner_w, inner_h)

			# Corridor openings (paint floor over walls)
			var openings: Array = OPENINGS.get(room_id, [])
			for op in openings:
				var wall: String = op["wall"]
				var op_start: int = op["start"]
				var op_len: int = op["len"]
				match wall:
					"N": draw_rect(Rect2((tx + op_start) * T, ty * T, op_len * T, T), floor_col)
					"S": draw_rect(Rect2((tx + op_start) * T, (ty + th - 1) * T, op_len * T, T), floor_col)
					"W": draw_rect(Rect2(tx * T, (ty + op_start) * T, T, op_len * T), floor_col)
					"E": draw_rect(Rect2((tx + tw - 1) * T, (ty + op_start) * T, T, op_len * T), floor_col)

			# Room name label
			var is_unlocked := GameState.is_room_unlocked(room_id)
			var name_col := label_col if is_unlocked else Color(0.45, 0.42, 0.38)
			draw_string(ThemeDB.fallback_font, Vector2(inner_x + 6, inner_y + 14),
				room["name"], HORIZONTAL_ALIGNMENT_LEFT, -1, 11, name_col)

			# Locked overlay + text
			if not is_unlocked:
				draw_rect(Rect2(inner_x, inner_y, inner_w, inner_h), Color(0.0, 0.0, 0.0, 0.40))
				var room_def: Dictionary = {}
				for r in ROOMS:
					if r["id"] == room_id:
						room_def = r
						break
				if not room_def.is_empty():
					var unlock_at: int = room_def.get("unlockAt", 0)
					var cx3 := (tx + tw / 2) * T
					var cy3 := (ty + th / 2) * T
					draw_string(ThemeDB.fallback_font, Vector2(cx3 - 48, cy3),
						"LOCKED — NEED %d SOLVED" % unlock_at,
						HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.85, 0.82, 0.78))

	func _draw_plant(px: float, py: float) -> void:
		draw_rect(Rect2(px, py + 8, 8, 10), Color(0.55, 0.32, 0.12))
		draw_circle(Vector2(px + 4, py + 6), 7, Color(0.20, 0.58, 0.14))
		draw_circle(Vector2(px, py + 10), 4, Color(0.25, 0.62, 0.18))
		draw_circle(Vector2(px + 8, py + 10), 4, Color(0.18, 0.52, 0.12))

	func _draw_water_cooler(cx: float, cy: float) -> void:
		draw_rect(Rect2(cx - 7, cy - 4, 14, 22), Color(0.88, 0.90, 0.92))       # white body
		draw_rect(Rect2(cx - 5, cy - 18, 10, 16), Color(0.38, 0.62, 0.88, 0.85)) # blue jug
		draw_circle(Vector2(cx, cy - 18), 5, Color(0.38, 0.62, 0.88, 0.85))      # jug dome
		draw_rect(Rect2(cx - 8, cy + 4, 3, 3), Color(0.18, 0.48, 0.82))          # blue spigot
		draw_rect(Rect2(cx + 5, cy + 4, 3, 3), Color(0.88, 0.18, 0.18))          # red spigot
		draw_rect(Rect2(cx + 6, cy - 2, 5, 8), Color(0.72, 0.72, 0.72))          # cup holder
		draw_rect(Rect2(cx + 7, cy - 1, 3, 2), Color(0.90, 0.90, 0.90))

	func _draw_whiteboard(x: float, y: float, w: float, h: float) -> void:
		draw_rect(Rect2(x - 2, y - 2, w + 4, h + 4), Color(0.58, 0.52, 0.44))   # frame
		draw_rect(Rect2(x, y, w, h), Color(0.97, 0.97, 0.96))                    # surface
		# Marker content
		draw_line(Vector2(x+5, y+7),  Vector2(x+w-10, y+7),  Color(0.0, 0.0, 0.80, 0.7), 1.5)
		draw_line(Vector2(x+5, y+12), Vector2(x+w-20, y+12), Color(0.0, 0.0, 0.80, 0.55), 1.5)
		draw_line(Vector2(x+5, y+17), Vector2(x+22, y+17),   Color(0.0, 0.0, 0.80, 0.45), 1.5)
		draw_arc(Vector2(x+w-14, y+12), 7, 0.0, TAU, 8, Color(0.85, 0.10, 0.10, 0.75), 1.5)
		draw_line(Vector2(x+w-22, y+6), Vector2(x+w-8, y+20), Color(0.10, 0.65, 0.10, 0.6), 1.5)
		draw_line(Vector2(x+w-8, y+6),  Vector2(x+w-22, y+20), Color(0.10, 0.65, 0.10, 0.6), 1.5)
		# Marker tray at bottom
		draw_rect(Rect2(x, y + h, w, 4), Color(0.70, 0.65, 0.58))
		for m in range(4):
			draw_rect(Rect2(x + 4 + m * 8, y + h + 1, 5, 2),
				[Color(0.8,0.1,0.1), Color(0.1,0.1,0.8), Color(0.1,0.6,0.1), Color(0.0,0.0,0.0)][m])

	func _draw_printer(cx: float, cy: float) -> void:
		draw_rect(Rect2(cx - 16, cy - 10, 32, 22), Color(0.78, 0.76, 0.74))      # body
		draw_rect(Rect2(cx - 16, cy - 10, 32, 7), Color(0.68, 0.66, 0.64))       # lid
		draw_rect(Rect2(cx - 12, cy + 8, 24, 4), Color(0.92, 0.92, 0.90))        # paper tray
		draw_rect(Rect2(cx - 10, cy + 9, 20, 1), Color(0.85, 0.85, 0.83))        # paper edge
		draw_circle(Vector2(cx + 12, cy - 7), 2, Color(0.0, 0.85, 0.20))         # ready light
		draw_rect(Rect2(cx - 6, cy - 8, 12, 7), Color(0.38, 0.52, 0.72))         # control panel
		draw_rect(Rect2(cx - 4, cy - 6, 4, 3), Color(0.55, 0.72, 0.90))          # button
		draw_rect(Rect2(cx + 2, cy - 6, 3, 3), Color(0.90, 0.55, 0.20))          # button 2

	func _draw_room_extras(room_id: String, ix: float, iy: float, iw: float, ih: float) -> void:
		match room_id:
			"office":
				# Water cooler — top-right corner
				_draw_water_cooler(ix + iw - 30, iy + 28)
				# Whiteboard on north wall
				_draw_whiteboard(ix + iw * 0.25, iy + 4, iw * 0.45, 22)
				# MFP printer — bottom-left area
				_draw_printer(ix + 30, iy + ih - 28)
			"lobby":
				# Reception desk (long counter)
				draw_rect(Rect2(ix + iw * 0.3, iy + 18, iw * 0.4, 16), Color(0.72, 0.64, 0.50))
				draw_rect(Rect2(ix + iw * 0.3, iy + 18, iw * 0.4, 3), Color(0.82, 0.74, 0.60))
				draw_rect(Rect2(ix + iw * 0.3 + 4, iy + 22, 8, 10), Color(0.22, 0.48, 0.82, 0.6)) # monitor
				# Lobby seating (couch)
				draw_rect(Rect2(ix + 10, iy + ih - 24, 50, 16), Color(0.62, 0.32, 0.22))  # sofa
				draw_rect(Rect2(ix + 10, iy + ih - 28, 50, 6), Color(0.52, 0.26, 0.18))   # back
				draw_rect(Rect2(ix + 8, iy + ih - 24, 6, 16), Color(0.52, 0.26, 0.18))    # arm L
				draw_rect(Rect2(ix + 56, iy + ih - 24, 6, 16), Color(0.52, 0.26, 0.18))   # arm R
				# Info board
				_draw_whiteboard(ix + iw - 46, iy + 4, 38, 28)
			"it":
				# Network patch panel on wall
				draw_rect(Rect2(ix + 10, iy + 6, 60, 12), Color(0.35, 0.35, 0.38))
				for p in range(12):
					var port_col := Color(0.0, 0.85, 0.30) if p % 3 != 2 else Color(0.85, 0.30, 0.10)
					draw_rect(Rect2(ix + 13 + p * 5, iy + 10, 3, 4), port_col)
				# Water cooler
				_draw_water_cooler(ix + iw - 28, iy + ih / 2)
			"server":
				# Server racks (top-down view: dark tall rectangles)
				for r in range(4):
					var rx := ix + 8 + r * 28
					draw_rect(Rect2(rx, iy + 6, 22, ih - 12), Color(0.22, 0.22, 0.26))
					for u in range(8):
						var light := Color(0.0, 0.85, 0.30) if u % 3 != 2 else Color(0.85, 0.65, 0.0)
						draw_rect(Rect2(rx + 3, iy + 10 + u * 14, 4, 3), light)
						draw_rect(Rect2(rx + 10, iy + 10 + u * 14, 9, 3), Color(0.15, 0.15, 0.18))
			"noc":
				# Wall-of-monitors display (north wall)
				for m in range(5):
					var mx := ix + 10 + m * 26
					draw_rect(Rect2(mx, iy + 4, 22, 16), Color(0.18, 0.18, 0.22))
					draw_rect(Rect2(mx + 2, iy + 6, 18, 11),
						[Color(0.0,0.5,0.8), Color(0.8,0.3,0.0), Color(0.0,0.7,0.4),
						 Color(0.6,0.0,0.8), Color(0.8,0.6,0.0)][m])
			"mgmt":
				# Conference table (big rectangle in centre)
				draw_rect(Rect2(ix + iw/2 - 40, iy + ih/2 - 18, 80, 36), Color(0.58, 0.44, 0.28))
				draw_rect(Rect2(ix + iw/2 - 38, iy + ih/2 - 16, 76, 32), Color(0.64, 0.50, 0.32))
				# Chairs around table
				for c in range(5):
					var cx2 := ix + iw/2 - 35 + c * 18
					draw_rect(Rect2(cx2, iy + ih/2 - 28, 12, 8), Color(0.35, 0.25, 0.18))
					draw_rect(Rect2(cx2, iy + ih/2 + 22, 12, 8), Color(0.35, 0.25, 0.18))
			"security":
				# Camera monitor wall
				for m in range(3):
					var mx := ix + 8 + m * 36
					draw_rect(Rect2(mx, iy + 4, 30, 20), Color(0.18, 0.14, 0.14))
					draw_rect(Rect2(mx + 2, iy + 6, 26, 16), Color(0.15, 0.08, 0.08))
					# Camera feeds (dark with a spot of light)
					draw_circle(Vector2(mx + 15, iy + 14), 5, Color(0.30, 0.28, 0.24))
			"rd":
				# Lab bench equipment
				draw_rect(Rect2(ix + 6, iy + 6, iw - 12, 14), Color(0.82, 0.82, 0.80))
				for e in range(4):
					draw_rect(Rect2(ix + 10 + e * 30, iy + 8, 18, 10), Color(0.40, 0.46, 0.55))
					draw_rect(Rect2(ix + 12 + e * 30, iy + 9, 6, 4), Color(0.0, 0.75, 0.92, 0.8))
			"design":
				# Creative mood board (pin board)
				draw_rect(Rect2(ix + 8, iy + 4, iw * 0.5, 26), Color(0.72, 0.58, 0.40))
				for p in range(8):
					var px2 := ix + 12 + p * 18
					var col2: Color = ([Color(0.9,0.2,0.2), Color(0.2,0.5,0.9), Color(0.2,0.8,0.3),
								Color(0.9,0.8,0.1), Color(0.8,0.3,0.8), Color(0.3,0.7,0.7),
								Color(0.95,0.5,0.1), Color(0.5,0.9,0.5)] as Array)[p]
					draw_rect(Rect2(px2, iy + 7, 12, 18), col2)
			"exec":
				# Bookshelf along north wall
				draw_rect(Rect2(ix + 4, iy + 4, iw - 8, 18), Color(0.40, 0.28, 0.16))
				for b in range(14):
					var bw := 8 + (b * 3) % 5
					draw_rect(Rect2(ix + 6 + b * 12, iy + 6, bw, 14),
						[Color(0.7,0.1,0.1), Color(0.1,0.3,0.7), Color(0.1,0.6,0.2),
						Color(0.7,0.6,0.1), Color(0.4,0.1,0.6), Color(0.7,0.3,0.1),
						Color(0.1,0.5,0.5)][b % 7])
			"vault":
				# Dense server rack rows
				for r in range(5):
					var rx := ix + 6 + r * 28
					draw_rect(Rect2(rx, iy + 4, 20, ih - 8), Color(0.18, 0.10, 0.12))
					for u in range(10):
						draw_rect(Rect2(rx + 2, iy + 8 + u * 10, 16, 4), Color(0.10, 0.06, 0.08))
						var lc := Color(0.90, 0.15, 0.10) if u % 4 == 0 else Color(0.0, 0.72, 0.28)
						draw_circle(Vector2(rx + 17, iy + 10 + u * 10), 2, lc)

	# Per-desk character data (ws_idx → personality)
	const DESK_CHARS: Dictionary = {
		0: {"owner": "Bob",    "vibe": "bob_mess"},
		1: {"owner": "Robert", "vibe": "hitech"},
		2: {"owner": "Karen",  "vibe": "neat"},
		3: {"owner": "Dave",   "vibe": "gamer"},
		4: {"owner": "Tim",    "vibe": "intern"},
		5: {"owner": "Janet",  "vibe": "plant_lover"},
		6: {"owner": "Carl",   "vibe": "food_mess"},
		7: {"owner": "Sarah",  "vibe": "sticky_notes"},
		8: {"owner": "Mike",   "vibe": "it_guy"},
		9: {"owner": "Boss",   "vibe": "executive"},
	}

	func _draw_workstations() -> void:
		for i in range(main_ref._workstation_positions.size()):
			var ws_pos: Vector2 = main_ref._workstation_positions[i]
			var level_id := i + 1
			var room: Dictionary = main_ref._get_room_for_workstation(i)
			if room.is_empty():
				continue

			var room_unlocked: bool = GameState.is_room_unlocked(room["id"])
			var is_solved: bool    = GameState.is_solved(level_id)
			var is_skipped: bool   = GameState.is_skipped(level_id)
			var is_near: bool      = (i == main_ref._near_ws_idx)

			# Base color palette per game state
			var desk_col: Color
			var monitor_col: Color
			var screen_col: Color
			var num_col: Color

			if not room_unlocked:
				desk_col    = Color(0.42, 0.40, 0.37)
				monitor_col = Color(0.30, 0.28, 0.26)
				screen_col  = Color(0.16, 0.15, 0.14)
				num_col     = Color(0.5, 0.5, 0.5)
			elif is_solved:
				desk_col    = Color(0.52, 0.68, 0.48)
				monitor_col = Color(0.30, 0.45, 0.28)
				screen_col  = Color(0.08, 0.70, 0.42)
				num_col     = Color(0.0, 1.0, 0.55)
			elif is_skipped:
				desk_col    = Color(0.72, 0.62, 0.35)
				monitor_col = Color(0.52, 0.42, 0.20)
				screen_col  = Color(0.88, 0.62, 0.10)
				num_col     = Color(1.0, 0.80, 0.20)
			else:
				desk_col    = Color(0.74, 0.63, 0.48)
				monitor_col = Color(0.48, 0.40, 0.30)
				screen_col  = Color(0.22, 0.48, 0.82)
				num_col     = Color(0.85, 0.92, 1.00)

			var vibe: String = str(DESK_CHARS.get(i, {}).get("vibe", ""))
			var owner: String = str(DESK_CHARS.get(i, {}).get("owner", ""))

			# ── Override screen colour for desk personalities ─────────────────
			if room_unlocked and not is_solved and not is_skipped:
				match vibe:
					"bob_mess":    screen_col = Color(0.92, 0.62, 0.68)  # beach/warm wallpaper
					"hitech":      screen_col = Color(0.04, 0.08, 0.16)  # super dark pro
					"neat":        screen_col = Color(0.70, 0.80, 0.95)  # corporate blue
					"gamer":       screen_col = Color(0.10, 0.02, 0.20)  # dark purple
					"intern":      screen_col = Color(0.88, 0.88, 0.88)  # blank/blank
					"plant_lover": screen_col = Color(0.28, 0.62, 0.32)  # soft green
					"food_mess":   screen_col = Color(0.75, 0.45, 0.10)  # YT orange
					"sticky_notes":screen_col = Color(0.55, 0.72, 0.48)  # spreadsheet
					"it_guy":      screen_col = Color(0.05, 0.14, 0.05)  # terminal green
					"executive":   screen_col = Color(0.10, 0.08, 0.18)  # dark dashboard

			# ── PRE-DESK extras (drawn behind desk) ──────────────────────────
			match vibe:
				"bob_mess":
					# Box of cables and busted keyboards on the floor beside desk
					draw_rect(Rect2(ws_pos.x + 14, ws_pos.y - 2, 14, 12), Color(0.40, 0.30, 0.18))  # cardboard box
					draw_rect(Rect2(ws_pos.x + 14, ws_pos.y - 2, 14, 2), Color(0.30, 0.22, 0.12))
					# Cable squiggles
					for c2 in range(4):
						draw_line(Vector2(ws_pos.x + 16 + c2 * 3, ws_pos.y),
								  Vector2(ws_pos.x + 18 + c2 * 3, ws_pos.y + 8),
								  Color(0.15, 0.15, 0.15, 0.8), 1.5)
					# Broken keyboard fragment
					draw_rect(Rect2(ws_pos.x + 16, ws_pos.y + 4, 10, 5), Color(0.55, 0.52, 0.50))
				"hitech":
					# Second ultra-wide monitor to the right
					draw_rect(Rect2(ws_pos.x + 12, ws_pos.y - 16, 20, 11), Color(0.10, 0.10, 0.12))
					draw_rect(Rect2(ws_pos.x + 13, ws_pos.y - 14, 18, 8), Color(0.04, 0.08, 0.16))
					# Docking station on desk
					draw_rect(Rect2(ws_pos.x + 10, ws_pos.y + 1, 8, 5), Color(0.20, 0.20, 0.22))
				"gamer":
					# RGB strip on desk edge
					var rgb_cols := [Color(1,0,0,0.7), Color(0,1,0,0.7), Color(0,0,1,0.7),
									 Color(1,0,1,0.7), Color(1,1,0,0.7), Color(0,1,1,0.7)]
					for r2 in range(6):
						draw_rect(Rect2(ws_pos.x - 13 + r2 * 4, ws_pos.y + 7, 4, 2), rgb_cols[r2])
					# Energy drink can
					draw_rect(Rect2(ws_pos.x + 8, ws_pos.y - 3, 5, 8), Color(0.10, 0.70, 0.20))
					draw_rect(Rect2(ws_pos.x + 8, ws_pos.y - 5, 5, 3), Color(0.88, 0.88, 0.88))
				"food_mess":
					# Burger wrapper
					draw_rect(Rect2(ws_pos.x - 14, ws_pos.y + 1, 8, 5), Color(0.80, 0.72, 0.30))
					# Coffee cup tipped
					draw_rect(Rect2(ws_pos.x - 14, ws_pos.y - 4, 5, 5), Color(0.75, 0.60, 0.45))
					draw_rect(Rect2(ws_pos.x - 16, ws_pos.y - 1, 10, 3), Color(0.45, 0.25, 0.10, 0.5))
				"sticky_notes":
					# Sticky notes fanned around monitor bezel (drawn after monitor)
					pass  # handled below
				"it_guy":
					# Second monitor
					draw_rect(Rect2(ws_pos.x + 12, ws_pos.y - 16, 20, 11), Color(0.20, 0.20, 0.22))
					draw_rect(Rect2(ws_pos.x + 13, ws_pos.y - 14, 18, 8), Color(0.05, 0.14, 0.05))

			# ── Interaction glow ─────────────────────────────────────────────
			if is_near and room_unlocked:
				draw_arc(ws_pos, 22.0, 0.0, TAU, 20, Color(0.95, 0.85, 0.25, 0.75), 2.5)

			# ── Chair ────────────────────────────────────────────────────────
			var chair_col := Color(0.30, 0.26, 0.22)
			if vibe == "executive": chair_col = Color(0.18, 0.12, 0.08)
			if vibe == "gamer":     chair_col = Color(0.12, 0.08, 0.18)
			draw_rect(Rect2(ws_pos.x - 7, ws_pos.y + 7, 14, 9), chair_col)
			draw_rect(Rect2(ws_pos.x - 5, ws_pos.y + 4, 10, 4), chair_col)
			if vibe == "executive":
				# Taller exec chair back
				draw_rect(Rect2(ws_pos.x - 5, ws_pos.y + 1, 10, 5), chair_col)

			# ── Desk surface ─────────────────────────────────────────────────
			var desk_w := 26
			if vibe in ["hitech", "executive", "it_guy"]: desk_w = 30
			draw_rect(Rect2(ws_pos.x - desk_w/2, ws_pos.y - 3, desk_w, 10), desk_col)
			draw_rect(Rect2(ws_pos.x - desk_w/2, ws_pos.y + 7, desk_w, 2),
				Color(desk_col.r * 0.72, desk_col.g * 0.72, desk_col.b * 0.72))

			# ── Desk items ───────────────────────────────────────────────────
			# Keyboard
			var kb_col := Color(desk_col.r * 0.80, desk_col.g * 0.80, desk_col.b * 0.80)
			if vibe == "gamer":   kb_col = Color(0.18, 0.14, 0.22)
			if vibe == "hitech":  kb_col = Color(0.15, 0.15, 0.18)
			draw_rect(Rect2(ws_pos.x - 8, ws_pos.y + 2, 12, 3), kb_col)
			# Coffee mug (most desks)
			if vibe not in ["intern", "food_mess"]:
				draw_rect(Rect2(ws_pos.x + 7, ws_pos.y - 1, 4, 5), Color(0.85, 0.78, 0.65))
				draw_rect(Rect2(ws_pos.x + 7, ws_pos.y - 1, 4, 2), Color(0.40, 0.25, 0.10))
			# Plant on Janet's desk
			if vibe == "plant_lover":
				draw_rect(Rect2(ws_pos.x + 7, ws_pos.y - 1, 5, 5), Color(0.48, 0.28, 0.10))
				draw_circle(Vector2(ws_pos.x + 9, ws_pos.y - 4), 4, Color(0.22, 0.62, 0.16))

			# ── Monitor ──────────────────────────────────────────────────────
			var mon_w := 22
			if vibe in ["hitech", "it_guy"]: mon_w = 26
			if vibe == "executive":          mon_w = 28
			if vibe == "intern":             mon_w = 16  # just a laptop
			var mon_col := monitor_col
			if vibe == "hitech":   mon_col = Color(0.10, 0.10, 0.12)
			if vibe == "gamer":    mon_col = Color(0.14, 0.08, 0.20)
			if vibe == "executive":mon_col = Color(0.22, 0.18, 0.12)
			# Stand
			draw_rect(Rect2(ws_pos.x - 2, ws_pos.y - 7, 4, 5), mon_col)
			# Bezel
			draw_rect(Rect2(ws_pos.x - mon_w/2, ws_pos.y - 18, mon_w, 12), mon_col)
			# Screen
			draw_rect(Rect2(ws_pos.x - mon_w/2 + 2, ws_pos.y - 16, mon_w - 4, 8), screen_col)

			# Bob's wallpaper silhouettes on screen
			if vibe == "bob_mess" and room_unlocked:
				draw_circle(Vector2(ws_pos.x - 4, ws_pos.y - 12), 3, Color(0.85, 0.70, 0.62, 0.8))
				draw_rect(Rect2(ws_pos.x - 6, ws_pos.y - 11, 4, 5), Color(0.85, 0.70, 0.62, 0.8))
				draw_circle(Vector2(ws_pos.x + 4, ws_pos.y - 12), 3, Color(0.85, 0.70, 0.62, 0.8))
				draw_rect(Rect2(ws_pos.x + 2, ws_pos.y - 11, 4, 5), Color(0.85, 0.70, 0.62, 0.8))
				draw_rect(Rect2(ws_pos.x - 8, ws_pos.y - 9, 16, 2), Color(0.30, 0.65, 0.90, 0.6)) # sea

			# Robert's terminal glow
			if vibe == "hitech" and room_unlocked:
				draw_string(ThemeDB.fallback_font,
					Vector2(ws_pos.x - 11, ws_pos.y - 10),
					"> _", HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color(0.0, 0.90, 0.50))

			# Sarah's sticky notes on monitor
			if vibe == "sticky_notes":
				var sn_cols := [Color(0.98,0.92,0.25), Color(0.25,0.85,0.92), Color(0.98,0.55,0.25)]
				for s2 in range(3):
					draw_rect(Rect2(ws_pos.x - mon_w/2 - 5 + s2 * 4, ws_pos.y - 17, 6, 5), sn_cols[s2])

			# IT guy terminal text
			if vibe == "it_guy" and room_unlocked:
				draw_string(ThemeDB.fallback_font,
					Vector2(ws_pos.x - 11, ws_pos.y - 11),
					"$ ssh", HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color(0.0, 0.88, 0.20))

			# ── Owner name tag ───────────────────────────────────────────────
			if owner != "" and room_unlocked:
				draw_string(ThemeDB.fallback_font,
					Vector2(ws_pos.x - 10, ws_pos.y + 18),
					owner, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.30, 0.26, 0.20))

			# ── Level number on screen ───────────────────────────────────────
			if room_unlocked and vibe not in ["bob_mess", "hitech", "it_guy"]:
				draw_string(ThemeDB.fallback_font,
					Vector2(ws_pos.x - 8, ws_pos.y - 10),
					"%d" % level_id,
					HORIZONTAL_ALIGNMENT_LEFT, -1, 8, num_col)
			elif room_unlocked and vibe in ["hitech", "it_guy"]:
				draw_string(ThemeDB.fallback_font,
					Vector2(ws_pos.x - 11, ws_pos.y - 1),
					"%d" % level_id,
					HORIZONTAL_ALIGNMENT_LEFT, -1, 8, num_col)

	func _draw_door_indicators() -> void:
		var solved_count := GameState.get_solved_count()
		for door_def in DOOR_DEFS:
			var tx: int = door_def["tx"]
			var ty: int = door_def["ty"]
			var tw: int = door_def["tw"]
			var th: int = door_def["th"]
			var unlock_at: int = door_def["unlockAt"]
			var is_open := solved_count >= unlock_at

			if is_open:
				# Open door: warm wood planks with a gap
				draw_rect(Rect2(tx * T, ty * T, tw * T, th * T), Color(0.62, 0.45, 0.25))
				draw_rect(Rect2(tx * T + 2, ty * T + 2, tw * T - 4, th * T - 4), Color(0.78, 0.58, 0.32))
				draw_line(Vector2((tx + tw / 2) * T, ty * T), Vector2((tx + tw / 2) * T, (ty + th) * T), Color(0.50, 0.36, 0.18), 1.5)
			else:
				# Locked door: darker wood with red tint
				draw_rect(Rect2(tx * T, ty * T, tw * T, th * T), Color(0.48, 0.28, 0.20))
				draw_rect(Rect2(tx * T + 2, ty * T + 2, tw * T - 4, th * T - 4), Color(0.58, 0.32, 0.22))
				# Lock icon (small circle)
				var mid_x := (tx + tw / 2.0) * T
				var mid_y := (ty + th / 2.0) * T
				draw_circle(Vector2(mid_x, mid_y), 4, Color(0.85, 0.72, 0.18))
				draw_string(ThemeDB.fallback_font,
					Vector2(tx * T + 1, ty * T + th * T / 2 + 8),
					"%d/%d" % [solved_count, unlock_at],
					HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(1.0, 0.90, 0.70))

	func _draw_npc_dots() -> void:
		var near_idx: int = main_ref._near_npc_idx
		for i in range(main_ref.NPC_DEFS.size()):
			var npc: Dictionary = main_ref.NPC_DEFS[i]
			var p := Vector2(npc["tx"] * T, npc["ty"] * T)
			var shirt: Color = npc["shirt"]
			var skin: Color  = npc["skin"]
			# Highlight ring when player is nearby
			if i == near_idx:
				draw_arc(p, 12.0, 0.0, TAU, 16, Color(0.95, 0.85, 0.30, 0.80), 2.0)
			# Drop shadow
			draw_ellipse_approx(p + Vector2(0, 9), 5, 2, Color(0, 0, 0, 0.22))
			# Body
			draw_rect(Rect2(p.x - 5, p.y - 4, 10, 9), shirt)
			# Head
			draw_circle(p + Vector2(0, -8), 5, skin)
			# Hair
			draw_rect(Rect2(p.x - 4, p.y - 14, 8, 4), Color(0.20, 0.14, 0.07))

	func draw_ellipse_approx(center: Vector2, rx: float, ry: float, col: Color) -> void:
		for i in range(16):
			var a1 := float(i) / 16.0 * TAU
			var a2 := float(i + 1) / 16.0 * TAU
			draw_line(
				center + Vector2(cos(a1) * rx, sin(a1) * ry),
				center + Vector2(cos(a2) * rx, sin(a2) * ry),
				col, 3.0)
