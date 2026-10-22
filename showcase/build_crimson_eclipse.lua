if game.PlaceId ~= 114773467389373 then return "WRONGPLACE" end

local AssetService = game:GetService("AssetService")
local RS = game:GetService("ReplicatedStorage")

local CRIMSON = Color3.fromRGB(255, 35, 64)
local CRIMSON_DEEP = Color3.fromRGB(122, 10, 28)
local TEAL = Color3.fromRGB(51, 255, 224)
local BLACK = Color3.new(0, 0, 0)
local WHITE = Color3.new(1, 1, 1)
local GREY = Color3.fromRGB(163, 162, 165)

local function ns(...)
	local a, k = { ... }, {}
	for i = 1, #a, 2 do table.insert(k, NumberSequenceKeypoint.new(a[i], a[i + 1])) end
	return NumberSequence.new(k)
end
local function cs(...)
	local a, k = { ... }, {}
	for i = 1, #a, 2 do table.insert(k, ColorSequenceKeypoint.new(a[i], a[i + 1])) end
	return ColorSequence.new(k)
end
local function nr(a, b) return NumberRange.new(a, b or a) end

local corpus = workspace.modern_vfx
local sourceByTex = {}
for _, d in corpus:GetDescendants() do
	if d:IsA("ParticleEmitter") then
		local id = d.Texture:match("%d+$")
		if id and not sourceByTex[id] then sourceByTex[id] = d end
	end
end

local KEEP = { FlipbookLayout = true, FlipbookMode = true, FlipbookFramerate = true, FlipbookStartRandom = true }
local RESET = { "Color", "Transparency", "Size", "Squash", "LightEmission", "LightInfluence", "Brightness", "ZOffset", "Rate", "Lifetime", "Speed", "SpreadAngle", "Rotation", "RotSpeed", "Acceleration", "Drag", "VelocityInheritance", "LockedToPart", "EmissionDirection", "Shape", "ShapeStyle", "ShapeInOut", "ShapePartial", "Orientation", "TimeScale", "Enabled", "WindAffectsDrag" }
local fresh = Instance.new("ParticleEmitter")
local missing = {}

local function pe(parent, name, tex, props, attrs)
	local src = sourceByTex[tostring(tex)]
	local e
	if src then
		e = src:Clone()
		for _, c in e:GetChildren() do c:Destroy() end
		for k in e:GetAttributes() do e:SetAttribute(k, nil) end
		for _, p in RESET do e[p] = fresh[p] end
		for _, t in e:GetTags() do e:RemoveTag(t) end
	else
		e = Instance.new("ParticleEmitter")
		e.Texture = "rbxassetid://" .. tex
		table.insert(missing, tostring(tex))
	end
	e.Name = name
	e.Enabled = false
	for k, v in props do e[k] = v end
	for k, v in attrs do e:SetAttribute(k, v) end
	e.Parent = parent
	return e
end

local meshSizes = {}
local function meshPart(id)
	for _, d in corpus:GetDescendants() do
		if d:IsA("MeshPart") and d.MeshId:match("%d+$") == tostring(id) then
			local m = d:Clone()
			for _, c in m:GetChildren() do c:Destroy() end
			for k in m:GetAttributes() do m:SetAttribute(k, nil) end
			return m
		end
	end
	return AssetService:CreateMeshPartAsync("rbxassetid://" .. id)
end
local function nativeSize(id)
	if not meshSizes[id] then
		local m = meshPart(id)
		meshSizes[id] = m.MeshSize
		m:Destroy()
	end
	return meshSizes[id]
end

local function cfAt(y, yaw) return CFrame.new(0, y, 0) * CFrame.Angles(0, math.rad(yaw or 0), 0) end

