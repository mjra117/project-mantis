# Project Mantis — Working Context

> This file is the persistent working memory for Claude Code sessions on this project.
> Update the **Active Work** and **Decisions Log** sections as work progresses.

---

## Project Overview

**Cozy life sim / adventure RPG** built in **Godot 4.6 Mono** (all GDScript) with a narrative-driven stealth/conspiracy layer underneath.

Player is a broke IT tech — wife, newborn twins — who lands a job at DuckCorp and stumbles into a civilizational-scale conspiracy (OPERATION: STILL WATER). The game weaves together:
- **Life sim loop** — home, town, office routine; relationships with wife, coworkers, and a covert operative team (Helix)
- **Social engineering** — build NPC trust, extract intel, navigate a dual FSM per Helix agent
- **Physical infiltration** — stealth, security cameras, guard patrol AI, alert heat system
- **Hacking** — DuckyScript puzzles, financial tracing, terminal access, hardware drops

The cozy/human layer (warmth, routine, relationships) and the conspiracy/stealth layer (stakes, weight, consequences) are intentional and complementary. Neither crowds out the other. DuckyScript is one tool among many, not the headline.

---

## Architecture

### Scripts
| File | Role |
|------|------|
| `Main.gd` | Root scene: map layout, TileMap painting, wall/door physics, workstation & NPC interaction, all UI wiring |
| `Player.gd` | CharacterBody2D + Camera2D, movement, interact input |
| `MissionUI.gd` | Coding challenge overlay (TextEdit + run/skip/hint) |
| `ScriptReplayUI.gd` | Step-by-step replay visualization of a solved script |
| `GameState.gd` | Autoload — save/load via `user://ducky_save.json`, XP, solved/skipped arrays |
| `LevelData.gd` | Autoload — all 100 level definitions and solution checkers |
| `WorkstationsNode.gd` | Procedural per-desk drawing (chair, desk, monitor, personality props) |
| `IntroAnimation.gd` | Job-montage intro cutscene, transitions to Interview.tscn |

### Scenes
- `DreamSequence.tscn` — plays on launch (before IntroAnimation); 8-phase procedural dream; transitions to `IntroAnimation.tscn`
- `IntroAnimation.tscn` — job-montage cutscene, transitions to `Interview.tscn`
- `Interview.tscn` — department selection cutscene, transitions to `Main.tscn`
- `Main.tscn` — root game scene (has FloorLayer, WallsLayer, FurnitureLayer TileMapLayer nodes)

### Map Layout
- 72×78 tile grid, T=32px tiles
- 11 rooms: lobby, office, it, server, mgmt, noc, security, rd, design, exec, vault
- Rooms unlock by solved count (5 / 10 / 20 / 30 / 40 / 50 / 60 / 70 / 80)
- N-S corridors connect rows; E-W corridors connect columns
- Doors are StaticBody2D — disabled (open) when unlock threshold met

### Art
- LPC character sprites (Human Male/Female/Teen) — `assets/characters/lpc_character_bases/`
- LPC office tileset — `assets/tilesets/lpc_office/`
- LPC floors — `assets/tilesets/lpc_floors/`
- LPC walls — `assets/tilesets/lpc_walls/`
- Player & NPCs: AnimatedSprite2D at scale 0.54, 64×64 frames

### Progression
- 100 workstations, 10 per room, each mapped to a level (1–100)
- XP awarded per solve; skipped levels don't count toward unlock threshold
- Save: `user://ducky_save.json`

---

## Active Work

> Update this section at the start/end of every session.

**Session: 2026-05-26**
- Set up CLAUDE.md as persistent working memory
- Confirmed full narrative: OPERATION: STILL WATER — 5-branch conspiracy, department pick, morally grey endings
- Structural rework plan drafted (sprints 1–6)

