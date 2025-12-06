local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local stockUI = playerGui:WaitForChild("StockUI")

local closeButton = stockUI:FindFirstChild("CloseButton", true)

if not closeButton then
	local timeout = 10
	local elapsed = 0
	while not closeButton and elapsed < timeout do
		task.wait(0.1)
		closeButton = stockUI:FindFirstChild("CloseButton", true)
		elapsed += 0.1
	end
end

if closeButton then
	closeButton.MouseButton1Click:Connect(function()
		stockUI.Enabled = false
	end)
else
	warn("CloseButton not found in StockUI")
end

local openEvent = ReplicatedStorage:WaitForChild("OpenStockUI")
openEvent.OnClientEvent:Connect(function()
	stockUI.Enabled = true
end)