local function meshModel(parent, name, m)
	local model = Instance.new("Model")
	model.Name = name
	model:SetAttribute("EmitDelay", m.delay)
	model:SetAttribute("Duration", m.dur)
	model:SetAttribute("Easing", m.easing or "Quad")
	model:SetAttribute("EasingDirection", m.dir or "Out")
	local function make(which, cf, size, t)
		local p
		if m.decal then
			p = Instance.new("Part")
			p.Size = Vector3.new(1, 1, 1)
			p.Transparency = 1
			local sm = Instance.new("SpecialMesh")
			sm.MeshType = Enum.MeshType.FileMesh
			sm.MeshId = "rbxassetid://" .. m.id
			sm.Scale = size / nativeSize(m.id)
			sm.Parent = p
			local d = Instance.new("Decal")
			d.Name = "Decal"
			d.Texture = "rbxassetid://" .. m.decal.tex
			d.Face = Enum.NormalId.Top
			d.Color3 = m.decal.color
			d.Transparency = t
			d.Parent = p
		else
			p = meshPart(m.id)
			p.Size = size
			p.Color = m.color
			p.Material = m.material or Enum.Material.Neon
			p.Transparency = t
			p.DoubleSided = true
		end
		p.Name = which
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.CFrame = cf * (m.rot or CFrame.identity)
		p.Parent = model
	end
	make("Start", m.from[1], m.from[2], m.from[3])
	make("End", m.to[1], m.to[2], m.to[3])
	model.Parent = parent
end

local old = RS.VFX:FindFirstChild("CrimsonEclipse")
if old then old:Destroy() end

local fx = Instance.new("Model")
fx.Name = "CrimsonEclipse"
local root = Instance.new("Part")
root.Name = "Root"
root.Size = Vector3.new(1, 1, 1)
root.Transparency = 1
root.Anchored = true
root.CanCollide = false
root.CFrame = CFrame.identity
root.Parent = fx
fx.PrimaryPart = root

local function att(name, y)
	local a = Instance.new("Attachment")
	a.Name = name
	a.Position = Vector3.new(0, y, 0)
	a.Parent = root
	return a
end
local ground = att("Ground", 0.15)
local core = att("Core", 3)

local shell = Instance.new("Part")
shell.Name = "ChargeShell"
shell.Shape = Enum.PartType.Ball
shell.Size = Vector3.new(26, 26, 26)
shell.CFrame = CFrame.new(0, 3, 0)
shell.Transparency = 1
shell.Anchored = true
shell.CanCollide = false
shell.Parent = fx

local floor = Instance.new("Part")
floor.Name = "ChargeFloor"
floor.Size = Vector3.new(16, 0.2, 16)
floor.CFrame = CFrame.new(0, 0.1, 0)
floor.Transparency = 1
floor.Anchored = true
floor.CanCollide = false
floor.Parent = fx

local ring = Instance.new("Part")
ring.Name = "DustRing"
ring.Shape = Enum.PartType.Cylinder
ring.Size = Vector3.new(0.5, 4, 4)
ring.CFrame = CFrame.new(0, 0.6, 0) * CFrame.Angles(0, 0, math.rad(90))
ring.Transparency = 1
ring.Anchored = true
ring.CanCollide = false
ring.Parent = fx

local SPHERE_IN = { Shape = Enum.ParticleEmitterShape.Sphere, ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface, ShapeInOut = Enum.ParticleEmitterShapeInOut.Inward }

local function merge(a, b) local t = table.clone(a) for k, v in b do t[k] = v end return t end

pe(shell, "ChargeStreaks", 16002249604, merge(SPHERE_IN, { Color = cs(0, CRIMSON, 1, CRIMSON), LightEmission = 0, Brightness = 40, Size = ns(0, 0, 0.2, 0.9, 1, 0), Squash = ns(0, -1.5, 1, -2.5), Orientation = Enum.ParticleOrientation.VelocityParallel, Speed = nr(40, 55), Lifetime = nr(0.25, 0.32), Rate = 90 }), { EmitDuration = 0.55 })
pe(shell, "ChargeStreaksDark", 16002249604, merge(SPHERE_IN, { Color = cs(0, WHITE, 1, WHITE), LightEmission = 0, Brightness = 0, Size = ns(0, 0, 0.2, 1.1, 1, 0), Squash = ns(0, -1.5, 1, -2.5), Orientation = Enum.ParticleOrientation.VelocityParallel, Speed = nr(36, 50), Lifetime = nr(0.27, 0.34), Rate = 40, ZOffset = -0.5 }), { EmitDuration = 0.55 })
pe(core, "ChargeGlow", 1075864321, { Color = cs(0, CRIMSON, 1, CRIMSON), LightEmission = 1, Brightness = 3, Size = ns(0, 0, 1, 9), Transparency = ns(0, 0.9, 0.85, 0.15, 1, 1), Lifetime = nr(0.68), Speed = nr(0), ZOffset = 1 }, { EmitCount = 1 })
pe(core, "ChargeImplode", 107821950776778, { Color = cs(0, CRIMSON, 1, CRIMSON_DEEP), LightEmission = -5, Brightness = 30, Size = ns(0, 11, 1, 0.5), Transparency = ns(0, 1, 0.3, 0.2, 1, 0), Lifetime = nr(0.68), Speed = nr(0), ZOffset = 0.5 }, { EmitCount = 1 })
pe(floor, "ChargeSpecs", 17826438728, { Color = cs(0, CRIMSON, 1, CRIMSON_DEEP), LightEmission = -3, Brightness = 15, Size = ns(0, 0, 0.3, 1.2, 1, 0), Speed = nr(2, 6), Acceleration = Vector3.new(0, 8, 0), Drag = 1, SpreadAngle = Vector2.new(30, 30), Lifetime = nr(0.5, 0.8), Rate = 30, Rotation = nr(-360, 360), RotSpeed = nr(-400, 400), ShapeStyle = Enum.ParticleEmitterShapeStyle.Volume }, { EmitDuration = 0.55 })

