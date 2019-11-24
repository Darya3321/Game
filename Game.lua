local Field = require("Field");

function start()
    rowsCount = 10;
    columnsCount = 10;
    gameField = Field:new(rowsCount, columnsCount);
    gameField:init();
    gameField:dump();
    repeat
        print('Type command: ');
        command = io.read();
        from = checkCommand(command);
        if from ~= nil then
            to = getToObject(from);
            if to ~= nil then 
                gameField:move(from, to);
                canMove = checkMoves(gameField.tableField, gameField.row, gameField.column);
                if canMove == false then
                    gameField:mix();
                end
            end
        else
            if command ~= 'q' then
                print('Command is incorrect.');
            end
        end
    until command == 'q'
    os.exit();
end

--проверить введенную команду на корректность
function checkCommand(line)
    local commandList = {};
    local i = 1;
    local x, y, d, from;
    for item in string.gmatch(command, '%S+') do
        commandList[i] = item;
        i = i + 1;
    end
    if #commandList == 4 then
        if (commandList[1] == 'm' and tonumber(commandList[2]) ~= nil 
        and tonumber(commandList[3]) ~= nil 
        and (commandList[4] == 'u' or commandList[4] == 'l' or commandList[4] == 'd' or commandList[4] == 'r')) then
            x = tonumber(commandList[2]);
            y = tonumber(commandList[3]);
            d = commandList[4];
            if (x >= 0 and x < columnsCount and y >= 0 and y < rowsCount) then
                from = { x, y, d };
                return from;
            else
                return nil;
            end
        end 
    else
        return nil;
    end
end

--получить координаты для перемещения кристалла
function getToObject(from)
    local x1 = from[1];
    local y1 = from[2];
    local d = from[3];
    local x2 = x1;
    local y2 = y1;

    if d == 'l' then
        if x1 == 0 then 
            print('Can\'t move to the left!'); 
            return nil; 
        else 
            x2 = x1 - 1;  
        end
    elseif d == 'r' then
        if x1 == columnsCount - 1 then
            print('Can\'t move to the right!');
            return nil;
        else 
            x2 = x1 + 1
        end
    elseif d == 'u' then
        if y1 == 0 then 
            print('Can\'t move to the up!');
            return nil;
        else 
            y2 = y1 - 1; 
        end
    else 
        if y1 == rowsCount - 1 then
            print('Can\'t move to the down!');
            return nil;
        else 
            y2 = y1 + 1; 
        end
    end

    return {x2, y2};
end

start();