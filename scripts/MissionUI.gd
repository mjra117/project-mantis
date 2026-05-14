extends CanvasLayer

# ── Internal state ─────────────────────────────────────────────────────────────
var _current_idx: int = -1   # 0-based workstation index
var _current_level_id: int = -1
var _is_open: bool = false
var _hint_visible: bool = false
var _ref_visible: bool = false

# ── UI nodes (built programmatically) ─────────────────────────────────────────
var _overlay: ColorRect
var _panel: PanelContainer
var _title_label: Label
var _hud_level: Label
var _hud_xp: Label
var _hud_section: Label
var _hud_solved: Label
var _xp_bar: ProgressBar
var _mission_badge: Label
var _mission_num: Label
var _mission_title: Label
var _mission_desc: Label
var _keywords_label: Label
var _ref_toggle_btn: Button
var _ref_panel: PanelContainer
var _ref_label: Label
var _hint_btn: Button
var _hint_panel: PanelContainer
var _hint_label: Label
var _editor_label: Label
var _text_edit: TextEdit
var _run_btn: Button
var _skip_btn: Button
var _next_btn: Button
var _output_label: RichTextLabel

# Signals
signal mission_closed

var _replay_ui  # ScriptReplayUI CanvasLayer

# ── Color palette ──────────────────────────────────────────────────────────────
const C_BG        := Color(0.02, 0.05, 0.02, 0.97)
const C_PANEL     := Color(0.03, 0.08, 0.03)
const C_HEADER    := Color(0.02, 0.06, 0.02)
const C_BORDER    := Color(0.0, 0.5, 0.2)
const C_GREEN     := Color(0.0, 1.0, 0.4)
const C_DIM       := Color(0.3, 0.6, 0.3)
const C_TEAL      := Color(0.0, 0.8, 0.7)
const C_AMBER     := Color(1.0, 0.7, 0.1)
const C_RED       := Color(1.0, 0.3, 0.2)
const C_EDITOR_BG := Color(0.01, 0.03, 0.01)
const C_WHITE     := Color(0.9, 1.0, 0.9)

# ── Ducky Script reference text ────────────────────────────────────────────────
const REFERENCE_TEXT := """DUCKY SCRIPT QUICK REFERENCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BASIC COMMANDS
  STRING <text>       Type text
  ENTER               Press Enter key
  DELAY <ms>          Wait milliseconds
  REM <comment>       Comment line

KEY MODIFIERS
  GUI / WINDOWS       Windows key
  CTRL / CONTROL      Control key
  ALT                 Alt key
  SHIFT               Shift key
  GUI R               Win+R (Run dialog)
  CTRL ALT T          Open terminal (Linux)
  GUI SPACE           Spotlight (macOS)

SPECIAL KEYS
  BACKSPACE  DELETE   TAB  ESCAPE  SPACE
  F1-F12              Function keys
  UPARROW  DOWNARROW  LEFTARROW  RIGHTARROW
  HOME  END  PAGEUP  PAGEDOWN

EXAMPLE PAYLOADS
  Open CMD:           Open PowerShell:
  GUI R               GUI R
  DELAY 500           DELAY 500
  STRING cmd          STRING powershell
  ENTER               ENTER

  Copy all text:      Close window:
  CTRL A              ALT F4
  CTRL C
"""

func _ready() -> void:
	layer = 10
	_build_ui()
	_build_replay_ui()
	hide()

func _build_replay_ui() -> void:
	var script := load("res://scripts/ScriptReplayUI.gd")
	_replay_ui = CanvasLayer.new()
	_replay_ui.script = script
	add_child(_replay_ui)

# ─────────────────────────────────────────────────────────────────────────────
# UI Construction
# ─────────────────────────────────────────────────────────────────────────────

