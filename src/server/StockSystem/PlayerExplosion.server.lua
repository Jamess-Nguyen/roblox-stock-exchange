-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remote Events
local ExplodePlayer

-- Function Declarations

local function onPlayerExplode(player)
	local character = player.Character
	if character then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
		if humanoidRootPart then
			local explosion = Instance.new("Explosion")
			explosion.Position = humanoidRootPart.Position
			explosion.BlastRadius = 10
			explosion.BlastPressure = 500000
			explosion.Parent = workspace
		end
	end
end

local function setupExplodeEvent()
	ExplodePlayer = Instance.new("RemoteEvent")
	ExplodePlayer.Name = "ExplodePlayer"
	ExplodePlayer.Parent = ReplicatedStorage

	ExplodePlayer.OnServerEvent:Connect(onPlayerExplode)
end

-- If __name__ == "__main__":

local function main()
	setupExplodeEvent()
end

main()
