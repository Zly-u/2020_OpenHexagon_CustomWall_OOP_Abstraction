--Oshisaure's Code https://github.com/Oshisaure
local lillaCode = {}
function lillaCode.normal(x, y)
    local d = (x^2+y^2)^0.5
    return y/d, -x/d
end

function lillaCode.normal2(A, B, scale)
    local xA, yA = table.unpack(A)
    local xB, yB = table.unpack(B)
    local xN, yN = lillaCode.normal(xB-xA, yB-yA)
    return {x = xA + xN*scale, y = yA + yN*scale}
end

function lillaCode.normalisePolygonSprite(sprite)
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
Camera = {}

function Camera.new()
    local camera = {
        pos = {x = 0, y = 0},
        zoom = {x = 1, y = 1},
        shear = {x = 0, y = 0},
        angle = 0,
    }

    function camera:setPosition(...)
        local args = {...}
        if type(args[1]) == "table" then
            self.pos = args[1]
        else
            self.pos.x, self.pos.y = args[1], args[2]
        end
        return self
    end

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

    function camera:setShear(...)
        local args = {...}
        if type(args[1]) == "table" then
            self.shear = args[1]
        else
            self.shear.x, self.shear.y = args[1], args[2]
        end
        return self
    end

    function camera:setAngle(ang)
        self.angle = ang
        return self
    end

    function camera:getPosition()
        return self.pos
    end

    function camera:getZoom()
        return self.zoom
    end

    function camera:getShear()
        return self.shear
    end

    function camera:getAngle()
        return self.angle
    end

    setmetatable(camera, {
        __call = function(self)
            return utils.deepcopy(self)
        end
    })

    return camera
end

--Dude Custom magic walls AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
CustomWall = {
    type = {
        walls = {},
        sprites = {},
        spritesQuad = {}
    }
}

