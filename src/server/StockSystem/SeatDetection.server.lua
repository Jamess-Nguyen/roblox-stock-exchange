local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local OpenStockUI = Instance.new("RemoteEvent")
OpenStockUI.Name = "OpenStockUI"
OpenStockUI.Parent = ReplicatedStorage

print("SeatDetection script loaded!")

local function onCharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid")

	humanoid.StateChanged:Connect(function(oldState, newState)
		if newState == Enum.HumanoidStateType.Seated then
			local player = Players:GetPlayerFromCharacter(character)
			if player then
				OpenStockUI:FireClient(player)
			end
		end
	end)
end

for idx, player in Players:GetPlayers() do
	if player.Character then
		onCharacterAdded(player.Character)
	end
	player.CharacterAdded:Connect(onCharacterAdded)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(onCharacterAdded)
end)
