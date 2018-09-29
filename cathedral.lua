os.loadAPI("build/build.lua");

--API Aliases
function fif(cond, a, b) return build.fif(cond, a, b); end
function stairs(dir, inv) return build.getStairs(dir, inv); end
function dirMap(turns) return build.dirMap(turns); end

rotate = 0;
centerPos = build.coord(0, 124, 0);

--[[
function landing(pos, turns, erase)
  local D, U, N, S, W, E = dirMap(turns);
  local vol = build.cuboid(-6, -6, -8, 6, 0, 6):trn(turns, dir, pos);

  if erase then
    vol:gro(U, 4): erase();
    return;
  end
  
  print("building landing");  

  vol:box():top():up():fence();
  
  build.cuboid(pos):grohor(4):loop(build.stonechisel);
  pos:put(build.stonerosette);
  
  for i = 0, 3 do
    build.cuboid(pos):grohor(3):cnr(i)[1]:up():lamppost(4);
  end
  
  build.cuboid(pos):up():grohor(2):fac(S):off(S, 4):gro(U):erase();
end
]]--

--[[
function land(pos, turns, erase)
  local D, U, N, S, W, E = dirMap(turns);

  local cube = build.cuboid(-16, -9, -16, 16, -1, 16):trn(turns, nil, pos);

  if erase then
    cube:gro(U, 2):erase();
    cube:shr(D, 3):gro(S):erase();
    return;
  end
  
  print("building land");

  cube:box();
  cube:top():shrhor(1):fill(build.blockState("minecraft:grass", "snowy=false"));
  cube:top():up():fence();
  
  --Staircase and railing
  local stairs = build.cuboid(-2, -2, 12, 2, -1, 16):trn(turns, nil, pos);
  stairs:box();
  stairs:dunswe(0, 2, -1, 0, -1, -1, turns):erase():shr(S, 2):staircase(build.stairs, {S});
  stairs:top():up():fence({W, E});
  
  --Staircase from lower door
  local stairwell = build.cuboid(2, -8, 8, 12, -1, 12):trn(turns, nil, pos):box();
  stairwell:shr():gro(U):erase():shr(E, 2):staircase(build.stairs, {E});
  stairwell:fac(E):shr(U):fill(build.stone);
  stairwell:shr():fac(E):add(E):erase();
  stairwell:top():up():fence({ build.DIR.S, build.DIR.N, build.DIR.E });

  --Lower doors
  for xi = 11, -11, -22 do
    local entry = build.coord(xi, -7, 16):trn(turns, nil, pos):bigDoor(S, {"l","s"}, 4);
      entry:bot():shr(S):dwn():fill(build.stone);
      entry:shrhor():up():erase():shr():up():fill(build.chain)[1]:dwn():lamp(D);
  end

  --Sidewalk
  build.cuboid(build.coord(0, 0, 10)):trn(turns, nil, pos):dwn():grohor(2):box();
end
]]--

function vault(pos, turns)
  local D, U, N, S, W, E = dirMap(turns);

  --Vaulted ceiling
  for qturn = 0, 3 do
    build.Cuboid:newAll(-3, 0, -3, -1, 7, -1)
      :trn(turns + qturn, nil, pos)
      :stairsinv(build.stairs, build.dirRotateTable({S, E}, qturn));
  end

  --Archs  
  for qturn = 0, 3 do
     build.Cuboid:newAll(1, 0, -3, 2, 6, -3):trn(qturn + turns, nil, pos):stairsinv(build.stairs, build.dirRotateTable({W}, qturn));
     build.Cuboid:newAll(-2, 0, -3, -1, 6, -3):trn(qturn + turns, nil, pos):stairsinv(build.stairs, build.dirRotateTable({E}, qturn));
  end
  
  build.Cuboid:newAll(-3, 7, -3, 3, 7, 3):trn(turns, nil, pos):loop(build.stonebrick);
  
  local f = build.Cuboid:newAll(-3, 0, -3, 3, 9, 3):trn(turns, nil, pos);
  
  f:fac(U):gro(D):fill(build.stonebrick);
  
  for qturn = 0, 3 do
    f:cnr(qturn):top():gro(D, 5):pillar();
    f:cnr(qturn):bot():gro(U, 4):pillar();
  end
  
  f:fac(U):loop(build.stonechisel, build.stonerosette);
