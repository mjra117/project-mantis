extends CanvasLayer

signal replay_finished

const C_BG       := Color(0.00, 0.00, 0.00, 0.80)
const C_PANEL    := Color(0.02, 0.06, 0.02)
const C_BORDER   := Color(0.0, 0.5, 0.2)
const C_GREEN    := Color(0.0, 1.0, 0.4)
const C_DIM      := Color(0.3, 0.6, 0.3)
const C_AMBER    := Color(1.0, 0.7, 0.1)
const C_SCREEN   := Color(0.01, 0.04, 0.01)
const C_DONE     := Color(0.0, 0.55, 0.28)
const C_PENDING  := Color(0.12, 0.30, 0.12)

var _steps: Array = []
var _step_idx: int = -1
var _timer: float = 0.0
var _done: bool = false
var _level_id: int = 1

var _title_lbl: Label
var _lines_container: VBoxContainer
var _line_labels: Array = []
var _target_output: RichTextLabel
var _progress_bar: ProgressBar
var _counter_lbl: Label

func _ready() -> void:
	layer = 20
	set_process(false)
	_build_ui()
	hide()

# ── Public API ────────────────────────────────────────────────────────────────

func play(code: String, level_id: int) -> void:
	_level_id = level_id
	_steps = _parse(code)
	_step_idx = -1
	_done = false
	_timer = 0.4
	_title_lbl.text = "▶  EXECUTING PAYLOAD  —  LEVEL %d" % level_id
	_title_lbl.add_theme_color_override("font_color", C_GREEN)
	_progress_bar.max_value = max(_steps.size(), 1)
	_progress_bar.value = 0.0
	_counter_lbl.text = "0 / %d" % _steps.size()
	_target_output.text = ""
	_rebuild_lines()
	show()
	set_process(true)

# ── Step engine ───────────────────────────────────────────────────────────────

func _process(delta: float) -> void:
	if _done:
		return
	_timer -= delta
	if _timer <= 0.0:
		_advance()

func _advance() -> void:
	_step_idx += 1
	if _step_idx >= _steps.size():
		_on_finished()
		return

	# Update script list
	for i in range(_line_labels.size()):
		var lbl: Label = _line_labels[i]
		if i < _step_idx:
			lbl.add_theme_color_override("font_color", C_DONE)
			lbl.text = " ✓  " + _steps[i]
		elif i == _step_idx:
			lbl.add_theme_color_override("font_color", C_GREEN)
			lbl.text = " ▶  " + _steps[i]
		else:
			lbl.add_theme_color_override("font_color", C_PENDING)
			lbl.text = "    " + _steps[i]

	# Emit event to target screen
	var html := _interpret(_steps[_step_idx])
	if html != "":
		_target_output.append_text(html + "\n")
		_target_output.scroll_to_line(_target_output.get_line_count())

	# Progress
	_progress_bar.value = _step_idx + 1
	_counter_lbl.text = "%d / %d" % [_step_idx + 1, _steps.size()]

	# Delay until next step
	var up := _steps[_step_idx].to_upper().strip_edges()
	if up.begins_with("DELAY"):
		var parts := up.split(" ", false, 1)
		var ms := float(parts[1]) if parts.size() > 1 and parts[1].is_valid_float() else 500.0
		_timer = clampf(ms / 1200.0, 0.35, 1.2)
	elif up.begins_with("STRING"):
		var text_len := max(_steps[_step_idx].length() - 7, 0)
		_timer = clampf(0.35 + text_len * 0.04, 0.4, 1.5)
	else:
		_timer = 0.55

func _on_finished() -> void:
	_done = true
	set_process(false)
	for i in range(_line_labels.size()):
		var lbl: Label = _line_labels[i]
		lbl.add_theme_color_override("font_color", C_DONE)
		lbl.text = " ✓  " + _steps[i]
	_target_output.append_text("\n[color=#00ff88][b]✓  PAYLOAD EXECUTED SUCCESSFULLY[/b][/color]\n")
	_target_output.scroll_to_line(_target_output.get_line_count())
	_progress_bar.value = _steps.size()
	_counter_lbl.text = "%d / %d" % [_steps.size(), _steps.size()]
	_title_lbl.text = "✓  PAYLOAD COMPLETE  —  LEVEL %d" % _level_id
	await get_tree().create_timer(2.0).timeout
	_close()

