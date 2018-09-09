----------------------------------------------------------------
-- TABLES                                                     --
----------------------------------------------------------------

function tableDump(t)
   if type(t) == 'table' then
      local s = '{ '
      for k,v in pairs(t) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. tableDump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(t)
   end
end

function testValues(t)
  local test = {};
  for i,e in pairs(t) do
    test[e] = true;
  end
  return test;
end

function fif(cond, a, b)
  if cond then
    return a;
  else
    return b;
  end
end

----------------------------------------------------------------
-- COORDINATES                                                --
----------------------------------------------------------------

Coord = {}
Coord.__index = Coord;

function Coord:new(x, y, z)
    local coord = {}             -- our new object
    setmetatable(coord, Coord)  -- make Account handle lookup
    -- initialize our object
    coord.x = x;
    coord.y = y;
    coord.z = z;
   return coord
end

function coord(...)
  if #arg == 3 then return Coord:new(arg[1], arg[2], arg[3]); end
  return Coord:new(0, 0, 0);
end

function Coord:__tostring()
  return "coord: [" ..
    self.x .. ", " ..
    self.y .. ", " ..
    self.z .. "]";
end

function Coord:cpy()
  return Coord:new(self.x, self.y, self.z);
end

function Coord:scale(amount)
  return Coord:new(self.x * amount, self.y * amount, self.z * amount);
end

function Coord:print()
  print(self);
  return self;
end

function Coord:get()
  local x, y, z = commands.getBlockPosition();
  return Coord:new(x, y, z);
end

function Coord:add(c)
  return Coord:new(self.x + c.x, self.y + c.y, self.z + c.z);
end

function Coord:sub(c)
  return Coord:new(self.x - c.x, self.y - c.y, self.z - c.z);
end

function Coord:mul(c)
  return Coord:new(self.x * c.x, self.y * c.y, self.z * c.z);
end

function Coord:rot(qturns, a)
  qturns = qturns or 1;
  local c = self;
  if a ~= nil then c = c:sub(a); end
  qturns = qturns % 4;
  if qturns == 0 then c = Coord:new( c.x, c.y,  c.z); end;
  if qturns == 1 then c = Coord:new(-c.z, c.y,  c.x); end;
  if qturns == 2 then c = Coord:new(-c.x, c.y, -c.z); end;
  if qturns == 3 then c = Coord:new( c.z, c.y, -c.x); end;
  if a ~= nil then c = c:add(a); end
  return c;
end

function Coord:mir(axis, a)
  local c = self;
  if a ~= nil then c = c:sub(a); end
  if axis.x ~= 0 then c = Coord:new(-c.x,  c.y,  c.z); end
  if axis.y ~= 0 then c = Coord:new( c.x, -c.y,  c.z); end
  if axis.z ~= 0 then c = Coord:new( c.x,  c.y, -c.z); end
  if a ~= nil then c = c:add(a); end
  return c;
end

function Coord:up(amount)
  return self:add(Coord:new(0, amount or 1, 0));
end

function Coord:dwn(amount)
  return self:add(Coord:new(0, amount or -1, 0));
end

function Coord:trn(turns, mirAxis, pos)
  return self:rot(turns or 0):mir(mirAxis or coord()):add(pos or coord());
end

----------------------------------------------------------------
-- DIRECTIONS                                                 --
----------------------------------------------------------------

AXIS = {
 X = Coord:new(1, 0, 0),
 Y = Coord:new(0, 1, 0),
 Z = Coord:new(0, 0, 1)
};

DIR = {
  D = {x =  0, y = -1, z =  0, n = "down", a = 'y'},
  U = {x =  0, y =  1, z =  0, n = "up", a = 'y'},
  N = {x =  0, y =  0, z = -1, n = "north", a = 'z'},
  S = {x =  0, y =  0, z =  1, n = "south", a = 'z'},
  W = {x = -1, y =  0, z =  0, n = "west", a = 'x'},
  E = {x =  1, y =  0, z =  0, n = "east", a = 'x'}
};
DIR.HORIZONTALS = { DIR.N, DIR.S, DIR.W, DIR.E };
DIR.OPPOSITES = { [DIR.N] = DIR.S, [DIR.S] = DIR.N, [DIR.W] = DIR.E, [DIR.E] = DIR.W };
DIR.ROTATE = { [DIR.D] = DIR.D, [DIR.U] = DIR.U, [DIR.N] = DIR.E, [DIR.S] = DIR.W, [DIR.W] = DIR.N, [DIR.E] = DIR.S };