pe(core, "AnticipationGlints", 17230437889, { Color = cs(0, CRIMSON, 1, CRIMSON), LightEmission = -3, Brightness = 50, Size = ns(0, 1, 1, 12), Squash = ns(0, -3, 1, -3), Orientation = Enum.ParticleOrientation.VelocityParallel, Speed = nr(0.001), SpreadAngle = Vector2.new(360, 360), Lifetime = nr(0.05, 0.08) }, { EmitCount = 12, EmitDelay = 0.62 })

pe(core, "CoreFlash", 1075864321, { Color = cs(0, TEAL, 1, TEAL), LightEmission = 1, Brightness = 6, Size = ns(0, 40, 1, 0), Lifetime = nr(0.08), Speed = nr(0), ZOffset = 6 }, { EmitCount = 1, EmitDelay = 0.7 })
pe(core, "ImpactStar", 78043674430474, { Color = cs(0, CRIMSON, 1, CRIMSON), LightEmission = 0, Brightness = 25, Size = ns(0, 0, 0.3, 34, 1, 38), Transparency = ns(0, 0, 0.6, 0, 1, 1), Lifetime = nr(0.1), Speed = nr(0), Rotation = nr(-360, 360), ZOffset = 5 }, { EmitCount = 1, EmitDelay = 0.7 })
pe(core, "ImpactStarDark", 78043674430474, { Color = cs(0, WHITE, 1, WHITE), LightEmission = 0, Brightness = 0, Size = ns(0, 0, 0.3, 38, 1, 42), Transparency = ns(0, 0, 0.6, 0, 1, 1), Lifetime = nr(0.12), Speed = nr(0), Rotation = nr(-360, 360), ZOffset = 4.9 }, { EmitCount = 1, EmitDelay = 0.7 })

local SLASH = { LightEmission = -1, Brightness = 25, Size = ns(0, 0, 0.2, 9, 1, 0), Orientation = Enum.ParticleOrientation.VelocityParallel, Speed = nr(90, 150), SpreadAngle = Vector2.new(60, 60), Drag = 8, Acceleration = Vector3.new(0, -60, 0), Lifetime = nr(0.3, 0.45), TimeScale = 0.85, Color = cs(0, CRIMSON, 0.6, Color3.fromRGB(176, 16, 42), 1, BLACK) }
pe(core, "SlashA", 125589219124561, merge(SLASH, { Squash = ns(0, -1, 1, -2) }), { EmitCount = 2, EmitDelay = 0.7 })
pe(core, "SlashB", 125933365360022, merge(SLASH, { Squash = ns(0, 0, 0.3, -2.5, 1, -1) }), { EmitCount = 2, EmitDelay = 0.7 })
pe(core, "SlashC", 82694450715960, merge(SLASH, { Squash = ns(0, -0.5, 1, -3) }), { EmitCount = 2, EmitDelay = 0.7 })
pe(core, "SlashDark", 125589219124561, merge(SLASH, { Color = cs(0, WHITE, 1, WHITE), Brightness = 0, LightEmission = 0, Size = ns(0, 0, 0.2, 10, 1, 0), Speed = nr(80, 130), Acceleration = Vector3.new(0, -30, 0), ZOffset = -0.5, Squash = ns(0, -1.2, 1, -2.2) }), { EmitCount = 2, EmitDelay = 0.7 })

