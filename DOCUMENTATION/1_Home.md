# Custom Wall extension module Wiki for [Open Hexagon](https://github.com/SuperV1234/SSVOpenHexagon)
## Requirements:
- [Le Game](https://github.com/SuperV1234/SSVOpenHexagon).

- In the code, there is declared documentation that is used by [EmmyLua](https://github.com/EmmyLua) for [Jetbrains](https://www.jetbrains.com) IDEs for providing info and
  autocompletion for the functions and just much better Lua programming in general, any free IntelliJ based IDE will 
  work for you. (But it's not necessary anyway.)
  
- If you want to be able to import sprites into the game then you need to use my sprite editor I've made once for 
  Oshisaure's game [Puzzle Jungle Trouble](https://oshisaure.itch.io/puzzle-juggle-trouble): [PJT Sprite Editor](https://github.com/Zly-u/PJTSE).
  (Will upload soon(TM). It's a bit meh, but works.)

# Basics:

### Wiki notation:
- **Default Values:** Some functions have *Default Values* for some of their arguments which are *Optional* arguments. 
That means if you put a `nil` into an argument or don't pass anything which is equivalent to `nil` then it will simply
take a Default Value as an argument.

- `...` in arguments of functions means that amount of arguments can vary. It can be notated like this: 
  `fun(... : table | x, y)` which means function can take or `table` or `x` and `y` arguments.

### Lua:

- **Import:** Just import the module by using:

    ```lua
    u_execScript(yourPathHere.."cw.lua")
    ```
  
    In the future, when `require` command will be somewhat fixed in the game, it will be replaced by this:
    
    ```lua
    local cw = require(yourPathHere.."cw")
    ```
  
- `...`: in Lua, it actually means "Variable amount of arguments". Google it tbh, cool thing.

- **self:** `self` is a reference of the current object of the function it is in.

- **return:** if function returns a `table` or an `Object` it means it returns their reference, not copy.
  That means if you try to edit what you have got from the function - the changes will apply for those `tables` or `Objects`.
  But it also means you can "tie" those references to some variables to use somewhere else, 
  if it changes in the Object/Table - it also changes in that variable.
  
- **Passing `tables` in arguments:** same story as from above but for a property you set that table in.