end

function naveCeiling(pos, turns)
  turns = turns + 1;--Module was built facing west.  Standard is north, add 1 to compensate.
  local D, U, N, S, W, E = dirMap(turns);

  for _,flip in ipairs({false, true}) do
    local dir = fif(flip, N, build.coord(0, 0, 0));

    build.coord(-4, 0, -3)
      :trn(turns, dir, pos)
      :cub()
      :fill(build.stonerailing)
      :up()
      :fill(build.stonepaver);

    build.cuboid(-6, 2, -3, -4, 3, -2)
      :trn(turns, dir, pos)
      :stairsinv(build.stairs, fif(flip,{N, W}, {S, W}));

    build.cuboid(-5, 2, -3, -4, 2, -3):trn(turns, dir, pos):fill(build.stonebrick);
    build.cuboid(-7, 4, -3, -4, 6, -2):trn(turns, dir, pos):fill(build.stonebrick);
    build.coord(-7, 4, -2):trn(turns, dir, pos):cub():fill(stairs(fif(flip, S, N), true));
    build.coord(-7, 4, -3):trn(turns, dir, pos):cub():fill(stairs(E, true));
    build.coord(-8, 5, -3):trn(turns, dir, pos):cub():fill(build.stonebrick)
       :add(fif(flip, N, S))
       :fill(stairs(fif(flip, S, N), true));
    
    build.cuboid(-9, 5, -2, -9, 5, -3):trn(turns, dir, pos):fill(build.slab.t);
    
    build.cuboid(-10, 6, -3, -4, 7, -1):trn(turns, dir, pos):fill(build.stonebrick)
      :bot()
      :fac(fif(flip, N, S))
      :fill(stairs(fif(flip, S, N), true));

    build.cuboid(-11, 6, -3, -11, 6, -1):trn(turns, dir, pos):fill(build.slab.t);

  end
  
  build.cuboid(-11, 7, -3, -4, 7, 3):trn(turns, nil, pos):fill(build.stonebrick);  --Very Top
end

function clearstory(pos, turns)
  local D, U, N, S, W, E = dirMap(turns);

  local j = build.Cuboid:newAll(-3, 0, -3, 3, 11, 3):trn(turns, nil, pos):fac(N):fill(build.stonebrick);
  for qturn = 0, 3 do
    j:cnr(qturn):bot():gro(U, 3):pillar(build.stonechisel, build.stonechisel);
  end

  j:dunswe(-1, -3, 0, 0, -1, -1, turns):box(build.glass, build.stonecircular, build.glass, build.stonecircular);
end

function triforium(pos, turns)
  local D, U, N, S, W, E = dirMap(turns);
  local tri = build.Cuboid:newAll(-3, 9, -3, 3, 14, 3)
    :trn(turns, nil, pos)
    :fac(N)
    :box(build.stonebrick)
    :shr(U)
    :shr(D);

  tri:fac(E):off(W, 2):fill(build.stonerailing);
  tri:fac(W):off(E, 2):fill(build.stonerailing);
end

function aisleRoof(pos, turns)
  local D, U, N, S, W, E = dirMap(turns);
  build.Cuboid:newAll(-3, 0, -2, 3, 6, 3):trn(turns, nil, pos):up(10):roof(build.roofing, {S});
end

function naveRoof(pos, turns, hw)
  hw = hw or 3; --halfwidth
  local D, U, N, S, W, E = dirMap(turns);
  local vol = pos:cub():dunswe(0, 0, 0, 0, hw, hw, turns):roof(build.stairs, {S});
  vol = vol:off(N):up():gro(N, 6):roof(build.roofing, {S});
  vol:up(5):stairsinv(build.stairs, {N}, 0);
  vol = vol:fac(N):up(6):off(N):fill(build.stonebrick):up():fill(build.smoothslab.b);
