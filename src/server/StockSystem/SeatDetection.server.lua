-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Remote Events
local OpenStockUI

-- Function Declarations

local function onCharacterAdded(character)
	print("Character added:", character.Name)
	local humanoid = character:WaitForChild("Humanoid")

	humanoid.StateChanged:Connect(function(oldState, newState)
		print("State changed:", oldState, "->", newState)
		if newState == Enum.HumanoidStateType.Seated then
			local player = Players:GetPlayerFromCharacter(character)
			if player then
				print("Opening UI for:", player.Name)
				OpenStockUI:FireClient(player)
			end
		end
	end)
end

local function setupOpenStockUIEvent()
	OpenStockUI = Instance.new("RemoteEvent")
	OpenStockUI.Name = "OpenStockUI"
	OpenStockUI.Parent = ReplicatedStorage
end

local function connectExistingPlayers()
	for idx, player in Players:GetPlayers() do
		if player.Character then
			onCharacterAdded(player.Character)
		end
		player.CharacterAdded:Connect(onCharacterAdded)
	end
end

local function connectNewPlayers()
	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(onCharacterAdded)
	end)
end

-- If __name__ == "__main__":

local function main()
	setupOpenStockUIEvent()
	connectExistingPlayers()
	connectNewPlayers()
end

main()
