os.loadAPI("build/build.lua");

--API Aliases
function dirMap(turns) return build.dirMap(turns); end

dofile("config");
dofile("blocks");

local D, U, N, S, W, E = dirMap(0);

local compy = build.Coord:get();
local center = compy:off(N, radius + 3);
local vol = build.cuboid(center):grohor(radius + 3);

build.cuboid(compy:up()):gro(2,U):grohor():erase(); --Erase Monitors
build.cuboid(compy):grohor():loop(air); --Erase Base Around Computer
vol:gro(height + 2, U):shrhor():erase();
vol:gro(2, D):dwn():filla(sandstone);

--error(); --Uncomment to bail after erasing

vol:dwn():loop(hazardBlock);

vol = vol:shrhor():filla(platBlock);
vol = vol:shrhor():up():loop(frameBlock);
vol:gro(height + 1, U):box(air, frameBlock, frameBlock, frameBlock, frameBlock, frameBlock);
vol:shrhor():filla(wallBlock);

--TODO: Make glass ceiling

center = center:up();

build.cuboid(center):grohor():filla(ventBlock);
center:puta(dirt);

--Chamber walls
center:up():cylinder(wallBlock, radius, height);

build.cuboid(compy:up()):dunswe(0, 2, 1, 0, 1, 1):filla(frameBlock);
build.cuboid(compy):grohor():loop(platBlock);
build.cuboid(compy):off(S, 1):dunswe(0, 0, 0, 0, 1, 1):erase();

--Dendrocoil
compy:off(N, 1):put(build.blockState("mcf:dendrocoil",""));
build.cuboid(compy:off(N, 1):up()):gro(1, U):filla(frameBlock);

--Make monitors TODO:  Make monitor placement library
compy:up():putnbt(build.blockState("computercraft:peripheral", "variant=advanced_monitor_u"), "{dir:3,width:1,height:2,xIndex:0,yIndex:0}");
compy:up(2):putnbt(build.blockState("computercraft:peripheral", "variant=advanced_monitor_d"), "{dir:3,width:1,height:2,xIndex:0,yIndex:1}");

--os.reboot();
