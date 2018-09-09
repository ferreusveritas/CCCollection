a = peripheral.wrap("top");

local bx, by, bz = commands.getBlockPosition();

local radius = 512;

local x1 = bx - radius;
local x2 = bx + radius - 1;
local z1 = bz - radius;
local z2 = bz + radius - 1;

local docW = x2 - x1 + 1;
local docH = z2 - z1 + 1;

local output = "test.pgm";

file = fs.open(output, "w");
file.writeLine("P2");

file.writeLine(string.format("%d", docW) .. " " .. string.format("%d", docH));
file.writeLine("255");
local lineWidth = 0;

for z = z1, z2 do
  local hArray = -1;

  while hArray == -1 do
    hArray = a.getYTopSolidArray(x1, z, x2, z, 1);
    if hArray == -1 then
      sleep(.1);
    end
  end

  for i, h in ipairs(hArray) do
    file.write(string.format("%d ", h));
    lineWidth = lineWidth + 1;
    if(lineWidth >= 16) then
      lineWidth = 0;
      file.write("\n");
    end
  end
  file.flush();
  sleep(0.1);
end

file.close();
