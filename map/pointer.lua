
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

local x = 0;
local y = 64;
local z = -2;
local color = 0;
local step = 1 / 128;
local pointer = ... or 1;

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
