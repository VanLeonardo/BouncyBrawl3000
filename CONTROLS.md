# Bouncy Brawl 3000 — Controls & Input Guide

*Bouncy Brawl 3000* features native, cross-platform controller and keyboard support powered by Godot 4.7.
It seamlessly supports Xbox, PlayStation (DualShock / DualSense), Nintendo Switch Pro, and generic XInput / DirectInput controllers with automatic device hotplugging, analog deadzones, and full two-player local multiplayer isolation.

---

## 1. Single Player / Player 1 Default Controls

| Action | Keyboard | Xbox Gamepad | PlayStation Gamepad | Generic Gamepad |
|---|---|---|---|---|
| **Move Left / Right** | `A` / `D` or `←` / `→` | Left Stick / D-Pad | Left Stick / D-Pad | Left Stick / D-Pad |
| **Jump** | `Space` / `W` / `↑` | `A` button | `✕` (Cross) | Button 0 / South |
| **Air Jump** | Double-tap `Space` / `W` | Double-tap `A` | Double-tap `✕` | Double-tap South |
| **Drop Through Platform** | `S` + `Space` or `↓` on one-way | `Down` + `A` or Left Stick `↓` | `Down` + `✕` or Left Stick `↓` | `Down` + Button 0 |
| **Melee Attack** | `J` or `Z` | `X` button | `▢` (Square) | Button 2 / West |
| **Pause Game** | `Escape` or `P` | `Start` / `Menu` | `Options` | Button 6 / Start |

*Attack costs 18 stamina and deals 15 damage + 8% knockback.*

---

## 2. Local Two-Player Multiplayer

The game supports simultaneous 2-player local play with separate device assignments and isolated input streams.

### Player 2 Controls

| Action | Secondary Keyboard | Xbox Gamepad (P2) | PlayStation Gamepad (P2) |
|---|---|---|---|
| **Move Left / Right** | Numpad `4` / `6` or `J` / `L` | Left Stick / D-Pad (Dev 1) | Left Stick / D-Pad (Dev 1) |
| **Jump** | Numpad `0` / `Enter` or `/` | `A` button (Dev 1) | `✕` (Cross) (Dev 1) |
| **Drop Through Platform** | Numpad `5` / `2` or `K` | `Down` + `A` (Dev 1) | `Down` + `✕` (Dev 1) |
| **Attack** | Numpad `1` or `.` | `X` button (Dev 1) | `▢` (Square) (Dev 1) |
| **Pause** | Numpad `+` or `\` | `Start` (Dev 1) | `Options` (Dev 1) |

---

## 3. Multiplayer Modes & Device Isolation

The `InputManager` (`res://scripts/combat/input_manager.gd`) manages device routing via three operational modes:

1. **`MultiplayerMode.AUTO` (Default):**
   - **0 Controllers connected:** Player 1 uses primary keyboard (`WASD` / `Space` / `J`), Player 2 uses secondary keyboard (`Numpad` / `IJKL`).
   - **1 Controller connected:** Player 1 uses either the primary keyboard or Controller 0. Player 2 uses the secondary keyboard.
   - **2+ Controllers connected:** Player 1 is assigned Controller 0 (`device: 0`), Player 2 is assigned Controller 1 (`device: 1`).

2. **`MultiplayerMode.KEYBOARD_AND_CONTROLLER`:**
   - Player 1 is assigned exclusively to the keyboard (`device: -1`).
   - Player 2 is assigned to the first connected gamepad (`device: 0`).
   - Gamepad 0 inputs are strictly blocked from triggering Player 1 actions.

3. **`MultiplayerMode.TWO_CONTROLLERS`:**
   - Both players must use distinct gamepads (`device: 0` for P1, `device: 1` for P2).

---

## 4. UI & Menu Navigation

All menus (Title Screen, Controls Modal, Pause Menu, Victory/Defeat screen) support full controller and keyboard navigation:

| UI Action | Keyboard | Gamepad |
|---|---|---|
| **Navigate Up / Down** | `W` / `S` or `↑` / `↓` | Left Stick `↑` / `↓` or D-Pad `↑` / `↓` |
| **Select / Confirm** | `Enter` or `Space` | `A` / `✕` (Bottom Action Button) |
| **Back / Cancel / Close** | `Escape` | `B` / `◯` (Right Action Button) |
| **Pause / Resume** | `Escape` or `P` | `Start` / `Options` |

---

## 5. Technical Specifications

- **Analog Deadzone:** Configured to `0.25` on both horizontal (`JOY_AXIS_LEFT_X`) and vertical (`JOY_AXIS_LEFT_Y`) axes. Stick tilt below 25% produces zero velocity, eliminating analog stick drift. Proportional velocity is applied beyond the deadzone.
- **Hotplugging & Disconnect Safety:** When any controller is disconnected during gameplay, `_release_all_player_actions()` immediately releases all pressed actions across P1, P2, and UI. This prevents characters from getting stuck walking or repeating attacks.
- **Dynamic Prompts & Device Detection:** The title screen dynamically updates its badge based on the active input device (e.g., `🎮 ACTIVE INPUT: CONTROLLER` vs `⌨ ACTIVE INPUT: KEYBOARD`).
- **InputMap Persistence:** Default controller and keyboard bindings are persisted directly in `project.godot` under `[input]`.
