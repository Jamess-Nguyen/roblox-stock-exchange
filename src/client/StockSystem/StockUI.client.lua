local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local stockUI = playerGui:WaitForChild("StockUI")

local openEvent = ReplicatedStorage:WaitForChild("OpenStockUI")
openEvent.OnClientEvent:Connect(function()
	stockUI.Enabled = true
end)