end

function aisleFacade(pos, turns, bottom, h)
  print("Aisle Facade: " .. tostring(pos));
  local D, U, N, S, W, E = dirMap(turns);
  local h = h or 8;
  local vol = pos:up():cub():gro(W, 2):gro(E, 2):fill(build.stonebrick)
  vol:shr():fill(build.stoneknot);
  vol:up():stairs(build.stairs, {S});
  
  local pvol = pos:up(2):cub():gro(U, h - 3);
  pvol:pillar(build.stonedent, build.stonepaver, build.stonerosette);
  pvol:off(W, 2):pillar(build.stonedent, build.stonepaver, build.stonerosette);
  pvol:off(E, 2):pillar(build.stonedent, build.stonepaver, build.stonerosette);
  pvol:off(W, 1):shr(D):fill(build.barsornate);
  pvol:off(E, 1):shr(D):fill(build.barsornate);

  local wtop = pvol:top():up():off(N):gro(E):gro(W);
  wtop:stairsinv(build.stairs, {N}):dwn():erase();
  wtop = wtop:off(S):stairsinv(build.stairs, {S});

  --Top of window facade
  pvol:top():up():fill(build.stonebrick);
  wtop = wtop:gro(E):gro(W);
  wtop:fac(E):fill(build.stonebrick);
  wtop:fac(W):fill(build.stonebrick);
  wtop:up():fill(build.stonebrick);
  wtop = wtop:up():off(S):gro(D,h):box(build.air, build.air, build.stonedent, build.stonecircular, build.paver, build.stonerosette);
  wtop:top():dwn():mid():stairsinv(build.stairs, {S});
  
  --Railing and walkway header of window facade
  whead = wtop:top():up();
  whead:off(N):stairs(build.stairs, {S});
  whead:stairsinv(build.stairs, {S});
  whead:up():fill(build.stonerailing):mid():up():fill(build.stonerailing);
  for _,d in ipairs({W, E}) do
    whead:fac(d):fill(build.stonepaver);
  end

  --Bottom of window facade
  if bottom then
    local wbot = wtop:bot():dwn():gro(D,2);
    for _,d in ipairs({W, E}) do
      wbot:fac(d):fill(build.stoneknot):bot():dwn():fill(build.stonerosette):dwn():stairsinv(build.stairs, {build.dirOpposite(d)});
      wbot:fac(d):shr(D):off(N):fill(build.stonebrick):bot():off(N):fill(build.stonebrick);
    end
  
    wbot = wbot:mid():off(N):dunswe(-1, 0, 1, 0, 1, 1, turns);
    wbot:erase():stairsinv(build.stairs, {S}, build.stone);

    wbot = wbot:fac(S):mid():gro(U):gro(D);
    wbot:fill(build.stonedent):bot():fill(build.stonerosette):dwn():gro(D):fill(build.stonerailing);
  end

end

function aisle(pos, turns)
  local D, U, N, S, W, E = dirMap(turns);
  pos = pos:up(2);
  turns = turns or 0;
  aisleRoof(pos, turns);
  triforium(pos, turns);
  clearstory(pos:up(15), turns);
  vault(pos, turns);
  naveCeiling(pos:up(19), turns);
  naveRoof(pos:up(27):off(N, 3), turns);
  aisleFacade(pos:off(S, 4):dwn(), turns, true);
end

function cathedralSection(pos, turns)
  turns = turns or 0;
  aisle(pos:add(build.coord(-11, 0, 0):rot(turns)), turns + 1);
  aisle(pos:add(build.coord( 11, 0, 0):rot(turns)), turns - 1);
end

function cathedralRow(pos, sections, turns)
  turns = turns or 0;
  for z = 0,((sections-1)*6),6 do
    local pos = pos:add(build.coord(0, 0, z)):rot(turns);
    cathedralSection(pos, turns);
  end