local FLAT = { Orientation = Enum.ParticleOrientation.VelocityPerpendicular, EmissionDirection = Enum.NormalId.Top, Speed = nr(0.001) }
pe(ground, "GroundRing", 6862984716, merge(FLAT, { Color = cs(0, CRIMSON, 1, CRIMSON), LightEmission = 0, Brightness = 12, Size = ns(0, 0, 1, 32), Transparency = ns(0, 0, 0.5, 0.2, 1, 1), Lifetime = nr(0.45) }), { EmitCount = 1, EmitDelay = 0.7 })
pe(ground, "GroundRingDark", 6862984716, merge(FLAT, { Color = cs(0, WHITE, 1, WHITE), LightEmission = 0, Brightness = 0, Size = ns(0, 0, 1, 35), Transparency = ns(0, 0, 0.5, 0.2, 1, 1), Lifetime = nr(0.5), ZOffset = -0.05 }), { EmitCount = 1, EmitDelay = 0.72 })
pe(ground, "Shockwave", 17613747219, merge(FLAT, { Color = cs(0, CRIMSON, 1, BLACK), LightEmission = 1, Brightness = 0.6, Size = ns(0, 0, 0.2, 28, 1, 36), Transparency = ns(0, 0.2, 1, 1), Lifetime = nr(0.6), Rotation = nr(-360, 360) }), { EmitCount = 2, EmitDelay = 0.7 })
pe(ground, "Scorch", 82576941307593, merge(FLAT, { Color = cs(0, CRIMSON, 1, CRIMSON_DEEP), LightEmission = 0, Brightness = 60, Size = ns(0, 24, 1, 24), Transparency = ns(0, 1, 0.1, 0.72, 0.6, 0.8, 1, 1), Lifetime = nr(1.6, 2), Rotation = nr(-360, 360), ZOffset = -0.1 }), { EmitCount = 1, EmitDelay = 0.72 })
pe(ground, "DustBlast", 13959942757, merge(FLAT, { Color = cs(0, Color3.fromRGB(135, 135, 135), 1, Color3.fromRGB(56, 56, 56)), LightEmission = 1, Brightness = 3.5, Size = ns(0, 0, 0.2, 26, 1, 34), Transparency = ns(0, 0.78, 1, 1), Lifetime = nr(1, 1.4), Rotation = nr(-360, 360) }), { EmitCount = 2, EmitDelay = 0.7 })

pe(core, "Embers", 14844270653, { Color = cs(0, CRIMSON, 1, BLACK), LightEmission = 0, Brightness = 30, Size = ns(0, 1.2, 1, 0), Speed = nr(25, 70), SpreadAngle = Vector2.new(180, 180), Drag = 4, Acceleration = Vector3.new(0, -50, 0), Lifetime = nr(0.5, 1), Rotation = nr(-360, 360) }, { EmitCount = 18, EmitDelay = 0.7 })
pe(core, "EmbersDark", 14844270653, { Color = cs(0, WHITE, 1, WHITE), LightEmission = 0, Brightness = 0, Size = ns(0, 1.3, 1, 0), Speed = nr(20, 60), SpreadAngle = Vector2.new(180, 180), Drag = 4, Acceleration = Vector3.new(0, -25, 0), Lifetime = nr(0.6, 1.1), Rotation = nr(-360, 360) }, { EmitCount = 10, EmitDelay = 0.7 })
pe(core, "AccentTwinkles", 96013523226630, { Color = cs(0, TEAL, 1, TEAL), LightEmission = 1, Brightness = 4, Size = ns(0, 0, 0.2, 3, 1, 0), Speed = nr(10, 30), SpreadAngle = Vector2.new(180, 180), Drag = 6, Lifetime = nr(0.12, 0.2) }, { EmitCount = 5, EmitDelay = 0.72 })
pe(ground, "Debris", 11353163220, { Color = cs(0, Color3.fromRGB(59, 52, 54), 1, Color3.fromRGB(59, 52, 54)), LightEmission = 0, LightInfluence = 1, Brightness = 2, Size = ns(0, 0, 0.1, 1.2, 1, 0.8), Speed = nr(45, 80), SpreadAngle = Vector2.new(40, 40), Acceleration = Vector3.new(0, -140, 0), Drag = 1.5, Lifetime = nr(0.6, 1), Rotation = nr(-360, 360), RotSpeed = nr(-300, 300) }, { EmitCount = 10, EmitDelay = 0.7 })

