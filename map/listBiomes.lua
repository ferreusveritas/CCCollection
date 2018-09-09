
terr = peripheral.find("terraformer");

file = io.open("biomeList.csv", "a");

for id = 0, 255 do
	local name = terr.getBiomeName(id);
	if name then
		file:write(id .. "," .. name, "\n");
	end
end

file:close();