end

function cathedralWings(pos, turns)
  print("  Cathedral Wings: " .. tostring(pos));
  turns = turns or 0;

  cathedralRow(pos, 4, turns);
  cathedralRow(pos, 2, turns + 1);
  cathedralRow(pos, 2, turns + 2);
  cathedralRow(pos, 2, turns + 3);
end

function cathedralInsideCorner(pos, turns)
  print("  Cathedral Inside Corner: " .. tostring(pos));
  local D, U, N, S, W, E = dirMap(turns);

  local roofCube = pos:up(10):cub():grohor(3):gro(U,6);
  roofCube:roof(build.roofing, {S});
  roofCube:roof(build.roofing, {E});
  roofCube:shr(S):dwn():stairsinv(build.stairs, {N}, 0);
  roofCube:shr(E):dwn():stairsinv(build.stairs, {W}, 0);
  roofCube:shr(S, 2):stairs(build.airstairs, {S});
  roofCube:shr(E, 2):stairs(build.airstairs, {E});

  --Fill the gap between the modules
  roofCube:fac(S):off(S):roof(build.roofing, {E});
  roofCube:fac(E):off(E):roof(build.roofing, {S});
  
  local roofPos = pos:up(27):off(N, 3);

  for t = -1,0 do
    triforium(pos, turns + t);
    clearstory(pos:up(15), turns + t);
    naveCeiling(pos:up(19), turns + t);
    naveRoof(roofPos:rot(t, pos), turns + t);
  end
  naveRoof(roofPos:rot(-1, pos):off(S, 4), turns - 1, 0);
  naveRoof(roofPos:rot(0, pos):off(E, 4), turns, 0);

  vault(pos, 0);

  local pill1 = pos:off(W, 3):off(S, 4):cub():gro(U, 30);
  pill1:dunswe(0, 0, 0, 0, 1, 1, turns):fill(build.stonecircular):bot():fill(build.stonepaver);
  pill1:fill(build.stone);

  local pill2 = pos:off(N, 3):off(E, 4):cub():gro(U, 30);
  pill2:dunswe(0, 0, 1, 1, 0, 0, turns):fill(build.stonecircular):bot():fill(build.stonepaver);
  pill2:fill(build.stone);

  pillar(pos:off(W, 4):off(N, 4), 30, build.stonecircular);
end

function hallHalf(pos, turns)
  print("Hall Half: " .. tostring(pos));
  local D, U, N, S, W, E = dirMap(turns);
  local h = 20;
  aisleFacade(pos, turns, false, h);
  local roof = pos:up(h + 2):cub():gro(W, 2):gro(E, 2):fill(build.stonebrick);
  roof = roof:up():gro(N, 5):roof(build.roofing, {S}):up(4):shr(S):stairsinv(build.stairs, {N}, 0);
  roof = roof:fac(N):off(N):up():fill(build.stonebrick);
  roof = roof:up():fill(build.stonechisel);
  roof:off(S):stairsinv(build.stairs, {S}):up():fill(build.stonerailing);
  roof:off(N):stairsinv(build.stairs, {N}):up():fill(build.stonerailing);
end

function hallSection(pos, turns)
  print("Hall Section: " .. tostring(pos));
  turns = turns or 0;
  local offset = 6
  hallHalf(pos:add(build.coord(-offset, 0, 0):rot(turns)), turns + 1);
  hallHalf(pos:add(build.coord(offset, 0, 0):rot(turns)), turns - 1);
end

function hallRibbingHalf(pos, turns)
  local D, U, N, S, W, E = dirMap(turns);
  local h = 20;
  h = h + 1;
  local body = pos:up():cub():gro(U,h);
  body = body:gro(S,2):gro(N):box():top():up():off(N):gro(N,2):stairs(build.stairs, {S});
  body = body:gro(U,5):fac(N):off(N);
  body:fill(build.stonebrick):top():up():stairsinv(build.stairs, {S}):up():gro(U):fill(build.stonerailing);
  body:gro(N):fill(build.stonebrick);
