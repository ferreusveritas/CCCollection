os.loadAPI("build/build.lua");

--API Aliases
function fif(cond, a, b) return build.fif(cond, a, b); end
function stairs(dir, inv) return build.getStairs(dir, inv); end
function dirMap(turns) return build.dirMap(turns); end

function landing(pos, turns, erase)
  local D, U, N, S, W, E = dirMap(turns);
  local vol = build.cuboid(-6, -6, -8, 6, 0, 6):trn(turns, dir, pos);

  if erase then
    vol:gro(4, U): erase();
    return;
  end
  
  print("building landing");  

  vol:box():top():up():fence();
  
  build.cuboid(pos):grohor(4):loop(build.stonechisel);
  pos:put(build.stonerosette);
  
  for i = 0, 3 do
    build.cuboid(pos):grohor(3):cnr(i)[1]:up():lamppost(4);
  end
  
  build.cuboid(pos):up():grohor(2):fac(S):off(4, S):gro(1, U):erase();
end

function land(pos, turns, erase)
  local D, U, N, S, W, E = dirMap(turns);

  local cube = build.cuboid(-16, -9, -16, 16, -1, 16):trn(turns, nil, pos);

  if erase then
    cube:gro(2, U):erase();
    cube:shr(3, D):gro(1, S):erase();
    return;
  end
  
  print("building land");

  cube:box();
  cube:top():shrhor(1):fill(build.blockState("minecraft:grass", "snowy=false"));
  cube:top():up():fence();
  
  --Staircase and railing
  local stairs = build.cuboid(-2, -2, 12, 2, -1, 16):trn(turns, nil, pos);
  stairs:box();
  stairs:dunswe(0, 2, -1, 0, -1, -1, turns):erase():shr(2, S):staircase(build.stairs, {S});
  stairs:top():up():fence({W, E});
  
  --Staircase from lower door
  local stairwell = build.cuboid(2, -8, 8, 12, -1, 12):trn(turns, nil, pos):box();
  stairwell:shr():gro(1, U):erase():shr(2, E):staircase(build.stairs, {E});
  stairwell:fac(E):shr(1, U):fill(build.stone);
  stairwell:shr():fac(E):add(E):erase();
  stairwell:top():up():fence({ build.DIR.S, build.DIR.N, build.DIR.E });

  --Lower doors
  for xi = 11, -11, -22 do
    local entry = build.coord(xi, -7, 16):trn(turns, nil, pos):bigDoor(S, {"l","s"}, 4);
      entry:bot():shr(1, S):dwn():fill(build.stone);
      entry:shrhor():up():erase():shr():up():fill(build.chain)[1]:dwn():lamp(D);
  end

  --Sidewalk
  build.cuboid(build.coord(0, 0, 10)):trn(turns, nil, pos):dwn():grohor(2):box();
end

function vault(pos, turns)
  local D, U, N, S, W, E = dirMap(turns);

  --Vaulted ceiling
  for qturn = 0, 3 do
    build.Cuboid:newAll(-3, 0, -3, -1, 7, -1)
      :trn(turns + qturn, nil, pos)
      :staircaseinv(build.stairs, build.dirRotateTable({S, E}, qturn));
  end

  --Archs  
  for qturn = 0, 3 do
     build.Cuboid:newAll(1, 0, -3, 2, 6, -3):trn(qturn + turns, nil, pos):staircaseinv(build.stairs, build.dirRotateTable({W}, qturn));
     build.Cuboid:newAll(-2, 0, -3, -1, 6, -3):trn(qturn + turns, nil, pos):staircaseinv(build.stairs, build.dirRotateTable({E}, qturn));
  end
  
  build.Cuboid:newAll(-3, 7, -3, 3, 7, 3):trn(turns, nil, pos):loop(build.stonebrick);
  
  local f = build.Cuboid:newAll(-3, 0, -3, 3, 9, 3):trn(turns, nil, pos);
  
  f:fac(U):gro(1, D):fill(build.stonebrick);
  
  for qturn = 0, 3 do
    f:cnr(qturn):top():gro(5, D):pillar();
    f:cnr(qturn):bot():gro(4, U):pillar();
  end
  
  f:fac(U):loop(build.stonechisel, build.stonerosette);
end

function pool(x, y, z)
  build.loop(x - 2, z - 2, x + 2, z + 2, y, build.stonechisel, build.stonerosette);
  build.fill(x - 2, y - 1, z - 2, x + 2, y - 1, z + 2, build.stone);
  build.fill(x - 1, y, z - 1, x + 1, y, z + 1, build.water);
  for _,corn in pairs(build.corners(x, y + 1, z, 2)) do
    build.lamppost(corn.x, corn.y, corn.z, 2);
  end
  build.loop(x - 1, z - 1, x + 1, z + 1, y - 3, build.stonechisel, build.stonerosette);
end

