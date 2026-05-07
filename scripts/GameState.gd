extends Node

# Save file path
const SAVE_PATH := "user://ducky_save.json"

# Game state
var xp: int = 0
var solved: Array = []      # Array of level IDs (1-100) that are solved
var skipped: Array = []     # Array of level IDs that are skipped
var complete: bool = false
var player_pos: Vector2 = Vector2(384.0, 1664.0)  # open office starting area

# Signals
signal state_changed
signal xp_gained(amount: int)

func _ready() -> void:
	load_save()

func load_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_reset_defaults()
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		_reset_defaults()
		return
	var json_str := file.get_as_text()
	file.close()
	var json := JSON.new()
	var err := json.parse(json_str)
	if err != OK:
		_reset_defaults()
		return
	var data = json.get_data()
	if typeof(data) != TYPE_DICTIONARY:
		_reset_defaults()
		return
	xp = int(data.get("xp", 0))
	solved = _to_int_array(data.get("solved", []))
	skipped = _to_int_array(data.get("skipped", []))
	complete = bool(data.get("complete", false))
	var pp = data.get("player_pos", null)
	if pp != null and typeof(pp) == TYPE_DICTIONARY:
		player_pos = Vector2(float(pp.get("x", 384.0)), float(pp.get("y", 1664.0)))
	else:
		player_pos = Vector2(384.0, 1664.0)

func save() -> void:
	var data := {
		"xp": xp,
		"solved": solved,
		"skipped": skipped,
		"complete": complete,
		"player_pos": {"x": player_pos.x, "y": player_pos.y}
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("GameState: cannot open save file for writing")
		return
	file.store_string(JSON.stringify(data))
	file.close()

func add_xp(amount: int) -> void:
	xp += amount
	emit_signal("xp_gained", amount)
	emit_signal("state_changed")

func solve_level(id: int, xp_reward: int) -> void:
	if id not in solved:
		solved.append(id)
	if id in skipped:
		skipped.erase(id)
	add_xp(xp_reward)
	save()

func skip_level(id: int) -> void:
	if id not in skipped:
		skipped.append(id)
	save()

func is_solved(id: int) -> bool:
	return id in solved

func is_skipped(id: int) -> bool:
	return id in skipped

func get_solved_count() -> int:
	return solved.size()

func get_total_xp() -> int:
	return xp

# How many unique levels have been completed (solved or skipped)
func get_done_count() -> int:
	var done := {}
	for s in solved:
		done[s] = true
	for s in skipped:
		done[s] = true
	return done.size()

# Returns true if a room is unlocked based on solved count
func is_room_unlocked(room_name: String) -> bool:
	var cnt := get_solved_count()
	match room_name:
		"lobby":   return true
		"office":  return true
		"it":      return cnt >= 5
		"server":  return cnt >= 10
		"mgmt":    return cnt >= 20
		"noc":     return cnt >= 30
		"security": return cnt >= 40
		"rd":      return cnt >= 50
		"design":  return cnt >= 60
		"exec":    return cnt >= 70
		"vault":   return cnt >= 80
		_:         return false

func _reset_defaults() -> void:
	xp = 0
	solved = []
	skipped = []
	complete = false
	player_pos = Vector2(384.0, 1664.0)

func _to_int_array(arr) -> Array:
	var result: Array = []
	if typeof(arr) == TYPE_ARRAY:
		for v in arr:
			result.append(int(v))
	return result
