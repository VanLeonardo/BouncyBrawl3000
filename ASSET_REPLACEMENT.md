# ASSET REPLACEMENT GUIDE — BOUNCY BRAWL 3000

This document describes all character sprites, projectiles, and UI assets in the project, their exact directory paths, dimensions, frame counts, and animation requirements. All character and combat projectile sprites are configured in pixel art style with `Nearest` filtering.

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

## 2. Boss 1: Mage & Fireball

- **Folder Path (Character):** `res://Assets/Evil mage/`
- **Frame Size:** `250 x 250` pixels per frame.
- **Visual Requirement:** Evil magic caster with robe, casting magical fireballs.
- **Texture Filter:** `Nearest` (set in `mage.tscn`).

### Mage Sprite Sheets and Animations

| Animation | File Name | Sheet Dimensions | Frame Count | Frame Size | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Idle** | `Idle.png` | 2000 x 250 px | 8 frames | 250 x 250 px | Looping idle stance |
| **Run** | `Run.png` | 2000 x 250 px | 8 frames | 250 x 250 px | Ground movement |
| **Attack** | `Attack1.png` | 2000 x 250 px | 8 frames | 250 x 250 px | Fireball casting gesture |
| **Jump** | `Jump.png` | 500 x 250 px | 2 frames | 250 x 250 px | Upward movement |
| **Fall** | `Fall.png` | 500 x 250 px | 2 frames | 250 x 250 px | Downward fall |
| **Hit** | `Take hit.png` | 750 x 250 px | 3 frames | 250 x 250 px | Flinch / damage reaction |
| **Death** | `Death.png` | 1750 x 250 px | 7 frames | 250 x 250 px | Defeat animation |

### Fireball Projectile

- **Folder Path:** `res://Assets/New Assets/Fire Ball Asset/FB00_nyknck/FB00_nyknck/`
- **Frames:** `FB001.png`, `FB002.png`, `FB003.png`, `FB004.png`, `FB005.png`
- **Frame Dimensions:** `64 x 32` pixels each (ARGB with alpha).
- **Animation:** 5-frame looping animation at 12 FPS, horizontal flame trail facing right by default, auto-flipped horizontally when cast leftwards.
- **Scene:** `res://scenes/effects/fireball.tscn`

---

## 3. Boss 2: Captain Canda & Boomerang Shield

- **Folder Path (Base Assets):** `res://Assets/New Assets/Cap Canda Assets/Captain Canada/`
- **Base Character File:** `CaptainCanada.png` (`32 x 32` pixels).
- **Shield Projectile File:** `Shield.png` (`32 x 32` pixels, 11px circular shield with red rim and maple leaf emblem).
- **Maple Emblem File:** `Maple.png` (`32 x 32` pixels).
- **Animation Sheet Folder:** `res://Assets/captain_canda/`
- **Texture Filter:** `Nearest` (set in `captain_canda.tscn` and `boomerang_shield.tscn`).

### Captain Canda Animations

| Animation | File Name | Sheet Dimensions | Frame Count | Frame Size | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Idle** | `canda_idle.png` | 32 x 32 px | 1 frame | 32 x 32 px | Base heroic posture |
| **Run** | `canda_run_sheet.png` | 128 x 32 px | 4 frames | 32 x 32 px | Looping 4-frame run cycle with stride and torso bob |
| **Attack** | `canda_throw_sheet.png` | 96 x 32 px | 3 frames | 32 x 32 px | Frame 0: shield windup, Frame 1: thrust throw, Frame 2: release |
| **Jump** | `canda_jump.png` | 32 x 32 px | 1 frame | 32 x 32 px | Airborne posture |
| **Fall** | `canda_fall.png` | 32 x 32 px | 1 frame | 32 x 32 px | Descent posture |
| **Hit** | `canda_hit.png` | 32 x 32 px | 1 frame | 32 x 32 px | Damage flash |
| **Death** | `canda_hit.png` | 32 x 32 px | 1 frame | 32 x 32 px | Defeat state |

### Boomerang Shield Projectile

- **Asset Path:** `res://Assets/New Assets/Cap Canda Assets/Captain Canada/Shield.png`
- **Scene:** `res://scenes/effects/boomerang_shield.tscn`
- **Scale:** `2.0 x 2.0` (22px diameter), continuously spins (`rotation += 12.0 * delta`) in flight toward the target and on return.

---

## 4. Boss 3: Shoebum

- **Folder Path:** `res://Assets/New Assets/Shoebum Asset/ShoeBum/`
- **Sprite Sheet:** `shoebum.png` (`144 x 128` pixels, containing two 72x128 frames side by side).
- **Hit Flash Texture:** `res://Assets/shoebum/shoebum_hit.png` (`72 x 128` pixels).
- **Texture Filter:** `Nearest` (set in `shoebum.tscn`).
- **Scale:** `0.45 x 0.45` preserving distinctive oversized-shoe design at standard fighter height (~54px).

### Shoebum Animations

| Animation | Texture Source | Region | Frame Count | Notes |
| :--- | :--- | :--- | :--- | :--- |
| **Idle** | `shoebum.png` | `Rect2(0, 0, 72, 128)` | 1 frame | Heavyweight resting stance |
| **Run** | `shoebum.png` | Frame 1 `(0, 0, 72, 128)`, Frame 2 `(72, 0, 72, 128)` | 2 frames | Looping lumbering run cycle at 5 FPS |
| **Attack** | `shoebum.png` | Frame 2 `(72, 0, 72, 128)` | 1 frame | Slap & stomp strike pose |
| **Jump** | `shoebum.png` | Frame 2 `(72, 0, 72, 128)` | 1 frame | Airborne leap |
| **Fall** | `shoebum.png` | Frame 1 `(0, 0, 72, 128)` | 1 frame | Heavy descent |
| **Hit** | `shoebum_hit.png` | `Rect2(0, 0, 72, 128)` | 1 frame | White flash knockback reaction |
| **Death** | `shoebum_hit.png` | `Rect2(0, 0, 72, 128)` | 1 frame | Defeat reaction |

> **Note on Projectile:** Shoebum uses close-range Slap and multi-pulse Ground Stomp shockwaves in the game design. No standalone projectile sprite was supplied in the `Shoebum Asset` folder.

---

## 5. UI Assets

### Health & Stamina HUD

- **Asset Path:** `res://Assets/New Assets/UI Assets/Health and StaminaUI/`
- **Panel Insets:** `res://Assets/New Assets/UI Assets/Ui for title screen/Default/Transparent center/panel-transparent-center-000.png` (48x48 9-slice panel).
- **Bar Values:** 0–125 HP (Player/Enemy), 0–100 Stamina (Player/Enemy), dynamic numeric readout (`125 / 125`).
- **Scene:** `res://scenes/ui/battle_hud.tscn`

### Title Screen

- **Background:** `res://Assets/Bg/background_0.png` and `res://Assets/Bg/background_1.png` (deep starry night sky).
- **Panels & Buttons:** `res://Assets/New Assets/UI Assets/Ui for title screen/Default/Panel/panel-000.png` (9-slice styled buttons with hover/press modulations) and `Transparent center/panel-transparent-center-000.png` (fighter preview showcases).
- **Scene:** `res://scenes/ui/title_screen.tscn`
