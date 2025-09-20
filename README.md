## Tower Defense (very creative name)
A tower defense game with some quirks:
- Towers require resources (bullets, energy, etc) to attack;
- Money can be converted into resources by certain towers;
- Enemies will try to find the least dangerous path;
- Players can use walls to redirect the enemies' path.

## Features
The game is not finished and new content is being added over time. As of writing this, the following have been added:
- 5 maps,
- 4 towers,
- 2 wall types,
- 2 resource types,
- 20 waves,
- 7 enemy types.

## Smart Enemy Pathfinding
Unlike many other tower defense games, enemies in this game do not follow a fixed path. Instead, they will try to find the least dangerous path depending on the towers you place and where you place them.
For example:
- Enemies will avoid towers that deal high damage, and try to exit a tower's range as fast as possible;
- Tanks will charge into turrets as they are immune to bullets;
- Breakers will try to look for walls to explode.

Enemies also have some randomness built into their pathfinding algorithm, just for fun :)

## Getting the Game
You can download a build from the releases page. These builds have been tested and should not contain any glaring issues. However, as this is a work-in-progress, do not expect a bug-free experience.  
If you want to try out the latest changes, you can clone this repository and import it using the [Godot Engine](https://godotengine.org/).