func _build_ui() -> void:
	# Fullscreen dark overlay
	_overlay = ColorRect.new()
	_overlay.color = Color(0.0, 0.0, 0.0, 0.85)
	_overlay.anchor_right = 1.0
	_overlay.anchor_bottom = 1.0
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_overlay)

	# Main scroll container (so it works on small screens)
	var scroll := ScrollContainer.new()
	scroll.anchor_right = 1.0
	scroll.anchor_bottom = 1.0
	scroll.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(scroll)

	# Panel container (centered by margin container)
	var margin := MarginContainer.new()
	margin.custom_minimum_size = Vector2(900, 0)
	margin.anchor_right = 1.0
	margin.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 20)
	margin.add_theme_constant_override("margin_bottom", 20)
	scroll.add_child(margin)

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(820, 0)
	var panel_style := _make_flat_style(C_PANEL, C_BORDER, 2, 6)
	_panel.add_theme_stylebox_override("panel", panel_style)
	margin.add_child(_panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	_panel.add_child(vbox)

	# ── Terminal header bar ─────────────────────────────────────────────
	var header := _build_header_bar()
	vbox.add_child(header)

	# ── HUD row ─────────────────────────────────────────────────────────
	var hud := _build_hud()
	vbox.add_child(hud)

	# ── XP Progress bar ─────────────────────────────────────────────────
	_xp_bar = ProgressBar.new()
	_xp_bar.min_value = 0.0
	_xp_bar.max_value = 1.0
	_xp_bar.value = 0.0
	_xp_bar.custom_minimum_size = Vector2(0, 10)
	_xp_bar.show_percentage = false
	var bar_bg := _make_flat_style(Color(0.0, 0.1, 0.0), Color(0.0, 0.0, 0.0, 0.0))
	var bar_fill := _make_flat_style(Color(0.0, 0.8, 0.3))
	_xp_bar.add_theme_stylebox_override("background", bar_bg)
	_xp_bar.add_theme_stylebox_override("fill", bar_fill)
	var xp_margin := MarginContainer.new()
	xp_margin.add_theme_constant_override("margin_left", 8)
	xp_margin.add_theme_constant_override("margin_right", 8)
	xp_margin.add_child(_xp_bar)
	vbox.add_child(xp_margin)

	# ── Mission card ────────────────────────────────────────────────────
	var mission_card := _build_mission_card()
	vbox.add_child(mission_card)

	# ── Reference toggle + panel ─────────────────────────────────────────
	_ref_toggle_btn = Button.new()
	_ref_toggle_btn.text = "[ DUCKY SCRIPT REFERENCE ]"
	_ref_toggle_btn.add_theme_color_override("font_color", C_DIM)
	_ref_toggle_btn.add_theme_color_override("font_hover_color", C_GREEN)
	_ref_toggle_btn.flat = true
	_ref_toggle_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	var ref_btn_margin := MarginContainer.new()
	ref_btn_margin.add_theme_constant_override("margin_left", 8)
	ref_btn_margin.add_child(_ref_toggle_btn)
	vbox.add_child(ref_btn_margin)

	_ref_panel = PanelContainer.new()
	_ref_panel.visible = false
	var ref_style := _make_flat_style(Color(0.01, 0.04, 0.01), Color(0.0, 0.3, 0.1))
	_ref_panel.add_theme_stylebox_override("panel", ref_style)
	var ref_inner := MarginContainer.new()
	ref_inner.add_theme_constant_override("margin_left", 12)
	ref_inner.add_theme_constant_override("margin_right", 12)
	ref_inner.add_theme_constant_override("margin_top", 8)
	ref_inner.add_theme_constant_override("margin_bottom", 8)
	_ref_panel.add_child(ref_inner)
	_ref_label = Label.new()
	_ref_label.text = REFERENCE_TEXT
	_ref_label.add_theme_color_override("font_color", Color(0.6, 0.9, 0.6))
	_ref_label.add_theme_font_size_override("font_size", 12)
	_ref_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	ref_inner.add_child(_ref_label)
	vbox.add_child(_ref_panel)

	# ── Hint toggle + panel ──────────────────────────────────────────────
	_hint_btn = Button.new()
	_hint_btn.text = "[ HINT ]"
	_hint_btn.add_theme_color_override("font_color", C_TEAL)
	_hint_btn.add_theme_color_override("font_hover_color", Color(0.3, 1.0, 0.9))
	_hint_btn.flat = true
	_hint_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	var hint_btn_margin := MarginContainer.new()
	hint_btn_margin.add_theme_constant_override("margin_left", 8)
	hint_btn_margin.add_child(_hint_btn)
	vbox.add_child(hint_btn_margin)

	_hint_panel = PanelContainer.new()
	_hint_panel.visible = false
	var hint_style := _make_flat_style(Color(0.01, 0.05, 0.06), Color(0.0, 0.4, 0.5))
	_hint_panel.add_theme_stylebox_override("panel", hint_style)
	var hint_inner := MarginContainer.new()
	hint_inner.add_theme_constant_override("margin_left", 12)
	hint_inner.add_theme_constant_override("margin_right", 12)
	hint_inner.add_theme_constant_override("margin_top", 8)
	hint_inner.add_theme_constant_override("margin_bottom", 8)
	_hint_panel.add_child(hint_inner)
	_hint_label = Label.new()
	_hint_label.add_theme_color_override("font_color", C_TEAL)
	_hint_label.add_theme_font_size_override("font_size", 13)
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint_inner.add_child(_hint_label)
	vbox.add_child(_hint_panel)

	# ── Editor ───────────────────────────────────────────────────────────
	_editor_label = Label.new()
	_editor_label.text = "> DUCKY SCRIPT EDITOR:"
	_editor_label.add_theme_color_override("font_color", C_DIM)
	_editor_label.add_theme_font_size_override("font_size", 11)
	var editor_lbl_m := MarginContainer.new()
	editor_lbl_m.add_theme_constant_override("margin_left", 8)
	editor_lbl_m.add_child(_editor_label)
	vbox.add_child(editor_lbl_m)

	_text_edit = TextEdit.new()
	_text_edit.custom_minimum_size = Vector2(0, 150)
	_text_edit.placeholder_text = "REM Write your Ducky Script payload here...\nSTRING Hello, World!\nENTER"
	var te_style := _make_flat_style(C_EDITOR_BG, C_BORDER)
	_text_edit.add_theme_stylebox_override("normal", te_style)
	_text_edit.add_theme_stylebox_override("focus", _make_flat_style(C_EDITOR_BG, C_GREEN))
	_text_edit.add_theme_color_override("font_color", C_GREEN)
	_text_edit.add_theme_color_override("caret_color", C_GREEN)
	_text_edit.add_theme_color_override("selection_color", Color(0.0, 0.5, 0.2, 0.5))
	_text_edit.add_theme_font_size_override("font_size", 14)
	var te_margin := MarginContainer.new()
	te_margin.add_theme_constant_override("margin_left", 8)
	te_margin.add_theme_constant_override("margin_right", 8)
	te_margin.add_child(_text_edit)
	vbox.add_child(te_margin)

	# ── Button row ───────────────────────────────────────────────────────
	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 8)
	var btn_margin := MarginContainer.new()
	btn_margin.add_theme_constant_override("margin_left", 8)
	btn_margin.add_theme_constant_override("margin_right", 8)
	btn_margin.add_theme_constant_override("margin_bottom", 4)
	btn_margin.add_child(btn_row)
	vbox.add_child(btn_margin)

	_run_btn = _make_button("▶ RUN PAYLOAD", C_GREEN, Color(0.0, 0.2, 0.05))
	_run_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	btn_row.add_child(_run_btn)

	_hint_btn = _make_button("? HINT", C_TEAL, Color(0.0, 0.1, 0.12))
	btn_row.add_child(_hint_btn)

	_skip_btn = _make_button("⏩ SKIP", C_AMBER, Color(0.15, 0.1, 0.0))
	btn_row.add_child(_skip_btn)

	_next_btn = _make_button("▶▶ NEXT LEVEL", C_GREEN, Color(0.0, 0.2, 0.05))
	_next_btn.visible = false
	btn_row.add_child(_next_btn)

	# ── Output ───────────────────────────────────────────────────────────
	_output_label = RichTextLabel.new()
	_output_label.custom_minimum_size = Vector2(0, 60)
	_output_label.bbcode_enabled = true
	_output_label.scroll_active = false
	_output_label.fit_content = true
	var out_style := _make_flat_style(Color(0.01, 0.02, 0.01), Color(0.0, 0.2, 0.0))
	_output_label.add_theme_stylebox_override("normal", out_style)
	_output_label.add_theme_color_override("default_color", C_DIM)
	_output_label.add_theme_font_size_override("normal_font_size", 13)
	var out_margin := MarginContainer.new()
	out_margin.add_theme_constant_override("margin_left", 8)
	out_margin.add_theme_constant_override("margin_right", 8)
	out_margin.add_theme_constant_override("margin_bottom", 8)
	out_margin.add_child(_output_label)
	vbox.add_child(out_margin)

	# ── Connect signals ──────────────────────────────────────────────────
	_run_btn.pressed.connect(run_payload)
	_hint_btn.pressed.connect(toggle_hint)
	_skip_btn.pressed.connect(skip_level)
	_next_btn.pressed.connect(advance_level)
	_ref_toggle_btn.pressed.connect(toggle_ref)