function dirName(dir)
  return dir.n;
end

function dirLetter(dir)
  return string.sub(dirName(dir), 1, 1);
end

function dirAxis(dir)
  return dir.a;
end

function dirCoord(dir)
  return coord(dir.x, dir.y, dir.z);
end

function dirOpposite(dir)
  return DIR.OPPOSITES[dir];
end

function dirOppositeTable(dir)
  local r = {};
  for k,v in pairs(dirs) do
    r[k] = dirOpposite(v);
  end
  return r;
end

function dirRotate(dir, qturns)
  qturns = qturns or 1;
  qturns = qturns % 4;
  for i = 0, qturns - 1 do
    dir = DIR.ROTATE[dir];
  end
  return dir;
end

function dirRotateTable(dirs, qturns)
  local r = {};
  for k,v in pairs(dirs) do
    r[k] = dirRotate(v, qturns);
  end
  return r;
end

function dirMirror(dir, axis)
  if dir.a == axis then return dirOpposite(dir); end
  return dir;
end

function dirMirrorTable(dir, axis)
  local r = {};
  for k,v in pairs(dirs) do
    r[k] = dirMirror(v, axis);
  end
  return r;
end

function dirMap(turns)
  return
    dirRotate(DIR.D, turns),
    dirRotate(DIR.U, turns),
    dirRotate(DIR.N, turns),
    dirRotate(DIR.S, turns),
    dirRotate(DIR.W, turns),
    dirRotate(DIR.E, turns);
end

function Coord:off(amount, dir)
  amount = amount or 1;
  dir = dir or DIR.U;
  return self:add(coord(dir.x * amount, dir.y * amount, dir.z * amount));
end

----------------------------------------------------------------
-- BLOCKSTATES                                                --
----------------------------------------------------------------

function blockState(block, data)
  local a = {};
  a.block = block;
  a.data = data;
  return a;
end

function makeStairs(block, fillBlock)
  local s = {};
  s.n = blockState(block, "half=bottom,facing=north");
  s.s = blockState(block, "half=bottom,facing=south");
  s.w = blockState(block, "half=bottom,facing=west");
  s.e = blockState(block, "half=bottom,facing=east");
  s.ni = blockState(block, "half=top,facing=north");
  s.si = blockState(block, "half=top,facing=south");
  s.wi = blockState(block, "half=top,facing=west");
  s.ei = blockState(block, "half=top,facing=east");
  s.f = fillBlock;
  return s;
end

function makeSlabs(block, variant)
  local s = {};
  s.t = blockState(block, "half=top,variant="..variant);
  s.b = blockState(block, "half=bottom,variant="..variant);
  return s;
end

air = blockState("minecraft:air", "");
stone = blockState("minecraft:stone", "variant=stone");
stonebrick = blockState("minecraft:stonebrick", "variant=stonebrick");
stoneknot = blockState("cathedral:extras_block_stone", "variant=knot");
stonepaver = blockState("cathedral:extras_block_stone", "variant=paver");
stonechisel = blockState("chisel:stonebrick2", "variation=7");
stonecircular = blockState("chisel:stonebrick1", "variation=6");
stonerosette = blockState("minecraft:stonebrick", "variant=chiseled_stonebrick");
stonewide = blockState("chisel:stonebrick", "variation=3");
stonerailing = blockState("cathedral:cathedral_railing_various", "variant=stone");
glass = blockState("chisel:glass", "variation=2");
water = blockState("minecraft:water");
lattice = blockState("rustic:iron_lattice", "leaves=false");
chain = blockState("rustic:chain", "");

basaltpaver = blockState("cathedral:basalt_block_carved", "variant=paver");

cartographer = blockState("mcf:cartographer", "");
terraformer = blockState("mcf:terraformer", "");
sentinel = blockState("mcf:sentinel", "");

colFill = stone;
colBody = stoneknot;
colHead = stonerosette;
colFoot = stonepaver;
colBase = stonewide;
colCrwn = stonechisel;

tileOdd = stonepaver;
tileEven = basaltpaver;

railing = stonerailing;

roofing = makeStairs("cathedral:roofing_shingles_purple", stonebrick);
stairs = makeStairs("minecraft:stone_brick_stairs", stonebrick);
slab = makeSlabs("minecraft:stone_slab", "stone_brick");


----------------------------------------------------------------
-- CUBOIDS                                                    --
----------------------------------------------------------------

