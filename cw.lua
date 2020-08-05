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

--Zly's Code
--Camera that you prob don't have to worry about, unless you want to do idk cool stuff..?
---Camera for global transformations for every rendered wall on the screen.
---@class Camera
---@type Camera @global class type
Camera = {}

---Creates a new camera
---@return Camera|cameraData
function Camera.new()
    ---@class cameraData : Camera A super class for handling different types of wall data.
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
    ---@overload fun(x:number, y:number):Camera
    ---@return Camera
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
    ---Pass a table reference like {x = 0, y = 0} to tie it to the propertie, or 2 arguments for x and y.
    ---@vararg table[]|number
    ---@overload fun(x:number, y:number):Camera
    ---@return Camera
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
    ---@overload fun(x:number, y:number):Camera
    ---@return Camera
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
    ---@return Camera
    function camera:setAngle(angle)
        self.angle = angle
        return self
    end

    ---Returns Position table
    ---@return table[]
    function camera:getPosition()
        return self.pos
    end

    ---Returns Zoom table
    ---@return table[]
    function camera:getZoom()
        return self.zoom
    end

    ---Returns Shear table
    ---@return table[]
    function camera:getShear()
        return self.shear
    end

    ---Returns Angle value
    ---@return number in radians
    function camera:getAngle()
        return self.angle
    end

    setmetatable(camera, {
        ---Deep copies the wallObject
        ---@return Camera|cameraData
        __call = function(self)
            return utils.deepcopy(self)
        end
    })

    return camera
end


---Dude Custom magic walls
---@class CustomWall A super class for creating and managing different types of wall data.
---@field private walls table[] stores regular wall data
---@field private sprites table[] stores sprite handlers for walls
---@field private sprites_quad table[] stores sprite quad handlers for walls
CustomWall = {
    type = {
        walls = {},
        sprites = {},
        sprites_quad = {}
    }
}

