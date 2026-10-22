if game.PlaceId ~= 114773467389373 then return "WRONGPLACE" end
local uses = {}
local function add(id, cls, name, top, layout)
	id = tostring(id):match("%d+$")
	if not id then return end
	local u = uses[id] or { n = 0, names = {}, tops = {}, cls = cls, layout = layout or "" }
	u.n += 1
	u.names[name] = true
	u.tops[top] = true
	uses[id] = u
end
for _, top in workspace.modern_vfx:GetChildren() do
	for _, d in top:GetDescendants() do
		if d:IsA("ParticleEmitter") then add(d.Texture, "PE", d.Name, top.Name, d.FlipbookLayout.Name)
		elseif d:IsA("Beam") or d:IsA("Trail") then add(d.Texture, d.ClassName, d.Name, top.Name)
		elseif d:IsA("Decal") and d.Parent.Name ~= "MeshFlipbooks" then add(d.Texture, "Decal", d.Parent.Name .. "/" .. d.Name, top.Name)
		elseif d:IsA("MeshPart") then add(d.MeshId, "Mesh", d.Name, top.Name)
		elseif d:IsA("SpecialMesh") then add(d.MeshId, "Mesh", d.Parent.Name, top.Name)
		end
	end
end
local out = {}
for id, u in uses do
	local names, tops = {}, {}
	for k in u.names do table.insert(names, k) end
	for k in u.tops do table.insert(tops, k) end
	table.insert(out, string.format("%s\t%s\t%d\t%s\t%s\t%s", u.cls, id, u.n, u.layout, table.concat(tops, ","), table.concat(names, " | "):sub(1, 120)))
end
table.sort(out)
return (string.gsub(table.concat(out, "\n"), "[^\n\t\32-\126]", "?"))
