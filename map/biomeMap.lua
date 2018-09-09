os.loadAPI("map/biomePalette.lua");

cart = peripheral.find("cartographer");
terr = peripheral.find("terraformer");

local args = {...};

local mapNum = tonumber(args[1]) or 0; -- Which map panel we are dealing with
local offsetX = tonumber(args[2]) or 0; -- Which map panel column we are dealing with
local offsetZ = tonumber(args[3]) or 0; -- Which map panel row we are dealing with
local scale = tonumber(args[4]) or 16; -- 1 Pixel = 16 Blocks(1 Chunk)
--local biomes = {};

cart.setMapNum(mapNum);

local mapScale = 0;
local scaleMapping = { [1] = 0, [2] = 1, [4] = 2, [8] = 3, [16] = 4 };

if scaleMapping[scale] ~= nil then
  mapScale = scaleMapping[scale];
else
  scale = 1;
end

cart.setMapScale(mapScale);

local mapSize = 128; --A minecraft map is always 128x128

local startX = offsetX * mapSize * scale;
local endX = (offsetX + 1) * mapSize * scale;
local startZ = offsetZ * mapSize * scale;
local endZ = (offsetZ + 1) * mapSize * scale;

local xCenter = bit.brshift(startX + endX, 1);
local zCenter = bit.brshift(startZ + endZ, 1);

cart.setMapCenter(xCenter, zCenter);

local ids = terr.getBiomeArray(startX, startZ, endX, endZ, scale);

for i, id in pairs(ids) do
  local iter = i - 1;
  colorIndex = biomePalette.colors[id + 1];
  local x = iter % 128;
  local y = math.floor(iter / 128);
  cart.setMapPixel(x, y, colorIndex);
end

cart.updateMap();