func _close() -> void:
	set_process(false)
	hide()
	emit_signal("replay_finished")

# ── Command interpretation ────────────────────────────────────────────────────

func _interpret(line: String) -> String:
	var up := line.to_upper().strip_edges()

	if up.begins_with("STRING"):
		var text := line.substr(7).strip_edges() if line.length() > 7 else ""
		return "[color=#00cc77]⌨[/color]  [color=#aaffcc]" + text.xml_escape() + "[/color]"

	if up == "ENTER":
		return "[color=#88aaff]↵  ENTER[/color]"

	if up.begins_with("DELAY"):
		var parts := up.split(" ", false, 1)
		var ms := parts[1] if parts.size() > 1 else "?"
		return "[color=#555555]⏳  DELAY " + ms + " ms[/color]"

	if up == "GUI R" or up == "WINDOWS R":
		return "[color=#ffcc44]⊞  WIN + R  →  Run dialog opened[/color]"

	if up == "GUI SPACE" or up == "WINDOWS SPACE":
		return "[color=#ffcc44]⊞  WIN + Space  →  Spotlight / Search[/color]"

	if up == "GUI" or up == "WINDOWS":
		return "[color=#ffcc44]⊞  Windows key[/color]"

	if up.begins_with("GUI ") or up.begins_with("WINDOWS "):
		var rest := up.substr(4).strip_edges()
		return "[color=#ffcc44]⊞  WIN + " + rest + "[/color]"

	if up == "CTRL ALT T" or up == "CONTROL ALT T":
		return "[color=#ffcc44]⌨  Ctrl + Alt + T  →  Terminal opened[/color]"

	if up == "ALT F4":
		return "[color=#ff8866]⌨  Alt + F4  →  Window closed[/color]"

	if up.begins_with("CTRL ") or up.begins_with("CONTROL "):
		var rest := up.substr(up.find(" ") + 1)
		return "[color=#aaaaff]⌨  Ctrl + " + rest + "[/color]"

	if up.begins_with("ALT "):
		return "[color=#aaaaff]⌨  Alt + " + up.substr(4).strip_edges() + "[/color]"

	if up.begins_with("SHIFT "):
		return "[color=#aaaaff]⌨  Shift + " + up.substr(6).strip_edges() + "[/color]"

	if up in ["TAB", "ESCAPE", "SPACE", "BACKSPACE", "DELETE",
			  "HOME", "END", "PAGEUP", "PAGEDOWN",
			  "UPARROW", "DOWNARROW", "LEFTARROW", "RIGHTARROW"]:
		return "[color=#aaaaff]⌨  [" + up + "][/color]"

	if up.begins_with("F") and up.length() <= 3 and up.substr(1).is_valid_int():
		return "[color=#aaaaff]⌨  [" + up + "][/color]"

	return "[color=#aaffaa]⌨  " + line.xml_escape() + "[/color]"

# ── Helpers ───────────────────────────────────────────────────────────────────

func _parse(code: String) -> Array:
	var result: Array = []
	for raw in code.split("\n"):
		var line := raw.strip_edges()
		if line.is_empty():
			continue
		var up := line.to_upper()
		if up == "REM" or up.begins_with("REM ") or up.begins_with("REM\t"):
			continue
		result.append(line)
	return result

func _rebuild_lines() -> void:
	_line_labels.clear()
	for child in _lines_container.get_children():
		child.queue_free()
	for step in _steps:
		var lbl := Label.new()
		lbl.text = "    " + step
		lbl.add_theme_color_override("font_color", C_PENDING)
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.clip_text = true
		_lines_container.add_child(lbl)
		_line_labels.append(lbl)

func _s(bg: Color, border: Color = Color.TRANSPARENT, bw: int = 1, radius: int = 4) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(bw)
	s.set_corner_radius_all(radius)
	s.content_margin_left   = 6.0
	s.content_margin_right  = 6.0
	s.content_margin_top    = 4.0
	s.content_margin_bottom = 4.0
	return s

# ── UI construction ───────────────────────────────────────────────────────────

