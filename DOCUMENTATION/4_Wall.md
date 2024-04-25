## Description

Regular Custom Wall type.
A subclass that inherits [WallObject](https://github.com/Zly-u/OpenHexagon_CustomWall_module/wiki/WallObject-Superclass).

---

## Main Functions:

### `Wall()`

**Description:** Returns a copy of the object with all its data.

- **Returns:** `WallObject`.

##

### `Wall:destroy()`

**Description:** Destroys the wall and clears its data.

- **Returns:** `void`.

---

## Set Functions:

### `Wall:setVerts(verts)`

| Argument  | Type  | Default Value |
|:-:        |:-:    |:-:            |
| `verts` | table| - |

**Description:** Sets custom vertices data into a wall.

- `verts` can recieve: `{{x = 0, y = 0}, ...}` or `{{0, 0}, ...}`.

- **Returns:** `self`.

##

### `Wall:setVertsColors(... : table  |r, g, b, a)`

| Argument  | Type  | Range |  Default Value |
|:-:        |:-:    |:-:    |:-:|
| `...` | table | {0-255} |{255}|
| `r` | float | 0-255 |255|
| `g` | float | 0-255 |255|
| `b` | float | 0-255 |255|
| `a` | float | 0-255 |255|

**Description:** Sets custom color data into a wall's vertices.

- `...` can recieve: `{{255, 255, 255, 255}, ...}` or `255, 255, 255, 255`.
- If you pass the arguments `r`, `g`, `b`, `a`, instead of a `table` of color data, it will set this color to every vertex.


- **Returns:** `self`.

---

## Get Functions:

### `Wall:getVerts()`

**Description:** Returns a `table` of vertices data`.

- **Returns:** `table`.

##

### `Wall:getVertsColors()`

**Description:** Returns a copy of the object with all its data.

- details

- **Returns:** `table`.