func _build_header_bar() -> Control:
	var header := PanelContainer.new()
	var h_style := _make_flat_style(C_HEADER, C_BORDER, 0, 0)
	# Only round top corners
	h_style.corner_radius_top_left = 6
	h_style.corner_radius_top_right = 6
	h_style.corner_radius_bottom_left = 0
	h_style.corner_radius_bottom_right = 0
	header.add_theme_stylebox_override("panel", h_style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	header.add_child(hbox)

	var dot_box := HBoxContainer.new()
	dot_box.add_theme_constant_override("separation", 6)
	var m := MarginContainer.new()
	m.add_theme_constant_override("margin_left", 10)
	m.add_theme_constant_override("margin_top", 0)
	m.add_child(dot_box)
	hbox.add_child(m)

	for col in [Color(1, 0.25, 0.2), Color(1, 0.75, 0.0), Color(0.2, 0.8, 0.2)]:
		var dot := ColorRect.new()
		dot.custom_minimum_size = Vector2(12, 12)
		dot.color = col
		dot_box.add_child(dot)

	_title_label = Label.new()
	_title_label.text = "DUCKY SCRIPT: ZERO TO HERO"
	_title_label.add_theme_color_override("font_color", C_GREEN)
	_title_label.add_theme_font_size_override("font_size", 14)
	_title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hbox.add_child(_title_label)

	var close_btn := Button.new()
	close_btn.text = "[ ESC ]"
	close_btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	close_btn.add_theme_color_override("font_hover_color", C_RED)
	close_btn.flat = true
	close_btn.pressed.connect(close_mission)
	var cm := MarginContainer.new()
	cm.add_theme_constant_override("margin_right", 8)
	cm.add_child(close_btn)
	hbox.add_child(cm)

	return header

func _build_hud() -> Control:
	var hud_margin := MarginContainer.new()
	hud_margin.add_theme_constant_override("margin_left", 8)
	hud_margin.add_theme_constant_override("margin_right", 8)
	hud_margin.add_theme_constant_override("margin_top", 6)

	var hud := HBoxContainer.new()
	hud.add_theme_constant_override("separation", 6)
	hud_margin.add_child(hud)

	var labels := [
		["LEVEL", "1"],
		["XP", "0"],
		["SECTION", "BASICS"],
		["SOLVED", "0/100"],
	]
	var refs := [_hud_level, _hud_xp, _hud_section, _hud_solved]

	for i in range(labels.size()):
		var cell := PanelContainer.new()
		cell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var cell_style := _make_flat_style(Color(0.02, 0.07, 0.02), Color(0.0, 0.35, 0.1))
		cell.add_theme_stylebox_override("panel", cell_style)

		var cell_v := VBoxContainer.new()
		cell_v.add_theme_constant_override("separation", 2)
		cell.add_child(cell_v)

		var lbl_key := Label.new()
		lbl_key.text = labels[i][0]
		lbl_key.add_theme_color_override("font_color", C_DIM)
		lbl_key.add_theme_font_size_override("font_size", 9)
		lbl_key.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cell_v.add_child(lbl_key)

		var lbl_val := Label.new()
		lbl_val.text = labels[i][1]
		lbl_val.add_theme_color_override("font_color", C_GREEN)
		lbl_val.add_theme_font_size_override("font_size", 14)
		lbl_val.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cell_v.add_child(lbl_val)

		hud.add_child(cell)

		match i:
			0: _hud_level = lbl_val
			1: _hud_xp = lbl_val
			2: _hud_section = lbl_val
			3: _hud_solved = lbl_val

	return hud_margin

func _build_mission_card() -> Control:
	var card := PanelContainer.new()
	var card_style := _make_flat_style(Color(0.025, 0.06, 0.025), Color(0.0, 0.4, 0.15))
	card.add_theme_stylebox_override("panel", card_style)

	var card_margin := MarginContainer.new()
	card_margin.add_theme_constant_override("margin_left", 8)
	card_margin.add_theme_constant_override("margin_right", 8)
	card_margin.add_theme_constant_override("margin_top", 8)
	card_margin.add_theme_constant_override("margin_bottom", 8)
	card.add_child(card_margin)

	var outer_m := MarginContainer.new()
	outer_m.add_theme_constant_override("margin_left", 8)
	outer_m.add_theme_constant_override("margin_right", 8)
	outer_m.add_child(card)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 12)
	card_margin.add_child(hbox)

	# Badge
	_mission_badge = Label.new()
	_mission_badge.text = "BASICS"
	_mission_badge.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))
	_mission_badge.add_theme_font_size_override("font_size", 10)
	_mission_badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mission_badge.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_mission_badge.custom_minimum_size = Vector2(70, 0)
	hbox.add_child(_mission_badge)

	# Number
	_mission_num = Label.new()
	_mission_num.text = "#001"
	_mission_num.add_theme_color_override("font_color", C_GREEN)
	_mission_num.add_theme_font_size_override("font_size", 28)
	_mission_num.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_mission_num.custom_minimum_size = Vector2(65, 0)
	hbox.add_child(_mission_num)

	# Title + desc
	var text_vbox := VBoxContainer.new()
	text_vbox.add_theme_constant_override("separation", 4)
	text_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(text_vbox)

	_mission_title = Label.new()
	_mission_title.text = "Hello, Duck World"
	_mission_title.add_theme_color_override("font_color", C_WHITE)
	_mission_title.add_theme_font_size_override("font_size", 16)
	text_vbox.add_child(_mission_title)

	_mission_desc = Label.new()
	_mission_desc.text = ""
	_mission_desc.add_theme_color_override("font_color", C_DIM)
	_mission_desc.add_theme_font_size_override("font_size", 12)
	_mission_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_vbox.add_child(_mission_desc)

	_keywords_label = Label.new()
	_keywords_label.text = ""
	_keywords_label.add_theme_color_override("font_color", Color(0.0, 0.7, 0.5))
	_keywords_label.add_theme_font_size_override("font_size", 11)
	_keywords_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_vbox.add_child(_keywords_label)

	return outer_m