---@param _type string takes *`"wall"`*, *`"sprite"`* and *`"spriteQuad"`*, *`nil`* equivalent to *`"wall"`*.
---@return wallObject|wall|sprite|quad
function CustomWall.new(_type)
    ---@class wallObject A super class for handling different types of wall data.
    ---@field private type string type of data
    ---@field private table_id number id in the *`CustomWall.type.walls`* table
    ---@field private pos table position
    ---@field private orient table orientation
    ---@field private scale table scale
    ---@field private shear table shear/skew
    ---@field private angle number angle in radians
    local object = {
        type = _type or "wall",

        table_id = nil,

        pos     = {x = 0, y = 0},
        orient  = {x = 0, y = 0},
        scale   = {x = 1, y = 1},
        shear   = {x = 0, y = 0},
        angle   = 0,
    }

    ---
    ---@class wall : wallObject Regular Wall type, inherited by `wallObject`
    ---@field private id number wall id
    ---@field private init_verts table table for initial vertices
    ---@field private projected_verts table table for projected vertices
    ---@field private vert_colors table table of colors for each individual vertecies
    local wall = {
        id = cw_create(),

        init_verts      = {},
        projected_verts  = {},
        vert_colors      = {},

        ---Sets custom vertecies data into a wall
        ---@type fun(verts_table:table[]):wallObject
        setVerts = function(self, verts_table)
            local temp_vertData
            if not verts_table[1].x then
                temp_vertData = {}
                for _, vert in pairs(verts_table) do
                    table.insert(temp_vertData, {x = vert[1], y = vert[2]})
                end
            end
            self.init_verts = temp_vertData or verts_table
            return self
        end,

        ---Sets custom color data for vertecies into a wall
        ---@vararg table[]|number
        ---@return wallObject
        setVertsColors = function(self, ...)
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
        end,

        ---Updates vertex data projection for rendering.
        ---@type fun(void):void
        updateProjection = function(self)
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
        end,

        ---Updates the wall
        ---@type fun(camera: Camera):void
        update = function(self, camera)
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
        end,

        ---Returns a reference to the table of vertices data.
        ---@return table[]
        getVerts = function(self) return self.projected_verts end,

        ---Returns a reference to the table of vertices color data.
        ---@return table[]
        getVertsColors = function(self) return self.vert_colors end,
    }

    ---`Sprite` type that handles walls to draw and transform acording to `sprite` data
    ---@class sprite : wallObject inherited by `wallObject`
    ---@field private sprite table table for initial sprite data
    ---@field private projected_verts table table for projected vertices of the sprite data
    ---@field private lines table table of walls for drawing the "lines" of a sprite
    ---@field private line_thickness number thickness of lines
    local sprite = {
        sprite          = nil,
        projected_sprite= {},
        lines           = {},
        line_thickness  = 5,

        setLineThickness = function(self, thicc)
            self.line_thickness = thicc
            return self
        end,

        ---Updates vertex data projection for rendering.
        ---@return void
        updateProjection = function(self)
            --Init projection data
            self.projected_sprite = {}
            for polyID, line in pairs(self.sprite) do
                self.projected_sprite[polyID] = {verts = {}, color = {}}
                local line_proj = self.projected_sprite[polyID]
                for _, vert in pairs(line.verts) do
                    table.insert(line_proj.verts, {self.orient.x+vert[1], self.orient.y+vert[2]})
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
                end
            end
        end,

        ---Updates the sprite
        ---@type fun(camera: Camera):void
        update = function(self, camera)
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
        end,

        getLineThickness = function(self) return self.line_thickness end,
    }

    ---`SpriteQuad` type that handles walls to draw and transform acording to `sprite` data
    ---@class quad : wallObject @`wallObject` inherited by `wallObject`
    ---@field private sprite table table for initial sprite data
    ---@field private projected_verts table table for projected vertices of the sprite data
    ---@field private quads table table of walls for drawing the "quads" of a sprite
    local quad = {
        sprite           = nil,
        projected_sprite = {},
        quads            = {},

        ---Updates vertex data projection for rendering.
        ---@return void
        updateProjection = function(self)
            --Init projection data
            self.projected_sprite = {}
            for polyID, polygon in pairs(self.sprite) do
                self.projected_sprite[polyID] = {verts = {}, color = {}}
                local line_proj = self.projected_sprite[polyID]
                for _, vert in pairs(polygon.verts) do
                    table.insert(line_proj.verts, {self.orient.x+vert[1], self.orient.y+vert[2]})
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
                end
            end
        end,

        ---Updates the sprite
        ---@type fun(camera: Camera):void
        update = function(self, camera)
            self:updateProjection(camera)

            for id, quad in pairs(self.projected_sprite) do
                self.quads[1+#self.quads-id]:setVerts(quad.verts):setVertsColors(table.unpack(quad.color))
            end
        end,

        --Dummy functions
        setLineThickness = function() end,
        getLineThickness = function() end,
    }

    ---Init function on creation
    ---@return wallObject
    function object:init()
        local inherit = self.type == "wall"         and wall    or
                self.type == "sprite"       and sprite  or
                self.type == "spriteQuad"   and quad    or error("Unknown wall type: "..self.type)

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
    ---@overload fun(x:number, y:number):wallObject
    ---@vararg table[]|number
    ---@return wallObject
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
    ---@overload fun(x:number, y:number):wallObject
    ---@vararg table[]|number
    ---@return wallObject
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
    ---Pass a table reference like {x = 0, y = 0} to tie it to the propertie, or 2 arguments for x and y.
    ---@vararg table[]|number
    ---@overload fun(x:number, y:number):wallObject
    ---@return wallObject
    function object:setScale(...)
        local args = {...}
        if type(args[1]) ~= "table" then
            self.scale = {x = args[1], y = args[2]}
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
    ---@overload fun(x:number, y:number):wallObject
    ---@vararg table[]|number
    ---@return wallObject
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
    ---@return wallObject
    function object:setAngle(angle)
        self.angle = angle
        return self
    end

    ---Returns Position table
    ---@return table[]
    function object:getPosition()
        return self.pos
    end
    ---Returns Position table
    ---@return table[]
    function object:getOrientationOffset()
        return self.orient
    end
    ---Returns Position table
    ---@return table[]
    function object:getScale()
        return self.scale
    end
    ---Returns Position table
    ---@return table[]
    function object:getShear()
        return self.shear
    end
    ---Returns Position table
    ---@return number in radians
    function object:getAngle()
        return self.angle
    end

    ---Global Camera transformation
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
        ---Deep copies the wallObject
        ---@return wallObject|wall|sprite|quad
        __call = function(self)
            local newWall = utils.deepcopy(self)
            local table_to_put = newWall.sprite and CustomWall.type.sprites or CustomWall.type.walls
            newWall.id = self.id and cw_create() or nil
            table.insert(table_to_put, newWall)
            newWall.table_id = #table_to_put

            return newWall
        end
    })

    local table_to_put =    object.type == "wall"       and CustomWall.type.walls       or
            object.type == "sprite"     and CustomWall.type.sprites     or
            object.type == "spriteQuad" and CustomWall.type.sprites_quad or error("Unknown wall type: "..object.type)

    local id = #table_to_put+1
    object.table_id = id
    table_to_put[id] = object:init()

    return object