function sort(v1, v2)
  if(v1 > v2) then return v2, v1; else return v1, v2; end
end

Cuboid = {}
Cuboid.__index = Cuboid;

function Cuboid:new(c1, c2)
  local cuboid = {};             -- our new object
  setmetatable(cuboid, Cuboid);  -- make handle lookup
  c1 = c1:cpy();
  c2 = c2:cpy();
  c1.x, c2.x = sort(c1.x, c2.x);
  c1.y, c2.y = sort(c1.y, c2.y);
  c1.z, c2.z = sort(c1.z, c2.z);
  cuboid[1] = c1;
  cuboid[2] = c2;
  return cuboid;
end

function cuboid(...)
  if #arg == 1 then return Cuboid:new(arg[1], arg[1]); end
  if #arg == 2 then return Cuboid:new(arg[1], arg[2]); end
  if #arg == 6 then return Cuboid:newAll(arg[1], arg[2], arg[3], arg[4], arg[5], arg[6]); end
  return Cuboid:newAll(0, 0, 0, 0, 0, 0);
end

function Cuboid:__tostring()
  return "cuboid: [" ..
    self[1].x .. "," ..
    self[1].y .. "," ..
    self[1].z .. "," ..
    self[2].x .. "," ..
    self[2].y .. "," ..
    self[2].z .. "]";
end

function Cuboid:newAll(x1, y1, z1, x2, y2, z2)
  return Cuboid:new(Coord:new(x1, y1, z1), Coord:new(x2, y2, z2));
end

function Cuboid:print()
  print(self);
  return self;
end

function Cuboid:cpy()
  return Cuboid:new(self[1], self[2]);
end

function Cuboid:add(o)
  return Cuboid:new(self[1]:add(o), self[2]:add(o));
end

function Cuboid:sub(o)
  return Cuboid:new(self[1]:sub(o), self[2]:sub(o));
end

function Cuboid:rot(qturns, a)
  return Cuboid:new(self[1]:rot(qturns, a), self[2]:rot(qturns, a));
end

function Cuboid:mir(axis, a)
  return Cuboid:new(self[1]:mir(axis, a), self[2]:mir(axis, a));
end

function Cuboid:len(axis)
  if axis.x ~= 0 then return self[2].x - self[1].x + 1; end;
  if axis.y ~= 0 then return self[2].y - self[1].y + 1; end;
  if axis.z ~= 0 then return self[2].z - self[1].z + 1; end;
end

function Cuboid:gro(amount, dir)
  amount = amount or 1;
  if dir == nil then
    return self:gro(amount, coord(1, 1, 1)):gro(amount, coord(-1, -1, -1))
  end
  local c = self:cpy();
  if dir.x < 0 then c[1].x = c[1].x - amount; end
  if dir.y < 0 then c[1].y = c[1].y - amount; end
  if dir.z < 0 then c[1].z = c[1].z - amount; end
  if dir.x > 0 then c[2].x = c[2].x + amount; end
  if dir.y > 0 then c[2].y = c[2].y + amount; end
  if dir.z > 0 then c[2].z = c[2].z + amount; end
  return c;
end

function Cuboid:shr(amount, dir)
  amount = amount or 1;
  return self:gro(-amount, dir);
end

function Cuboid:off(amount, dir)
  amount = amount or 1;
  dir = dir or DIR.U;
  return self:add(coord(dir.x * amount, dir.y * amount, dir.z * amount));
end

function Cuboid:uni(c)
  return Cuboid:newAll(
    math.min(self[1].x, c[1].x),
    math.min(self[1].y, c[1].y),
    math.min(self[1].z, c[1].z),
    math.max(self[2].x, c[2].x),
    math.max(self[2].y, c[2].y),
    math.max(self[2].z, c[2].z)
  );
end

function Cuboid:fac(dir)
  local c = self:cpy();
  if dir.x > 0 then c = Cuboid:new(coord(c[2].x, c[1].y, c[1].z), c[2]); end
  if dir.y > 0 then c = Cuboid:new(coord(c[1].x, c[2].y, c[1].z), c[2]); end
  if dir.z > 0 then c = Cuboid:new(coord(c[1].x, c[1].y, c[2].z), c[2]); end
  if dir.x < 0 then c = Cuboid:new(c[1], coord(c[1].x, c[2].y, c[2].z)); end
  if dir.y < 0 then c = Cuboid:new(c[1], coord(c[2].x, c[1].y, c[2].z)); end
  if dir.z < 0 then c = Cuboid:new(c[1], coord(c[2].x, c[2].y, c[1].z)); end
  return c;