function CustomWall.new(_type)
    local object = {
        type = _type or "wall",

        table_id = nil,

        pos     = {x = 0, y = 0},
        orient  = {x = 0, y = 0},
        scale   = {x = 1, y = 1},
        shear   = {x = 0, y = 0},
        angle   = 0,
    }


    local wall = {
        id = cw_create(),

        init_verts      = {},
        projectedVerts  = {},
        vertColors      = {},

        setVerts = function(self, vertsTable)
            local temp_vertData
            if not vertsTable[1].x then
                temp_vertData = {}
                for _, vert in pairs(vertsTable) do
                    table.insert(temp_vertData, {x = vert[1], y = vert[2]})
                end
            end
            self.init_verts = temp_vertData or vertsTable
            return self
        end,

        setVertsColors = function(self, ...)
            self.vertColors = {}

            local color_table = {...}
            if type(color_table[1]) ~= "table" then
                for _ = 1, 4 do
                    table.insert(self.vertColors, color_table)
                end
            else
                self.vertColors = color_table[1]
            end

            return self
        end,


        updateProjection = function(self)
            --Init
            self.projectedVerts = {}
            for _, vert in pairs(self.init_verts) do
                table.insert(self.projectedVerts, {x = self.orient.x+vert.x, y = self.orient.y+vert.y})
            end

            --Transformations
            local c, s = math.cos(self.angle), math.sin(self.angle)
            for _, vert in pairs(self.projectedVerts) do
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

        update = function(self, camera)
            self:updateProjection(camera)
            self:updateCameraProjection(camera)

            if #self.init_verts == 0 then return end
            for i, vert in pairs(self.projectedVerts) do
                cw_setVertexPos(self.id, i-1, vert.x, vert.y)
            end

            if #self.vertColors == 0 then return end
            for i, vert_color in pairs(self.vertColors) do
                cw_setVertexColor(self.id, i-1, table.unpack(vert_color))
            end
        end,

        getVerts        = function(self) return self.projectedVerts  end,
        getVertsColors  = function(self) return self.vertColors      end,
    }

    local sprite = {
        sprite          = nil,
        projectedSprite = {},
        lines           = {},
        lineThickness   = 5,

        setLineThickness = function(self, thicc)
            self.lineThickness = thicc
            return self
        end,

        updateProjection = function(self)
            --Init projection data
            self.projectedSprite = {}
            for polyID, line in pairs(self.sprite) do
                self.projectedSprite[polyID] = {verts = {}, color = {}}
                local line_proj = self.projectedSprite[polyID]
                for _, vert in pairs(line.verts) do
                    table.insert(line_proj.verts, {self.orient.x+vert[1], self.orient.y+vert[2]})
                end
                for _, ch in pairs(line.color) do
                    table.insert(line_proj.color, math.floor(0.5+ch*255))
                end
            end

            --Transformations
            local c, s = math.cos(self.angle), math.sin(self.angle)
            for _, polygon in pairs(self.projectedSprite) do
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

        update = function(self, camera)
            self:updateProjection(camera)

            local _verts = {}
            for _, polygon in pairs(self.projectedSprite) do
                for i = 1, #polygon.verts do
                    local p1 = polygon.verts[i]
                    local p2 = polygon.verts[1 + (i % #polygon.verts)]
                    table.insert(_verts, {p1, p2, polygon.color})
                end
            end

            for i, v in pairs(_verts) do
                local p1, p2, color = v[1], v[2], v[3]
                self.lines[i]:setVerts{
                    lillaCode.normal2(p1, p2, self.lineThickness/2),
                    lillaCode.normal2(p1, p2,-self.lineThickness/2),
                    lillaCode.normal2(p2, p1, self.lineThickness/2),
                    lillaCode.normal2(p2, p1,-self.lineThickness/2),
                }:setVertsColors(table.unpack(color))
            end
        end,

        getLineThickness = function(self) return self.lineThickness end,
    }


    local quad = {
        sprite          = nil,
        projectedSprite = {},
        quads           = {},

        updateProjection = function(self)
            --Init projection data
            self.projectedSprite = {}
            for polyID, polygon in pairs(self.sprite) do
                self.projectedSprite[polyID] = {verts = {}, color = {}}
                local line_proj = self.projectedSprite[polyID]
                for _, vert in pairs(polygon.verts) do
                    table.insert(line_proj.verts, {self.orient.x+vert[1], self.orient.y+vert[2]})
                end
                for _, ch in pairs(polygon.color) do
                    table.insert(line_proj.color, math.floor(0.5+ch*255))
                end
            end

            --Transformations
            local c, s = math.cos(self.angle), math.sin(self.angle)
            for _, polygon in pairs(self.projectedSprite) do
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

        update = function(self, camera)
            self:updateProjection(camera)

            for id, quad in pairs(self.projectedSprite) do
                self.quads[1+#self.quads-id]:setVerts(quad.verts):setVertsColors(table.unpack(quad.color))
            end
        end,

        setLineThickness = function() end,
        getLineThickness = function() end,
    }



    function object:init()
        local inherit = self.type == "wall"         and wall    or
                self.type == "sprite"       and sprite  or
                self.type == "spriteQuad"   and quad    or error("Unknown wall type: "..self.type)

        for i, v in pairs(inherit) do
            self[i] = v
        end
        if self.type == "wall" then
            for _ = 1, 4 do
                table.insert(self.vertColors, {255, 255, 255, 255})
            end
        end
        return self
    end

    function object:setPosition(...)
        local args = {...}
        if type(args[1]) ~= "table" then
            self.pos = {x = args[1], y = args[2]}
        else
            self.pos = args[1]
        end
        return self
    end

    function object:setOrientationOffset(...)
        local args = {...}
        if type(args[1]) ~= "table" then
            self.orient = {x = args[1], y = args[2]}
        else
            self.orient = args[1]
        end
        return self
    end

    function object:setScale(...)
        local args = {...}
        if type(args[1]) ~= "table" then
            self.scale = {x = args[1], y = args[2]}
        else
            self.scale = args[1]
        end
        return self
    end

    function object:setShear(...)
        local args = {...}
        if type(args[1]) ~= "table" then
            self.shear = {x = args[1], y = args[2]}
        else
            self.shear = args[1]
        end
        return self
    end

    function object:setAngle(angle)
        self.angle = angle
        return self
    end


    function object:getPosition()
        return self.pos
    end
    function object:getOrientationOffset()
        return self.orient
    end
    function object:getScale()
        return self.scale
    end
    function object:getShear()
        return self.shear
    end
    function object:getAngle()
        return self.angle
    end


    --Global Camera transformation
    function object:updateCameraProjection(camera)
        local c, s = math.cos(camera.angle), math.sin(camera.angle)
        for _, vert in pairs(self.projectedVerts) do
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
        __call = function(self)
            local newWall = utils.deepcopy(self)
            local tableToPut = newWall.sprite and CustomWall.type.sprites or CustomWall.type.walls
            newWall.id = self.id and cw_create() or nil
            table.insert(tableToPut, newWall)
            newWall.table_id = #tableToPut

            return newWall
        end
    })

    local tableToPut =  object.type == "wall"       and CustomWall.type.walls       or
            object.type == "sprite"     and CustomWall.type.sprites     or
            object.type == "spriteQuad" and CustomWall.type.spritesQuad or error("Unknown wall type: "..object.type)

    local id = #tableToPut+1
    object.table_id = id
    tableToPut[id] = object:init()

    return object
end

function CustomWall.importSpriteLine(sprite)  --this is where I began to lost my brain cells
    lillaCode.normalisePolygonSprite(sprite)

    local newSprite = CustomWall.new("sprite")
    newSprite.sprite = sprite
    for _, polygon in pairs(sprite) do
        for _ = 1, #polygon.verts do
            table.insert(newSprite.lines, CustomWall.new("wall"))
        end
    end

    local id = #CustomWall.type.sprites+1
    newSprite.table_id = id
    CustomWall.type.sprites[id] = newSprite
    return newSprite
end

function CustomWall.importSpriteQuad(sprite)
    lillaCode.normalisePolygonSprite(sprite)

    local newSpriteQuad = CustomWall.new("spriteQuad")
    newSpriteQuad.sprite = sprite
    for _ in pairs(sprite) do
        table.insert(newSpriteQuad.quads, CustomWall.new("wall"))
    end

    local id = #CustomWall.type.spritesQuad+1
    newSpriteQuad.table_id = id
    CustomWall.type.spritesQuad[id] = newSpriteQuad
    return newSpriteQuad
end

function CustomWall.importSprite(_type, sprite)
    return  _type == "line" and CustomWall.importSpriteLine(sprite) or
            _type == "quad" and CustomWall.importSpriteQuad(sprite) or error("Unknown sprite type: "..tostring(_type))
end

function CustomWall.clean()
    CustomWall.type.walls        = nil
    CustomWall.type.sprites      = nil
    CustomWall.type.spritesQuad  = nil
end

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

function CustomWall.updateWalls(camera)
    camera = camera or Camera.new()

    for _, type in pairs(CustomWall.type) do
        for _, object in pairs(type) do
            object:update(camera)
        end
    end
end

function CustomWall.onUnload()
    cw_clear()
    CustomWall.clean()
    collectgarbage("collect")
end

function CustomWall.getWalls()
    return CustomWall.type.walls
end

function CustomWall.getSprites()
    return CustomWall.type.sprites
end

function CustomWall.getSpriteQuad()
    return CustomWall.type.spritesQuad
end

return CustomWall