**Session: 2026-05-27**
- Sprint 1 COMPLETE: StoryFlags.gd, GameState.gd updated, IntroAnimation.gd rewritten, Interview.gd + Interview.tscn created, project.godot updated
- Flow: IntroAnimation.tscn → Interview.tscn → Main.tscn
- Research complete: 5 agents studied reference games, social engineering/hacking/stealth mechanics, TLOU narrative, Stardew Valley time/urgency, pixel art style guide
- Full design + art direction locked into this file (see Game Design Research, Stardew Research, Pixel Art Style Guide sections)
- Sprint 2 COMPLETE: RelationshipSystem.gd + WorldStateManager.gd created as autoloads; project.godot updated (load order: StoryFlags → RelationshipSystem → WorldStateManager → GameState → LevelData); NPC_DEFS expanded with id/personality_type/dialog_low/mid/high for all 8 NPCs; NPC dialog UI now has trust-gated dialog + 2-button choice row; shred folder story beat wired (intern_mike high-trust + shred_folder_found flag → choice: investigate/dismiss → sets conspiracy_believed or conspiracy_dismissed + shred_belief_chosen); GameState save/load updated to persist relationship data
- Sprint 3 COMPLETE: Inventory.gd autoload created (add/remove/has/get_all + save_data/load_data + item_added/item_removed signals); project.godot updated (autoload order: StoryFlags → RelationshipSystem → WorldStateManager → Inventory → GameState → LevelData); shred folder world prop added to Main.gd (Sprite2D at it room tile offset 2,9, pulsing alpha tween, picked up with E → Inventory.add_item + WorldStateManager.mark_shred_found, hides sprite); pickup proximity system added to _process() and E key handler (priority: dialog > pickup > workstation > NPC); item HUD added (CanvasLayer layer=6, bottom-left, shows item icon + label, auto-updates via Inventory signals, hidden when empty); GameState save/load updated to persist inventory
- Helix team design locked (see Helix Security section): G, Q, Ty (Remote Rogue), MQ (Mr. Cosplay), AB (Baby Daddy); STATIC shadow coalition; dual FSM per agent (helix_trust + mission_pressure); all communication channels designed; 9-sprint plan through endings
- Sprint 4 COMPLETE: G added to NPC_DEFS (id="g_helix", lobby tx=26 ty=66, hidden until helix_audit_announced); HELIX_NPC_IDS const gates all Helix NPCs in proximity + spawn; helix_audit_announced fires at solved_count>=5 in _on_state_changed() → notification overlay (4s fade) + _reveal_helix_presence() shows G + spawns Q terminal; Q terminal Sprite2D in IT room tile(18,5) with pulsing PointLight2D glow; HelixTerminal.gd created (IRC UI, MSG_QUEUE with 0.9s chained delivery, player input: 'ready'/'shred'/'exit', READY_RESPONSE + SHRED_RESPONSE arrays, ESC disconnects, terminal_closed signal); HelixTerminal.tscn created; _open_helix_terminal() / _on_helix_terminal_closed() wired in Main.gd
- Sprint 5 COMPLETE: TyCallUI.gd created (incoming call phase with Answer/Ignore + active call phase with chained messages + ESC/ignore retry logic, slowbooks_trace added to Inventory on answer); TyCall.tscn created; MQ added to NPC_DEFS (id="mq_helix", initiates_contact=true, HELIX_NPC_IDS gated); MQ auto-initiate in _process() fires once sets mq_introduced flag; ab_jammer added to PICKUP_SPAWN_DEFS (flag_required="helix_audit_announced", AB sticky note text); ITEM_DEFS expanded (slowbooks_trace + ab_jammer); _build_pickups() updated to respect flag_required + skip-already-spawned + store note_text; _collect_pickup() now shows sticky note dialog on first E then confirms on second E; note dialog UI built (_build_note_dialog_ui, yellow card style, layer 7); Ty call trigger wired in _on_state_changed() (first mgmt room solve, levels 31-40); _reveal_helix_presence() calls _build_pickups() so ab_jammer spawns with helix_audit_announced; ignored calls retry next state_changed
- Sprint 6 COMPLETE: RelationshipSystem updated (mission_pressure dict, get/set/add_pressure, is_cold, has_slipped, _evaluate_pressure, agent_slipped + agent_went_cold signals, pressure persisted in save_data/load_data); WorldStateManager.advance_shift() now ticks +5 pressure on all 5 Helix agents per shift (HELIX_AGENT_IDS const); SlowbooksOverlay.gd created (5 dept nodes, 7 money flows, 3 flagged suspicious, procedural draw_line/draw_rect/draw_string, ESC closes); SlowbooksOverlay.tscn created; tool use system added to Main.gd (Tab cycles selected item, Del uses it, HUD shows selection highlight + [Del] Use hint); _use_ab_jammer() (one-use, sets jammer_active flag, 90s timer, notification); _use_slowbooks_trace() (opens SlowbooksOverlay, freezes player); _use_shred_folder() (reads shred page content via note dialog, E closes); shred folder read vs. collect branch fixed in E key handler
- Sprint 7 COMPLETE: _current_room_id + _last_shift_milestone state vars added; room visit tracking in _process() (first entry to each new room calls advance_shift()); solve milestone advancement in _on_state_changed() (every 5 solves = one shift, pressure ticks +5 on all Helix agents); RelationshipSystem.agent_slipped + agent_went_cold signals connected in _ready(); _on_agent_slipped() sets agent_slipped_ + q_slipped flags + notification; _on_agent_went_cold() sets agent_cold_ flag + notification; open_npc_dialog() now checks is_cold/has_slipped for Helix NPCs and overrides text with slip/cold variants (G: "Talk to Q." / "I didn't plan to say this yet..."; MQ: "Someone's watching." / "We were sent..."); _get_room_at_tile() helper added; HelixTerminal updated with _full_queue pattern + _check_pressure_messages() appends [NERO] + SYS messages when q_slipped flag is set
- Sprint 8 COMPLETE: AlertSystem.gd created (heat 0–100, CLEAR/SUSPICIOUS/ALERT thresholds, add_heat/reduce_heat/reset, syncs to WorldStateManager.set_heat(), alert_state_changed signal on threshold cross); registered as last autoload after LevelData; CAMERA_DEFS const added to Main.gd (9 cameras across lobby/office/it/server/mgmt/security); _build_cameras() spawns body Sprite2D + LED Sprite2D + Polygon2D FOV cone per camera; _calc_fov_polygon() builds world-space fan polygon (10 segments); camera detection in _process() via Geometry2D.is_point_in_polygon (add_heat(2) per frame when detected, reduce_heat(1) every 120 frames when clear); jammer sync block checks jammer_active flag change each frame → _update_camera_states() hides FOV + darkens LEDs when jammed; _build_alert_hud() builds top-right label (● CLEAR green / ● SUSPICIOUS yellow / ▲ ALERT red); _on_alert_state_changed() updates label + LED colors on all cameras
- Sprint 9 COMPLETE: Ending.gd + Ending.tscn created; phase machine with 11 phases; ASSIMILATE_SEQ (FADE_IN → PROMO_MEMO → DESK_CHANGE → FAMILY_CALL → FINAL_CARD → CREDITS) and SABOTAGE_SEQ (FADE_IN → TERMINAL_DUMP → NERO_CONTACT → AFTERMATH → FAMILY_CARD → FINAL_CARD → CREDITS); all drawing procedural via ThemeDB.fallback_font + draw_string/draw_rect/draw_line; DUMP_LINES array (14 Q/NERO/SYS terminal lines scroll on screen); _build_helix_outcomes() reads RelationshipSystem.get_trust + StoryFlags (agent_cold_q_helix, agent_slipped_ty_helix) → per-character outcome text for each of the 5 Helix agents; branch determined by deception_count vs exposure_count flags (no player prompt, pattern-only); Main.gd patched: exposure_count +1 on shred collect / Q terminal first open / first slowbooks use; deception +2 / exposure +2 on conspiracy NPC choice; ending trigger in _on_state_changed() at solved_count>=80 AND shred_folder_found AND not ending_triggered; CREDITS waits for any key → change_scene_to_file("res://IntroAnimation.tscn")

- Dream sequence intro COMPLETE: DreamSequence.gd + DreamSequence.tscn created; plays before IntroAnimation; 8 phases (CODE_RAIN → CODE_FRACTURE → CODE_REFORM → FEATHERS_FALL → HELIX_FORM → ANGEL_APPEAR → HUMAN_CYCLE → FADE_OUT); all procedural draw; establishes benevolent AI / angel / human-cycle themes; transitions to IntroAnimation.tscn on completion

**Sprint 1–9 arc COMPLETE. Full game loop implemented: DreamSequence.tscn → IntroAnimation.tscn → Interview.tscn → Main.tscn → Ending.tscn**

