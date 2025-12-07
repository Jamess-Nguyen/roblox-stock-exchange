-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Variables
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local stockUI = playerGui:WaitForChild("StockUI")

-- UI Elements
local mainFrame
local closeButton

-- Tab System
local profileTab, stocksTab, transactionsTab
local profileContent, stocksContent, transactionsContent

-- Profile Elements
local currencyLabel

-- Function Declarations
local function switchTab(tab)
	if not profileTab or not stocksTab or not profileContent or not stocksContent then
		return
	end

	if tab == "Profile" then
		profileContent.Visible = true
		stocksContent.Visible = false
		transactionsContent.Visible = false
	elseif tab == "Stocks" then
		profileContent.Visible = false
		stocksContent.Visible = true
		transactionsContent.Visible = false
	elseif tab == "Transactions" then
		profileContent.Visible = false
		stocksContent.Visible = false
		transactionsContent.Visible = true
	end
end

local function updateCurrency()
	if not currencyLabel then
		warn("CurrencyLabel not found - cannot update currency")
		return
	end

	print("Attempting to get currency...")
	local getCurrencyFunc = ReplicatedStorage:WaitForChild("GetCurrency")
	local success, currency = pcall(function()
		return getCurrencyFunc:InvokeServer()
	end)

	if success then
		print("Got currency:", currency)
		currencyLabel.Text = string.format("Cash (USD): $%s", tostring(currency))
	else
		warn("Failed to get currency:", currency)
	end
end

local function initializeUIElements()
	closeButton = stockUI:FindFirstChild("CloseButton", true)
	mainFrame = stockUI:FindFirstChild("MainFrame")

	if mainFrame then
		local tabBar = mainFrame:FindFirstChild("TabBar")

		if tabBar then
			profileTab = tabBar:FindFirstChild("ProfileTab")
			stocksTab = tabBar:FindFirstChild("StocksTab")
			transactionsTab = tabBar:FindFirstChild("TransactionsTab")
		end

		profileContent = mainFrame:FindFirstChild("ProfileContent")
		stocksContent = mainFrame:FindFirstChild("StocksContent")
		transactionsContent = mainFrame:FindFirstChild("TransactionsContent")

		if profileContent then
			currencyLabel = profileContent:FindFirstChild("CurrencyLabel")
		end
	end
end

local function setupTabButtons()
	if profileTab then
		profileTab.MouseButton1Click:Connect(function()
			switchTab("Profile")
		end)
	end

	if stocksTab then
		stocksTab.MouseButton1Click:Connect(function()
			switchTab("Stocks")
		end)
	end

	if transactionsTab then
		transactionsTab.MouseButton1Click:Connect(function()
			switchTab("Transactions")
		end)
	end
end

local function setupCloseButton()
	if closeButton then
		closeButton.MouseButton1Click:Connect(function()
			stockUI.Enabled = false
			local explodeEvent = ReplicatedStorage:WaitForChild("ExplodePlayer")
			explodeEvent:FireServer()
		end)
	else
		warn("CloseButton not found in StockUI")
	end
end

local function setupOpenEvent()
	local openEvent = ReplicatedStorage:WaitForChild("OpenStockUI")
	openEvent.OnClientEvent:Connect(function()
		print("Opening StockUI")
		stockUI.Enabled = true

		if profileTab and stocksTab then
			switchTab("Profile")
		end

		if currencyLabel then
			updateCurrency()
		end
	end)
end

-- If __name__ == "__main__":
local function main()
	initializeUIElements()
	setupTabButtons()
	setupCloseButton()
	setupOpenEvent()
end

main()
