local xoffset = -0.5;
local zoffset = -0.5;
local scale = 16;
local mapW = 5;

for z = 0, mapW - 1 do
  for x = 0, mapW - 1 do
    shell.run("biomeMap.lua ", ((z * 5) + x), (x - 2) + xoffset, (z - 2) + zoffset, scale);
    sleep(0.05);
  end
end
