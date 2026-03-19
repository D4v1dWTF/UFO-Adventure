# UFO Adventure (Godot 4)

2D platformer made with **Godot 4.6.1**. You play as a **UFO** with a float/fuel mechanic, shoot enemies, collect items, and finish the run.

## Controls

These are the default bindings (you can rebind them in **Settings**):

- `A` / `D`: Move left / right  
- `W`: Jump (press again in air to enter float mode)  
- `Space`: Cancel float (drop down)  
- `S`: Float down (move down while floating)  
- `J`: Shoot  
- `Esc`: Pause menu (Continue / Back to Menu)

## Gameplay features

- **Float mode with fuel**: vertical movement uses fuel; fuel regenerates on ground.
- **Bullets**: shoot in the direction you are facing; bullets disappear on impact.
- **Enemies**: simple patrols and contact damage with invulnerability on respawn.
- **Checkpoints (Beacons)**: touching a beacon sets your respawn point.
- **Portals**: directed portals that teleport you to another portal location.
- **Collectibles**:
  - **Light balls** increase your light-ball counter and can grant extra lives.
  - **Burger goal**: finish the run when collected.
- **HUD stats**:
  - Lives, Light balls, **Bullets shot**, **Kills**, Fuel bar, Respawns, and Total Time.
- **Leaderboard**:
  - After winning, enter a name (or choose Anonymous).
  - Records are stored locally.

## How to run

1. Open the project in Godot.
2. Click **Run**.
3. The main scene should start automatically.

If you need to set it manually:
- Main scene is `res://scenes/levels/mission_1.tscn`.

## Notes about saving data

- Settings and leaderboard data are stored in `user://` (local app data).
- The leaderboard is saved on win and loaded when you open the leaderboard screen.

## Art

This project uses UFO and game sprite PNGs: most were drawn by you on Pixilart, plus one burger sprite taken from the internet.

## Credits / Assets

- Sprites drawn by you on Pixilart: https://www.pixilart.com/draw (UFO player, enemies, bullets, light balls, beacons, portals, etc.)
- Burger sprite: from the internet.

## Development

This project is a beginner practice game to learn Godot, developed with help from Cursor during implementation.