function watertower()
  build.loop(c.x - 9, c.z - 15, c.x + 9, c.z + 3, c.y - 1, build.stonechisel, build.stonerosette);
  for y = 0, 170, 10 do
  build.loop(c.x - 9, c.z - 15, c.x + 9, c.z + 3, c.y + y, build.stonerailing, build.stonerailing);
    for z = -12, 0, 6 do
      for x = -6, 6, 6 do
        vault(c.x + x, c.y + y, c.z + z);
      end
    end
	build.checker(c.x - 8, c.z - 14, c.x  + 8, c.z + 2, c.y - 1 + y);
    pool(c.x, c.y + y, c.z - 6);
  end
  pool(c.x, c.y + 180, c.z - 6); --Pool on top
  build.erase(c.x, c.y + 1, c.z - 6, c.x, c.y + 180, c.z - 6); --Make a water shaft through all of the floors
end

function naveceiling(pos, turns)
  turns = turns + 1;--Module was built facing west.  Standard is north, add 1 to compensate.
  local D, U, N, S, W, E = dirMap(turns);

  for _,flip in ipairs({false, true}) do
    local dir = fif(flip, N, build.coord(0, 0, 0));

    build.coord(-4, 0, -3)
      :trn(turns, dir, pos)
      :put(build.stonerailing)
      :up()
      :put(build.stonepaver);

    build.cuboid(-6, 2, -3, -4, 3, -2)
      :trn(turns, dir, pos)
      :staircaseinv(build.stairs, fif(flip,{N, W}, {S, W}));

    build.cuboid(-5, 2, -3, -4, 2, -3):trn(turns, dir, pos):fill(build.stonebrick);
    build.cuboid(-7, 4, -3, -4, 8, -2):trn(turns, dir, pos):fill(build.stonebrick);
    build.coord(-7, 4, -2):trn(turns, dir, pos):put(stairs(fif(flip, S, N), true));
    build.coord(-7, 4, -3):trn(turns, dir, pos):put(stairs(E, true));
    build.coord(-8, 5, -3):trn(turns, dir, pos):put(build.stonebrick)
       :add(fif(flip, N, S))
       :put(stairs(fif(flip, S, N), true));
    
    build.cuboid(-9, 5, -2, -9, 5, -3):trn(turns, dir, pos):fill(build.slab.t);
    
    build.cuboid(-10, 8, -3, -4, 6, -1):trn(turns, dir, pos):fill(build.stonebrick)
      :bot()
      :fac(fif(flip, N, S))
      :fill(stairs(fif(flip, S, N), true));

    build.cuboid(-11, 6, -3, -11, 6, -1):trn(turns, dir, pos):fill(build.slab.t);

  end
  
  build.cuboid(-11, 7, -3, -4, 8, 3):trn(turns, nil, pos):fill(build.stonebrick);  --Very Top
end

function clearstory(pos, turns)
  local D, U, N, S, W, E = dirMap(turns);

  local j = build.Cuboid:newAll(-3, 0, -3, 3, 12, 3):trn(turns, nil, pos):fac(N):fill(build.stonebrick);
  for qturn = 0, 3 do
    j:cnr(qturn):bot():gro(3, U):pillar(build.stonechisel, build.stonechisel);
  end

  j:dunswe(-1, -3, 0, 0, -1, -1, turns):box(build.glass, build.stonecircular, build.glass, build.stonecircular);
end

function triforium(pos, turns)
  local D, U, N, S, W, E = dirMap(turns);
  local tri = build.Cuboid:newAll(-3, 9, -3, 3, 14, 3)
    :trn(turns, nil, pos)
    :fac(N)
    :box(build.stonebrick)
    :shr(1, U)
    :shr(1, D);

  tri:fac(E):off(2, W):fill(build.stonerailing);
  tri:fac(W):off(2, E):fill(build.stonerailing);
end

function roof(pos, turns)
  local D, U, N, S, W, E = dirMap(turns);
  build.Cuboid:newAll(-3, 0, -2, 3, 6, 3):trn(turns, nil, pos):up(10):roof(build.roofing, {S});
end

function aisle(pos, turns, erase)
  turns = turns or 0;
  if erase then
    build.cuboid( -3,  0, -3,  3, 32, 3):trn(turns, nil, pos):erase();
    build.cuboid(-3, 10, -11, 3, 32, 3):trn(turns, nil, pos):erase();
  else
    roof(pos, turns);
    triforium(pos, turns);
    clearstory(pos:up(15), turns);
    vault(pos, turns);
    naveceiling(pos:up(19), turns);
  end
end

function cathedralSection(pos, turns, erase)
  aisle(pos:add(build.coord(-11, 0, 0):rot(turns)), turns + 1, erase);
  aisle(pos:add(build.coord( 11, 0, 0):rot(turns)), turns - 1, erase);
end

function cathedral(pos, turns, erase)
  if not erase then print("building cathedral"); end
  turns = turns or 0;
  for z = 0,-12,-6 do
    local pos = pos:add(build.coord(0, 0, z)):rot(turns);
    cathedralSection(pos, turns, erase);
  end
end

function scene(pos, turns, erase)
  landingPos = pos:add(build.coord(0, -3, 24)):rot(turns);
  landing(landingPos, turns, erase);
  land(pos, turns, erase);
  cathedral(pos, turns, erase);
end

rotate = 0;
centerPos = build.coord(0, 71, 0);
--centerPos = centerPos:add(build.coord(0, 64, 0));
scene(centerPos, rotate, true);
scene(centerPos, rotate, false);

--watertower();