end

function Cuboid:cnr(c)
  return self:fac(Coord:new(-1, 0, -1):rot(c or 0));
end

function Cuboid:top()
  return self:fac(DIR.U);
end

function Cuboid:bot()
  return self:fac(DIR.D);
end

function Cuboid:up(amount)
  return self:off(amount, DIR.U);
end

function Cuboid:dwn(amount)
  return self:off(amount, DIR.D);
end

function Cuboid:trn(turns, mirAxis, pos)
  return self:rot(turns or 0):mir(mirAxis or coord()):add(pos or coord());
end

function Cuboid:dunswe(d, u, n, s, w, e, t)
  t = t or 0;
  return self
    :gro(d, dirRotate(DIR.D, t))
    :gro(u, dirRotate(DIR.U, t))
    :gro(n, dirRotate(DIR.N, t))
    :gro(s, dirRotate(DIR.S, t))
    :gro(w, dirRotate(DIR.W, t))
    :gro(e, dirRotate(DIR.E, t))
end

function Cuboid:grohor(amount)
  amount = amount or 1;
  return self:gro(amount, coord(-1, 0, -1)):gro(amount, coord(1, 0, 1));
end

function Cuboid:shrhor(amount)
  amount = amount or 1;
  return self:grohor(-amount);
end

----------------------------------------------------------------
-- BLOCK SETTERS                                              --
----------------------------------------------------------------

function Coord:put(state)
  commands.setblock(self.x, self.y, self.z, state.block, state.data);
  return self;
end

function Coord:puta(state)
  commands.async.setblock(self.x, self.y, self.z, state.block, state.data);
  return self;
end

function Coord:erase()
  return self:puta(air);
end

function Coord:putnbt(state, tag)
  commands.setblock(self.x, self.y, self.z, state.block, state.data, "replace", tag);
  return self;
end

--deprecated
function coordsSort(x1, y1, z1, x2, y2, z2)
  x1, x2 = sort(x1, x2);
  y1, y2 = sort(y1, y2);
  z1, z2 = sort(z1, z2);
  return x1, y1, z1, x2, y2, z2;
end

function Cuboid:fill(state)
  commands.fill(self[1].x, self[1].y, self[1].z, self[2].x, self[2].y, self[2].z, state.block, state.data);
  return self;
end

function Cuboid:filla(state)
  commands.async.fill(self[1].x, self[1].y, self[1].z, self[2].x, self[2].y, self[2].z, state.block, state.data);
  return self;
end

function Cuboid:erase()
  return self:filla(air);
end

function Cuboid:pillar(pBody, pFoot, pHead)
  self:filla(pBody or colBody);
  self:fac(DIR.D):filla(pFoot or colFoot);
  self:fac(DIR.U):filla(pHead or colHead);
  return self;
end

function Cuboid:checker()
  self:face(DIR.D):filla(tileOdd);
  for z = self[1].z, self[2].z do
    for x = self[1].x, self[2].x do
      if( ((x + z) % 2) == 0) then
        Coord:new(x, self[1].y, z):put(tileEven);
      end
    end
  end
  return self;
end

function Cuboid:loop(state, corners, sides)
  state = state or stone;
  sides = sides or {DIR.N, DIR.S, DIR.W, DIR.E};
  for _,side in pairs(sides) do
    self:fac(side):filla(state);
  end
  if(corners ~= nil) then
    for qturn = 0, 3 do
      self:fac(coord(-1, 0, -1):rot(qturn)):filla(corners);
    end
  end
  return self;
end

function Cuboid:fence(sides)
  sides = sides or {DIR.N, DIR.S, DIR.W, DIR.E};
  local work = self:bot();
  
  work:loop(stonerailing, stonerailing, sides);
  
  local xlen = work:len(AXIS.X) / 2;
  local zlen = work:len(AXIS.Z) / 2;
  local y = self[1].y + 1;
  
  for _,side in pairs(sides) do
    if(side == DIR.N) then
      for i = 0, xlen, 3 do
        coord(work[1].x + i, y, work[1].z):puta(stonerailing);
        coord(work[2].x - i, y, work[1].z):puta(stonerailing);
      end
    elseif(side == DIR.S) then
      for i = 0, xlen, 3 do
        coord(work[1].x + i, y, work[2].z):puta(stonerailing);
        coord(work[2].x - i, y, work[2].z):puta(stonerailing);
      end
    elseif(side == DIR.W) then
      for i = 0, zlen, 3 do
        coord(work[1].x, y, work[1].z + i):puta(stonerailing);
        coord(work[1].x, y, work[2].z - i):puta(stonerailing);
      end
    elseif(side == DIR.E) then
      for i = 0, zlen, 3 do
        coord(work[2].x, y, work[1].z + i):puta(stonerailing);
        coord(work[2].x, y, work[2].z - i):puta(stonerailing);
      end
    end
  end
  
