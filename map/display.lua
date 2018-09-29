os.loadAPI("map/biomePalette.lua");
os.loadAPI("build/build.lua");

--Globals
cart = peripheral.find("cartographer");
terr = peripheral.find("terraformer");
recv = peripheral.find("remotereceiver");
recv.connect();

----------------------------------------------------------------
-- DISPLAY                                                    --
----------------------------------------------------------------

Display = {}
Display.__index = Display;

--body A cuboid describing where the map is in the world
--dir  The direction the display is facing
function Display:new(body, dir, startIndex)
  local display = {};             -- our new object
  setmetatable(display, Display);  -- make handle lookup
  
  dir = dir or build.DIR.S;
  startIndex = startIndex or 0;

  body = body:fac(dir);
  
  local w = 0;
  local h = 0;
  local axis = build.dirAxis(dir);
  
  if axis == 'x' then
    w = body:zlen();
    h = body:ylen();
  elseif axis == 'y' then
    w = body:xlen();
    h = body:zlen();
  else --z
    w = body:xlen();
    h = body:ylen();
  end
  
  display.pos = pos;
  display.h = h;
  display.w = w;
  display.dir = dir;
  display.body = body;
  display.startIndex = startIndex;
  display.content = nil;
  
  return display;
end

function Display:setContent(content)
  self.content = content;
  self.content:setDisplay(self);
end

function Display:killMaps()
  commands.kill(
    "@e[type=item_frame,x=" .. self.body[1].x .. 
    ",y=" .. self.body[1].y .. 
    ",z=" .. self.body[1].z ..
    ",dx=" .. self.body:xlen() ..
    ",dy=" .. self.body:ylen() ..
    ",dz=" .. self.body:zlen() ..
    "]");
end

function Display:build()
  self:killMaps();--clear out old maps in case they're still around
  self.body:off(build.dirOpposite(self.dir)):fill(build.stonepaver);--Make a wall for the item frames to hang
  self:open();--creates the map tiles for the display
end

function Display:open()
  local body = self.body;
  local mapNum = self.startIndex;
  local dir = self.dir;
  local w = self.w;
  local h = self.h;  
  
  body:erase();--Clear a spot for the item frames
  
  --Populate wall with an array of maps in itemframes
  local xstart = body:top():fac(build.dirRotate(dir, 1)):pos();
  local xdir = build.dirRotate(dir, -1);
  local ydir = build.DIR.D;
  for y = 1, h do
    local pos = xstart;
    for x = 1, w do
      commands.summon("item_frame", pos.x, pos.y, pos.z, "{Facing:0,Item:{id:\"minecraft:filled_map\",Damage:" .. mapNum .. ",Count:1}}");
      pos = pos:off(xdir);
      mapNum = mapNum + 1;
    end
    xstart = xstart:off(ydir);
  end
  
  body:fill(build.blockState("mcf:mapguard"));
end

function Display:close()
  self:killMaps(); --removes all map item frames
  body:erase(); --remove map guards
end

function Display:erase()
  close();
  body:off(build.dirOpposite(self.dir)):erase();--erase wall behind maps
end

function Display:build5x5(pos, turns)
  buildDisplay(pos, turns, 5, 5);
end

function Display:black()
  local blk = string.char(119);
  for y = 0,self.h-1 do
    for x = 0,self.w-1 do
      self:blackTile(x, y);
    end
  end
end

function Display:blackTile(x, y)
  local blk = string.char(119);
  local tile = self:getTile(x, y);
  cart.setMapPixels(tile, string.rep(blk, 128*128));
  cart.updateMap(tile);
end

function Display:getTile(x, y)
  return self.startIndex + y * self.w + x;
end

function Display:shiftLeft()
  local numMaps = self.w * self.h;
  for i = 0,(numMaps - 2) do
    cart.swapMapData(i, (i + 1) % numMaps);
    cart.updateMap(i);
  end
  
  for i = 0,self.h-1 do
    self:blackTile(self.w - 1, i);
  end
  if self.content ~= nil then
    self.content:shiftLeft();
  end
  for y = 0,self.h-1 do
    self.content:updateTile(self.w - 1, y);
  end
end

function Display:shiftRight()
  local numMaps = self.w * self.h;
  for i = (numMaps - 2),0,-1 do
    cart.swapMapData(i, (i + 1) % numMaps);
    cart.updateMap((i + 1) % numMaps);
  end
  for i = 0,self.h-1 do
    self:blackTile(0, i);
  end  
  if self.content ~= nil then
    self.content:shiftRight();
  end
  for y = 0,self.h-1 do
    self.content:updateTile(0, y);
  end
end

function Display:shiftUp()
  local numMaps = self.w * self.h;
  for i = 0,(numMaps - self.w - 1) do
    cart.swapMapData(i, (i + self.w) % numMaps);
    cart.updateMap(i);
  end
  for i = 0,self.w-1 do
    self:blackTile(i, self.h - 1);
  end
  if self.content ~= nil then
    self.content:shiftUp();
  end
  for x = 0,self.w-1 do
    self.content:updateTile(x, self.h - 1);
  end
