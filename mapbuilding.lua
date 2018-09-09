os.loadAPI("build/build.lua");

c = build.coord(0, 71, 0);
l = build.coord(c.x + 0, c.y - 3, c.z + 24);
height = 8;

function erase()
  build.killMaps(c.x - 8, c.y - 1, c.z - 8, c.x + 8, c.y + height + 16, c.z + 8);
  build.erase(c.x - 16, c.y, c.z - 16, c.x + 16, c.y + height + 16, c.z + 16);
  build.erase(c.x - 16, c.y - 8, c.z - 16, c.x + 16, c.y, c.z + 16);
  build.erase(l.x - 6, l.y - 6, l.z - 9, l.x + 6, l.y + 4, l.z + 6);
end


function land()
  build.pillarCuboid(c.x - 16, c.y - 8, c.z - 16, c.x + 16, c.y - 1, c.z + 16);
  build.fill(c.x - 15, c.y - 1, c.z - 15, c.x + 15, c.y - 1, c.z + 15, build.blockState("minecraft:grass", "snowy=false"));
  build.fence(c.x - 16, c.z - 16, c.x + 16, c.z + 16, c.y);

  --Staircase and railing
  build.pillarCuboid(c.x - 2, c.y - 2, c.z + 12, c.x + 2, c.y - 1, c.z + 16);
  build.erase(c.x - 1, c.y - 2, c.z + 14, c.x + 1, c.y + 1, c.z + 16);
  build.staircase(c.x - 1, c.z + 13, c.x + 1, c.z + 14, c.y - 2, build.stairs, {build.DIR.S});
  build.fence(c.x - 2, c.z + 12, c.x + 2, c.z + 16, c.y, {build.DIR.W, build.DIR.E});

  --Lower doors
  build.bigDoor(c.x + 11, c.y - 8, c.z + 16, build.DIR.S, {"l"});
  build.bigDoor(c.x - 11, c.y - 8, c.z + 16, build.DIR.S, {"l"});

  --Staircase from lower door
  build.pillarCuboid(c.x + 2, c.y - 8, c.z + 8, c.x + 12, c.y - 1, c.z + 12);
  build.fill(c.x + 11, c.y - 8, c.z + 8, c.x + 13, c.y - 2, c.z + 12, build.stone);
  build.erase(c.x + 3, c.y - 7, c.z + 9, c.x + 11, c.y, c.z + 11);
  build.erase(c.x + 12, c.y - 7, c.z + 9, c.x + 12, c.y - 2, c.z + 11);
  build.erase(c.x + 10, c.y - 8, c.z + 12, c.x + 12, c.y - 4, c.z + 15);
  build.staircase(c.x + 3, c.z + 9, c.x + 9, c.z + 11, c.y - 7, build.stairs, {build.DIR.E});
  build.doorHole(c.x + 11, c.y - 7, c.z + 12, 4, 3, build.DIR.S, {"s"});
  build.put(c.x + 11, c.y - 4, c.z + 14, build.blockState("rustic:chain", ""));
  build.lamp(c.x + 11, c.y - 5, c.z + 14, build.DIR.D);
  build.fence(c.x + 2, c.z + 8, c.x + 12, c.z + 12, c.y, { build.DIR.S, build.DIR.N, build.DIR.E });

  --Sidewalk
  build.fill(c.x - 2, c.y - 1, c.z + 8, c.x + 2, c.y - 1, c.z + 12, build.stone);
  build.loop(c.x - 2, c.z + 8, c.x + 2, c.z + 12, c.y - 1, build.stonechisel, build.stonepaver);
end


function foundation()
  build.fill(c.x - 8, c.y - 1, c.z - 8, c.x + 8, c.y - 1, c.z + 8, build.stone);
end