end

function Cuboid:box(pFill, pBase, pCrwn, pBody, pFoot, pHead)
  self:filla(pFill or colFill); --Base Cuboid
  self:bot():loop(pBase or colBase); --Bottom Border
  self:top():loop(pCrwn or colCrwn); --Top Border
  for qturn = 0, 3 do
    self:cnr(qturn):pillar(pBody or colBody, pFoot or colFoot, pHead or colHead);
  end
  return self;
end

local rset = {};
rset[1] = { {0, 2}, {1, 2}, {2, 1} };
rset[2] = { {0, 2}, {1, 2}, {2, 1} };
rset[3] = { {0,3},{1,3},{2,3},{3,2},{3,1} };
rset[4] = { {0,4},{1,4},{2,4},{3,3},{4,2},{4,1} };
rset[5] = { {0,5},{1,5},{2,5},{3,4},{4,3},{5,2},{5,1} };
rset[6] = { {0,6},{1,6},{2,6},{3,5},{4,5},{5,4},{5,3},{6,2},{6,1} };
rset[7] = { {0,7},{1,7},{2,7},{3,6},{4,6},{5,5},{6,4},{6,3},{7,2},{7,1} };
rset[8] = { {0,8},{1,8},{2,8},{3,7},{4,7},{5,6},{6,5},{7,4},{7,3},{8,2},{8,1} };

function Coord:circle(block, r)
  for n, point in pairs(rset[r]) do
    self:add(coord( point[2], 0,  point[1])):puta(block);
    self:add(coord( point[1], 0, -point[2])):puta(block);
    self:add(coord(-point[1], 0,  point[2])):puta(block);
    self:add(coord(-point[2], 0, -point[1])):puta(block);
  end
end

function Coord:cylinder(block, r, h)
  for n, point in pairs(rset[r]) do
    cuboid(self:add(coord( point[2], 0,  point[1]))):gro(h, DIR.U):filla(block);
    cuboid(self:add(coord( point[1], 0, -point[2]))):gro(h, DIR.U):filla(block);
    cuboid(self:add(coord(-point[1], 0,  point[2]))):gro(h, DIR.U):filla(block);
    cuboid(self:add(coord(-point[2], 0, -point[1]))):gro(h, DIR.U):filla(block);
  end
end

function getStairs(dir, inv, stairsblocks)
  stairsblocks = stairsblocks or stairs;
  inv = inv or false;
  return stairsblocks[dirLetter(dir) .. fif(inv, "i", "")];
end

