Crystal = {};

function Crystal:new(x, y, color, type)
    local objCrystal = {};
    objCrystal.x = x;
    objCrystal.y = y;
    objCrystal.color = color;
    objCrystal.type = type;
    self.__index = self;
    return setmetatable(objCrystal, self);
end
return Crystal;