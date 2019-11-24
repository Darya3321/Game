Renderer = {}
function Renderer:new()
    local objRenderer= {};
    setmetatable(objRenderer, self);
    self.__index = self; 
	return objRenderer;
end

--отобразить игровое поле
function Renderer:displayField(tableField, row, column)
    row1 = {};
    row2 = {};
    for i = -2, column - 1 , 1 do
        if (i < 0) then
            table.insert(row1, ' ');         
        else
            table.insert(row1, i);
        end
        table.insert(row2, '-');
    end
    print(table.concat(row1, ' '));
    print(table.concat(row2, ' '));

    j = 0
    for key, value in pairs(tableField) do
        colors = {};
        for k = 1, #value do
            table.insert(colors, value[k].color);
        end
        print( j .. ' ' .. '| ' .. table.concat(colors, ' '));
        j = j + 1;
    end
end
return Renderer;