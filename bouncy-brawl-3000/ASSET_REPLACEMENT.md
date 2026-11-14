# ASSET REPLACEMENT GUIDE — BOUNCY BRAWL 3000

This document describes all character sprites and assets in the project, their exact directory paths, sheet dimensions, frame counts, and animation requirements. All character sprites should be designed in pixel art style.

---

## 1. Player Character: The Knight

- **Folder Path:** `res://Assets/knight/120x80_PNGSheets/`
- **Frame Size:** `120 x 80` pixels per frame.
- **Visual Requirement:** The knight must visibly carry a sword attached to the character for close-range melee combat.
- **Texture Filter:** `Nearest` (set in `player.tscn`).

### Sprite Sheets and Animations

| Animation | File Name | Sheet Dimensions | Frame Count | Frame Size | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Idle** | `_Idle.png` | 1200 x 80 px | 10 frames | 120 x 80 px | Looping idle breathing/stance |
| **Run** | `_Run.png` | 1200 x 80 px | 10 frames | 120 x 80 px | Looping ground run cycle |
| **Attack** | `_Attack.png` | 480 x 80 px | 4 frames | 120 x 80 px | Frame 0: windup, Frames 1-2: active swing window (hitbox enabled), Frame 3: recovery |
| **Jump** | `_Jump.png` | 360 x 80 px | 3 frames | 120 x 80 px | Upward ascending jump |
| **Fall** | `_Fall.png` | 360 x 80 px | 3 frames | 120 x 80 px | Downward descent / airtime |
| **Hit** | `_Hit.png` | 120 x 80 px | 1 frame | 120 x 80 px | Hit reaction / stagger |
| **Death** | `_Death.png` | 1200 x 80 px | 10 frames | 120 x 80 px | Defeat animation |

---

## 2. Boss 1: Mage

- **Folder Path:** `res://Assets/Evil mage/`
- **Frame Size:** `250 x 250` pixels per frame.
- **Visual Requirement:** Evil magic caster with robe, staff/hands casting magical fireballs.
- **Texture Filter:** `Nearest` (set in `mage.tscn`).

### Sprite Sheets and Animations

| Animation | File Name | Sheet Dimensions | Frame Count | Frame Size | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Idle** | `Idle.png` | 2000 x 250 px | 8 frames | 250 x 250 px | Looping idle stance |
| **Run** | `Run.png` | 2000 x 250 px | 8 frames | 250 x 250 px | Ground movement |
| **Attack** | `Attack1.png` | 2000 x 250 px | 8 frames | 250 x 250 px | Fireball casting gesture |
| **Jump** | `Jump.png` | 500 x 250 px | 2 frames | 250 x 250 px | Upward movement |
| **Fall** | `Fall.png` | 500 x 250 px | 2 frames | 250 x 250 px | Downward fall |
| **Hit** | `Take hit.png` | 750 x 250 px | 3 frames | 250 x 250 px | Flinch / damage reaction |
| **Death** | `Death.png` | 1750 x 250 px | 7 frames | 250 x 250 px | Defeat animation |

---

## 3. Boss 2: Captain Canda

- **Folder Path:** `res://Assets/captain_canda/`
- **Frame Size:** `120 x 80` pixels per frame.
- **Visual Requirement:** Canadian-themed superhero or warrior visibly carrying a shield with a red maple leaf design.
- **Texture Filter:** `Nearest` (set in `captain_canda.tscn`).

### Sprite Sheets and Animations

| Animation | File Name | Sheet Dimensions | Frame Count | Frame Size | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Idle** | `idle.png` | 960 x 80 px | 8 frames | 120 x 80 px | Heroic standing stance |
| **Run** | `run.png` | 960 x 80 px | 8 frames | 120 x 80 px | Running cycle |
| **Attack** | `attack.png` | 720 x 80 px | 6 frames | 120 x 80 px | Shield throw windup and toss |
| **Jump** | `jump.png` | 360 x 80 px | 3 frames | 120 x 80 px | Upward jump |
| **Fall** | `fall.png` | 360 x 80 px | 3 frames | 120 x 80 px | Downward descent |
| **Hit** | `hit.png` | 240 x 80 px | 2 frames | 120 x 80 px | Hit reaction |
| **Death** | `death.png` | 960 x 80 px | 8 frames | 120 x 80 px | Knockout animation |

---

## 4. Boss 3: Shoebum

- **Folder Path:** `res://Assets/shoebum/`
- **Frame Size:** `120 x 80` pixels per frame.
- **Visual Requirement:** Distinct brawler / eccentric opponent with oversized shoes or slap stance.
- **Texture Filter:** `Nearest` (set in `shoebum.tscn`).

### Sprite Sheets and Animations

| Animation | File Name | Sheet Dimensions | Frame Count | Frame Size | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Idle** | `idle.png` | 960 x 80 px | 8 frames | 120 x 80 px | Brawler idle stance |
| **Run** | `run.png` | 960 x 80 px | 8 frames | 120 x 80 px | Charging run |
| **Attack** | `attack.png` | 720 x 80 px | 6 frames | 120 x 80 px | Slap and ground stomp attack |
| **Jump** | `jump.png` | 360 x 80 px | 3 frames | 120 x 80 px | Ascending leap |
| **Fall** | `fall.png` | 360 x 80 px | 3 frames | 120 x 80 px | Heavy descent |
| **Hit** | `hit.png` | 240 x 80 px | 2 frames | 120 x 80 px | Stumble reaction |
| **Death** | `death.png` | 960 x 80 px | 8 frames | 120 x 80 px | Stagger and fall defeat |

---

## 5. Non-Pixelated UI and Environment Guidelines

Per project specifications:
- **Environment & Scenery:** `res://Assets/Bg/tileset.png` and background graphics remain crisp and high-resolution; do not apply global pixelation shaders or canvas item filter overrides to them.
- **HUD & Menus:** `res://scenes/ui/` remain crisp vector/text font rendering with default texture filtering.
- **Only Characters:** Character sprites use `texture_filter = TEXTURE_FILTER_NEAREST` on their respective `AnimatedSprite2D` nodes.
