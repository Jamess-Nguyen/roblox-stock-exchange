local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local stockUI = playerGui:WaitForChild("StockUI")

local closeButton = stockUI:FindFirstChild("CloseButton", true)
local mainFrame = stockUI:FindFirstChild("MainFrame")

local stuffTab, stocksTab, stuffContent, stocksContent, currencyLabel

if mainFrame then
	local tabBar = mainFrame:FindFirstChild("TabBar")
	if tabBar then
		stuffTab = tabBar:FindFirstChild("StuffTab")
		stocksTab = tabBar:FindFirstChild("StocksTab")
	end
	stuffContent = mainFrame:FindFirstChild("StuffContent")
	stocksContent = mainFrame:FindFirstChild("StocksContent")
	if stuffContent then
		currencyLabel = stuffContent:FindFirstChild("CurrencyLabel")
	end
end

local ACTIVE_TAB_COLOR = Color3.fromRGB(64, 64, 64)
local INACTIVE_TAB_COLOR = Color3.fromRGB(46, 46, 46)
local ACTIVE_TEXT_COLOR = Color3.fromRGB(255, 255, 255)
local INACTIVE_TEXT_COLOR = Color3.fromRGB(179, 179, 179)

local function switchTab(tab)
	if not stuffTab or not stocksTab or not stuffContent or not stocksContent then
		return
	end

	if tab == "Stuff" then
		stuffContent.Visible = true
		stocksContent.Visible = false
		stuffTab.BackgroundColor3 = ACTIVE_TAB_COLOR
		stuffTab.TextColor3 = ACTIVE_TEXT_COLOR
		stocksTab.BackgroundColor3 = INACTIVE_TAB_COLOR
		stocksTab.TextColor3 = INACTIVE_TEXT_COLOR
	elseif tab == "Stocks" then
		stuffContent.Visible = false
		stocksContent.Visible = true
		stuffTab.BackgroundColor3 = INACTIVE_TAB_COLOR
		stuffTab.TextColor3 = INACTIVE_TEXT_COLOR
		stocksTab.BackgroundColor3 = ACTIVE_TAB_COLOR
		stocksTab.TextColor3 = ACTIVE_TEXT_COLOR
	end
end

if stuffTab then
	stuffTab.MouseButton1Click:Connect(function()
		switchTab("Stuff")
	end)
end

if stocksTab then
	stocksTab.MouseButton1Click:Connect(function()
		switchTab("Stocks")
	end)
end

local function updateCurrency()
	if not currencyLabel then
		return
	end

	local getCurrencyFunc = ReplicatedStorage:WaitForChild("GetCurrency")
	local success, currency = pcall(function()
		return getCurrencyFunc:InvokeServer()
	end)

	if success then
		currencyLabel.Text = string.format("Cash (USD): $%s", tostring(currency))
	else
		warn("Failed to get currency:", currency)
	end
end

if closeButton then
	closeButton.MouseButton1Click:Connect(function()
		stockUI.Enabled = false
		local explodeEvent = ReplicatedStorage:WaitForChild("ExplodePlayer")
		explodeEvent:FireServer()
	end)
else
	warn("CloseButton not found in StockUI")
end

local openEvent = ReplicatedStorage:WaitForChild("OpenStockUI")
openEvent.OnClientEvent:Connect(function()
	print("Opening StockUI")
	stockUI.Enabled = true

	if stuffTab and stocksTab then
		switchTab("Stuff")
	end

	if currencyLabel then
		updateCurrency()
	end
end)