local RADIAL = { Shape = Enum.ParticleEmitterShape.Cylinder, ShapeStyle = Enum.ParticleEmitterShapeStyle.Surface, ShapeInOut = Enum.ParticleEmitterShapeInOut.Outward }
local SMOKE_T = ns(0, 0.6, 0.6, 0.87, 0.8, 1.12, 1, 1.6)
pe(ring, "SmokeWarm", 11827618350, merge(RADIAL, { Color = cs(0, Color3.fromRGB(92, 42, 49), 1, Color3.fromRGB(92, 42, 49)), LightEmission = 0.3, LightInfluence = 1.5, Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 6, 2), NumberSequenceKeypoint.new(1, 6, 2) }), Squash = ns(0, 0, 1, 0.2), Transparency = SMOKE_T, Speed = nr(45, 85), Drag = 6, Lifetime = nr(1, 1.6), Rotation = nr(-360, 360), RotSpeed = nr(-20, 20) }), { EmitCount = 7, EmitDelay = 0.72 })
pe(ring, "SmokeCool", 11827618350, merge(RADIAL, { Color = cs(0, Color3.fromRGB(79, 79, 79), 1, Color3.fromRGB(69, 69, 69)), LightEmission = 0.45, LightInfluence = 2, Size = NumberSequence.new({ NumberSequenceKeypoint.new(0, 7, 2), NumberSequenceKeypoint.new(1, 7, 2) }), Squash = ns(0, 0, 1, 0.2), Transparency = SMOKE_T, Speed = nr(40, 80), Drag = 6, Lifetime = nr(1, 1.6), Rotation = nr(-360, 360), RotSpeed = nr(-20, 20) }), { EmitCount = 7, EmitDelay = 0.74 })
pe(ring, "Grains", 1349050856, merge(RADIAL, { Color = cs(0, BLACK, 1, BLACK), LightEmission = 0, Brightness = 0, Size = ns(0, 0.6, 1, 0.3), Transparency = ns(0, 0.3, 1, 1), Speed = nr(40, 90), Drag = 3, Acceleration = Vector3.new(0, -80, 0), Lifetime = nr(0.6, 1) }), { EmitCount = 14, EmitDelay = 0.7 })

local function light(parent, name, color, b, range, delay, dur)
	local l = Instance.new("PointLight")
	l.Name = name
	l.Color = color
	l.Brightness = b
	l.Range = range
	l.Enabled = false
	l:SetAttribute("EmitDelay", delay)
	l:SetAttribute("EmitDuration", dur)
	l.Parent = parent
end
light(core, "ChargeLight", CRIMSON, 6, 18, 0, 0.7)
light(core, "ImpactLight", CRIMSON, 25, 30, 0.7, 0.7)

