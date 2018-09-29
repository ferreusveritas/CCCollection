a = peripheral.wrap("top");

function strsplit(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end

function readPgm(input)
  local file = fs.open(input, "r");
  local format = file.readLine();
  local data = {};
  
  if format ~= "P2" then return nil end
  
  local size;
  repeat
    size = file.readLine();
  until string.find( size, "#" ) == nil

  data.w = tonumber(string.match( size, "%d+" ));
  data.h = tonumber(string.match( size, "%s%d+"));
  data.maxVal = tonumber(file.readLine());
  data.data = {};
  
  local i = 0;
  for lineData in file.readLine do
    for k, value in pairs(strsplit(lineData)) do
      data.data[i] = value;
      i = i + 1;
    end
  end
  
  file.close();
  
  return data;
end

pgm = readPgm("heightmap.pgm");
halfx = pgm.w / 2;
halfz = pgm.h / 2;

for z = 0,pgm.h-1 do
  for x = 0,pgm.w-1 do
    local val = pgm.data[(z * pgm.w) + x];
    val = tonumber(val);
	if val ~= 0 then
      print(x, z, val);
      --commands.setBlock(x - 8, val, z - 8, "minecraft:diamond_block");
      commands.async.fill(x - halfx, 2, z - halfz, x - halfx, val, z - halfz, "minecraft:stone");
      local snowDepth = (val - 70) / 16;
      snowDepth = math.floor(snowDepth);
      if snowDepth < 1 then
        snowDepth = 0
      end
      if val > 65 then
        if snowDepth > 0 then 
          commands.async.fill(x - halfx, val - snowDepth, z - halfz, x - halfx, val, z - halfz, "minecraft:snow");
        else
          commands.async.setblock(x - halfx, val, z - halfz, "biomesoplenty:grass", "variant=overgrown_stone");
          commands.async.setblock(x - halfx, val + 1, z - halfz, "minecraft:snow_layer");
        end
      end
    end
  end
  sleep(0.1);
end


