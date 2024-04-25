## Description

A subclass that inherits [WallObject](https://github.com/Zly-u/OpenHexagon_CustomWall_module/wiki/CustomWall-Metaclass) 
and stores [Wall](https://github.com/Zly-u/OpenHexagon_CustomWall_module/wiki/Wall-Subclass) 
objects inside of it for additional manipulation and transformation.
Has a style of drawing sprites in "line mode".

---

## Main Functions:

### `SpriteLine()`

**Description:** Returns a copy of the object with all its data.

- **Returns:** `SpriteLine`.

##

### `SpriteLine:destroy()`

**Description:** Destroys and clears the data about the sprite and its walls.

- **Returns:** `void`.

---

## Set Functions:

### `SpriteLine:setLineThickness(thicc)`

| Argument  | Type  | Default Value |
|:-:        |:-:    |:-:            |
| `thicc` | float | 3 |

**Description:** Sets the line thickness of the sprite.

- **Returns:** `self`.

---

## Get Functions:

### `SpriteLine:getLineThickness()`

**Description:** Returns the line thickness.

- **Returns:** `float`.

##

### `SpriteLine:getSpriteData()`

**Description:** Returns the Sprite Data.

- **Returns:** `table`.