# ─────────────────────────────────────────────────────────────────────────────
# Public API
# ─────────────────────────────────────────────────────────────────────────────

func open_mission(workstation_idx: int) -> void:
	_current_idx = workstation_idx
	_current_level_id = workstation_idx + 1
	_hint_visible = false
	if _hint_panel != null:
		_hint_panel.visible = false
	_ref_visible = false
	if _ref_panel != null:
		_ref_panel.visible = false
	_text_edit.text = ""
	_output_label.text = ""
	if _next_btn:
		_next_btn.visible = false

	_update_ui()
	show()
	_is_open = true
	_text_edit.grab_focus()

func close_mission() -> void:
	if not _is_open:
		return
	_is_open = false
	hide()
	var pn := get_node_or_null("/root/Main/Player") as Node2D
	GameState.player_pos = pn.position if pn != null else GameState.player_pos
	GameState.save()
	emit_signal("mission_closed")

func _update_ui() -> void:
	var id := _current_level_id
	if id < 1 or id > 100:
		return
	var lvl := LevelData.get_level(id)
	if lvl.is_empty():
		return
	var sec := LevelData.get_section(id)
	var solved_count := GameState.get_solved_count()
	var total_xp := GameState.get_total_xp()

	# Update HUD
	if _hud_level:
		_hud_level.text = "%d" % id
	if _hud_xp:
		_hud_xp.text = str(total_xp)
	if _hud_section:
		_hud_section.text = sec.get("name", "---")
		var sec_color_hex: String = sec.get("color_hex", "#33ff88")
		_hud_section.add_theme_color_override("font_color", Color.html(sec_color_hex))
	if _hud_solved:
		_hud_solved.text = "%d/100" % solved_count

	# XP bar (estimate: 100000 total XP across all levels roughly)
	if _xp_bar:
		_xp_bar.value = clampf(float(total_xp) / 30000.0, 0.0, 1.0)

	# Mission card
	if _mission_badge:
		_mission_badge.text = sec.get("name", "BASICS")
		_mission_badge.add_theme_color_override("font_color", Color.html(sec.get("color_hex", "#33ff88")))
	if _mission_num:
		_mission_num.text = "#%03d" % id
	if _mission_title:
		_mission_title.text = lvl.get("title", "")
	if _mission_desc:
		_mission_desc.text = lvl.get("desc", "")
	if _keywords_label:
		var kws: Array = lvl.get("keywords", [])
		_keywords_label.text = "KEYWORDS: " + " · ".join(kws)

	# Hint text
	if _hint_label:
		_hint_label.text = lvl.get("hint", "")

	# Check if already solved / skipped
	var already_solved := GameState.is_solved(id)
	var already_skipped := GameState.is_skipped(id)

	if already_solved:
		_output_label.text = "[color=#00ff88]✓ ALREADY SOLVED — " + lvl.get("success_msg", "Well done!") + "[/color]"
		if _next_btn:
			_next_btn.visible = true
	elif already_skipped:
		_output_label.text = "[color=#ffbb22]⏩ SKIPPED — You can still solve this level for XP.[/color]"

	# Title bar
	if _title_label:
		_title_label.text = "DUCKY SCRIPT: ZERO TO HERO  |  " + LevelData.get_rank(solved_count)

