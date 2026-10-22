const ReplicatedStorage = game:GetService("ReplicatedStorage")
const RunService = game:GetService("RunService")
const UserInputService = game:GetService("UserInputService")

const Emit = require(ReplicatedStorage:WaitForChild("VFX"):WaitForChild("Emit"))
const spot = workspace:WaitForChild("CrimsonEclipseStage"):WaitForChild("Spot")
const camera = workspace.CurrentCamera

const IMPACT = 0.7
const LOOP = 3.6

local rumble = 0
local kick = 0

RunService:BindToRenderStep("CrimsonEclipseShake", Enum.RenderPriority.Camera.Value + 1, function(dt)
	kick = math.max(kick - dt * 3, 0)
	local amount = rumble * 0.15 + kick * kick
	if amount <= 0 then
		return
	end
	local t = os.clock() * 40
	camera.CFrame *= CFrame.Angles(math.noise(t, 1) * amount * 0.03, math.noise(t, 2) * amount * 0.03, math.noise(t, 3) * amount * 0.02)
end)

local function play(timeScale)
	local handle = Emit.play("CrimsonEclipse", spot.CFrame, { timeScale = timeScale })
	local hit = false
	handle:onStep(function(time)
		if time < IMPACT then
			rumble = time / IMPACT
		elseif not hit then
			hit = true
			rumble = 0
			kick = 1
			handle:freeze(0.07)
		end
	end)
	handle:onDone(function()
		rumble = 0
	end)
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.E then
		play(1)
	elseif input.KeyCode == Enum.KeyCode.Q then
		play(0.25)
	end
end)

task.wait(2)
while true do
	play(1)
	task.wait(LOOP)
end
