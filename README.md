# Ducky Script: Zero to Hero

A top-down 2D office hacking game built in **Godot 4.6**, designed to teach USB Rubber Ducky payload scripting through 100 progressive puzzle levels.

## About

You play as a hacker navigating a fully-realized office building, interacting with workstations and solving DuckyScript coding challenges to unlock new areas. The game progresses from basic keystrokes all the way to advanced payload techniques.

## Gameplay

- Explore an office map across 10 departments (Open Office → IT → Server Room → Management → NOC → Security → R&D → Design → Executive → Vault)
- Approach workstations and press **E** to interact
- Solve DuckyScript coding challenges to earn XP and unlock the next room
- Talk to 8 named NPCs for hints and lore (also with **E**)
- Progress is saved automatically

## Tech Stack

- **Engine:** Godot 4.6.2 Mono (all scripts are GDScript)
- **Art style:** Procedural — no external sprites or textures; fully drawn in code with a Stardew Valley-inspired office aesthetic

## Project Structure

```
scripts/
  Main.gd       — Map renderer, wall/door physics, workstation & NPC interaction
  Player.gd     — CharacterBody2D with Camera2D, movement & interaction logic
  MissionUI.gd  — Coding challenge overlay (TextEdit + run/skip/hint)
  GameState.gd  — Autoload; save/load via user://ducky_save.json, XP tracking
  LevelData.gd  — Autoload; all 100 level definitions and solution checkers
Main.tscn       — Root scene
```

## Getting Started

1. Install [Godot 4.6](https://godotengine.org/download/)
2. Clone this repo
3. Open `project.godot` in Godot
4. Press **F5** to run

## License

MIT