func _build_ui() -> void:
	# Dim overlay
	var overlay := ColorRect.new()
	overlay.color = C_BG
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	# Centred panel
	var center := CenterContainer.new()
	center.anchor_right = 1.0
	center.anchor_bottom = 1.0
	add_child(center)

	var outer := PanelContainer.new()
	outer.custom_minimum_size = Vector2(740, 470)
	outer.add_theme_stylebox_override("panel", _s(C_PANEL, C_BORDER, 2, 8))
	center.add_child(outer)

	var root_vbox := VBoxContainer.new()
	root_vbox.add_theme_constant_override("separation", 0)
	outer.add_child(root_vbox)

	# ── Title bar ─────────────────────────────────────────────────────────
	var title_bar := PanelContainer.new()
	var tb_s := _s(Color(0.02, 0.07, 0.02), C_BORDER, 0, 0)
	tb_s.corner_radius_top_left  = 8
	tb_s.corner_radius_top_right = 8
	title_bar.add_theme_stylebox_override("panel", tb_s)
	root_vbox.add_child(title_bar)

	var tb_hbox := HBoxContainer.new()
	tb_hbox.add_theme_constant_override("separation", 0)
	title_bar.add_child(tb_hbox)

	var dots_m := MarginContainer.new()
	dots_m.add_theme_constant_override("margin_left", 10)
	tb_hbox.add_child(dots_m)
	var dots_hb := HBoxContainer.new()
	dots_hb.add_theme_constant_override("separation", 5)
	dots_m.add_child(dots_hb)
	for col: Color in [Color(1, 0.25, 0.2), Color(1, 0.75, 0.0), Color(0.2, 0.8, 0.2)]:
		var d := ColorRect.new()
		d.custom_minimum_size = Vector2(10, 10)
		d.color = col
		dots_hb.add_child(d)

	_title_lbl = Label.new()
	_title_lbl.text = "▶  EXECUTING PAYLOAD"
	_title_lbl.add_theme_color_override("font_color", C_GREEN)
	_title_lbl.add_theme_font_size_override("font_size", 13)
	_title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_lbl.horizontal_alignment  = HORIZONTAL_ALIGNMENT_CENTER
	tb_hbox.add_child(_title_lbl)

	var skip_m := MarginContainer.new()
	skip_m.add_theme_constant_override("margin_right", 8)
	tb_hbox.add_child(skip_m)
	var skip_btn := Button.new()
	skip_btn.text = "SKIP →"
	skip_btn.flat = true
	skip_btn.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))
	skip_btn.add_theme_color_override("font_hover_color", C_AMBER)
	skip_btn.add_theme_font_size_override("font_size", 11)
	skip_btn.pressed.connect(_close)
	skip_m.add_child(skip_btn)

	# ── Body ──────────────────────────────────────────────────────────────
	var body_m := MarginContainer.new()
	body_m.add_theme_constant_override("margin_left",   12)
	body_m.add_theme_constant_override("margin_right",  12)
	body_m.add_theme_constant_override("margin_top",    10)
	body_m.add_theme_constant_override("margin_bottom",  8)
	body_m.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(body_m)

	var body_hbox := HBoxContainer.new()
	body_hbox.add_theme_constant_override("separation", 12)
	body_m.add_child(body_hbox)

	# Left: script panel
	var left := PanelContainer.new()
	left.size_flags_horizontal   = Control.SIZE_EXPAND_FILL
	left.size_flags_stretch_ratio = 0.42
	left.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_theme_stylebox_override("panel", _s(Color(0.01, 0.04, 0.01), Color(0.0, 0.28, 0.10)))
	body_hbox.add_child(left)

	var lp_vbox := VBoxContainer.new()
	lp_vbox.add_theme_constant_override("separation", 2)
	left.add_child(lp_vbox)

	var lp_hdr := Label.new()
	lp_hdr.text = " DUCKY SCRIPT"
	lp_hdr.add_theme_color_override("font_color", C_DIM)
	lp_hdr.add_theme_font_size_override("font_size", 10)
	lp_vbox.add_child(lp_hdr)

	var lp_sep := HSeparator.new()
	lp_sep.add_theme_color_override("color", Color(0.0, 0.28, 0.10))
	lp_vbox.add_child(lp_sep)

	var lp_scroll := ScrollContainer.new()
	lp_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	lp_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	lp_vbox.add_child(lp_scroll)

	_lines_container = VBoxContainer.new()
	_lines_container.add_theme_constant_override("separation", 1)
	lp_scroll.add_child(_lines_container)

	# Right: target screen panel
	var right := PanelContainer.new()
	right.size_flags_horizontal   = Control.SIZE_EXPAND_FILL
	right.size_flags_stretch_ratio = 0.58
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_theme_stylebox_override("panel", _s(C_SCREEN, Color(0.0, 0.5, 0.22)))
	body_hbox.add_child(right)

	var rp_vbox := VBoxContainer.new()
	rp_vbox.add_theme_constant_override("separation", 0)
	right.add_child(rp_vbox)

	# Fake CMD window chrome
	var mon_bar := PanelContainer.new()
	var mb_s := _s(Color(0.12, 0.12, 0.14), Color(0.22, 0.22, 0.25), 0, 0)
	mb_s.content_margin_top    = 3.0
	mb_s.content_margin_bottom = 3.0
	mon_bar.add_theme_stylebox_override("panel", mb_s)
	rp_vbox.add_child(mon_bar)

	var mb_hbox := HBoxContainer.new()
	mb_hbox.add_theme_constant_override("separation", 5)
	mon_bar.add_child(mb_hbox)

	for col: Color in [Color(0.85, 0.28, 0.22, 0.9), Color(0.88, 0.68, 0.12, 0.9), Color(0.28, 0.78, 0.28, 0.9)]:
		var d := ColorRect.new()
		d.custom_minimum_size = Vector2(9, 9)
		d.color = col
		mb_hbox.add_child(d)

	var mb_title := Label.new()
	mb_title.text = "  Administrator: cmd.exe  —  TARGET MACHINE"
	mb_title.add_theme_color_override("font_color", Color(0.65, 0.65, 0.65))
	mb_title.add_theme_font_size_override("font_size", 10)
	mb_hbox.add_child(mb_title)

	_target_output = RichTextLabel.new()
	_target_output.bbcode_enabled = true
	_target_output.fit_content    = false
	_target_output.scroll_active  = true
	_target_output.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_target_output.add_theme_stylebox_override("normal", _s(C_SCREEN, Color.TRANSPARENT))
	_target_output.add_theme_color_override("default_color", C_DIM)
	_target_output.add_theme_font_size_override("normal_font_size", 12)
	rp_vbox.add_child(_target_output)

	# ── Progress row ──────────────────────────────────────────────────────
	var prog_m := MarginContainer.new()
	prog_m.add_theme_constant_override("margin_left",   12)
	prog_m.add_theme_constant_override("margin_right",  12)
	prog_m.add_theme_constant_override("margin_top",     4)
	prog_m.add_theme_constant_override("margin_bottom", 10)
	root_vbox.add_child(prog_m)

	var prog_hbox := HBoxContainer.new()
	prog_hbox.add_theme_constant_override("separation", 10)
	prog_m.add_child(prog_hbox)

	_progress_bar = ProgressBar.new()
	_progress_bar.min_value  = 0.0
	_progress_bar.max_value  = 1.0
	_progress_bar.value      = 0.0
	_progress_bar.custom_minimum_size = Vector2(0, 8)
	_progress_bar.show_percentage = false
	_progress_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_progress_bar.add_theme_stylebox_override("background", _s(Color(0.0, 0.07, 0.0), Color.TRANSPARENT))
	_progress_bar.add_theme_stylebox_override("fill",       _s(C_GREEN))
	prog_hbox.add_child(_progress_bar)

	_counter_lbl = Label.new()
	_counter_lbl.text = "0 / 0"
	_counter_lbl.add_theme_color_override("font_color", C_DIM)
	_counter_lbl.add_theme_font_size_override("font_size", 11)
	_counter_lbl.custom_minimum_size    = Vector2(58, 0)
	_counter_lbl.horizontal_alignment   = HORIZONTAL_ALIGNMENT_RIGHT
	prog_hbox.add_child(_counter_lbl)
