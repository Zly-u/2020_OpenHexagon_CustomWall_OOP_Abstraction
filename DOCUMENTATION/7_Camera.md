## Description

A class for global wall transformation that basically mimics how Camera/Viewport in games could work.

---

## Main Functions:

### `Camera.new()`
**Description:** Creates a new `Camera`.

- **Returns:** `Camera`.

---

## Set Functions:

### `Camera:setPosition(... : table | x, y)`

| Argument  | Type  | Default Value |
|:-:        |:-:    |:-:            |
| `...` | table  | - |
| `x` | float  | - |
| `y` | float  | - |

**Description:** Sets the Position of the `Camera`.

- In arguments, you can pass: `{x = 42, y = 2}` or `{435, 7}` or `x, y` like this: `Camera:setPosition(10, 200)`.

- **Returns:** `self`.

##

### `Camera:setZoom(... : table | x, y | zoom)`

| Argument  | Type  | Default Value |
|:-:        |:-:    |:-:            |
| `...` | table  | - |
| `x` | float  | - |
| `y` | float  | - |
| `zoom` | float  | - |

**Description:** Sets the Zoom of the `Camera`.

- In arguments, you can pass: `{x = 42, y = 2}` or `{435, 7}` or `x, y` like this: `Camera:setZoom(10, 200)`.
- You can also pass only 1 argument `zoom` for both `x` and `y` arguments.


- **Returns:** `self`.

##

### `Camera:setShear(... : table | x, y)`

| Argument  | Type  | Default Value |
|:-:        |:-:    |:-:            |
| `...` | table  | - |
| `x` | float  | - |
| `y` | float  | - |

**Description:** Sets the Shear of the `Camera`.

- In arguments, you can pass: `{x = 42, y = 2}` or `{435, 7}` or `x, y` like this: `Camera:setShear(10, 200)`.

- **Returns:** `self`.

##

### `Camera:setAngle(angle)`

| Argument  | Type  | Default Value |
|:-:        |:-:    |:-:            |
| `angle` | float  | 0 |

**Description:** Sets the Position of the `Camera`.

- In arguments, you can pass: `{x = 42, y = 2}` or `{435, 7}` or `x, y` like this: `Camera:setZoom(10, 200)`.

- **Returns:** `self`.

---

## Get Functions:

### `Camera:getPosition()`

**Description:** Returns Position table.

- **Returns:** `table = {x = float, y = float}`.

##

### `Camera:getZoom()`

**Description:** Returns Zoom table.

- **Returns:** `table = {x = float, y = float}`.

##

### `Camera:getShear()`

**Description:** Returns Shear table.

- **Returns:** `table = {x = float, y = float}`.

##

### `Camera:getAngle()`

**Description:** Returns Angle value in radians.

- **Returns:** `float`.