# ─────────────────────────────────────────────────────────────────────────────
# Button actions
# ─────────────────────────────────────────────────────────────────────────────

func run_payload() -> void:
	var code := _text_edit.text
	if code.strip_edges().is_empty():
		_output_label.text = "[color=#ff4444]✗ Empty payload. Write some Ducky Script first![/color]"
		return

	var id := _current_level_id
	var result := LevelData.check_solution(id, code)
	var lvl := LevelData.get_level(id)

	if result:
		var xp_reward: int = lvl.get("xp", 100)
		var already_solved := GameState.is_solved(id)
		if not already_solved:
			GameState.solve_level(id, xp_reward)
			_output_label.text = "[color=#00ff88]✓ PAYLOAD ACCEPTED! +" + str(xp_reward) + " XP — " + lvl.get("success_msg", "Well done!") + "[/color]"
		else:
			_output_label.text = "[color=#00ff88]✓ Correct! (Already solved — no bonus XP)[/color]"
		if _next_btn:
			_next_btn.visible = true
		_update_ui()
		# Notify main to refresh workstations
		var main := get_node_or_null("/root/Main")
		if main and main.has_method("refresh_workstations"):
			main.refresh_workstations()
		# Show script execution replay
		if _replay_ui:
			_replay_ui.play(code, id)
	else:
		_output_label.text = "[color=#ff4444]✗ PAYLOAD REJECTED. Check the requirements and try again.[/color]"

