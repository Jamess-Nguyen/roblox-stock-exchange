local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ExplodePlayer = Instance.new("RemoteEvent")
ExplodePlayer.Name = "ExplodePlayer"
ExplodePlayer.Parent = ReplicatedStorage

ExplodePlayer.OnServerEvent:Connect(function(player)
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
end)
