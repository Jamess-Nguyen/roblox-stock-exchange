local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Function to set jump height for a character
local function setJumpHeight(character)
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")

	humanoid.JumpHeight = 200

	local wasGoingUp = false
	local connection

	-- Track jump apex
	connection = RunService.Heartbeat:Connect(function()
		if not character.Parent or not humanoid.Parent then
			connection:Disconnect()
			return
		end

		local velocity = rootPart.AssemblyLinearVelocity.Y

		-- Detect if going up (jumping)
		if velocity > 5 then
			wasGoingUp = true
		end

		-- Detect apex (was going up, now going down or stopped)
		if wasGoingUp and velocity <= 0 then
			wasGoingUp = false

			-- Create explosion at apex
			local explosion = Instance.new("Explosion")
			explosion.Position = rootPart.Position
			explosion.BlastRadius = 10
			explosion.BlastPressure = 500000
			explosion.Parent = workspace
		end
	end)
end

-- Handle existing players
for _, player in Players:GetPlayers() do
	if player.Character then
		setJumpHeight(player.Character)
	end
	player.CharacterAdded:Connect(setJumpHeight)
end

-- Handle new players joining
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(setJumpHeight)
end)