end

function Display:shiftDown()
  local numMaps = self.w * self.h;
  for i = (numMaps - self.w - 1),0,-1 do
    cart.swapMapData(i, (i + self.w) % numMaps);
    cart.updateMap((i + self.w) % numMaps);
  end
  for i = 0,self.w-1 do
    self:blackTile(i, 0);
  end
  if self.content ~= nil then
    self.content:shiftDown();
  end
  for x = 0,self.w-1 do
    self.content:updateTile(x, 0);
  end
end

function Display:rebuildContents()
  local w = self.w;
  local h = self.h;

  if self.content == nil then
    return;
  end

  for z = 0, h - 1 do
    for x = 0, w - 1 do
      self.content:updateTile(x, z);
      print("(" ..x .."," .. z .. ")", os.clock());
      sleep(0.05);--Yield
    end
  end
end

function Display:translate(x, y, z)
  if z >= 0.062 and z <= 0.063 then
    if y >= self.body[1].y and y < self.body[2].y + 1 then
      if x >= self.body[1].x and x < self.body[2].x + 1 then
        local h = self.h * 128;
        local xt = math.floor((x - self.body[1].x) * 128);
        local yt = math.floor((y - self.body[1].y) * 128);
        return xt, h - yt;
      end
    end
  end
  return nil;
end

function Display:input(hit, name)
  if self.content ~= nil then
    x, y = self:translate(hit.x, hit.y, hit.z);
    if x ~= nil then
      return self.content:click(x, y, name);
    end
  end
  return false;
end

function Display:size(scale)
  scale = scale or 1;
  return self.w * 128 * scale, self.h * 128 * scale;
end

----------------------------------------------------------------
-- CONTENT                                                    --
----------------------------------------------------------------

Content = {}
Content.__index = Content;

--body A cuboid describing where the map is in the world
--dir  The direction the display is facing
function Content:new()
  local content = {};             -- our new object
  setmetatable(content, Content);  -- make handle lookup
  content.worldX = 0;
  content.worldZ = 0;
  content.zoomLevel = 4;
  content.scale = bit.blshift(1, content.zoomLevel);
  return content;
end

function Content:setDisplay(display)
  self.display = display;
end

function Content:setScale(scale)
  self.scale = scale;
end

--mapNum  Which map panel we are dealing with
--offsetX Which map panel column we are dealing with
--offsetZ Which map panel row we are dealing with
--scale 1 Pixel = 16 Blocks(1 Chunk)
function Content:updateTile(x, y)
  local mapNum = self.display:getTile(x, y);
  local offsetX = x - (self.display.w / 2) + self.worldX;
  local offsetZ = y - (self.display.h / 2) + self.worldZ;
  local scale = self.scale;
  local mapScale = 0;
  local scaleMapping = { [1] = 0, [2] = 1, [4] = 2, [8] = 3, [16] = 4 };
  
  if scaleMapping[scale] ~= nil then
    mapScale = scaleMapping[scale];
  else
    --scale = 1;
  end
  
  local mapSize = 128; --A minecraft map is always 128x128
  
  local startX = offsetX * mapSize * scale;
  local endX = (offsetX + 1) * mapSize * scale;
  local startZ = offsetZ * mapSize * scale;
  local endZ = (offsetZ + 1) * mapSize * scale;
  
  local xCenter = bit.brshift(startX + endX, 1);
  local zCenter = bit.brshift(startZ + endZ, 1);
  
  local pixels = "";
  
  local test = false;
  
  if test then
    local biomeId = string.char(24);
    local biomeData = string.rep(biomeId, 128*128);
    for i = 1, 128*128 do
      pixels = pixels .. string.char(biomePalette.colors[biomeData:byte(i) + 1]);
    end
  else 
    local biomeData = terr.getBiomeByteArray(startX, startZ, mapSize, mapSize, scale);
    for i = 1, biomeData:len() do
      pixels = pixels .. string.char(biomePalette.colors[biomeData:byte(i) + 1]);
    end
  end
  
  cart.setMapScale(mapNum, mapScale);
  cart.setMapCenter(mapNum, xCenter, zCenter);
  cart.setMapPixels(mapNum, pixels);
  cart.updateMap(mapNum);
end

function Content:shiftLeft()
  self.worldX = self.worldX + 1;
end

function Content:shiftRight()
  self.worldX = self.worldX - 1;
end

function Content:shiftUp()
  self.worldZ = self.worldZ + 1;
end

function Content:shiftDown()
  self.worldZ = self.worldZ - 1;
end

