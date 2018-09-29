os.loadAPI("build/build.lua");

--API Aliases

function dirMap(turns) return build.dirMap(turns); end
function fif(cond, a, b) return build.fif(cond, a, b); end

dofile("config");
dofile("blocks");

local D, U, N, S, W, E = dirMap(0);

local compy = build.Coord:get();
local center = compy:off(N, 8 + 3):up();

grow = false;
codesPerRad = 20;
count = codesPerRad;

monitor = peripheral.find("monitor");
coil = peripheral.find("dendrocoil");

monitor.setBackgroundColor(colors.black);
monitor.clear();

mainTimer = 0;

function startTimer()
mainTimer = os.startTimer(0.5);
end

function stopTimer()
os.cancelTimer(mainTimer);
end

----------------------------------------------------------------
-- BUTTONS                                                --
----------------------------------------------------------------

Button = {}
Button.__index = Button;

function Button:new(x, y, text, color)
  color = color or colors.black;
  local button = {};             -- our new object
  setmetatable(button, Button);  -- make handle lookup
  button.coords = build.Coord:new(x, y, 0);
  button.text = text;
  button.color = color;
  button.monitor = monitor;
  return button;
end

function Button:setMonitor(m)
  self.monitor = m;
  return self;
end

function Button:draw()
  mon = self.monitor;
  mon.setCursorPos(self.coords.x, self.coords.y);
  mon.clearLine();
  mon.setBackgroundColor(self.color);
  mon.clearLine();
  mon.write(self.text);
  return self;
end

function Button:setText(text)
  if text ~= self.text then
    self.text = text;
    self:draw();
  end
  return self;
end

function Button:setColor(color)
  self.color = color;
  self:draw();
  return self;
end

function Button:click(x, y)
  if y == self.coords.y then
    if self.action ~= nil then 
		self.action(self, x, y);
    end
  end
end

function Button:setAction(action)
  self.action = action;
  return self;
end

function open()
  center:up():cylinder(air, radius, height);
end

function close()
  center:up():cylinder(wallBlock, radius, height);
end

function kill()
  coil.killTree(center.x, center.y, center.z);
  center:up():erase();--In the case of a sapling
  center:put(dirt);
  --commands.kill("@e[type=item]");
end

function plant()
  coil.plantTree(center.x, center.y + 1, center.z, tree);
end

openButton   = Button:new(1, 1,  " OPEN   ", colors.purple):setAction( open );
closeButton  = Button:new(1, 2,  " CLOSE  ", colors.blue):setAction( close );
growButton   = Button:new(1, 3,  " START  ", colors.green);
plantButton  = Button:new(1, 4,  " PLANT  ", colors.lime):setAction( function() plant(); end );
killButton   = Button:new(1, 5,  " KILL   ", colors.orange):setAction( function() kill(); grow = false; end ) ;
purgeButton  = Button:new(1, 6,  " PURGE  ", colors.brown):setAction( function() build.cuboid(center:up()):grohor(8):gro(height, U):erase(); end );
countButton  = Button:new(1, 9,  "        ", colors.gray);
treeButton   = Button:new(1, 10, tree,       colors.gray);
radiusButton = Button:new(1, 11, "        ", colors.gray);
soilButton   = Button:new(1, 12, "        ", colors.gray);

growButton.stop = function(b) b:setColor(colors.green); b:setText(" START "); grow = false; end
growButton.start = function(b) b:setColor(colors.red); b:setText(" STOP  ") grow = true; close(); end
growButton:setAction( function(b) if grow then b:stop(); else b:start(); end; end);

countButton.setCount = function(b, c) b:setText("LEFT:" .. c); end;
countButton:setAction( function(b) count = codesPerRad; b:setCount(count); end );
countButton:setCount(count);

radiusButton.setRadius = function(b, r) b:setText("  R:" .. r); end;
radiusButton.click = function(b, x, y) if x < 3 then radius = radius - 1; elseif x > 5 then radius = radius + 1; end; b:setRadius(radius); end;
radiusButton:setRadius(radius);

soilButton.setSoilLife = function(b, life) soilButton:setText(" " .. string.rep("0", 2 - string.len(life)) .. life .. "/15 "); end

allButtons = { openButton, closeButton, growButton, plantButton, killButton, purgeButton, countButton, treeButton, radiusButton, soilButton };

function drawScreen()
  for i, v in ipairs(allButtons) do
    v:draw();
  end
end

function clickScreen(x, y)
  for i, v in ipairs(allButtons) do
    v:click(x, y);
  end
end

drawScreen();

indicator = false;

function growPulse()
  if(grow) then
    --coil.growPulse();
    indicator = not indicator;
  else
    indicator = false;
  end
  redstone.setOutput("left", indicator);
end


function purge()
  build.cuboid(center:up()):grohor(radius):gro(height, U):erase();
end

function clearVines()
  --Do nothing for now
end

function getSoilLife()
  return coil.getSoilLife(center.x, center.y, center.z);
end

startTimer();

while true do
  event, par1, xPos, yPos = os.pullEvent();
  if(event == "monitor_touch") then
    stopTimer();
    clickScreen(xPos, yPos)
    startTimer();
  end
  if(event == "timer") then
    growPulse();
    startTimer();
  end
  local soilLife = getSoilLife();
  soilButton:setSoilLife(soilLife);
  if(soilLife <= 0 and grow == true) then
    stopTimer();
    if(soilLife == 0) then
      code = coil.getCode(center.x, center.y, center.z);
      code = string.gsub(code, "+", "%%2b");
      kill();
      http.request("http://127.0.0.1/trees/trees.php?".. "tree="..tree.."&code="..code.."&radius="..radius, nil);
      count = count - 1;
      if count <= 0 then
        count = codesPerRad;
        open();
        radius = radius - 1;
        radiusButton:setRadius(radius);
        close();
        if radius < 2 then
          growButton:stop()
        end
      end
      countButton:setCount(count);
    end
    sleep(0.1);
    if grow then 
      plant();
    end
    startTimer();
  end
end