end

function hallRibbing(pos, turns)
  turns = turns or 0;
  local offset = 6
  hallRibbingHalf(pos:add(build.coord(-offset, 0, 0):rot(turns)), turns + 1);
  hallRibbingHalf(pos:add(build.coord(offset, 0, 0):rot(turns)), turns - 1);
end

function hallRow(pos, sections, turns)
  local D, U, N, S, W, E = dirMap(turns);
  turns = turns or 0;
  for z = 0,((sections-1)*6),6 do
    local pos1 = pos:add(build.coord(0, 0, z)):rot(turns);
    hallSection(pos1, turns);
  end
  
  for z = 0,((sections)*6),6 do
    local pos2 = pos:add(build.coord(0, 0, z-3)):rot(turns);
    hallRibbing(pos2, turns);
  end
  
end

function hallWings(pos, turns)
  print("Hall Wings: " .. tostring(pos));
  local D, U, N, S, W, E = dirMap(turns);
  pos = pos:dwn();

  hallRow(pos, 3, turns + 1);
  hallRow(pos, 3, turns + 3);
end

function hangingTreePlanter(pos, turns)
  print("Planter: " .. tostring(pos));
  local D, U, N, S, W, E = dirMap(turns);
  local body = pos:cub():grohor():fill(build.stonechisel);
  body:up():shr(N):fill(build.railing):fac(S):up():fill(build.railing):mid():erase();
  pos:cub():fill(build.dirt):up():erase();
  body:dwn():fill(build.stonewide):fac(S):mid():fill(build.stoneknot);
  body:dwn(2):stairsinv(build.stairs, {N,S,W,E})
    :mid():dwn():gro(D):fill(build.stonedent)
    :bot():dwn():fill(build.stonepaver)
    :dwn():fill(build.stonerailing)
    :dwn():mid():fill(build.blockState("quark:iron_rod","facing=down,connected=true"))
    :dwn():fill(build.blockState("quark:iron_rod","facing=down,connected=false"))
  
  --JJJxxJOOPXzf1vnyWR8P1qQ8hJ7eJz87c
  --JJxxOJOOJ+f1vnU+bw+Lvj6WWXvh7rfmb188xOb6Xy8
  --JJxxxxxOOfXnz+Xt8+WRXnrPkx8z8x67eZfmPn
end

function treePlanters(pos, turns)
  local D, U, N, S, W, E = dirMap(turns);
  
  for _,dir in ipairs({E, W}) do
    for _,side in ipairs({S, N}) do
      local planter = pos:dwn():off(dir, 34):off(side, 15):off(dir,3);
      for i = 0,2 do
        local t = turns;
        if side == N then t = turns + 2 end;
        hangingTreePlanter(planter, t);
        planter = planter:off(dir,6);
      end
    end
  end

end

function cathedral(pos, turns)
  print("Cathedral: " .. tostring(pos));
  local D, U, N, S, W, E = dirMap(turns);
  
  local wingOffset = pos:off(S, 19);
  cathedralWings(wingOffset, turns);
  
  for i = 0,3 do
    cornoff = build.coord(11, 0, 11):up(2):rot(i);
    cathedralInsideCorner(pos:add(cornoff), turns + i);
  end
  
  hallWings(pos:off(S, 37), turns);

  treePlanters(pos, turns);
end