function Content:zoom(level)
  local prevZoomLevel = self.zoomLevel;
  self.zoomLevel = math.floor(level);
  if self.zoomLevel < 0 then self.zoomLevel = 0; end
  if self.zoomLevel > 6 then self.zoomLevel = 6; end
  self.scale = bit.blshift(1, self.zoomLevel);
  local zoomDelta = self.zoomLevel - prevZoomLevel;
  if zoomDelta < 0 then 
    self.worldX = self.worldX * 2;
    self.worldZ = self.worldZ * 2;
  elseif zoomDelta > 0 then
    self.worldX = self.worldX / 2;
    self.worldZ = self.worldZ / 2;
  end
  commands.tellraw("@a", "{\"text\":\"Zoom Level: " .. self.zoomLevel .. " ( 1 pixel = " .. self.scale .. " blocks)\"}");
  if zoomDelta ~= 0 then 
    self.display:rebuildContents();
  end
end

function Content:zoomIn()
  self:zoom(self.zoomLevel - 1);
end

function Content:zoomOut()
    self:zoom(self.zoomLevel + 1);
end

function Content:click(x, y, name)
  local scale = self.scale;
  local blocksW, blocksH = self.display:size(scale);
  x = x * scale;
  y = y * scale;
  local blockX = x - blocksW / 2 + self.worldX * 128 * scale;
  local blockZ = y - blocksH / 2 + self.worldZ * 128 * scale;
  
  b = terr.getBiome(blockX, blockZ);
  print(b);
  commands.tellraw(name, "{\"text\":\"[" .. blockX .. "," .. blockZ .."]: " .. b .. "\"}");
  return true;
end

function killPointer(p)
  commands.kill("@e[type=armor_stand,name=pointer" .. p .. "]");
end

function makePointer(p, x, y, z)
  commands.summon("armor_stand", x, y, z,
  "{" .. 
  "ShowArms:1," ..
  "Rotation:[180f, 0f]," ..
  "Pose:{LeftArm:[75f,180f,-45f]}," ..
  "NoGravity:1," ..
  "Invisible:1," ..
  "Marker:1," ..
  "CustomName:\"pointer" .. p .. "\"," ..
  "Small:1" ..
  "}"
  );
end

function movePointer(p, x, y, z)
  commands.entitydata(
  "@e[type=armor_stand,name=pointer" .. p .. "] " ..
  "{Pos:[" .. (x + 0.295) .. "d," .. (y + 0.495) .. "d," .. (z + 0.42) .. "d]}"
  );
end

function setPointerFlag(p, c)
  commands.entitydata(
  "@e[type=armor_stand,name=pointer" .. p .. "] " ..
  "{HandItems:[{},{Count:1,id:\"openblocks:flag\",Damage:" .. c .. "}]}"
  );
end

function keyboardInput()
  local x = 0;
  local y = 64;
  local z = -2;
  local color = 0;
  local step = 1 / 128;
  local pointer = 1;
  
  killPointer(pointer);
  makePointer(pointer, 0, 64, 0);
  setPointerFlag(pointer, 3);
  
  while true do
    print(x, y, z, color);
    movePointer(pointer, x, y, z);
    local event, param = os.pullEvent();
  
    if event == "key" then
      if param == 2 then
        x = x + step;
      elseif param == 3 then
        y = y + step;
      elseif param == 4 then
        z = z + step;
      elseif param == 5 then
        color = bit.band(color + 1, 0xf);
        setPointerFlag(pointer, color);
      elseif param == 16 then
        x = x - step;
      elseif param == 17 then
        y = y - step;
      elseif param == 18 then
        z = z - step;
      elseif param == 19 then
        color = bit.band(color - 1, 0xf);
        setPointerFlag(pointer, color);
      else
        print(param);
      end
    end
  end
end


centerPos = build.coord(0, 129, 0);
local mapBody = centerPos:cub():dunswe(2, 2, 0, 0, 2, 2, 0);
mapBody:dunswe(1, 1, 0, 0, 2, 2, 0):off(build.DIR.N):box();

local disp = Display:new(mapBody, build.DIR.S, 0);
--disp:build();

local content = Content:new();
disp:setContent(content);
disp:black();
disp:rebuildContents();

function makeButton(pos, action)
  local b = {};
  b.pos = pos;
  b.action = action;
  return b;
end

buttons = {};
buttons.right   = makeButton(build.coord( 3, 129, 0), function() disp:shiftLeft(); end);
buttons.left    = makeButton(build.coord(-3, 129, 0), function() disp:shiftRight(); end);
buttons.up      = makeButton(build.coord( 0, 132, 0), function() disp:shiftDown(); end);
buttons.down    = makeButton(build.coord( 0, 126, 0), function() disp:shiftUp(); end);
buttons.zoomIn  = makeButton(build.coord( 2, 126, 0), function() content:zoomIn(); end);
buttons.zoomOut = makeButton(build.coord( 3, 126, 0), function() content:zoomOut(); end);

while true do
  local event, name, id, hit, blk = os.pullEvent("remote_control");
  --print(name, id);
  --print("hit: ", hit.x, hit.y, hit.z);
  local handled = disp:input(hit, name);

  if not handled then
    for _,b in pairs(buttons) do
      if b.pos:eq(blk) then
        b.action();
        handled = true;
      end
    end
  end

end