function Cuboid:roof(stairBlocks, sides)
  sides = sides or DIR.HORIZONTALS;
  local xlen = self:len(AXIS.X);
  local zlen = self:len(AXIS.Z);
  
  test = testValues(sides);
  
  if(test[DIR.W] and test[DIR.E]) then xlen = math.floor(xlen / 2); end
  if(test[DIR.N] and test[DIR.S]) then zlen = math.floor(zlen / 2); end
  
  local h = math.min(xlen, zlen);
  
  if(#sides == 1) then
    local lens = {x = xlen, z = zlen};
    local axis = sides[next(sides)].a;
    h = lens[axis];
  end
  local p = self:fac(DIR.D); --get bottom face

  for i = 1, h do
    for _,side in pairs(sides) do
      p:fac(side):filla(stairBlocks[dirLetter(dirOpposite(side))]);
      if p:len(side) > 1 then
        p = p:gro(-1, side);
      end
    end
    p = p:up(); --move up one block
  end
  
  return self;
end


function Cuboid:staircase(stairBlocks, sides, filler)
  sides = sides or DIR.HORIZONTALS;
  filler = filler or stairBlocks.f;
  
  local xlen = self:len(AXIS.X);
  local zlen = self:len(AXIS.Z);
  
  test = testValues(sides);
  
  if(test[DIR.W] and test[DIR.E]) then xlen = math.floor(xlen / 2); end
  if(test[DIR.N] and test[DIR.S]) then zlen = math.floor(zlen / 2); end
  
  local h = math.min(xlen, zlen);

  if(#sides == 1) then
    local lens = {x = xlen, z = zlen};
    local axis = sides[next(sides)].a;
    h = lens[axis];
  end
  
  local p = self:fac(DIR.D); --get bottom face

  for i = 1, h do
    for _,side in pairs(sides) do
      p:filla(filler);
      p:fac(side):filla(stairBlocks[dirLetter(dirOpposite(side))]);
      if p:len(side) > 1 then
        p = p:gro(-1, side);
      end
    end
    p = p:up(); --move up one block
  end
  return self;
end


function Cuboid:staircaseinv(stairBlocks, sides, filler)
  sides = sides or DIR.HORIZONTALS;
  filler = filler or stairBlocks.f;

  local xlen = self:len(AXIS.X);
  local zlen = self:len(AXIS.Z);
  
  test = testValues(sides);
  
  if(test[DIR.W] and test[DIR.E]) then xlen = math.floor(xlen / 2); end
  if(test[DIR.N] and test[DIR.S]) then zlen = math.floor(zlen / 2); end
  
  local h = math.min(xlen, zlen);

  if(#sides == 1) then
    local lens = {x = xlen, z = zlen};
    local axis = sides[next(sides)].a;
    h = lens[axis];
  end
  
  local p = self:fac(DIR.U); --get top face

  for i = 1, h do
    for _,side in pairs(sides) do
      p:filla(filler);
      p:fac(side):filla(stairBlocks[dirLetter(dirOpposite(side)) .. 'i']);
      if p:len(side) > 1 then
        p = p:gro(-1, side);
      end
    end
    p = p:dwn(); --move down one block
  end
  return self;
end

function Cuboid:doorHole(outDir, features)
  local test = testValues(features);
  local hasStairs = test.s or false;
  local hasLamps = test.l or false;
  
  self:box():shr():gro(1, outDir):gro(1, DIR.D):gro(1, dirOpposite(outDir)):erase();
  
  if hasStairs then
    self:fac(outDir):gro(1, DIR.D):box(air, getStairs(dirOpposite(outDir)));
  end

  if hasLamps then
    local lampBox = self:fac(outDir):add(outDir):fac(DIR.U);
    lampBox[1]:lamp(outDir);
    lampBox[2]:lamp(outDir);
  end
  
  return self;
  
end


function Coord:bigDoor(outDir, features, depth)
  depth = depth or 0;
  local cube = cuboid(self)
    :gro(2, dirRotate(outDir, 1))
    :gro(2, dirRotate(outDir, -1))
    :gro(3, DIR.U)
    :gro(depth, dirOpposite(outDir))
    :doorHole(outDir, features);
  self:puta(blockState("malisisdoors:big_door_spruce_3x3", "direction=" .. DIR.OPPOSITES[outDir].n ));
  return cube;
end

function Coord:lamp(dir)
  return self:puta(blockState("rustic:iron_lantern", "facing=" .. dir.n));
end

function Coord:lamppost(h)
  h = h or 3;
  cuboid(self):gro(h - 1, DIR.U):filla(lattice):top()[1]:lamp(DIR.U);
end


function killMaps(x1, y1, z1, x2, y2, z2)
  commands.kill("@e[type=item_frame,x=" .. x1 .. ",y=" .. y1 .. ",z=" .. z1 .. ",dx=" .. (x2 - x1 + 1) .. ",dy=" .. (y2 - y1 + 1) .. ",dz=" .. (z2 - z1 + 1) .. "]");
end


function map(mapX, mapY, mapZ, mapW, mapH)
  --Build wall behind map
  filla(mapX, mapY, mapZ, mapX + mapW - 1, mapY + mapH - 1, mapZ, air); --Clear a spot for the item frames
  filla(mapX, mapY, mapZ - 1, mapX + mapW - 1, mapY + mapH - 1, mapZ - 1, stonepaver); --Make a wall for the item frames to hang

  local mapNum = 0;

  --Populate wall with an array of maps in itemframes
  for y = mapH - 1, 0, -1 do
    for x = 0, mapW - 1 do
      commands.summon("item_frame", mapX + x, mapY + y, mapZ, "{Facing:0,Item:{id:\"minecraft:filled_map\",Damage:" .. mapNum .. ",Count:1}}");
      mapNum = mapNum + 1;
    end
  end

end


function map5x5(maxX, mapY, mapZ)
  map(maxX, mapY, mapZ, 5, 5);
end