function exterior()
  build.loop(c.x - 8, c.z - 8, c.x + 8, c.z + 8, c.y, build.stone);
  build.pillarCuboid(c.x - 8, c.y + 1, c.z - 8, c.x + 8, c.y + height, c.z + 8);
  build.erase(c.x - 7, c.y, c.z - 7, c.x + 7, c.y + height - 1, c.z + 7);
  for i,dir in pairs(build.DIR.HORIZONTALS) do
    build.bigDoor(c.x + (dir.x * 8), c.y + 1, c.z + (dir.z * 8), dir, {"s", "l"});
  end
  build.loop(c.x - 7, c.z - 7, c.x + 7, c.z + 7, c.y + height, build.stoneknot);
  build.fill(c.x - 6, c.y + height, c.z - 6, c.x + 6, c.y + height, c.z + 6, build.glass);
  
  --Windows
  for _,crn in pairs(build.corners(c.x, c.y, c.z, 1)) do
    build.fill(c.x + (crn.x * 5), c.y + 3, c.z + (crn.z * 8), c.x + (crn.x * 5), c.y + height - 2, c.z + (crn.z * 8), build.glass);
    build.fill(c.x + (crn.x * 8), c.y + 3, c.z + (crn.z * 5), c.x + (crn.x * 8), c.y + height - 2, c.z + (crn.z * 5), build.glass);
  end
  
  --Building Top
  build.loop(c.x - 3, c.z - 3, c.x + 3, c.z + 3, c.y + height + 1, build.stonerailing);
  for _,crn in pairs(build.corners(0, 0, 0, 1)) do
    build.put(c.x + (crn.x * 3), c.y + height + 2, c.z + (crn.z * 3), build.stonerailing);
    build.put(c.x + (crn.x * 3), c.y + height + 3, c.z + (crn.z * 3), build.stonerailing);
  end
  for _,p in pairs(build.DIR.HORIZONTALS) do
    build.fill(c.x + (p.x * 3), c.y + height + 2, c.z + (p.z * 3), c.x + (p.x * 3), c.y + height + 3, c.z + (p.z * 3), build.stonerailing);
  end
  build.loop(c.x - 3, c.z - 3, c.x + 3, c.z + 3, c.y + height + 4, build.stonerailing);
  build.roof(c.x - 3, c.z - 3, c.x + 3, c.z + 3, c.y + height + 5, build.roofing, build.DIR.HORIZONTALS);
  build.put(c.x, c.y + height + 8, c.z, build.stonechisel);
  build.put(c.x, c.y + height + 9, c.z, build.stonerosette);
  build.put(c.x, c.y + height + 10, c.z, build.stonerailing);
  build.fill(c.x, c.y + height + 11, c.z, c.x, c.y + height + 13, c.z, build.lattice);
  
  --Railing and posts around top edge
  build.fence(c.x - 8, c.z - 8, c.x + 8, c.z + 8, c.y + height + 1);
  for _,crn in pairs(build.corners(c.x, c.y, c.z, 1)) do
    build.fill(c.x + (crn.x * 8), c.y + height + 1, c.z + (crn.z * 8), c.x + (crn.x * 8), c.y + height + 2, c.z + (crn.z * 8), build.stonechisel);
    build.put(c.x + (crn.x * 8), c.y + height + 3, c.z + (crn.z * 8), build.stonerosette);
    build.put(c.x + (crn.x * 8), c.y + height + 4, c.z + (crn.z * 8), build.stonerailing);
    build.fill(c.x + (crn.x * 8), c.y + height + 5, c.z + (crn.z * 8), c.x + (crn.x * 8), c.y + height + 6, c.z + (crn.z * 8), build.lattice);
  end
  
end


function interior()
  --Interior Pillars
  for _,crn in pairs(build.corners(0, 0, 0, 1)) do
    build.pillar(c.x + (crn.x * 3), c.y + 1, c.z + (crn.z * 3), height - 1);
    build.pillar(c.x + (crn.x * 3), c.y + 1, c.z + (crn.z * 7), height - 1);
    build.pillar(c.x + (crn.x * 7), c.y + 1, c.z + (crn.z * 3), height - 1);
  end
  build.loop(c.x - 3, c.z - 3, c.x + 3, c.z + 3, c.y + height, build.stonechisel, build.colFoot);

  --Flooring
  build.checker(c.x - 7, c.z - 7, c.x + 7, c.z + 7, c.y);
end


function furnish()
  --Build map display
  build.map5x5(c.x - 2, c.y + 2, c.z - 2);
  build.fill(c.x - 2, c.y + 1, c.z - 3, c.x + 2, c.y + 1, c.z - 3, build.stonewide);
  build.fill(c.x - 2, c.y + height - 1, c.z - 3, c.x + 2, c.y + height - 1, c.z - 3, build.stoneknot);
end


function mapBuilding()
  land();

  foundation();
  exterior();
  interior();
  furnish();
end

function landing()
  build.pillarCuboid(l.x - 6, l.y - 6, l.z - 8, l.x + 6, l.y, l.z + 6);
  build.fence(l.x - 6, l.z - 8, l.x + 6, l.z + 6, l.y + 1);
  build.loop(l.x - 4, l.z - 4, l.x + 4, l.z + 4, l.y, build.stonechisel);
  build.put(l.x, l.y, l.z, build.stonerosette);
  for _,corn in pairs(build.corners(l.x, l.y + 1, l.z, 3)) do
    build.lamppost(corn.x, corn.y, corn.z);
  end
  build.erase(l.x - 2, l.y + 1, l.z + 6, l.x + 2, l.y + 2, l.z + 6);
end

function setupSecurity()
  ccp = build.getPos();
  build.put(ccp.x, ccp.y + 1, ccp.z, build.sentinel);
  sentinel = peripheral.wrap("top");
  
  sentinel.addCuboidBounds("spawn", "test", c.x - 16, c.y - 32, c.z - 16, c.x + 16, c.y + 64, c.z + 16);
  sentinel.addCuboidBounds("blast", "test", c.x - 16, c.y - 32, c.z - 16, c.x + 16, c.y + 64, c.z + 16);
  sentinel.addCuboidBounds("break", "test", c.x - 16, c.y - 32, c.z - 16, c.x + 16, c.y + 64, c.z + 16);
  sentinel.addCuboidBounds("place", "test", c.x - 16, c.y - 32, c.z - 16, c.x + 16, c.y + 64, c.z + 16);
  sentinel.addCuboidBounds("ender", "test", c.x - 16, c.y - 32, c.z - 16, c.x + 16, c.y + 64, c.z + 16);
  
  build.put(ccp.x, ccp.y + 1, ccp.z, build.air);

  commands.setworldspawn(l.x, l.y + 1, l.z);
end

function setBiome()
  build.put(ccp.x, ccp.y + 1, ccp.z, build.terraformer);
  terra = peripheral.wrap("top");
  terra.setBiome(-16, -16, 16, 16, 2);
end

erase();
landing();
mapBuilding();
setupSecurity();

--/summon Item -100 71 278 {Item:{id:"dynamictrees:acaciaseed",Count:1,tag:{lifespan:100,forceplant:true,code:JOJxOJxJ+v0nf1t+k06+S1+nXb1+nf1uvy7+k0+XfyWnXb1+nf0mU7ny1uvXWnWvXet1770717} }}

