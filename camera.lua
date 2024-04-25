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

return Camera