local meshes = fx
local NEON = Enum.Material.Neon
local function hdr(r, g, b) return Color3.new(r, g, b) end
local list = {
	{ "ChargeBand", { id = 4681227436, color = GREY, delay = 0, dur = 0.6, easing = "Quad", dir = "In", from = { cfAt(-2, 0), Vector3.new(7, 3, 7), 0.82 }, to = { cfAt(2.5, 165), Vector3.new(5, 11, 5), 1 } } },
	{ "ChargeBandCounter", { id = 113322248153294, color = GREY, delay = 0.12, dur = 0.5, easing = "Quad", dir = "In", from = { cfAt(-1.5, 0), Vector3.new(9, 2, 9), 0.88 }, to = { cfAt(3, -140), Vector3.new(6, 9, 6), 1 } } },
	{ "ImplodeHoop", { id = 18434669670, color = GREY, delay = 0.45, dur = 0.25, easing = "Quad", dir = "In", from = { cfAt(3, 0), Vector3.new(1.2, 26, 26), 0.8 }, to = { cfAt(3, 90), Vector3.new(0.3, 34, 1), 1 } } },
	{ "HotCrown", { id = 102470267627424, color = CRIMSON, delay = 0.7, dur = 0.14, from = { cfAt(4, 0), Vector3.new(6, 10, 6), 0.2 }, to = { cfAt(-1, 110), Vector3.new(30, 3, 30), 1 } } },
	{ "HotNeedle", { id = 137685697016553, color = CRIMSON, delay = 0.7, dur = 0.18, from = { cfAt(2, 0), Vector3.new(1.5, 4, 1.5), 0.3 }, to = { cfAt(18, 60), Vector3.new(0.1, 36, 0.1), 1 } } },
	{ "DarkShell", { id = 71849885439764, color = BLACK, delay = 0.7, dur = 0.2, from = { cfAt(3, 0), Vector3.new(10, 8, 10), 0.35 }, to = { cfAt(0, -95), Vector3.new(36, 2.5, 36), 1 } } },
	{ "SlamRing", { id = 7430299023, color = GREY, delay = 0.7, dur = 0.55, easing = "Cubic", from = { cfAt(2.5, 0), Vector3.new(8, 4, 8), 0.8 }, to = { cfAt(-0.6, 140), Vector3.new(38, 1, 38), 1 } } },
	{ "SlamRingPulse", { id = 7430299023, color = GREY, delay = 0.8, dur = 0.5, easing = "Cubic", from = { cfAt(2, 60), Vector3.new(6, 3, 6), 0.86 }, to = { cfAt(-0.4, 170), Vector3.new(30, 0.8, 30), 1 } } },
	{ "SheenRing", { id = 129778117978668, color = WHITE, delay = 0.72, dur = 1.2, easing = "Quart", from = { cfAt(4, 0), Vector3.new(14, 7, 14), 0.93 }, to = { cfAt(0.2, -150), Vector3.new(48, 0.6, 48), 1 } } },
	{ "ResidueSwirl", { id = 6351288405, color = GREY, delay = 0.85, dur = 1.6, easing = "Quint", from = { cfAt(0.5, 0), Vector3.new(20, 3, 20), 0.9 }, to = { cfAt(1.5, 120), Vector3.new(40, 1.5, 40), 1 } } },
	{ "RendColumn", { id = 7722530552, decal = { tex = 108886089477305, color = hdr(6, 0.5, 1.1) }, delay = 0.7, dur = 0.45, from = { cfAt(0, 0), Vector3.new(8, 5, 8), 0.55 }, to = { cfAt(6, 100), Vector3.new(11, 26, 11), 1 } } },
	{ "SpikeRing", { id = 7423457269, decal = { tex = 18280512172, color = hdr(4, 0.3, 0.7) }, delay = 0.7, dur = 0.3, from = { cfAt(0.2, 0), Vector3.new(12, 1.2, 12), 0.5 }, to = { cfAt(0, 40), Vector3.new(15, 8, 15), 1 } } },
	{ "ShockDome", { id = 8501563708, rot = CFrame.Angles(0, 0, math.rad(90)), decal = { tex = 14277319792, color = hdr(5, 0.4, 0.9) }, delay = 0.7, dur = 0.32, from = { cfAt(1, 0), Vector3.new(1, 10, 10), 0.6 }, to = { cfAt(0.5, 120), Vector3.new(9, 30, 30), 1 } } },
	{ "ShockDomeDark", { id = 8501563708, rot = CFrame.Angles(0, 0, math.rad(90)), decal = { tex = 14277319792, color = BLACK }, delay = 0.72, dur = 0.38, from = { cfAt(1, 30), Vector3.new(1, 11, 11), 0.7 }, to = { cfAt(0.5, -50), Vector3.new(10, 33, 33), 1 } } },
}
for _, entry in list do meshModel(meshes, entry[1], entry[2]) end

fx:SetAttribute("EffectDuration", 2.8)
fx.Parent = RS.VFX

local count = 0
for _, d in fx:GetDescendants() do if d:IsA("ParticleEmitter") then count += 1 end end
return "built CrimsonEclipse: " .. count .. " emitters, " .. #list .. " meshes; missing sources: " .. table.concat(missing, ",")
