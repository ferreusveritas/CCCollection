
terr = peripheral.find("terraformer");

file = io.open("biomeList.csv", "a");

for id = 0, 255 do
	local name = terr.getBiomeName(id);
    print(id, name);
	if name then
		file:write(id .. "," .. name, "\n");
	end
    sleep(0.05);
end

file:close();
