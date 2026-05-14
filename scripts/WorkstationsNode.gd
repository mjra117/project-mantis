extends Node2D

# Set by Main after add_child so _draw() can read workstation data.
var main_ref

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

func _draw() -> void:
	if main_ref == null:
		return
	_draw_workstations()

func _draw_workstations() -> void:
	for i in range(main_ref._workstation_positions.size()):
		var ws_pos: Vector2 = main_ref._workstation_positions[i]
		var level_id := i + 1
		var room: Dictionary = main_ref._get_room_for_workstation(i)
		if room.is_empty():
			continue

		var room_unlocked: bool = GameState.is_room_unlocked(room["id"])
		var is_solved: bool     = GameState.is_solved(level_id)
		var is_skipped: bool    = GameState.is_skipped(level_id)
		var is_near: bool       = (i == main_ref._near_ws_idx)

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

		var char_data: Dictionary = DESK_CHARS.get(i % 10, {})
		var vibe:  String = str(char_data.get("vibe",  ""))
		var owner: String = str(char_data.get("owner", ""))

		# Per-personality screen colour override (only when active/unsolved)
		if room_unlocked and not is_solved and not is_skipped:
			match vibe:
				"bob_mess":     screen_col = Color(0.92, 0.62, 0.68)
				"hitech":       screen_col = Color(0.04, 0.08, 0.16)
				"neat":         screen_col = Color(0.70, 0.80, 0.95)
				"gamer":        screen_col = Color(0.10, 0.02, 0.20)
				"intern":       screen_col = Color(0.88, 0.88, 0.88)
				"plant_lover":  screen_col = Color(0.28, 0.62, 0.32)
				"food_mess":    screen_col = Color(0.75, 0.45, 0.10)
				"sticky_notes": screen_col = Color(0.55, 0.72, 0.48)
				"it_guy":       screen_col = Color(0.05, 0.14, 0.05)
				"executive":    screen_col = Color(0.10, 0.08, 0.18)

		# ── Pre-desk extras (drawn behind desk) ──────────────────────────────
		match vibe:
			"bob_mess":
				draw_rect(Rect2(ws_pos.x + 14, ws_pos.y - 2, 14, 12), Color(0.40, 0.30, 0.18))
				draw_rect(Rect2(ws_pos.x + 14, ws_pos.y - 2, 14, 2),  Color(0.30, 0.22, 0.12))
				for c in range(4):
					draw_line(Vector2(ws_pos.x + 16 + c * 3, ws_pos.y),
							  Vector2(ws_pos.x + 18 + c * 3, ws_pos.y + 8),
							  Color(0.15, 0.15, 0.15, 0.8), 1.5)
				draw_rect(Rect2(ws_pos.x + 16, ws_pos.y + 4, 10, 5), Color(0.55, 0.52, 0.50))
			"hitech":
				draw_rect(Rect2(ws_pos.x + 12, ws_pos.y - 16, 20, 11), Color(0.10, 0.10, 0.12))
				draw_rect(Rect2(ws_pos.x + 13, ws_pos.y - 14, 18, 8),  Color(0.04, 0.08, 0.16))
				draw_rect(Rect2(ws_pos.x + 10, ws_pos.y + 1,  8,  5),  Color(0.20, 0.20, 0.22))
			"gamer":
				var rgb_cols := [Color(1,0,0,0.7), Color(0,1,0,0.7), Color(0,0,1,0.7),
								 Color(1,0,1,0.7), Color(1,1,0,0.7), Color(0,1,1,0.7)]
				for r in range(6):
					draw_rect(Rect2(ws_pos.x - 13 + r * 4, ws_pos.y + 7, 4, 2), rgb_cols[r])
				draw_rect(Rect2(ws_pos.x + 8, ws_pos.y - 3, 5, 8), Color(0.10, 0.70, 0.20))
				draw_rect(Rect2(ws_pos.x + 8, ws_pos.y - 5, 5, 3), Color(0.88, 0.88, 0.88))
			"food_mess":
				draw_rect(Rect2(ws_pos.x - 14, ws_pos.y + 1,  8, 5), Color(0.80, 0.72, 0.30))
				draw_rect(Rect2(ws_pos.x - 14, ws_pos.y - 4,  5, 5), Color(0.75, 0.60, 0.45))
				draw_rect(Rect2(ws_pos.x - 16, ws_pos.y - 1, 10, 3), Color(0.45, 0.25, 0.10, 0.5))
			"it_guy":
				draw_rect(Rect2(ws_pos.x + 12, ws_pos.y - 16, 20, 11), Color(0.20, 0.20, 0.22))
				draw_rect(Rect2(ws_pos.x + 13, ws_pos.y - 14, 18, 8),  Color(0.05, 0.14, 0.05))

		# ── Interaction glow ─────────────────────────────────────────────────
		if is_near and room_unlocked:
			draw_arc(ws_pos, 22.0, 0.0, TAU, 20, Color(0.95, 0.85, 0.25, 0.75), 2.5)

		# ── Chair ────────────────────────────────────────────────────────────
		var chair_col := Color(0.30, 0.26, 0.22)
		if vibe == "executive": chair_col = Color(0.18, 0.12, 0.08)
		if vibe == "gamer":     chair_col = Color(0.12, 0.08, 0.18)
		draw_rect(Rect2(ws_pos.x - 7, ws_pos.y + 7, 14, 9), chair_col)
		draw_rect(Rect2(ws_pos.x - 5, ws_pos.y + 4, 10, 4), chair_col)
		if vibe == "executive":
			draw_rect(Rect2(ws_pos.x - 5, ws_pos.y + 1, 10, 5), chair_col)

		# ── Desk surface ─────────────────────────────────────────────────────
		var desk_w := 26
		if vibe in ["hitech", "executive", "it_guy"]: desk_w = 30
		draw_rect(Rect2(ws_pos.x - desk_w / 2, ws_pos.y - 3,  desk_w, 10), desk_col)
		draw_rect(Rect2(ws_pos.x - desk_w / 2, ws_pos.y + 7,  desk_w,  2),
			Color(desk_col.r * 0.72, desk_col.g * 0.72, desk_col.b * 0.72))

		# ── Keyboard ─────────────────────────────────────────────────────────
		var kb_col := Color(desk_col.r * 0.80, desk_col.g * 0.80, desk_col.b * 0.80)
		if vibe == "gamer":  kb_col = Color(0.18, 0.14, 0.22)
		if vibe == "hitech": kb_col = Color(0.15, 0.15, 0.18)
		draw_rect(Rect2(ws_pos.x - 8, ws_pos.y + 2, 12, 3), kb_col)

		# ── Coffee mug ───────────────────────────────────────────────────────
		if vibe not in ["intern", "food_mess"]:
			draw_rect(Rect2(ws_pos.x + 7, ws_pos.y - 1, 4, 5), Color(0.85, 0.78, 0.65))
			draw_rect(Rect2(ws_pos.x + 7, ws_pos.y - 1, 4, 2), Color(0.40, 0.25, 0.10))

		# ── Janet's plant ────────────────────────────────────────────────────
		if vibe == "plant_lover":
			draw_rect(Rect2(ws_pos.x + 7,  ws_pos.y - 1, 5, 5), Color(0.48, 0.28, 0.10))
			draw_circle(Vector2(ws_pos.x + 9, ws_pos.y - 4), 4,   Color(0.22, 0.62, 0.16))

		# ── Monitor ──────────────────────────────────────────────────────────
		var mon_w := 22
		if vibe in ["hitech", "it_guy"]: mon_w = 26
		if vibe == "executive":          mon_w = 28
		if vibe == "intern":             mon_w = 16
		var mon_col := monitor_col
		if vibe == "hitech":    mon_col = Color(0.10, 0.10, 0.12)
		if vibe == "gamer":     mon_col = Color(0.14, 0.08, 0.20)
		if vibe == "executive": mon_col = Color(0.22, 0.18, 0.12)
		draw_rect(Rect2(ws_pos.x - 2,           ws_pos.y - 7,  4,          5), mon_col)    # stand
		draw_rect(Rect2(ws_pos.x - mon_w / 2,   ws_pos.y - 18, mon_w,     12), mon_col)    # bezel
		draw_rect(Rect2(ws_pos.x - mon_w / 2 + 2, ws_pos.y - 16, mon_w - 4, 8), screen_col)  # screen

		# Bob's beach wallpaper silhouettes
		if vibe == "bob_mess" and room_unlocked:
			draw_circle(Vector2(ws_pos.x - 4, ws_pos.y - 12), 3, Color(0.85, 0.70, 0.62, 0.8))
			draw_rect(Rect2(ws_pos.x - 6, ws_pos.y - 11, 4, 5),  Color(0.85, 0.70, 0.62, 0.8))
			draw_circle(Vector2(ws_pos.x + 4, ws_pos.y - 12), 3, Color(0.85, 0.70, 0.62, 0.8))
			draw_rect(Rect2(ws_pos.x + 2, ws_pos.y - 11, 4, 5),  Color(0.85, 0.70, 0.62, 0.8))
			draw_rect(Rect2(ws_pos.x - 8, ws_pos.y - 9, 16, 2),  Color(0.30, 0.65, 0.90, 0.6))

		# Robert's terminal prompt
		if vibe == "hitech" and room_unlocked:
			draw_string(ThemeDB.fallback_font,
				Vector2(ws_pos.x - 11, ws_pos.y - 10),
				"> _", HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color(0.0, 0.90, 0.50))

		# Sarah's sticky notes on monitor bezel
		if vibe == "sticky_notes":
			var sn_cols := [Color(0.98, 0.92, 0.25), Color(0.25, 0.85, 0.92), Color(0.98, 0.55, 0.25)]
			for s in range(3):
				draw_rect(Rect2(ws_pos.x - mon_w / 2 - 5 + s * 4, ws_pos.y - 17, 6, 5), sn_cols[s])

		# Mike's terminal SSH prompt
		if vibe == "it_guy" and room_unlocked:
			draw_string(ThemeDB.fallback_font,
				Vector2(ws_pos.x - 11, ws_pos.y - 11),
				"$ ssh", HORIZONTAL_ALIGNMENT_LEFT, -1, 6, Color(0.0, 0.88, 0.20))

		# ── Owner name tag ───────────────────────────────────────────────────
		if owner != "" and room_unlocked:
			draw_string(ThemeDB.fallback_font,
				Vector2(ws_pos.x - 10, ws_pos.y + 18),
				owner, HORIZONTAL_ALIGNMENT_LEFT, -1, 7, Color(0.30, 0.26, 0.20))

		# ── Level number on screen ───────────────────────────────────────────
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