end

---Returns a new sprite data of a *`line`* type
---@param sprite table takes table of sprite data.
---@return wallObject|sprite
function CustomWall.importSpriteLine(sprite)  --this is where I began to lost my brain cells
    LillaCode.normalisePolygonSprite(sprite)

    local new_sprite = CustomWall.new("sprite")
    new_sprite.sprite = sprite
    for _, polygon in pairs(sprite) do
        for _ = 1, #polygon.verts do
            table.insert(new_sprite.lines, CustomWall.new("wall"))
        end
    end

    local id = #CustomWall.type.sprites+1
    new_sprite.table_id = id
    CustomWall.type.sprites[id] = new_sprite
    return new_sprite
end

---Returns a new sprite data of a *`quad`* type
---@param sprite table takes table of sprite data.
---@return wallObject|quad
function CustomWall.importSpriteQuad(sprite)
    LillaCode.normalisePolygonSprite(sprite)

    local new_sprite_quad = CustomWall.new("spriteQuad")
    new_sprite_quad.sprite = sprite
    for _ in pairs(sprite) do
        table.insert(new_sprite_quad.quads, CustomWall.new("wall"))
    end

    local id = #CustomWall.type.sprites_quad+1
    new_sprite_quad.table_id = id
    CustomWall.type.sprites_quad[id] = new_sprite_quad
    return new_sprite_quad
end

---Returns a new sprite data deppending on a passed type
---@param _type string takes "line" or "quad"
---@param sprite table takes table of sprite data.
---@return wallObject|sprite|quad
function CustomWall.importSprite(_type, sprite)
    return  _type == "line" and CustomWall.importSpriteLine(sprite) or
            _type == "quad" and CustomWall.importSpriteQuad(sprite) or error("Unknown sprite type: "..tostring(_type))
end

---Cleans up all stored walls and sprites data
---@return void
function CustomWall.clean()
    CustomWall.type.walls        = nil
    CustomWall.type.sprites      = nil
    CustomWall.type.sprites_quad = nil
end

---Prints some debug info about currently existing walls
---@return void
function CustomWall.printWallData()
    print("=========================")
    print("=========================")
    print("=========================")
    print(" ")
    print("--[[====WALL DATA====]]--")
    for i, wall in pairs(CustomWall.type.walls) do
        print("wall", i, wall.id)
    end
    print(" ")
    print("--[[====SPRITE DATA===]]--")
    for n, sprite in pairs(CustomWall.type.sprites) do
        print("sprite", n)
        for i, wall in pairs(sprite.lines) do
            print("\t", i, wall.id)
        end
    end
end

---Updates walls that are stored in *`CustomWall`*.
---If *`camera`* argument is nil then it uses a camera with default params.
---@type fun(camera:Camera):void
---@overload fun():void
function CustomWall.updateWalls(camera)
    camera = camera or Camera.new()

    for _, type in pairs(CustomWall.type) do
        for _, object in pairs(type) do
            object:update(camera)
        end
    end
end

---Clears memory and walls from the game to potentionally safe the perfomance.
---@return void
function CustomWall.onUnload()
    cw_clear()
    CustomWall.clean()
    collectgarbage("collect")
end

---Returns a table of regular walls type
---@return table[]
function CustomWall.getWalls()
    return CustomWall.type.walls
end

---Returns a table of sprite type
---@return table[]
function CustomWall.getSprites()
    return CustomWall.type.sprites
end

---Returns a table of spriteQuads type
---@return table[]
function CustomWall.getSpriteQuad()
    return CustomWall.type.sprites_quad
end

return CustomWall