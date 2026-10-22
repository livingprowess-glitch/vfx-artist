local TARGET = "__PATH__"

local function resolve(path)
	local node = game
	for seg in string.gmatch(path, "[^%.]+") do
		node = node:FindFirstChild(seg)
		if not node then return nil end
	end
	return node
end

local function r(n) return math.floor(n * 1000 + 0.5) / 1000 end
local function c3(c)
	if c.R > 1 or c.G > 1 or c.B > 1 then return string.format("hdr(%s,%s,%s)", r(c.R), r(c.G), r(c.B)) end
	return string.format("#%02X%02X%02X", math.round(c.R * 255), math.round(c.G * 255), math.round(c.B * 255))
end
local function v3(v) return string.format("(%s,%s,%s)", r(v.X), r(v.Y), r(v.Z)) end
local function v2(v) return string.format("(%s,%s)", r(v.X), r(v.Y)) end
local function nr(n) return n.Min == n.Max and tostring(r(n.Min)) or (r(n.Min) .. ".." .. r(n.Max)) end
local function cs(s)
	local t = {}
	for _, k in s.Keypoints do table.insert(t, r(k.Time) .. ":" .. c3(k.Value)) end
	return "[" .. table.concat(t, " ") .. "]"
end
local function ns(s)
	local t, kps = {}, s.Keypoints
	local step = #kps > 8 and math.ceil(#kps / 6) or 1
	for i, k in kps do
		if (i - 1) % step == 0 or i == #kps then
			table.insert(t, r(k.Time) .. ":" .. r(k.Value) .. (k.Envelope ~= 0 and ("~" .. r(k.Envelope)) or ""))
		end
	end
	return "[" .. table.concat(t, " ") .. "]" .. (step > 1 and ("(" .. #kps .. "pts)") or "")
end
local function cf(c, base)
	local rel = base and base:ToObjectSpace(c) or c
	local rx, ry, rz = rel:ToOrientation()
	return string.format("pos%s rot(%s,%s,%s)", v3(rel.Position), r(math.deg(rx)), r(math.deg(ry)), r(math.deg(rz)))
end

local EASINGS = {
	["0,0,1,1"] = "linear",
	["0.215,0.61,0.355,1"] = "outCubic",
	["0.42,0,0.58,1"] = "inOut",
	["0.42,0,1,1"] = "in",
	["0,0,0.58,1"] = "out",
	["0.25,0.1,0.25,1"] = "ease",
	["0.755,0.05,0.855,0.06"] = "inQuint",
	["0.23,1,0.32,1"] = "outQuint",
	["0.165,0.84,0.44,1"] = "outQuart",
	["0.19,1,0.22,1"] = "outExpo",
	["0.55,0.055,0.675,0.19"] = "inCubic",
	["0.645,0.045,0.355,1"] = "inOutCubic",
	["0.25,0.25,0.75,0.75"] = "linear",
}

local function fmt(v)
	local t = typeof(v)
	if t == "Color3" then return c3(v)
	elseif t == "Vector3" then return v3(v)
	elseif t == "Vector2" then return v2(v)
	elseif t == "NumberRange" then return nr(v)
	elseif t == "NumberSequence" then return ns(v)
	elseif t == "ColorSequence" then return cs(v)
	elseif t == "EnumItem" then return v.Name
	elseif t == "number" then return tostring(r(v))
	elseif t == "Instance" then return v.Name
	elseif t == "CFrame" then return cf(v)
	elseif t == "string" and string.find(v, "[^\32-\126]") and #v % 4 == 0 then
		local b, f = buffer.fromstring(v), {}
		for i = 0, #v - 4, 4 do table.insert(f, r(buffer.readf32(b, i))) end
		local wild = false
		for _, x in f do if math.abs(x) > 1e6 then wild = true break end end
		if wild and #v % 8 == 0 then
			local ids = {}
			for i = 0, #v - 8, 8 do table.insert(ids, string.format("%d", buffer.readf64(b, i))) end
			return "f64[" .. table.concat(ids, ",") .. "]"
		end
		if #f == 12 and f[1] == 0 and f[2] == 1 and f[7] == 1 and f[8] == 0 then
			local key = f[3] .. "," .. r(1 - f[4]) .. "," .. f[5] .. "," .. r(1 - f[6])
			return "bezier(" .. key .. ")" .. (EASINGS[key] and ("=" .. EASINGS[key]) or "")
		end
		return "f32[" .. table.concat(f, ",") .. "]"
	end
	return tostring(v)
end

local PROPS = {
	ParticleEmitter = { "Enabled", "Texture", "Color", "Transparency", "Size", "Squash", "LightEmission", "LightInfluence", "Brightness", "ZOffset", "Rate", "Lifetime", "Speed", "SpreadAngle", "Rotation", "RotSpeed", "Acceleration", "Drag", "VelocityInheritance", "LockedToPart", "EmissionDirection", "Shape", "ShapeStyle", "ShapeInOut", "ShapePartial", "Orientation", "FlipbookLayout", "FlipbookMode", "FlipbookFramerate", "FlipbookStartRandom", "TimeScale", "WindAffectsDrag" },
	Beam = { "Enabled", "Attachment0", "Attachment1", "Texture", "TextureMode", "TextureLength", "TextureSpeed", "Color", "Transparency", "Width0", "Width1", "CurveSize0", "CurveSize1", "Segments", "FaceCamera", "LightEmission", "LightInfluence", "Brightness", "ZOffset" },
	Trail = { "Enabled", "Attachment0", "Attachment1", "Texture", "TextureMode", "TextureLength", "Color", "Transparency", "Lifetime", "MinLength", "MaxLength", "WidthScale", "FaceCamera", "LightEmission", "LightInfluence", "Brightness" },
	Part = { "Shape", "Size", "Color", "Material", "Transparency", "Reflectance", "CastShadow", "Anchored", "CanCollide" },
	MeshPart = { "MeshId", "TextureID", "Size", "Color", "Material", "Transparency", "Reflectance", "CastShadow", "Anchored", "CanCollide", "DoubleSided" },
	SpecialMesh = { "MeshType", "MeshId", "TextureId", "Scale", "Offset", "VertexColor" },
	Decal = { "Texture", "Face", "Color3", "Transparency", "ZIndex" },
	Highlight = { "FillColor", "FillTransparency", "OutlineColor", "OutlineTransparency", "DepthMode", "Adornee", "Enabled" },
	PointLight = { "Color", "Brightness", "Range", "Shadows", "Enabled" },
	Attachment = {},
	Motor6D = { "Part0", "Part1", "C0", "C1" },
	SurfaceAppearance = { "ColorMap", "AlphaMode", "Color" },
	RayValue = { "Value" },
}

local root = resolve(TARGET)
if not root then return "NOT FOUND " .. TARGET end
local rootCf = root:IsA("BasePart") and root.CFrame or (root:IsA("Model") and root:GetPivot()) or nil

local out = {}
local DEFAULTS = {}
local ALWAYS = { Enabled = true, Color = true, Color3 = true, FillColor = true, OutlineColor = true, FillTransparency = true, OutlineTransparency = true, Texture = true, Size = true, LightEmission = true, Transparency = true }
local SKIP_VALUES = { [""] = true, ["false"] = true, ["0"] = true, ["[0:0 1:0]"] = true, ["(0,0,0)"] = true, ["(0,0)"] = true, ["None"] = true }
local SKIP_KEYS = { PestoId = true, Qwinkle = true, Transformed = true, PreloadTexture = true, LinkMode = true, OldId = true }
local function walk(inst, depth)
	local pad = string.rep("  ", depth)
	local line = pad .. inst.Name .. " <" .. inst.ClassName .. ">"
	local list = PROPS[inst.ClassName]
	local bits = {}
	if inst:IsA("BasePart") then table.insert(bits, "cf=" .. cf(inst.CFrame, rootCf)) end
	if inst:IsA("Attachment") then table.insert(bits, "local=" .. cf(inst.CFrame)) end
	if list then
		if DEFAULTS[inst.ClassName] == nil then
			local okn, made = pcall(Instance.new, inst.ClassName)
			DEFAULTS[inst.ClassName] = okn and made or false
		end
		local def = DEFAULTS[inst.ClassName]
		local okd = def ~= false
		for _, p in list do
			local ok, v = pcall(function() return inst[p] end)
			if ok and v ~= nil and v ~= "" then
				local s = fmt(v)
				if not (okd and fmt(def[p]) == s) or ALWAYS[p] then table.insert(bits, p .. "=" .. s) end
			end
		end
	end
	local attrs = {}
	for k, v in inst:GetAttributes() do
		local s = fmt(v)
		if not (SKIP_VALUES[s] or string.sub(k, 1, 1) == "_" or SKIP_KEYS[k]) then table.insert(attrs, "@" .. k .. "=" .. s) end
	end
	table.sort(attrs)
	table.move(attrs, 1, #attrs, #bits + 1, bits)
	for _, tag in inst:GetTags() do table.insert(bits, "#" .. tag) end
	if #bits > 0 then line ..= " | " .. table.concat(bits, " ; ") end
	table.insert(out, line)
	for _, ch in inst:GetChildren() do walk(ch, depth + 1) end
end
walk(root, 0)
local text = string.gsub(table.concat(out, "\n"), "[^\n\t\32-\126]", function(ch) return string.format("\\x%02X", string.byte(ch)) end)
return text
