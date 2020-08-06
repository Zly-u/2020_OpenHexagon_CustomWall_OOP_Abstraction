--[=====[     ---    Custom Wall Extension Module   ---     ]=====]--
--                   ----[[  VERSION: 1.0  ]]----                  --
--	                                                               --
--  Written by Zly. Credit not necessary, but highly appreciated ♥ --
--  https://twitter.com/zly_u      |      https://github.com/Zly-u --
--[===============================================================]--

--Oshisaure's Code https://github.com/Oshisaure
local LillaCode = {}
function LillaCode.normal(x, y)
    local d = (x^2+y^2)^0.5
    return y/d, -x/d
end

function LillaCode.normal2(A, B, scale)
    local xA, yA = table.unpack(A)
    local xB, yB = table.unpack(B)
    local xN, yN = LillaCode.normal(xB-xA, yB-yA)
    return {x = xA + xN*scale, y = yA + yN*scale}
end

function LillaCode.normalisePolygonSprite(sprite)
    local maxx =-math.huge
    local minx = math.huge
    local maxy =-math.huge
    local miny = math.huge
    for _, poly in ipairs(sprite) do
        for _, pt in ipairs(poly.verts) do
            maxx = math.max(pt[1], maxx)
            maxy = math.max(pt[2], maxy)
            minx = math.min(pt[1], minx)
            miny = math.min(pt[2], miny)
        end
    end
    local midx = (maxx+minx)/2
    local midy = (maxy+miny)/2
    local dx = maxx-minx
    local dy = maxy-miny
    local dm = math.max(dx, dy)/2
    for _, poly in ipairs(sprite) do
        for _, pt in ipairs(poly.verts) do
            pt[1] = (pt[1]-midx)/dm
            pt[2] = (pt[2]-midy)/dm
        end
    end
end

--Zly's Code https://github.com/Zly-u
--Camera that you prob don't have to worry about, unless you want to do idk cool stuff..?
---Camera for global transformations for every rendered wall on the screen.
---@class Camera
---@type Camera @global class type
Camera = {}

---Creates a new camera
---@return Camera|CameraData
function Camera.new()
    ---@class CameraData : Camera A super class for handling different types of wall data.
    ---@field private pos table position
    ---@field private zoom table scale
    ---@field private shear table shear/skew
    ---@field private angle number angle in radians
    local camera = {
        pos     = {x = 0, y = 0},
        zoom    = {x = 1, y = 1},
        shear   = {x = 0, y = 0},
        angle   = 0,
    }

    ---Sets the Position of the *`Camera`*.
    ---Pass a table reference like {x = 0, y = 0} to tie it to the propertie, or 2 arguments for x and y.
    ---@vararg table[]|number
    ---@overload fun(x:number, y:number):self
    ---@return self
    function camera:setPosition(...)
        local args = {...}
        if type(args[1]) == "table" then
            self.pos = args[1]
        else
            self.pos.x, self.pos.y = args[1], args[2]
        end
        return self
    end

    ---Sets the Zoom of the *`Camera`*.
    ---Pass a table reference like {x = 0, y = 0} to tie it to the propertie, or 2 arguments for `x` and `y` or 1 argument for both `x` and `y`.
    ---@vararg table[]|number
    ---@overload fun(x:number, y:number):self
    ---@overload fun(zoom:number):self
    ---@return self
    function camera:setZoom(...)
        local args = {...}
        if type(args[1]) == "table" then
            self.zoom = args[1]
        else
            if #args ~= 1 then
                self.zoom.x, self.zoom.y = args[1], args[2]
            else
                self.zoom.x, self.zoom.y = args[1], args[1]
            end
        end
        return self
    end

    ---Sets the Shear of the *`Camera`*.
    ---Pass a table reference like {x = 0, y = 0} to tie it to the propertie, or 2 arguments for x and y.
    ---@vararg table[]|number
    ---@overload fun(x:number, y:number):self
    ---@return self
    function camera:setShear(...)
        local args = {...}
        if type(args[1]) == "table" then
            self.shear = args[1]
        else
            self.shear.x, self.shear.y = args[1], args[2]
        end
        return self
    end

    ---Sets the Angle of the *`Camera`*.
    ---@param angle number in radians
    ---@overload fun():void
    ---@return self
    function camera:setAngle(angle)
        self.angle = angle or 0
        return self
    end

    ---Returns Position table.
    ---@return table[]
    function camera:getPosition()
        return self.pos
    end

    ---Returns Zoom table.
    ---@return table[]
    function camera:getZoom()
        return self.zoom
    end

    ---Returns Shear table.
    ---@return table[]
    function camera:getShear()
        return self.shear
    end

    ---Returns Angle value.
    ---@return number in radians
    function camera:getAngle()
        return self.angle
    end

    setmetatable(camera, {
        ---Deep copies the WallObject.
        ---@return Camera|CameraData
        __call = function(self)
            return utils.deepcopy(self)
        end
    })

    return camera
