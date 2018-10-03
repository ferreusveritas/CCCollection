os.loadAPI("build/build.lua");

--API Aliases
function fif(cond, a, b) return build.fif(cond, a, b); end
function stairs(dir, inv) return build.getStairs(dir, inv); end
function dirMap(turns) return build.dirMap(turns); end

rotate = 0;
centerPos = build.coord(0, 90, 0);
compyPos = build.Coord:get();

build.setSync(true);
compyPos:dwn():cub():fill(build.sentinel);
build.setSync(false);

sent = peripheral.wrap("bottom");

local radius = 16 * 11; --11 Chunks radius
local types = {"spawn", "break", "place", "blast", "ender"};

for _,t in ipairs(types) do
  sent.addCylinderBounds(t, "no" .. t, centerPos.x, centerPos.z, 0, 255, radius);
end

compyPos:dwn():cub():erase();

commands.gamerule("logAdminCommands", false);
commands.gamerule("commandBlockOutput", false);
