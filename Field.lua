local Crystal = require("Crystal")
local Renderer = require("Renderer")
local renderer = Renderer:new();

Field = {};

function Field:new(row, column)
    local objField = {};
    objField.row = row;
    objField.column = column;
    objField.tableField = {};
    objField.changeCount = 0;
    self.__index = self;
    return setmetatable(objField, self);
end

--заполнить игровое поле кристаллами 
function Field:init()    
    math.randomseed(os.time());
    for i = 1, self.row do
        self.tableField[i] = {};
        for j = 1, self.column do
            repeat
                color = string.char(math.random(65,70));
            until not((i >= 3 and self.tableField[i - 1][j].color == color and self.tableField[i - 2][j].color == color)
                or (j >= 3 and self.tableField[i][j - 1].color == color and self.tableField[i][j - 2].color == color))
            cr = Crystal:new(i, j, color, 'simple');
            self.tableField[i][j] = cr;
        end
    end

    local canMove = checkMoves(self.tableField, self.row, self.column);
    if canMove == false then
        self:init();
    end
end

--посчитать количество изменений на поле
function Field:tick()
    self.changeCount = self.changeCount + 1;
    self:dump();
end

--перемешать кристаллы на поле
function Field:mix()
    math.randomseed(os.time())
    local m, n
    for i = self.row, 1, -1 do
        for j = self.column, 1, -1 do
            k = math.random(1, self.row);
            l = math.random(1, self.column);
            self.tableField[i][j], self.tableField[k][l] = self.tableField[k][l], self.tableField[i][j];
        end
    end
    local chainsSet = findChains(self.tableField, self.row, self.column);
    local canMove = checkMoves(self.tableField, self.row, self.column);
    if (#chainsSet > 0 or canMove == false) then
        self:mix();
    end
    self:tick();
end

--подвинуть кристалл на поле
function Field:move(from, to)
    local x1 = from[1] + 1;
    local y1 = from[2] + 1;
    local x2 = to[1] + 1;
    local y2 = to[2] + 1;
    local chainsSet;
    self.tableField[y1][x1], self.tableField[y2][x2] = self.tableField[y2][x2], self.tableField[y1][x1];
    self:tick();
    chainsSet = findChains(self.tableField, self.row, self.column);
    repeat 
        for i = 1, #chainsSet do
            if (chainsSet[i].direct == 'horizontal') then
                for j = 0, chainsSet[i].len - 1 do
                    self.tableField[chainsSet[i].row][chainsSet[i].col + j].color = '0';
                end
            else
                for j = 0, chainsSet[i].len - 1 do
                    self.tableField[chainsSet[i].row + j][chainsSet[i].col].color = '0';
                end 
            end
        end
        self:tick();
        offsetCrystal(self.tableField, self.row, self.column);
        self:tick();
        chainsSet = findChains(self.tableField, self.row, self.column);
    until #chainsSet == 0

end

--отобразить игровое поле
function Field:dump()
    renderer:displayField(self.tableField, self.row, self.column);
end

--проверить возможные перемещения кристаллов
function checkMoves(tableField, row, column)
    local chainsSet;
    for i = 1, row do
        for j = 1, column - 1 do
            tableField[i][j], tableField[i][j + 1] = tableField[i][j + 1], tableField[i][j];
            chainsSet = findChains(tableField, row, column);
            tableField[i][j], tableField[i][j + 1] = tableField[i][j + 1], tableField[i][j];
            if #chainsSet > 0 then
                return true;
            end
        end
    end

    for j = 1, column do
        for i = 1, row - 1 do
            tableField[i][j], tableField[i + 1][j] = tableField[i + 1][j], tableField[i][j];
            chainsSet = findChains(tableField, row, column);
            tableField[i][j], tableField[i + 1][j] = tableField[i + 1][j], tableField[i][j];
            if #chainsSet > 0 then
                return true;
            end
        end
    end

    return false;

end

--сместить кристаллы на поле
function offsetCrystal(tableField, row, column)
    local offset;
    for j = 1, column do
        offset = 0;
        for i = row, 1, -1 do
            if tableField[i][j].color == '0' then
                tableField[i][j].color = string.char(math.random(65,70));
                offset = offset + 1;
            else
                if offset > 0 then
                    tableField[i][j], tableField[i + offset][j] = tableField[i + offset][j],tableField[i][j];
                end
            end
        end
    end
end

--найти готовые цепочки кристаллов
function findChains(tableField, row, column)
    local chains = {};
    local chainLen, checkCrystal, chain;

    for i = 1, row do
        chainLen = 1;
        for j = 1, column do
            checkCrystal = false;
            if j == column then
                checkCrystal  = true;
            else
                if tableField[i][j].color == tableField[i][j + 1].color then
                    chainLen = chainLen + 1;
                else
                    checkCrystal = true;
                end
                
            end

            if checkCrystal == true then
                if chainLen >= 3 then
                    chain = {['row'] = i, ['col'] = j + 1 - chainLen, ['len'] = chainLen, ['direct'] = 'horizontal'};
                    table.insert(chains, chain);
                end
                chainLen = 1;
            end

        end
    end

    for j = 1, column do
        chainLen = 1;
        for i = 1, row do
            checkCrystal = false;
            if i == row then
                checkCrystal  = true;
            else
                if tableField[i][j].color == tableField[i + 1][j].color then
                    chainLen = chainLen + 1;
                else
                    checkCrystal = true;
                end
                
            end

            if checkCrystal == true then
                if chainLen >= 3 then
                    chain = {['row'] = i + 1 - chainLen, ['col'] = j, ['len'] = chainLen, ['direct'] = 'vertical'};
                    table.insert(chains, chain);
                end
                chainLen = 1;
            end

        end
    end
    return chains;
end

return Field;