end


---Dude Custom magic walls.
---@class CustomWall A global metaclass that handles other classes and global functionality over them and their properties.
---@field private type table[] stores wall types
---@field private walls table[] stores regular wall data
---@field private sprites table[] stores sprite handlers for walls
---@field private sprites_quad table[] stores sprite quad handlers for walls
CustomWall = {
    type = {
        walls           = {},
        sprites_line    = {},
        sprites_quad    = {}
    }
}

---Creates a new wall or wall handler deppending on a passed type.
---@param _type string takes *`"wall"`*, *`"spriteLine"`* and *`"spriteQuad"`*, default value is *`"wall"`*.
---@return WallObject|Wall|SpriteLine|SpriteQuad
function CustomWall.new(_type)
    ---Regular Wall type, inherited by `WallObject`
    ---@class Wall : WallObject
    ---@field private id number wall id
    ---@field private init_verts table table for initial vertices
    ---@field private projected_verts table table for projected vertices
    ---@field private vert_colors table table of colors for each individual vertecies
    local wall = {
        id = cw_create() or 621420133769.314159,

        init_verts       = {},
        projected_verts  = {},
        vert_colors      = {},
    }

    ---Sets custom vertecies data into a wall
    ---@overload fun(x: number, y:number):self
    ---@param verts_table table[]
    ---@return self
    function wall:setVerts(verts_table)
        local temp_vertData
        if not verts_table[1].x then
            temp_vertData = {}
            for _, vert in pairs(verts_table) do
                table.insert(temp_vertData, {x = vert[1], y = vert[2]})
            end
        end
        self.init_verts = temp_vertData or verts_table
        return self
    end

    ---Sets custom color data for vertecies into a wall
    ---@vararg table[]
    ---@overload fun(r:number, g:number, b:number, a:number):self
    function wall:setVertsColors(...)
        self.vert_colors = {}

        local color_table = {...}
        if type(color_table[1]) ~= "table" then
            for _ = 1, 4 do
                table.insert(self.vert_colors, color_table)
            end
        else
            self.vert_colors = color_table[1]
        end

        return self
    end

    ---Updates vertex data projection for rendering.
    ---@return void
    function wall:updateProjection()
        --Init
        self.projected_verts = {}
        for _, vert in pairs(self.init_verts) do
            table.insert(self.projected_verts, {x = self.orient.x+vert.x, y = self.orient.y+vert.y})
        end

        --Transformations
        local c, s = math.cos(self.angle), math.sin(self.angle)
        for _, vert in pairs(self.projected_verts) do
            --Scale
            vert.x, vert.y = vert.x*self.scale.x, vert.y*self.scale.y
            --Angle
            vert.x, vert.y = vert.x*c - vert.y*s, vert.x*s + vert.y*c
            --Shear
            vert.x, vert.y = vert.x+self.shear.x*vert.y, vert.y+self.shear.y*vert.x
            --Position
            vert.x, vert.y = vert.x+self.pos.x, vert.y+self.pos.y
        end
    end

    ---Updates the wall.
    ---@param camera Camera
    ---@return void
    function wall:update(camera)
        self:updateProjection(camera)
        self:updateCameraProjection(camera)

        if #self.init_verts == 0 then return end
        for i, vert in pairs(self.projected_verts) do
            cw_setVertexPos(self.id, i-1, vert.x, vert.y)
        end

        if #self.vert_colors == 0 then return end
        for i, vert_color in pairs(self.vert_colors) do
            cw_setVertexColor(self.id, i-1, table.unpack(vert_color))
        end
    end

    ---Destroys and clears the data about the wall.
    ---@return void
    function wall:destroy()
        cw_destroy(self.id)
        CustomWall.type.walls[self.id] = nil
    end

    ---Returns a reference to the table of vertices data.
    ---@return table[]
    function wall:getVerts() return self.projected_verts end

    ---Returns a reference to the table of vertices color data.
    ---@return table[]
    function wall:getVertsColors() return self.vert_colors end


    --[[============================================================================================================]]--
    --[[============================================================================================================]]--
    --[[============================================================================================================]]--


    ---`Sprite` type that handles walls to draw and transform acording to `sprite` data
    ---@class SpriteLine : WallObject
    ---@field private table_id number id in the *`CustomWall.type.sprites_line`* table
    ---@field private sprite table table for initial sprite data
    ---@field private projected_verts table table for projected vertices of the sprite data
    ---@field private lines table table of walls for drawing the "lines" of a sprite
    ---@field private line_thickness number thickness of lines
    local sprite_line = {
        table_id = nil,

        sprite          = nil,
        projected_sprite= {},
        lines           = {},
        line_thickness  = 3,
    }

    ---Sets the line thickness of the sprite.
    ---@param thicc number
    ---@return self
    function sprite_line:setLineThickness(thicc)
        self.line_thickness = thicc or 3
        return self
    end

    ---Updates vertex data projection for rendering.
    ---@return void
    function sprite_line:updateProjection()
        --Init projection data
        self.projected_sprite = {}
        for polyID, line in pairs(self.sprite) do
            self.projected_sprite[polyID] = {verts = {}, color = {}}
            local line_proj = self.projected_sprite[polyID]
            for _, vert in pairs(line.verts) do
                table.insert(line_proj.verts, {self.orient.x*(1/self.scale.y)+vert[1], self.orient.y*(1/self.scale.y)+vert[2]})
            end
            for _, ch in pairs(line.color) do
                table.insert(line_proj.color, math.floor(0.5+ch*255))
            end
        end

        --Transformations
        local c, s = math.cos(self.angle), math.sin(self.angle)
        for _, polygon in pairs(self.projected_sprite) do
            for _, vert in pairs(polygon.verts) do
                --Scale
                vert[1], vert[2] = vert[1]*self.scale.x, vert[2]*self.scale.y
                --Angle
                vert[1], vert[2] = vert[1]*c - vert[2]*s, vert[1]*s + vert[2]*c
                --Shear
                vert[1], vert[2] = vert[1]+self.shear.x*vert[2], vert[2]+self.shear.y*vert[1]
                --Position
                vert[1], vert[2] = vert[1]+self.pos.x, vert[2]+self.pos.y
            end
        end
    end

    ---Updates the sprite
    ---@param camera Camera
    ---@return void
    function sprite_line:update(camera)
        self:updateProjection(camera)

        local _verts = {}
        for _, polygon in pairs(self.projected_sprite) do
            for i = 1, #polygon.verts do
                local p1 = polygon.verts[i]
                local p2 = polygon.verts[1 + (i % #polygon.verts)]
                table.insert(_verts, {p1, p2, polygon.color})
            end
        end

        for i, v in pairs(_verts) do
            local p1, p2, color = v[1], v[2], v[3]
            self.lines[i]:setVerts{
                LillaCode.normal2(p1, p2, self.line_thickness/2),
                LillaCode.normal2(p1, p2,-self.line_thickness/2),
                LillaCode.normal2(p2, p1, self.line_thickness/2),
                LillaCode.normal2(p2, p1,-self.line_thickness/2),
            }:setVertsColors(table.unpack(color))
        end
    end

    ---Destroys and clears the data about the sprite and its walls.
    ---@return void
    function sprite_line:destroy()
        for _, line in pairs(self.lines) do
            line:destroy()
        end
        CustomWall.type.sprites_line[self.table_id] = nil
    end

    ---Returns the line thickness.
    ---@return number
    function sprite_line:getLineThickness() return self.line_thickness end

    ---Returns the sprite data.
    ---@return table
    function sprite_line:getSpriteData() return self.sprite end


    --[[============================================================================================================]]--
    --[[============================================================================================================]]--
    --[[============================================================================================================]]--


    ---`SpriteQuad` type that handles walls to draw and transform acording to `sprite` data
    ---@class SpriteQuad : WallObject
    ---@field private table_id number id in the *`CustomWall.type.sprites_quad`* table
    ---@field private sprite table table for initial sprite data
    ---@field private projected_verts table table for projected vertices of the sprite data
    ---@field private quads table table of walls for drawing the "quads" of a sprite
    local sprite_quad = {
        table_id = nil,

        sprite           = nil,
        projected_sprite = {},
        quads            = {},

        --Dummy functions
        setLineThickness = function() end,
        getLineThickness = function() end,

    }

    ---Updates vertex data projection for rendering.
    ---@return void
    function sprite_quad:updateProjection()
        --Init projection data
        self.projected_sprite = {}
        for polyID, polygon in pairs(self.sprite) do
            self.projected_sprite[polyID] = {verts = {}, color = {}}
            local line_proj = self.projected_sprite[polyID]
            for _, vert in pairs(polygon.verts) do
                table.insert(line_proj.verts, {self.orient.x*(1/self.scale.x)+vert[1], self.orient.y*(1/self.scale.y)+vert[2]})
            end
            for _, ch in pairs(polygon.color) do
                table.insert(line_proj.color, math.floor(0.5+ch*255))
            end
        end

        --Transformations
        local c, s = math.cos(self.angle), math.sin(self.angle)
        for _, polygon in pairs(self.projected_sprite) do
            for _, vert in pairs(polygon.verts) do
                --Scale
                vert[1], vert[2] = vert[1]*self.scale.x, vert[2]*self.scale.y
                --Angle
                vert[1], vert[2] = vert[1]*c - vert[2]*s, vert[1]*s + vert[2]*c
                --Shear
                vert[1], vert[2] = vert[1]+self.shear.x*vert[2], vert[2]+self.shear.y*vert[1]
                --Position
                vert[1], vert[2] = vert[1]+self.pos.x, vert[2]+self.pos.y
            end
        end
    end

    ---Updates the sprite
    ---@param camera Camera
    ---@return void
    function sprite_quad:update(camera)
        self:updateProjection(camera)

        for id, quad in pairs(self.projected_sprite) do
            self.quads[1+#self.quads-id]:setVerts(quad.verts):setVertsColors(table.unpack(quad.color))
        end
    end

    ---Destroys and clears the data about the sprite and its walls.
    ---@return void
    function sprite_quad:destroy()
        for _, quad in pairs(self.quads) do
            quad:destroy()
        end
        CustomWall.type.sprites_quad[self.table_id] = nil
    end

    ---Returns the sprite data.
    ---@return table
    function sprite_quad:getSpriteData() return self.sprite end


    --[[============================================================================================================]]--
    --[[============================================================================================================]]--
    --[[============================================================================================================]]--


    ---@class WallObject A super class for handling different types of wall data.
    ---@field private type string type of data
    ---@field private pos table position
    ---@field private orient table orientation
    ---@field private scale table scale
    ---@field private shear table shear/skew
    ---@field private angle number angle in radians
    local object = {
        type = _type or "wall",

        pos     = {x = 0, y = 0},
        orient  = {x = 0, y = 0},
        scale   = {x = 1, y = 1},
        shear   = {x = 0, y = 0},
        angle   = 0,
    }

    ---Init function on creation
    ---@return self
    function object:init()
        local inherit = self.type == "wall"         and wall        or
                        self.type == "spriteLine"   and sprite_line or
                        self.type == "spriteQuad"   and sprite_quad or error("Unknown wall type: "..self.type)

        for i, v in pairs(inherit) do
            self[i] = v
        end
        if self.type == "wall" then
            for _ = 1, 4 do
                table.insert(self.vert_colors, {255, 255, 255, 255})
            end
        end
        return self
    end

    ---Sets the position of the *`wall`*, *`sprite`*, or *`spriteQuads`*.
    ---Pass a table reference like {x = 0, y = 0} to tie it to the propertie, or 2 arguments for x and y.
    ---@overload fun(x:number, y:number):self
    ---@vararg table[]|number
    ---@return self
    function object:setPosition(...)
        local args = {...}

        if type(args[1]) ~= "table" then
            self.pos = {x = args[1], y = args[2]}
        else
            if args[1].x then
                self.pos = args[1]
            else
                self.pos = {x = args[1][1], y = args[1][2]}
            end
        end

        return self
    end

    ---Sets the orientation offset of the *`wall`*, *`sprite`*, or *`spriteQuads`*.
    ---Pass a table reference like {x = 0, y = 0} to tie it to the propertie, or 2 arguments for x and y.
    ---@overload fun(x:number, y:number):self
    ---@vararg table[]|number
    ---@return self
    function object:setOrientationOffset(...)
        local args = {...}

        if type(args[1]) ~= "table" then
            self.orient = {x = args[1], y = args[2]}
        else
            if args[1].x then
                self.orient = args[1]
            else
                self.orient = {x = args[1][1], y = args[1][2]}
            end
        end
        return self
    end

    ---Sets the scale of the *`wall`*, *`sprite`*, or *`spriteQuads`*.
    ---Pass a table reference like {x = 0, y = 0} to tie it to the propertie, or 2 arguments for `x` and `y` or 1 argument for both `x` and `y`.
    ---@vararg table[]|number
    ---@overload fun(x:number, y:number):self
    ---@overload fun(scale:number):void
    ---@return self
    function object:setScale(...)
        local args = {...}
        if type(args[1]) ~= "table" then
            if #args ~= 1 then
                self.scale = {x = args[1], y = args[2]}
            else
                self.scale = {x = args[1], y = args[1]}
            end
        else
            if args[1].x then
                self.scale = args[1]
            else
                self.scale = {x = args[1][1], y = args[1][2]}
            end
        end
        return self
    end

    ---Sets the shear of the *`wall`*, *`sprite`*, or *`spriteQuads`*.
    ---Pass a table reference like {x = 0, y = 0} to tie it to the propertie, or 2 arguments for x and y.
    ---@overload fun(x:number, y:number):self
    ---@vararg table[]|number
    ---@return self
    function object:setShear(...)
        local args = {...}
        if type(args[1]) ~= "table" then
            self.shear = {x = args[1], y = args[2]}
        else
            if args[1].x then
                self.shear = args[1]
            else
                self.shear = {x = args[1][1], y = args[1][2]}
            end
        end
        return self
    end

    ---Sets the angle of the *`wall`*, *`sprite`*, or *`spriteQuads`*.
    ---@param angle number in radians
    ---@overload fun():void
    ---@return self
    function object:setAngle(angle)
        self.angle = angle or 0
        return self
    end


    ---Returns Position table.
    ---@return table[]
    function object:getPosition()
        return self.pos
    end

    ---Returns Orientation Offset table.
    ---@return table[]
    function object:getOrientationOffset()
        return self.orient
    end

    ---Returns Scale table.
    ---@return table[]
    function object:getScale()
        return self.scale
    end

    ---Returns Shear table.
    ---@return table[]
    function object:getShear()
        return self.shear
    end

    ---Returns Angle value.
    ---@return number in radians
    function object:getAngle()
        return self.angle
    end


    ---Global Camera transformation.
    ---@param camera Camera
    ---@return void
    function object:updateCameraProjection(camera)
        local c, s = math.cos(camera.angle), math.sin(camera.angle)
        for _, vert in pairs(self.projected_verts) do
            --Position
            vert.x, vert.y = vert.x-camera.pos.x, vert.y-camera.pos.y
            --Scale
            vert.x, vert.y = vert.x*camera.zoom.x, vert.y*camera.zoom.y
            --Angle
            vert.x, vert.y = vert.x*c - vert.y*s, vert.x*s + vert.y*c
            --Shear
            vert.x, vert.y = vert.x+camera.shear.x*vert.y, vert.y+camera.shear.y*vert.x
        end
    end

    setmetatable(object, {
        ---Deep copies the WallObject.
        ---@return WallObject|Wall|SpriteLine|SpriteQuad
        __call = function(self)
            local newWall = utils.deepcopy(self)
            local table_to_put = newWall.sprite and CustomWall.type.sprites_line or CustomWall.type.walls
            newWall.id = self.id and cw_create() or nil
            table.insert(table_to_put, newWall)
            newWall.table_id = #table_to_put

            return newWall
        end
    })

    local table_to_put =    object.type == "wall"       and CustomWall.type.walls           or
                            object.type == "spriteLine" and CustomWall.type.sprites_line    or
                            object.type == "spriteQuad" and CustomWall.type.sprites_quad    or error("Unknown wall type: "..object.type)

    object:init()
    local id
    if object.type == "wall" then
        table_to_put[object.id] = object
    else
        id = #table_to_put+1
        object.table_id = id
        table_to_put[id] = object
    end

    return object
end

---Returns a new sprite data of a *`line`* type.
---@param sprite table takes table of sprite data.
---@return WallObject|SpriteLine
function CustomWall.importSpriteLine(sprite)  --this is where I began to lost my brain cells
    LillaCode.normalisePolygonSprite(sprite)

    local new_sprite = CustomWall.new("spriteLine")
    new_sprite.sprite = sprite
    for _, polygon in pairs(sprite) do
        for _ = 1, #polygon.verts do
            table.insert(new_sprite.lines, CustomWall.new("wall"))
        end
    end

    return new_sprite
end

---Returns a new sprite data of a *`quad`* type.
---@param sprite table takes table of sprite data.
---@return WallObject|SpriteQuad
function CustomWall.importSpriteQuad(sprite)
    LillaCode.normalisePolygonSprite(sprite)

    local new_sprite_quad = CustomWall.new("spriteQuad")
    new_sprite_quad.sprite = sprite
    for _ in pairs(sprite) do
        table.insert(new_sprite_quad.quads, CustomWall.new("wall"))
    end

    return new_sprite_quad
end

---Returns a new sprite data deppending on a passed type.
---@param type string takes "line" or "quad"
---@param sprite table takes table of sprite data.
---@return WallObject|SpriteLine|SpriteQuad
function CustomWall.importSprite(type, sprite)
    return  type == "line" and CustomWall.importSpriteLine(sprite) or
            type == "quad" and CustomWall.importSpriteQuad(sprite) or error("Unknown sprite type: "..tostring(type))
end

---Cleans up all stored walls and sprites data.
---@return void
function CustomWall.destroyAll()
    for _, table in pairs(CustomWall.type) do
        for _, object in pairs(table) do
            object:destroy()
        end
    end
end

---Prints some debug info about currently existing walls.
---@return void
function CustomWall.printWallData()
    print("=========================")
    print("=========================")
    print("=========================")
    print(" ")
    print("--[[====WALL DATA====]]--")
    for i, wall in pairs(CustomWall.type.walls) do
        print(wall.type, i, wall.id)
    end
    print(" ")
    print("--[[====SPRITE LINE DATA===]]--")
    for n, sprite in pairs(CustomWall.type.sprites_line) do
        print(sprite.type, n)
        for i, wall in pairs(sprite.lines) do
            print("\t", i, wall.id)
        end
    end
    print(" ")
    print("--[[====SPRITE QUAD DATA===]]--")
    for n, sprite in pairs(CustomWall.type.sprites_quad) do
        print(sprite.type, n)
        for i, wall in pairs(sprite.quads) do
            print("\t", i, wall.id)
        end
    end
end

---Updates walls that are stored in *`CustomWall`*.
---@param camera Camera If is nil then it uses a camera with default params.
---@overload fun():void
function CustomWall.updateWalls(camera)
    camera = camera or Camera.new()

    for _, type in pairs(CustomWall.type) do
        for _, object in pairs(type) do
            object:update(camera)
        end
    end
end

---Clears memory and walls from the game to potentionally safe the perfomance idk.
---@return void
function CustomWall.onUnload()
    cw_clear()
    for _, table in pairs(CustomWall.type) do
        table = {}
    end
    collectgarbage("collect")
end

---Returns a table of Walls type.
---@return table[]
function CustomWall.getWallsTable()
    return CustomWall.type.walls
end

---Returns a table of SpriteLine type.
---@return table[]
function CustomWall.getSpriteLineTable()
    return CustomWall.type.sprites_line
end

---Returns a table of SpriteQuad type.
---@return table[]
function CustomWall.getSpriteQuadTable()
    return CustomWall.type.sprites_quad
end

return CustomWall