# Custom Wall extension module for [Open Hexagon](https://github.com/SuperV1234/SSVOpenHexagon)

Extends the functionality of custom walls in [Open Hexagon](https://github.com/SuperV1234/SSVOpenHexagon) by @SuperV1234.

Made for my own practice in general.

## Requirements:
- [Le Game](https://github.com/SuperV1234/SSVOpenHexagon).

- In the code there is a declared documentation that is used by [EmmyLua](https://github.com/EmmyLua) for [Jetbrains](https://www.jetbrains.com) IDEs for providing info and
  autocompletion for the functions and just much better lua programming in general, any free Intelij based IDE will 
  work for you. (But it's not neccessary anyway.)
  
- If you want to be able to import sprites into the game then you need to use my sprite editor I've made once for 
  Oshisaure's game [Puzzle Jungle Trouble](https://oshisaure.itch.io/puzzle-juggle-trouble): [PJT Sprite Editor](https://github.com/Zly-u/PJTSE).
  (Will upload soon(tm). It's a bit meh, but works.)

## Usage:
Just import the module by using:
```lua
u_execScript(yourPathHere.."cw.lua")
```

IN the future, when `require` command will be somewhat fixed in the game, it will be replaced to this:
```lua
local cw = require(yourPathHere.."cw")
```

## Credits:
Thanks to @Oshisaure for the help with the code in some bits.
  
  
  
  
  
  
  
  