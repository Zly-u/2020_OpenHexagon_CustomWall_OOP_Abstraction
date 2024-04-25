## Description:

A superclass of main functions for other types of walls.
It contains common functions and properties for every wall type.

Everything that inherits it receives the same transformations and changes from it.

---

## Main Functions:

### `WallObject()`

**Description:** Returns a copy of the object with all its data.

- **Returns:** `WallObject`.

---

## Set Functions:

### `WallObject:setPosition(... : table | x, y)`

| Argument  | Type  | Default Value | Optional  |
|:-:        |:-:    |:-:            |:-:        |
| `...` | table  | - | - |
| `x` | float  | - | - |
| `y` | float  | - | - |

**Description:** Sets the position of the `WallObject`.

- In arguments, you can pass a table reference like `{x = 42, y = 2}`, `{435, 7}` or a table variable to tie it to the propertie, 
  or 2 arguments for `x` and `y` like this: `WallObject:setPosition(10, 200)`.
  
- **Returns:** `self`.

##

### `WallObject:setOrientationOffset(... : table | x, y)`

| Argument  | Type  | Default Value | Optional  |
|:-:        |:-:    |:-:            |:-:        |
| `...` | table  | - | - |
| `x` | float  | - | - |
| `y` | float  | - | - |

**Description:** Sets the orientation offset of the `WallObject`.

- In arguments, you can pass a table reference like `{x = 42, y = 2}`, `{435, 7}` or a table variable to tie it to the propertie, 
  or 2 arguments for `x` and `y` like this: `WallObject:setOrientationOffset(10, 200)`.
  
- **Returns:** `self`.

##

### `WallObject:setScale(... : table | x, y)`

| Argument  | Type  | Default Value | Optional  |
|:-:        |:-:    |:-:            |:-:        |
| `...` | table  | - | - |
| `x` | float  | - | - |
| `y` | float  | - | - |

**Description:** Sets the scale of the `WallObject`.

- In arguments, you can pass a table reference like `{x = 42, y = 2}`, `{435, 7}` or a table variable to tie it to the propertie, 
  or 2 arguments for `x` and `y` like this: `WallObject:setScale(10, 200)`.
  
- **Returns:** `self`.

##

### `WallObject:setShear(... : table | x, y)`

| Argument  | Type  | Default Value | Optional  |
|:-:        |:-:    |:-:            |:-:        |
| `...` | table  | - | - |
| `x` | float  | - | - |
| `y` | float  | - | - |

**Description:** Sets the shear(or skew) of the `WallObject`.

- In arguments, you can pass a table reference like `{x = 42, y = 2}`, `{435, 7}` or a table variable to tie it to the propertie, 
  or 2 arguments for `x` and `y` like this: `WallObject:setShear(10, 200)`.
  
- **Returns:** `self`.

##

### `WallObject:setAngle(angle)`

| Argument  | Type  | Default Value | Optional  |
|:-:        |:-:    |:-:            |:-:        |
| `angle` | float | - | - |

**Description:** Sets the shear(or skew) of the `WallObject`.

- `angle` is in radians.

- **Returns:** `self`.

---

## Get Functions:

### `WallObject:getPosition()`

**Description:** Returns Position table.

- **Returns:** `table = {x = float, y = float}`.

##

### `WallObject:getOrientationOffset()`

**Description:** Returns Orientation Offset table.

- **Returns:** `table = {x = float, y = float}`.

##

### `WallObject:getScale()`

**Description:** Returns Scale table.

- **Returns:** `table = {x = float, y = float}`.

##

### `WallObject:getShear()`

**Description:** Returns Shear table.

- **Returns:** `table = {x = float, y = float}`.

##

### `WallObject:getAngle()`

**Description:** Returns Angle value in radians.

- **Returns:** `float`.