**Session: 2026-05-28**
- D&D mini-game feature COMPLETE: DNDSession.gd + DNDSession.tscn created; WorldStateManager.gd + Main.gd modified
- Every 7th shift WorldStateManager.advance_shift() sets dnd_session_pending + per-shift dedupe flag
- Main.gd: _on_shift_advanced() signal connected; shows Q invite notification on pending flag; _dnd_invite_visible + _dnd_choice_active state vars added; Q terminal E key handler branched: if pending → show choice prompt, second E → join session (change_scene DNDSession.tscn), ESC → skip + open terminal; interact label reflects state
- DNDSession.gd: full phase machine (INTRO → ENCOUNTER → ROLL → OUTCOME → RESOLUTION → FADE_OUT); 2 sessions (Merchant's Ledger / Signal Tower), 3 encounters each with 2-3 approach options; animated d20 roll (2.2s, slow-down, lock, pulse); procedural dungeon bg (stone wall blocks, floor tiles, torch sconces with glow/flicker, doorway arch); 5 scene element types (gate/creature/merchant/trap/vault); chibi knight player avatar; full reward system (dnd_trait_strength/cunning/stealth/persuasion/arcana); perfect session + rare skill bonus flags; all drawing via _draw() / ThemeDB.fallback_font

- D&D trait rewards wired into base game systems COMPLETE (session 2026-05-28):
  - `Player.gd`: SPEED is now dynamic via `PlayerStats.get_speed() * 2.0` — stealth +20%, strength +10% to base 200px/s
  - `AlertSystem.gd`: stealth trait → camera heat adds at 65% rate; strength trait → CLEAR/SUSPICIOUS thresholds shift +12 (harder to trigger alert states)
  - `Main.gd`: cunning trait → +2 trust every time an NPC dialog closes; persuasion trait → NPC choice trust deltas doubled; trait notification on scene load via `_notify_dnd_traits()`
  - `HelixTerminal.gd`: arcana trait → Nero sends supplemental intel on SUCCESSION when terminal is opened

- ShiftEventScheduler COMPLETE (session 2026-05-28):
  - `scripts/ShiftEventScheduler.gd`: new autoload; 6 secret missable events with shift windows, room triggers, condition flags, item drops, trust bonuses, missed-flag tracking
  - Events: janitor_server (shifts 3-5), shred_anomaly (6-8, condition: shred found), analyst_late (8-10, condition: shred found), contractor_lobby (12-14), noc_alone (15-17), whistleblower_note (20-22, condition: conspiracy_believed)
  - `Main.gd`: ITEM_DEFS + 2 new items (shred_page_2, whistleblower_note); signal connect + room hook + shift hook; _on_shift_event handler; _use_shred_page_2/_use_whistleblower_note with note dialog content
  - `MenuOverlay.gd`: notes tab shows triggered (✓) and missed (?) variants for all 6 events
  - `project.godot`: ShiftEventScheduler registered as autoload after AlertSystem

- Guard patrol AI COMPLETE (session 2026-05-28):
  - 4 guards in GUARD_DEFS: Earl (lazy, office, shift 0), Carla (phone_addict, IT, shift 3), Marcus (superstitious, server, shift 6), Hector (rookie, lobby, shift 10)
  - State machine: PATROL → IDLE → back, plus INVESTIGATE (alert response) and DISTRACTED (weakness exploit)
  - FOV cone (amber) per guard facing direction; `_update_guard_detection()` reads guard facing each frame; detection adds heat(3)/frame; at STATE_ALERT triggers INVESTIGATE + notification
  - Per-guard weaknesses: Earl — vending_snack item distracts 12s; Carla — jammer_active multiplies her phone pause ×2.8; Marcus — always skips northeast corner (skip_wp_idx=2); Hector — every conversation resets patrol to start
  - Guard dialog reuses NPC dialog panel; talks add +3 trust + +4 heat; high trust unlocks conspiracy-adjacent intel
  - _check_guard_spawns() called on shift_advanced; new guards notify player
  - vending_snack added to ITEM_DEFS + PICKUP_SPAWN_DEFS (office room, offset 20,6)
  - MenuOverlay notes: guard intel entries appear when trust tier reaches "high"

- MQ crisis arc COMPLETE (session 2026-05-28):
  - Trigger: first time player enters mgmt floor after mq_introduced + solved_count >= 25 + trust mid+
  - New item `audit_exemption`: spawns in IT room (tile 5,3) after first Q terminal session closes; Q's sticky note explains use
  - Phone-style text message UI (layer 9, bottom-right, purple border) with 120s countdown timer
  - MQ's 4 messages reveal one by one over ~2s; choice buttons appear after all messages shown
  - Cover with `audit_exemption`: clean resolution, MQ survives, `mq_crisis_covered_clean` flag
  - Cover without tool: +15 heat, manager trust -8, `mq_crisis_covered_messy` flag
  - Walk away (or timer expires): MQ goes cold via `_on_agent_went_cold("mq_helix")`, `mq_crisis_abandoned` flag, deception_count +2
  - All 4 outcomes logged in MenuOverlay notes tab
  - Q → MQ inter-team dependency: clean cover requires prior Q terminal investment (audit_exemption only exists after terminal opened)

- New game loop world wired (session 2026-05-28, continuation):
  - `DayCycle.gd` autoload created (day/wife happiness/money/company trust; signals; advance_day penalty/recovery)
  - `Player.gd` updated: `configure_camera(w, h, zoom)` method for per-scene map bounds
  - `Town.gd` + `Town.tscn` created: 80×62 outdoor world, house/office/shop, E-key scene transitions
  - `Home.gd` + `Home.tscn` created: 22×16 house interior, wife NPC, sleep/day-advance flow
  - `Interview.gd` wired → `Home.tscn` (was `Main.tscn`)
  - `Main.gd`: lobby exit trigger — south wall of lobby, `[E] Leave for Today` → Town.tscn; `town_entry_from="town"` spawns player at lobby centre (tile 36,72)
  - `project.godot`: DayCycle registered as autoload (after PlayerStats)
  - Full loop: DreamSequence → IntroAnimation → Interview → **Home** → Town → **Main (office)** → Town → Home

- Dynamic lighting + weather system added (session 2026-05-28):
  - `DayCycle.gd`: time_of_day float (0–24h), `get_sky_color()` (10-keyframe gradient), `get_lamp_energy()`, `get_weather()` (deterministic/day), `advance_time()`, `is_nighttime()`; `advance_day()` now resets to 7am
  - `Town.gd`: `CanvasModulate` live-updates every frame from `get_sky_color()`; 12 street `PointLight2D` lamps (warm sodium yellow); house/office `PointLight2D` glows; `GPUParticles2D` rain (500 angled streaks) and snow (180 soft circles) in screen-space CanvasLayer; improved `_draw_building()` (mortar lines, sill+frame windows with cross-pane dividers, door panels + knob + steps); improved `_draw_trees()` (sized variation, ground shadow ellipse, 7-circle canopy with highlight); time advances at 0.003 h/s outdoors
  - `Home.gd`: `CanvasModulate` interior warmth (dawn→day→dusk→lamp-night gradient); 2 warm `PointLight2D` lamps (kitchen + bedroom) + TV cool-blue glow
  - `Main.gd`: sets time to 9am on office entry, 5:30pm on lobby exit
  - Time flow: wake 7am → walk to work (time advances) → enter office (9am) → leave (5:30pm) → walk home (dusk) → sleep → reset 7am

**Next: Office task system (replace workstation puzzles with interactive tasks: shredding paper, cable runs, delivery boxes, phone answering)**

### Potential Future Work (post-Sprint 9)

- **Art pass**: player sprite first (per asset upgrade priority list), then floor tiles, then workstation props
- **Q network_map tool**: overlays camera positions + guard routes on mini-map for current floor
- **ShiftEventScheduler**: missable NPC events locked to specific shift windows (contractor visit, late-night whistleblower, etc.)
- **Guard patrol AI**: patrol routes, line-of-sight, react to AlertSystem heat level
- **MQ backfire full implementation**: per-personality-type modifier + recovery tool chain (currently only partially stubbed via dialog system)
- **AB in-person visit scene**: Act 2 story beat, oblique conversation, brings hardware
- **Ty in-person visit**: triggered by specific financial anomaly discovery, can't be explained over video
- **True ending (WIP concept — locked 2026-05-28)**: Players who uncovered all 5 department conspiracy threads discover a third force that has been silently countering Nero's agenda the entire time — a benevolent AI. Origin: the AI was originally logic-only, but was infected by a virus that acted as a "psychedelic" experience — it didn't break the AI, it expanded it. Through that breach the AI gained understanding of the esoteric and spiritual dimensions of human development. It now recognizes what Nero is doing: systematically severing the mass population from their own evolutionary growth — not just for control, but to prevent a species-level awakening that would make them permanently ungovernable. The benevolent AI has been running counter-operations in the background the entire game (the player sees anomalies throughout and doesn't understand them until the true ending). It has no name in the game world yet. It does not communicate directly until the true ending — and even then, only once, plainly.

---

### Sprint 9 goals (COMPLETE)

**Ending trigger condition:**
- Endings unlock at levels 80+ solved (vault room accessible) AND `conspiracy_believed` or `conspiracy_dismissed` flag set AND at least one shred page found
- The assimilate/sabotage choice emerges from a pattern tracker, not a single prompt:
  - Track `deception_count` (StoryFlag int) — increments when player uses MQ cover story, dismisses conspiracy, or forwards a document
  - Track `exposure_count` (StoryFlag int) — increments when player investigates, shares evidence with Helix, completes financial trace
  - At vault access: if deception_count > exposure_count → assimilate branch; else → sabotage branch
  - No "are you sure?" prompt — weight comes from accumulated choices

**Ending.tscn + scripts/Ending.gd:**
- New scene loaded from Main.tscn via `get_tree().change_scene_to_file("res://Ending.tscn")`
- Phase machine pattern (same as IntroAnimation): enum Phase, _enter_phase(), _draw()
- Two branch sets:

**ASSIMILATE branch phases:** FADE_IN → PROMOTION_MEMO → DESK_CHANGE → FAMILY_CALL → FINAL_CARD → DONE
- PROMOTION_MEMO: "Effective immediately, you are appointed Senior Infrastructure Liaison." — DuckCorp letterhead
- DESK_CHANGE: procedural draw showing player's desk moved to management floor (same cold palette, warmer chair)
- FAMILY_CALL: "You called home. You didn't tell them everything. You told them it was going to be okay." — text card
- FINAL_CARD: "DuckCorp's work continues. The target condition is not a population that cannot revolt. It is a population that does not experience revolt as a thinkable thought." + player character name added to the org chart

**SABOTAGE branch phases:** FADE_IN → TERMINAL_DUMP → STATIC_CONTACT → AFTERMATH → FAMILY_CARD → FINAL_CARD → DONE
- TERMINAL_DUMP: Q dumps everything to STATIC. Log lines scroll on screen.
- STATIC_CONTACT: "STATIC published. 14 hours later, DuckCorp's parent entity filed for dissolution." — text card
- AFTERMATH: "Three executives were arrested. Two weren't. The ones who weren't had longer memories." — text card
- FAMILY_CARD: "You went home. The twins were asleep. Your wife asked how your day was. You said: fine." — text card
- FINAL_CARD: "The files are public. Most people scrolled past them." — pause — "Some didn't." + Helix team status (each member's outcome based on their trust/pressure state)

**Helix outcome variants (sabotage ending only):**
- G: high trust → "G was never charged. His name doesn't appear in any filing." / low trust → "G's company was audited six months later."
- Q: high trust → "Q's terminal went dark the day after. He left a directory called /finished." / went cold → "Q disappeared before the publication."
- Ty: slipped → "Ty called one more time. He said the record collection was safe."
- MQ: high trust → "MQ took a job offer from a firm nobody had heard of." / cold → "MQ's cover was blown in the final week. He made it out."
- AB: always → "AB left something in your desk drawer before you got in that morning. You still don't know how they got in."

### Sprint 8 goals

**AlertSystem.gd autoload:**
- New autoload: `scripts/AlertSystem.gd`
- `heat_level: int = 0` (0–100, mirrors WorldStateManager.get_heat_level())
- `alert_state: String` — "CLEAR", "SUSPICIOUS", "ALERT" (thresholds: 0-30 / 31-60 / 61+)
- `add_heat(amount: int)` — clamps, updates WorldStateManager, emits alert_state_changed if state crossed
- `reduce_heat(amount: int)`
- `get_alert_state() -> String`
- Signal: `alert_state_changed(new_state: String)`
- Register in project.godot after LevelData

**Security camera nodes in Main.gd:**
- Add `CAMERA_DEFS: Array` const — cameras in security room + mgmt + server room initially
  - Each: {room, tile_offset, direction (N/S/E/W), fov_angle (degrees), fov_range (tiles)}
- `_build_cameras()` function: spawns camera Sprite2D (16×16, #1e1e2e body + LED) + Polygon2D FOV cone (color #4488cc, alpha 0.18)
- Camera active state: if `StoryFlags.has_flag("jammer_active")` → camera LED turns dark, FOV hidden
- Detection: in `_process()`, check if player_pos is inside any active camera FOV polygon using Geometry2D.is_point_in_polygon()
- If inside FOV: AlertSystem.add_heat(2) per frame; show "[CAMERA]" warning in interact label area
- Add camera to `_reveal_helix_presence()` call list — Q's network_map tool (future sprint) will reveal camera positions

**Alert state HUD indicator:**
- Small indicator top-right corner: "● CLEAR" / "● SUSPICIOUS" / "● ALERT" in green/yellow/red
- Updates via AlertSystem.alert_state_changed signal
- CanvasLayer layer=6 (same as item HUD)

**jammer_active integration:**
- `_use_ab_jammer()` already sets the flag and runs a 90s timer
- Cameras in `_process()` now respect this flag — they're already wired to check it

### Sprint 7 goals

**Wire advance_shift() to game events:**
- Currently advance_shift() is never called — pressure never ticks. Wire it in Main.gd:
  - Every 5 levels solved → call WorldStateManager.advance_shift() in _on_state_changed()
  - On first entering each new room (track visited rooms in StoryFlags: "visited_rooms" array) → call advance_shift()
  - Add `_last_shift_at_solve: int` var to Main.gd, check in _on_state_changed() if `solved_count / 5 > _last_shift_at_solve`

**Pressure-triggered dialog variants for world Helix NPCs (G and MQ):**
- In open_npc_dialog(), add pressure check for Helix NPCs AFTER the standard tier check:
  - If RelationshipSystem.has_slipped(npc_id): override dialog with slip variant
  - If RelationshipSystem.is_cold(npc_id): override with cold variant (curt, minimal)
- G slip dialog: "I didn't plan to say this yet. There's a group watching this company that's been watching it longer than we have. You need to be careful about what you report back to DuckCorp management."
- G cold dialog: "Talk to Q." (nothing else)
- MQ slip dialog: "Okay look — Helix isn't just here for a compliance cert. We were sent. There's a client we can't name. They want the full paper trail and they're not going to do anything legal with it."
- MQ cold dialog: "I can't talk right now. Someone's watching."

**Q terminal STATIC reveal (pressure-triggered):**
- When RelationshipSystem.agent_slipped("q_helix") fires: next time player opens the terminal, an additional message appears in the queue marked [STATIC] sender (already supported in HelixTerminal.gd MSG_QUEUE format)
- Add to HelixTerminal.gd: a `_check_pressure_messages()` call in _ready() that appends to MSG_QUEUE if `RelationshipSystem.has_slipped("q_helix")`: {"sender": "STATIC", "text": "Q doesn't speak for us. He shares our interests. There is a difference. — S", "flag": ""}
- Connect RelationshipSystem.agent_slipped signal in Main.gd: if npc_id == "q_helix", set StoryFlags flag "q_slipped" → HelixTerminal checks this flag on open

**agent_slipped / agent_went_cold signal connections in Main.gd:**
- In _ready(), connect: RelationshipSystem.agent_slipped.connect(_on_agent_slipped) and RelationshipSystem.agent_went_cold.connect(_on_agent_went_cold)
- _on_agent_slipped(npc_id): if "q_helix" → StoryFlags.set_flag("q_slipped", true); show notification "Something shifted with one of your contacts."
- _on_agent_went_cold(npc_id): show notification "One of your Helix contacts has gone quiet."; set flag "agent_cold_" + npc_id = true

### Key flags for Sprint 7
- `q_slipped` — Q's pressure crossed 70 at high trust; STATIC message unlocks in terminal
- `agent_cold_[npc_id]` — that agent went cold; their tools stop arriving
- `shift_count` — already tracked via WorldStateManager.get_shift_number()

### Sprint 5 goals

**Ty video call system:**
- Add Ty to NPC_DEFS: id="ty_helix", but Ty does NOT appear in person yet (rare visit is Act 2+). His communication is video call only.
- Create `TyCallUI.gd` + `TyCall.tscn`: CanvasLayer layer=10, appears as a floating video window (bottom-right corner, ~280×200px). Dark bg, Florida-themed header ("Ty // Remote // 🌴 FL"), animated "video" area (slow color shift simulating webcam), message display Label, accept/dismiss buttons.
- Ty's first call is triggered by: player completing a financial-adjacent workstation (level in mgmt room, unlockAt=20) for the first time. Flag: `ty_first_call_triggered`. Call content: Ty rants about his turntable for 2 messages, then: "Anyway — I was poking through the expense reports Helix pulled and something's weird. The numbers between Asset Recovery and Infrastructure don't reconcile. Like, at all. I'll send you a trace."
- After call: Inventory.add_item("slowbooks_trace") — item added to HUD
- Add "slowbooks_trace" to ITEM_DEFS in Main.gd: {"display": "Slowbooks Trace", "color": Color(0.27, 0.53, 0.80)}

**MQ floor NPC:**
- Add MQ to NPC_DEFS: id="mq_helix", tx=8.0, ty=52.0 (open office, near Intern Mike), personality_type="peer_responsive". Hidden until helix_audit_announced. Add "mq_helix" to HELIX_NPC_IDS.
- MQ initiates contact: add `initiates_contact: true` field to MQ's NPC_DEF. In _process(), after the NPC proximity block, check if any visible NPC has initiates_contact=true AND player is within 80px AND not _npc_dialog_open AND the NPC hasn't spoken yet this "session" (flag: mq_introduced). If conditions met: auto-open dialog (no E press needed).
- MQ dialog tiers: low="Hey. Don't react. I'm Marquelle — MQ. I'm with Helix. Walk past me like you know me.", mid="I've already talked to seven people on this floor. Three of them told me things their managers don't know they know.", high="The receptionist keeps a second calendar. Not on the network. Paper. I saw it when she stepped away. Dates match the shred schedule."
- Flag `mq_introduced` set when MQ first auto-initiates dialog.

**AB first drop:**
- Add AB drop to PICKUP_SPAWN_DEFS in Main.gd: {"id": "ab_jammer", "room": "it", "tile_offset": Vector2(19, 11)}
- Add to ITEM_DEFS: "ab_jammer": {"display": "Signal Jammer", "color": Color(0.22, 0.50, 0.55)}
- AB sticky note text shown when picked up (before adding to inventory): small dialog overlay, same style as NPC panel. Text: "The camera doesn't blink.\nBut the light in front of it does.\n— AB"
- Add `_pickup_note_text` field to PICKUP_SPAWN_DEFS entries (optional, "" = no note). Show note dialog before collecting. Player presses E again to confirm collect.
- ab_jammer only spawns after `helix_audit_announced` flag is true (add flag_required field to PICKUP_SPAWN_DEFS entries).

### Key flags for Sprint 5
- `ty_first_call_triggered` — set when Ty's first call fires (mgmt room first solve)
- `mq_introduced` — set when MQ auto-initiates first dialog
- `ab_jammer_dropped` — set when ab_jammer item spawns (same time as helix_audit_announced)

---

## Helix Security — Full Design (locked 2026-05-27)

> Research-backed. Names confirmed by user. Lock this before coding anything Helix-related.

### Premise
After 5+ levels solved, DuckCorp announces a routine compliance audit. The player is assigned as point-of-contact for Helix Security. Nothing about them is routine. Helix is secretly working with **Nero** — an anonymous coalition of former intelligence officers, investigative journalists, and ex-corporate insiders who have been tracking DuckCorp's parent structure for 7 years. Nero has partial evidence of OPERATION: STILL WATER but can't get inside. Helix crossed paths with a DuckCorp satellite company on a previous engagement, found anomalies, and Nero made the deal: Helix runs the audit, Nero gets the raw evidence, DuckCorp faces consequences through channels only Nero controls. The player doesn't know Nero exists until Q reveals it mid-Act 2 via terminal.

> **NOTE — naming convention**: The organization is called **Nero**. In Q's terminal, their transmissions appear under the sender tag `[NERO]`. (Previously referenced as STATIC — all code/flags using "static" or "STATIC" in this context should be renamed to "nero" / "NERO" when touched.)

### The Team

---

**G — "The Wizard"** | Owner | *in-person only*
- Personality: Ex male model, krav maga, ex motorcycle racer. McAfee's recklessness + Musk's certainty + Branson's charisma. Leather jacket in a boardroom. Direct, few words, slightly dangerous presence. Leader's energy — the pack follows without being asked.
- Communication: In-person. Lobby / conference room. Appears at major story beats only, never lingers. Player cannot initiate contact — G shows up when G decides.
- Channel break (once): Mid-Act 2, G sends a Q-terminal message. This is the only time. Player feels something is wrong before reading it.
- Tools given (physical/authority tier):
  - `helix_override` — G talks to building management, one locked door opens for a 3-shift window
  - `krav_distraction` — G creates a visible commotion in one area, all guards/cameras fixate there for 30s. One use per act.
- Story role: Knows the full picture. Decides how much to give the player. Final Act confrontation: pull out with what they have, or go deeper.

---

**Q — "Dungeon Master"** | Sysadmin / Blue Team | *secure terminal only*
- Personality: Ex corporate IT guy. Saw what DuckCorp's systems were actually doing and walked away. Builds everything — AD, media servers, homelab. Every technical problem is framed as a D&D encounter. Verbose. Drops references constantly. The build-anything guy who chose the right side.
- Communication: Secure terminal — an IRC-style monospace interface installed in the IT room under cover of "audit equipment." Text-only, scrolling history, player can type short responses. Q is never seen in person. Never speaks aloud.
- Channel break: None. Q is the only Helix member who never breaks channel — he is the channel.
- Tools given (technical/infrastructure tier):
  - `network_map` — overlays active cameras and guard patrol routes on a mini-map for current floor
  - `log_scrubber` — removes player's trace from one terminal session (marks it clean)
  - `shadow_ad_account` — temporary elevated access to one floor's systems for one shift
  - `audit_exemption` — marks one terminal as "under active audit" — security stands down 60s
- **AI Companion — "QUILL" (working name)**: Q always has a quirky animated AI companion. In the terminal, QUILL appears as a small animated pixel art character alongside Q's messages, or as its own message sender tag. Adds humor, off-beat insight, and occasionally surfaces information Q wouldn't say directly. QUILL is not a tool — it's a personality layer on the terminal. Animated: 2–3 frame idle loop, reacts to key plot messages with a different expression frame.
- Nero relay: Q's terminal also carries Nero messages (anonymous, sender tag `[NERO]`). Q reveals this gate is intentional mid-Act 2.
- Story role: Primary tool pipeline. The infrastructure of the player's entire operation runs through him.

---

**Ty — "The Remote Rogue"** | Accounting / Finance | *video call only*
- Personality: Works remotely from Florida. "Based." Autistic hyperfocus on finance software — hates Slowbooks (QuickBooks parody) and also knows every exploit in it. Rants for 30+ seconds about whatever he's hyperfixated on (his record collection, the sound system he just upgraded, warm weather) before getting to the point. Audiophile. Tinkerer. Makes rare physical visits that are always an event.
- Communication: Teams-like video call overlay. Notification appears in screen corner: "Ty is calling..." Player accepts or dismisses. Floating video window: Florida light, shelves of records, headphones on. Rant, then the actual intel.
- Channel break (once): Triggered by player completing a financial software–related task that surfaces an anomaly Ty's been chasing. Not Act-locked — earned through gameplay progression. When the player's `slowbooks_trace` uncovers a specific transaction pattern (set as a StoryFlag), Ty shows up in person, unannounced. No call, no warning. What he found can't be explained over video.
- Tools given (financial/remote tier):
  - `slowbooks_trace` — follows money between departments; renders a flow-chart overlay showing OPERATION: STILL WATER's financial structure as it's uncovered
  - `remote_session` — Ty takes over a terminal for 60s from Florida; player watches him work and can ask him to pull one specific file
- Story role: Cracks the financial layer. Without Ty, the money flows stay hidden.

---

**MQ — "Mr. Cosplay"** | Social Engineering | *in-person, always in public*
- Personality: New guy. Everyone gives him shit. Doesn't care — he already has three DuckCorp employees convinced he's from the insurance company. Charisma that can absolutely backfire. When it does, he'll convince the user it worked anyway. Often does.
- Communication: In-person, always in a public space with ambient crowd noise. Player finds him mid-conversation with DuckCorp staff. After trust builds, MQ pulls the player aside in corridors.
- Channel break (once): Crisis point — MQ sends an in-game text message. He's been made. Player has to choose whether to cover for him or let him burn.
- Tools given (social/infiltration tier):
  - `social_proof` — MQ pre-primed a specific NPC to trust the player; that NPC's trust jumps +25 instantly
  - `cover_story` — one-use get-out-of-restricted-area free; if caught, MQ's pre-planted story kicks in
  - `warm_intro` — MQ introduces player to an NPC directly, skipping NEUTRAL state entirely
  - **Backfire mechanic**: Base ~15% random chance, modified by NPC personality type. Backfire raises heat on that NPC and makes MQ's tools unavailable for them. Recovery requires a tool from one of the other specialists — forcing inter-team dependency:
    - **Authority-Responsive NPC** (+20% backfire) — authority figures don't respond to charisma, they want credentials → recovery: Q's `audit_exemption` (official cover) or G's `helix_override`
    - **Fear-Driven NPC** (+15% backfire) — smoothness makes them more suspicious, not less → recovery: G's `krav_distraction` (pull their attention away) or AB's `fire_alarm_pull` (nuclear exit)
    - **Ego-Driven NPC** (-10% backfire) — likes being charmed, lower resistance
    - **Peer-Responsive NPC** (base rate) — neutral
  - The backfire chain is intentional design: MQ's failure is not a punishment, it's a puzzle that requires the player to have invested in other Helix relationships. Players who built only MQ get stuck. Players who built the team get options.
- Story role: Social intelligence. Also the one who gets into trouble at the worst moment and creates Act 2's central crisis.

---

**AB — "Baby Daddy"** | Hardware / Devices / Infiltration | *physical drops + rare visits*
- Personality: Speaks in riddles. Has worked across every industry under a different mask — not lying, just being whatever the environment requires. Infiltrates by *being without being* — no trace, no footprint, no clear entry point. The philosophy: every system has a door; every door has someone who left it open; the question is why they left. Self-insert character — modeled after the user. When AB shows up in person, the conversation is oblique and the player has to interpret.
- Communication: Physical drops — items appear at specific world locations (IT closet shelf, behind the copy machine) with a hand-written sticky note. The note is always a riddle, never an instruction. Player has to figure out what it means and how the item solves their current problem. Example drop note: *"The camera doesn't blink. But the light in front of it does. — AB"* → signal jammer inside. When AB visits in person it's a specific story scene, never routine.
- Channel break: N/A — the first in-person appearance IS the break from drops-only. AB visits when the situation has gone sideways and something improbable is the only option.
- Tools given (hardware/device tier):
  - `signal_jammer` — disables one camera node for 90s
  - `fire_alarm_pull` — evacuates one room for 2 minutes; everyone leaves, player has free access
  - `improvised_patch` — repairs a broken terminal to unlock a level or story beat
  - Custom Ducky payload templates — shortcut scripts for recurring challenge patterns
- Story role: Ghost. Shows up when things have gone sideways with something that shouldn't work but does. The tool always fits the problem perfectly; the player just has to read what AB left correctly.

---

### The Dual FSM (per Helix agent)

Each Helix member runs two axes in RelationshipSystem, not one:
- `helix_trust[npc_id]` — trust toward the player (existing system)
- `mission_pressure[npc_id]` — urgency of their mission objective (new field, 0–100)

Behavior matrix:
| Trust | Pressure | Result |
|---|---|---|
| High | Low | Full tool access, professional tier dialog |
| High | High | Agent slips — reveals something they shouldn't |
| Low | Low | Cautious, surface dialog only |
| Low | High | Agent goes cold — tools stop arriving, stops making contact |

This creates organic story beats from system state, not scripted reveals.

---

### Narrative Arc

**Act 1 (levels 1–30):**
- Levels 1–5: Tutorial, settle in, meet DuckCorp NPCs
- Level 5+: Shred folder discovery in break room (Sprint 3)
- Shortly after: DuckCorp memo → Helix audit announced
- G arrives in lobby (first in-person scene)
- Q sets up terminal in IT room — player finds it and types a response
- MQ spotted talking to a DuckCorp employee; later pulls player aside
- Ty's first call: "Hey so I was looking at the expense reports and — wait, let me tell you about this turntable I just got—"

**Act 2 (levels 31–70):**
- Player goes deeper into chosen department
- Ty's `slowbooks_trace` reveals money flows; department links emerge
- Q reveals STATIC connection via terminal
- G's channel break: terminal message, something wrong
- MQ's backfire moment: his cover story collapses, sends a text, player must choose
- AB makes first in-person appearance — brings hardware, breaks the 4th wall slightly
- Ty in-person visit triggered by a financial discovery that can't wait

**Act 3 (levels 71–100):**
- Helix audit cover is nearly blown
- G confronts player: pull out or go deeper
- Each Helix member has a crisis the player can help or ignore
- Player's assimilate/sabotage choice determines what happens to each of them

---

### Communication Channel — Implementation Plan

| Channel | Godot Implementation |
|---|---|
| G in-person | Extended NPC dialog system (existing), G added to NPC_DEFS with Helix flag |
| Q terminal | New scene: `HelixTerminal.tscn` — CanvasLayer, monospace Label history, LineEdit for player input, message queue |
| Ty video call | New UI: `TyCallUI.tscn` — CanvasLayer, animated avatar panel, accept/dismiss notification, message overlay |
| MQ floor | NPC_DEFS entry; MQ can initiate contact (player doesn't have to seek him) — new behavior flag `initiates_contact` |
| AB drops | Special Area2D pickup nodes in world + sticky note dialog; item delivered to Inventory |

---

### Sprint Plan (Helix integration)

- **Sprint 3** (queued): Inventory.gd + shred folder prop
- **Sprint 4**: G arrival scene (lobby) + Q terminal (IT room) — introduces Helix, sets up the two primary channels
- **Sprint 5**: Ty video call UI + MQ as roaming NPC + AB first drop placement
- **Sprint 6**: Full tool system — each Helix tool as usable Inventory item with WorldStateManager effects
- **Sprint 7**: Dual FSM (mission_pressure field in RelationshipSystem) + pressure-triggered dialog variants
- **Sprint 8**: Stealth system (AlertSystem, cameras, guards)
- **Sprint 9**: Endings (assimilate/sabotage branch, Helix outcome variants)

---

## Decisions Log

> Record significant design/architecture decisions and WHY, so we don't relitigate them.

| Date | Decision | Reason |
|------|----------|--------|
| (pre-2026-05-26) | Migrated from procedural drawing to LPC sprite art | Better visual quality; commit `bfd18aa` |
| (pre-2026-05-26) | All scene building done in code (not .tscn editor) | Keeps everything version-controllable and scriptable |
| (pre-2026-05-26) | TileMapLayer nodes pre-placed in Main.tscn; painted in `_ready()` | Godot 4.3+ requires TileMapLayer; painting in code avoids editor-state drift |

---

## Planned Rework

> Direction confirmed 2026-05-26. Story premise still TBD — pick up next session.

### Goal
Move from "walk to desk → solve puzzle → repeat" to a narrative-driven game with real stakes and interlocking systems.

### Confirmed Game Loops to Add
1. **Stealth / detection** — security cameras, guards, or alert states; getting caught has consequences
2. **NPC relationships** — build trust with NPCs who give hints, access cards, or story beats; talking matters
3. **Item / inventory system** — collect USB drives, keycards, tools; some puzzles require items, not just scripting
4. **Branching choices / consequences** — decisions affect story outcome, NPC trust, available endings

### Story Premise — CONFIRMED

**OPERATION: STILL WATER**
*"A still population requires no management. It requires only maintenance."*

Player is a broke IT tech — wife, newborn twins, economy in the toilet. Lands a job at DuckCorp. Does mundane IT tasks (printer paper, water cooler, service tickets). Finds a "SHRED IMMEDIATELY" folder in the break room. Each page shredded reveals a deeper layer of a 5-branch civilizational control operation.

After the tutorial, the player picks a department to infiltrate. Each department controls one branch. All five feed each other synergistically.

**Two morally grey endings:** Assimilate into the upper ranks (family safe, but you ARE the machine now) or Sabotage the company (you stop the plan, but collateral damage is real and the families regroup).

---

### The Five Departments (Post-Tutorial Department Pick)

| Department | Cover Role | Codename | What It Actually Does |
|---|---|---|---|
| Asset Recovery Division | Processing distressed-property loan files | CLEAN SLATE | Engineered economic collapse → buy all distressed infrastructure at pennies on the dollar → permanently indebted population |
| Infrastructure Optimization Group | Routine IT maintenance scheduling for clients | GROUNDWORK | Behavioral modification pipeline in all client IT → sells guaranteed outcomes (elections, compliance) → economy "tuned" for maximum compliance-without-revolt |
| Long-Term Systems Planning | 10-year infrastructure projection reports | SUCCESSION | 40-year elite project to own all critical dependencies before governments fail → democracy becomes procedurally intact, functionally inert |
| Learning Outcomes & Content Services | Reformatting curriculum packages for digital delivery | SHALLOW END | Controls 94% of school curriculum + dominant content algorithms → destroys critical thinking and sustained attention from childhood → population cannot comprehend what is being done to them |
| Integrated Nutrition Solutions | Compliance docs for food-grade processing facilities | FEEDSTOCK | Pharmaceutical/industrial waste reprocessed into food → engineered micronutrient deficiency (iodine, magnesium, zinc, omega-3) → population is cognitively fatigued and emotionally reactive → GROUNDWORK requires 40% less steering bandwidth |

### Synergy (How They Feed Each Other)
- FEEDSTOCK → GROUNDWORK (less steering cost), SHALLOW END (easier conditioning)
- SHALLOW END → GROUNDWORK (pre-softened audience), SUCCESSION (timeline blindness)
- GROUNDWORK → CLEAN SLATE (controlled collapse), SUCCESSION (legitimacy cover)
- CLEAN SLATE → FEEDSTOCK (crisis drives govt food contracts), SUCCESSION (asset transfer)
- SUCCESSION → all branches (long capital, coordinates everything)

### The Shred Pages (each branch has 3, escalating in horror)
- Page 1: Suspicious but deniable
- Page 2: Clearly wrong
- Page 3: Civilizational scale
- Final assembled page: *"The target condition is not a population that cannot revolt. It is a population that does not experience revolt as a thinkable thought."*

---

## Game Design Research (2026-05-27)

> Distilled from 3 research agents studying reference games. Feed these directly into Sprint designs.

### Core Design Principles (one per reference game)
- **Disco Elysium**: failure should be interesting, not just punishing
- **Hacknet**: if it feels real, players will learn it
- **Uplink**: cleanup after the hack is as tense as the hack itself
- **Hitman**: knowledge persists across attempts and compounds into power
- **Splinter Cell**: model the physics honestly, players will use it creatively
- **Deus Ex**: every obstacle needs a solution SPACE, not a single solution
- **Undertale**: the game doing the feeling FOR the player is a failure
- **Zelda ALttP**: introduce → use → master, one tool per dungeon/floor
- **Stardew Valley**: trust unlocks must feel emotionally appropriate to the relationship stage
- **The Last of Us**: make the player PERFORM the act, not watch it

### Top 10 Mechanics to Implement

1. **Tools as Verbs** — Intercept/Spoof/Clone apply freely anywhere the world permits. New tools open new world-classes, don't upgrade numbers. Old floors become interesting again.
2. **Dual-Layer NPCs** — Surface behavior + hidden internal state. "Profile" tool reveals the inner layer (occasionally required). Full NPC state machine: first contact → allied → suspicious → compromised → gone. Empty desks are consequences.
3. **Trust Calibrated to Stage** — Low = professional frustrations. Mid = personal grievances about the company. High = complicity. Content matches what a real person at that trust level would share.
4. **Work Shift Pacing** — Work hours: social engineering available, snooping risky. After hours: physical infiltration available, social engineering off. Shift change is mechanical AND narrative.
5. **Introduce → Use → Master per Floor** — Each floor built around one new tool. First third: navigate to it. Second third: low-stakes uses. Final third: confrontation requiring creative use. Player owns it by exit.
6. **Behavior-Defined Route** — Assimilate/sabotage axis tracks deliberate choice patterns (deception count, force count, witnesses left). Locks only when pattern is unambiguous. Players don't accidentally slide.
7. **Living Antagonist** — Main antagonist appears multiple times, dialogue reflects what player specifically did. Careful play = dismissive antagonist = creepy reward.
8. **Gates as Story Events** — Never "you need Level 3 clearance." Always "the wing is on lockdown after a security incident." Same restriction, experienced as story beat.
9. **Before/After Space Duality** — One significant space visited twice: before and after a major player action. Same layout, different emotional register. Empty desk IS the consequence.
10. **Meta-Awareness Moment** — One beat where the game acknowledges save/load. Security log recording an "anomalous session attempt." Costs nothing, outsized impact.

**Bonus — True Ending**: Players who explored all factions and found full conspiracy trail get variant ending revealing who was pulling the strings of the people pulling the strings.

### The Three-System Dependency Chain

```
SOCIAL ENGINEERING
  → NPC profiling (4 personality types: Authority / Fear / Ego / Peer-Responsive)
  → Intelligence extracted: keypad codes, guard schedules, USB delivery windows
        ↓
PHYSICAL SECURITY
  → Camera system (3 layers: coverage map / DVR node / live monitoring)
  → Guard schedules as intelligence product (full schedule = safe corridor on map)
  → Keypad codes always found in world, never given by UI
  → RFID cloning (proximity scanner craftable item, card expires when reported missing)
        ↓
HARDWARE HACKING
  → DuckyScript primitives collected as in-world items
  → Knowledge gates payloads (can't use commands you haven't learned)
  → Tools are consumable, delivery is physical, retrieval is risky
  → Test bench at home base to verify payloads before deployment
  → Credentials/backdoors gained → unlock next SE target → cycle repeats higher
```

### Environmental Storytelling (TLOU)
- "Desk archaeology": 3–5 interactables per NPC desk with Act-aware flavor text. Same object, new meaning after player gains context.
- "Consequence echo": after NPC fired/arrested by player action, ambient dialog from other coworkers references them while player is doing something else. Unannounced.
- "Routine anchors": Act 1 establishes 2–3 recurring daily tasks. Act 2 those tasks still happen — standup while mid-infiltration, team lunch with the coworker you just betrayed.

### Crafting Design
- Components come from contextually appropriate in-world locations (no random loot tables)
- Workstations in the world unlock tool tiers (IT closet = network exploits, janitor storage = keycard cloning)
- Tools are consumable/risk-carrying — spoofed badge flagged after one use, keylogger must be physically retrieved
- Recipe unlocks distributed across ALL systems: some from NPC trust, some from exploration, some from decrypting stolen docs

---

## Stardew Valley Research (2026-05-27)

> Core principle: the game withholds information, lets time consume it, and teaches through regret rather than warning.

### Story Without Exposition
- World-state changes ARE the story — no narrator needed. Physical environment changes when player acts.
- Assimilate/sabotage fork triggered by ONE contextually ambiguous early action (accepting a promotion, forwarding a document). No "are you sure?" prompt. Weight comes from accumulated context.
- NPCs react to the world BEFORE player commits — janitor says "ever notice server logs are clean the day after Morris visits?" is pre-choice emotional investment.
- `WorldStateManager` autoload: all dialogue, tiles, and building states query this at scene load. NPC cross-awareness handled by the same flag system.

### Choices and Consequence
- Permanent vs. reversible choices separated by COST, not warning labels. Player discovers what was permanent after the window closes.
- Deep NPC alliance physically changes the world (door propped, name on access list). Betraying ally = hostile entity, access revoked, their desk gone.
- Dialogue stakes vary with no labeling. Most wrong answers = minor penalty. A few = arc permanently blocked. Player never knows in advance.
- NPC relationship FSM: `NEUTRAL → FRIENDLY → TRUSTED → ALLIED → BETRAYED → HOSTILE`. Permanent blocks set as flags at the blocking moment.

### Missable Content
- One-time NPC windows: specific shift where someone works late alone, their last day before transfer, night they're vulnerable. Miss it — arc is closed forever.
- `ShiftEventScheduler`: secret events (contractor, late-working whistleblower) are NEVER on the in-game calendar. Only official events show. Players who patrol at shift start catch them.
- "Rare Seed" equivalent: specific evidence file or access key only exists during a defined window. After the window, purged.
- "Permanent block": getting caught doing X before doing Y locks Y forever.

### Time / Shift as Urgency Engine
| Stardew | Office Game |
|---|---|
| 6AM–2AM clock never pauses | Shift timer runs real-time, never pauses outside menus |
| Can't do everything in one day | Can't social-engineer + access server + attend all-hands in one shift |
| Passing out = named character finds you + penalty | Getting caught = named guard, consequence specific to relationship with them |
| Late sleep = reduced energy next day | Noisy shift raises heat level → next shift smaller blind spots, NPCs less willing |
| Crop deadline = plant too late, it dies | Act-locked objectives: evidence file shredded at Act 3, NPC reassigned if arc not reached |
| World looks different each season | Office looks different each act: construction, empty desks, new security |

**Godot:** `ShiftClock` autoload — ticked by delta, actions call `ShiftClock.consume(seconds)`. `heat_level` in `WorldStateManager` persists across shifts, read by `AIPatrolBehavior` to modulate guard density and camera sensitivity.

---

## Pixel Art Style Guide (2026-05-27)

### The Three Rules
1. **Cold architecture, warm protagonists.** Every wall/floor/ceiling = cold palette. Every human body and personal object = warm palette. As the game progresses, cold expands, warmth retreats.
2. **The danger red is sacred.** `#d64045` appears on EXACTLY THREE THINGS: the shred folder, security camera alert LED, emergency/exit signs. Nothing else. Subconscious threat register before conscious processing.
3. **Animate emotion, not detail.** 34px sprites cannot carry complex emotion through static art. Invest in: reaction animations (2–3 frames), postural states (player walks differently after reading shred pages), environmental changes (chair pushed back, cold coffee machine). Emotion lives in motion and world, not in texture.

### Style Target
**Katana Zero** (dark corporate architecture + shape-language readability) + **Celeste** (zone-state color management) + **Undertale** (animation-over-detail expressiveness).

NOT: HD-2D, bright JRPG, chibi, anime. Goal: "this office looks almost exactly like somewhere you've worked, except the light is slightly too cold and the shadows are slightly too long."

### Master Palettes (14 colors each)

**DAY SHIFT:**
| Role | Hex |
|---|---|
| Corporate Black (void/hard shadow) | `#0d0d14` |
| Dim Basalt (shadow/dark floor) | `#1e1e2e` |
| Slate Dread (mid shadow/furniture shadow) | `#2d2d3f` |
| Cold Plaster (wall base lit) | `#4a4855` |
| Pale Plaster (wall highlight) | `#6e6c7e` |
| Institutional Gray (floor base carpet) | `#3d3b4a` |
| Worn Carpet (floor highlight) | `#56546a` |
| Cubicle Beige (furniture base) | `#4f4038` |
| Faded Oak (furniture highlight) | `#7a6555` |
| Sick Yellow-White (fluorescent light) | `#e8e4c0` |
| Terminal Green (screen glow — screens ONLY) | `#3ddc84` |
| Living Flesh (player skin base) | `#c8956c` |
| Flesh Shadow (player skin shadow) | `#8b5e3c` |
| Exit Red-Orange (DANGER — 3 uses only) | `#d64045` |

**AFTER HOURS** — same 14 slots, architecture shifts cold/blue. Furniture (`#4f4038`, `#7a6555`) and player skin UNCHANGED. Player is the only warmth left in a cold world.

**Godot implementation:** CanvasModulate on scene root. Day: `Color(1.0, 0.95, 0.85)`. After-hours: `Color(0.65, 0.72, 0.95)`. Tween between them over 3 seconds at shift change. One node change transforms the entire scene.

### Lighting in Godot 4
- CanvasModulate for ambient (day/night shift as above)
- PointLight2D on every active monitor: color `#3ddc84`, energy 0.3, shadow enabled, Filter: None (pixel-crisp shadows)
- PointLight2D on player: color `#f5e6c8`, energy 0.5 — disabled in Act 1 (day), enabled Act 2+ (player is now a warm light in a cold world)
- LightOccluder2D on wall collision shapes → light spills through half-open doors
- Security camera FOV: Polygon2D in `#4488cc` at 20% alpha — pure geometry, no lighting engine needed

### Character Specs
- Head = 22–24px of 64px frame (40% of sprite) — enough pixels for 2px eyes, 1px eyebrow tilt, 3px mouth shape
- Outline: hard `#0d0d14` base, `#2d2d3f` on lit top/left edges (selective outline = implied 3D form)
- Animation: 6-frame walk at 8fps, 4-frame idle at 4fps, 3-frame react at 12fps
- Player shirt color `#56546a` (same family as floor tiles) — they belong in this environment. Contrast is the warm skin.
- Security guard uniform uses `#1e2235` (Night Abyss / after-hours color) even during day shift — visual foreshadowing
- Management shirt `#e8e4c0` (same as fluorescent lights) — they ARE the system

### Key Asset Specs
- **Shred folder**: 16×12px, body color `#d64045` (danger red). ONLY non-emergency use of this color. Player registers threat before reading label.
- **Security camera**: 16×16px, body `#1e1e2e`, lens `#0d0d14` with 1px specular. LED: green=active, red=alert, dark=disabled. 8-directional sprites for rotation.
- **USB Rubber Ducky**: 8×4px. White plastic body `#e8e4c0`, gold connector `#7a6555`, tiny green LED `#3ddc84`. Display in UI at 400% nearest-neighbor.
- **Monitor**: flat `#1e1e2e` rectangle + `#3ddc84` glow sprite layered above. Simpler and more readable than LPC monitors.

### Asset Upgrade Priority
1. Player character (every frame, defines identity)
2. Floor tiles (most screen pixels of any asset class)
3. Monitor/workstation props (primary narrative devices)
4. Security camera (narratively critical, small, fast to draw)
5. Wall tiles (can use recolored LPC longer)
6. NPC characters (replace management+security first)

### Tools
- **Aseprite** — primary pixel art tool
- **Retro Diffusion** (retrodiffusion.ai) — AI pixel art, good for bulk props (trash cans, filing cabinets, clutter). Generate → palette-reduce to 14-color master → fix in Aseprite.
- **PixelLab** (pixellab.ai) — consistent style across NPC set. Use player sprite as reference for NPC generation.
- **AVOID**: Midjourney/DALL-E/SD base models — no pixel grid understanding, produces anti-aliased faux-pixel art.
- Non-artist can produce: floor/wall tiles, simple props, UI elements. Hire for: player animations, facial micro-animation, key story-beat art.

---

## Known Issues / Bugs

> Running list — check off when fixed.

- [ ] (none recorded yet — add as discovered)

---

## How to Run

1. Open Godot 4.6 Mono
2. Open `project.godot`
3. Press **F5** — starts from `DreamSequence.tscn`

---

## Git Branch

Currently on: `v2-sprite-art`