function mainPlatform(pos, turns)
  print("Main Platform: " .. tostring(pos));
  local D, U, N, S, W, E = dirMap(turns);
  local platWidth = 15;
  local platSpan = 33;
  local roundOffset = 32;
  local plat = build.cuboid(pos):dunswe(0, 1, platWidth, platWidth, platSpan, platSpan, turns);
  local cross = build.cuboid(pos):dunswe(0, 1, roundOffset, 47, platWidth, platWidth, turns);
  
  plat:fill(build.stone);

  for _,dir in ipairs({E, W}) do
    local decor = plat:fac(dir):dwn(2):gro(dir, 20):fill(build.stone); --Create the base platform
    for _,side in ipairs({S, N}) do
      decor:shr(build.dirOpposite(dir)):fac(build.coord():up():off(side)):fill(build.stonedent)
        :dwn():stairsinv(build.stairs, {side})
        :up(2):fill(build.stonerailing);
    end
  end
  
  cross:fill(build.stone);
  pos:off(N, roundOffset):cylinder(build.stone, 15, 2, true):up():cub():fill(build.stonerosette);
  pos:up():cub():fill(build.stonerosette);
end

function spawnPlatform(pos, turns)
  print("Spawn Platform: " .. tostring(pos));
  local D, U, N, S, W, E = dirMap(turns);
  pos = pos:dwn(3);
  pos:cub():grohor(7):gro(D):box();
  pos:cub():fill(build.stonerosette);

  for i = 0, 3 do
    pos:cub():grohor(3):cnr(i)[1]:up():lamppost(4);
  end

  commands.setworldspawn(pos.x, pos.y + 1, pos.z);
end

function pillar(pos, h, block)
  h = h - 1;
  pos:cub():dunswe(0, h, 0, 0, 1, 1):fill(block):bot():fill(build.stonepaver);
  pos:cub():dunswe(0, h, 1, 1, 0, 0):fill(block):bot():fill(build.stonepaver);
end

function scene(pos, turns)
  print("Scene: " .. tostring(pos));
  local D, U, N, S, W, E = dirMap(turns);
  --mainPlatform(pos, turns);
  --spawnPlatform(pos:off(S, 67), turns);
  --cathedral(pos, turns);
end

function sideEntrance(pos, turns, height)
  local D, U, N, S, W, E = dirMap(turns);
  local body = pos:cuboid():gro(U, height - 1);
  body:gro(W):gro(E):fill(build.stonepaver):shr(U,3):shr(D):fill(build.stonecircular);
  body:shr(U,3):fill(build.stoneknot):top():fill(build.stonepaver);
  body:bot():up(2):staircaseinv(build.stairs,{S});
  body:bot()
    :mid():puta(build.blockState("biomesoplenty:cherry_door_block", "facing=" .. build.dirName(S) .. ",half=lower"))
    :up():puta(build.blockState("biomesoplenty:cherry_door_block", "facing=" .. build.dirName(S) .. ",half=upper"));
  local face = body:off(S):top():gro(D);
  face:gro(E):gro(W):fill(build.stonerailing);
  face:fill(build.stoneknot):gro(D, 2):bot():staircaseinv(build.stairs,{S}):up():fill(build.stonerosette);
  
  body = body:off(N);
  body:gro(E):gro(W):fill(build.stonepaver):shr(D):bot():gro(U, 3):fill(build.stonedent);
  body:off(N):gro(E):gro(W):shr(D, 5):fill(build.stonebrick):bot():staircaseinv(build.stairs, {N});
  
  pos:off(N):cuboid():gro(U,4):erase()
    :top():fill(build.stonepaver)
    :dwn():fill(build.stoneknot)
    :dwn():staircaseinv(build.stairs, {N});
  
  pos:up(4):off(N, 2):put(build.blockState("rustic:iron_lantern", "facing=" .. build.dirName(N)));
end

function tower(pos, turns, height)
  height = height or 2;
  height = height - 1;
  local D, U, N, S, W, E = dirMap(turns);
  pos:cuboid():grohor(2):gro(U, height):box();
end


--build.setErase(true);

--test = build.coord(-37, 125, 15);
--hangingTreePlanter(test, 0);




--towertest = build.coord(31, 126, 7);
--tower(towertest, 0, 30);

--towertest2 = build.coord(31, 126, 14);
--towertest2:cuboid():dunswe(0, 8, 1, 2, 2, 2, rotate):box();

scene(centerPos, rotate);