func toggle_hint() -> void:
	_hint_visible = not _hint_visible
	if _hint_panel:
		_hint_panel.visible = _hint_visible

func toggle_ref() -> void:
	_ref_visible = not _ref_visible
	if _ref_panel:
		_ref_panel.visible = _ref_visible

func skip_level() -> void:
	var id := _current_level_id
	GameState.skip_level(id)
	_output_label.text = "[color=#ffbb22]⏩ Level skipped. No XP awarded. You can return to solve it later.[/color]"
	_update_ui()
	# Notify main to refresh doors
	var main := get_node_or_null("/root/Main")
	if main and main.has_method("refresh_doors"):
		main.refresh_doors()
	if main and main.has_method("refresh_workstations"):
		main.refresh_workstations()

func advance_level() -> void:
	# Try to open the next mission if it's accessible
	var next_id := _current_level_id + 1
	if next_id > 100:
		show_victory()
		return
	_current_level_id = next_id
	_current_idx = next_id - 1
	_hint_visible = false
	if _hint_panel:
		_hint_panel.visible = false
	_text_edit.text = ""
	_output_label.text = ""
	if _next_btn:
		_next_btn.visible = false
	_update_ui()

func show_victory() -> void:
	_mission_title.text = "OPERATION COMPLETE"
	_mission_desc.text = "You have completed all 100 missions. You are a DUCK COMMANDER. The corporate network is yours."
	_output_label.text = "[color=#ffdd00][b]🦆 CONGRATULATIONS! ALL 100 MISSIONS COMPLETE! 🦆[/b][/color]"
	GameState.complete = true
	GameState.save()

# ─────────────────────────────────────────────────────────────────────────────
# Input handling
# ─────────────────────────────────────────────────────────────────────────────

func _unhandled_input(event: InputEvent) -> void:
	if not _is_open:
		return
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			close_mission()
			get_viewport().set_input_as_handled()

# ─────────────────────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────────────────────

func _make_flat_style(bg: Color, border: Color = Color.TRANSPARENT, border_w: int = 1, radius: int = 4) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(border_w)
	s.set_corner_radius_all(radius)
	s.content_margin_left = 6.0
	s.content_margin_right = 6.0
	s.content_margin_top = 4.0
	s.content_margin_bottom = 4.0
	return s

func _make_button(txt: String, fg: Color, bg: Color) -> Button:
	var btn := Button.new()
	btn.text = txt
	btn.add_theme_color_override("font_color", fg)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", Color.WHITE)
	var normal_style := _make_flat_style(bg, fg)
	var hover_style := _make_flat_style(fg * 0.3, fg)
	btn.add_theme_stylebox_override("normal", normal_style)
	btn.add_theme_stylebox_override("hover", hover_style)
	btn.add_theme_stylebox_override("pressed", hover_style)
	btn.add_theme_font_size_override("font_size", 13)
	return btn
