## Description

A subclass that inherits [WallObject](https://github.com/Zly-u/OpenHexagon_CustomWall_module/wiki/CustomWall-Metaclass) 
and stores [Wall](https://github.com/Zly-u/OpenHexagon_CustomWall_module/wiki/Wall-Subclass) 
objects inside of it for additional manipulation and transformation.

Has a style of drawing sprites in "quad mode" or "fill mode".

---

## Main Functions:

### `SpriteQuad()`

**Description:** Returns a copy of the object with all its data.

- **Returns:** `SpriteQuad`.

##

### `SpriteQuad:destroy()`

**Description:** Destroys and clears the data about the sprite and its walls.

- **Returns:** `void`.

##

### `SpriteQuad:getSpriteData()`

**Description:** Returns the Sprite Data.

- **Returns:** `table`.