# Project Mantis

> *"A still population requires no management. It requires only maintenance."*

---

## What It Is

Project Mantis is a **cozy life sim / adventure RPG** with a narrative-driven stealth and conspiracy layer underneath, built in **Godot 4.6 Mono** (GDScript).

You play a broke IT tech — wife, newborn twins, economy in the toilet. You land a job at DuckCorp. You do mundane work: printer paper, water cooler, service tickets. Then you find a folder marked **SHRED IMMEDIATELY**.

The game weaves together four pillars:

- **Life sim loop** — home, town, daily office routine; relationships with your wife, coworkers, and a covert operative team (Helix)
- **Social engineering** — build NPC trust, extract intel, navigate a dual relationship/pressure system per Helix agent
- **Physical infiltration** — stealth, security cameras, guard patrol AI, escalating heat/alert system
- **Hacking** — DuckyScript puzzles, financial tracing, terminal access, hardware drops

The cozy/human layer and the conspiracy/stealth layer are intentional and complementary. Neither crowds out the other.

---

## The Conspiracy — OPERATION: STILL WATER

Five departments. Each controls one branch of a civilizational control operation.

| Department | Codename | What It Actually Does |
|---|---|---|
| Asset Recovery Division | CLEAN SLATE | Engineered economic collapse → buy all distressed infrastructure at pennies on the dollar |
| Infrastructure Optimization Group | GROUNDWORK | Behavioral modification pipeline in all client IT systems |
| Long-Term Systems Planning | SUCCESSION | 40-year elite project to own all critical dependencies before governments fail |
| Learning Outcomes & Content Services | SHALLOW END | Controls 94% of school curriculum — destroys critical thinking from childhood |
| Integrated Nutrition Solutions | FEEDSTOCK | Pharmaceutical waste reprocessed into food → engineered cognitive fatigue |

All five feed each other. The final assembled shred page reads:

> *"The target condition is not a population that cannot revolt. It is a population that does not experience revolt as a thinkable thought."*

---

## The Helix Team

After 5 levels solved, DuckCorp announces a compliance audit. The auditors — Helix Security — are not what they seem.

| Agent | Role | Channel |
|---|---|---|
| **G** — The Wizard | Owner, ex-model, krav maga | In-person only. Shows up when G decides. |
| **Q** — Dungeon Master | Sysadmin, homelab builder, D&D guy | Secure IRC terminal in the IT room |
| **Ty** — The Remote Rogue | Finance, autistic hyperfocus on Slowbooks | Video call from Florida. Rants first, intel second. |
| **MQ** — Mr. Cosplay | Social engineering, new guy | In-person, always in public. Can backfire. |
| **AB** — Baby Daddy | Hardware, infiltration, speaks in riddles | Physical drops with sticky note clues |

Each agent runs a dual FSM: **trust** (toward the player) × **mission pressure** (urgency). High trust + high pressure = the agent slips and reveals something they shouldn't. Low trust + high pressure = they go cold and stop making contact.

---

## Scene Flow

```
DreamSequence → IntroAnimation → Interview → Home → Town → Main (office) → Ending
```

---

## Systems Built

| System | Status |
|---|---|
| Story flags + save/load | Complete |
| Department selection (Interview scene) | Complete |
| NPC relationship system (trust tiers + FSM) | Complete |
| Dual FSM: helix_trust + mission_pressure | Complete |
| Inventory system + item HUD | Complete |
| All 5 Helix communication channels | Complete |
| Q IRC terminal + QUILL AI companion | Complete |
| Ty video call UI | Complete |
| MQ roaming NPC + crisis arc | Complete |
| AB physical drops + sticky note riddles | Complete |
| Tool use system (Tab cycle, Del use) | Complete |
| Slowbooks financial overlay | Complete |
| Alert system (heat 0–100, CLEAR/SUSPICIOUS/ALERT) | Complete |
| Security cameras + FOV detection | Complete |
| Guard patrol AI (4 guards, weaknesses, dialog) | Complete |
| D&D mini-game (every 7th shift, trait rewards) | Complete |
| D&D traits wired into base systems | Complete |
| Shift event scheduler (6 missable events) | Complete |
| Day/night cycle + dynamic weather | Complete |
| Town + Home scenes (full world loop) | Complete |
| Endings — assimilate / sabotage branches | Complete |
| Dream sequence procedural intro | Complete |

---

## Endings

Two morally grey outcomes determined by accumulated behavior — no explicit choice prompt:

- **Assimilate** — family safe. You are the machine now.
- **Sabotage** — you stop the plan. Collateral damage is real. The families regroup.

A **true ending** exists for players who uncover all five conspiracy threads.

---

## How to Run

1. Open **Godot 4.6 Mono**
2. Open `project.godot`
3. Press **F5** — starts from `DreamSequence.tscn`

---

## Stack

- Engine: Godot 4.6 Mono
- Language: GDScript (no C#)
- Branch: `v2-sprite-art`
- Art: LPC character/office tileset + procedural draw for UI and cutscenes
