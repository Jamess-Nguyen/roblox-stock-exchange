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
local portfolioValueLabel

-- Stocks Elements
local portfolioLabel

-- Transactions Elements
local stockRows = {}
local statusLabel
local stockListFrame
local stockRowTemplate
local selectedStock = nil
local selectedAmount = 0

-- Action Area Elements
local actionArea
local selectedStockLabel
local amount1Btn, amount10Btn, amount50Btn, amount100Btn
local buyButton, sellButton

-- Feature flags
local hasActionArea = false

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

local function updatePortfolioValue()
	if not portfolioValueLabel then
		warn("PortfolioValueLabel not found - cannot update portfolio value")
		return
	end

	print("Attempting to get portfolio value...")
	local getPortfolioValueFunc = ReplicatedStorage:WaitForChild("GetPortfolioValue")
	local success, portfolioValue = pcall(function()
		return getPortfolioValueFunc:InvokeServer()
	end)

	if success then
		print("Got portfolio value:", portfolioValue)
		portfolioValueLabel.Text = string.format("Portfolio Value: $%s", tostring(portfolioValue))
	else
		warn("Failed to get portfolio value:", portfolioValue)
	end
end

local function displayMessage(message)
	if statusLabel then
		statusLabel.Text = message
	end
end

local function displayStockData()
	if not portfolioLabel then
		warn("PortfolioLabel not found - cannot display stock data")
		return
	end

	print("Fetching enriched portfolio data...")
	local getEnrichedPortfolioFunc = ReplicatedStorage:WaitForChild("GetEnrichedPortfolio")
	local success, enrichedPortfolio = pcall(function()
		return getEnrichedPortfolioFunc:InvokeServer()
	end)

	if success and enrichedPortfolio then
		local lines = {}

		for _, stock in ipairs(enrichedPortfolio) do
			local plColor = stock.isProfit and "+" or "-"
			local line = string.format(
				"%s: %d shares | Price: $%.2f | Value: $%.2f | Avg Cost: $%.2f | P/L: %s$%.2f",
				stock.symbol,
				stock.quantity,
				stock.currentPrice,
				stock.totalValue,
				stock.averageCost,
				plColor,
				math.abs(stock.unrealizedPL)
			)
			table.insert(lines, line)
		end

		if #lines == 0 then
			portfolioLabel.Text = "No stocks owned"
		else
			portfolioLabel.Text = table.concat(lines, "\n")
		end
		print("Portfolio displayed with enriched data")
	else
		warn("Failed to get enriched portfolio")
		portfolioLabel.Text = "Failed to load portfolio"
	end
end

local function updateActionAreaState()
	if not hasActionArea then
		return
	end

	if buyButton and sellButton then
		local hasSelection = selectedStock ~= nil
		local hasAmount = selectedAmount > 0

		buyButton.Active = hasSelection and hasAmount
		sellButton.Active = hasSelection and hasAmount

		local enabledColor = Color3.new(0, 0.8, 0)
		local disabledColor = Color3.new(0.5, 0.5, 0.5)

		buyButton.BackgroundColor3 = (hasSelection and hasAmount) and enabledColor or disabledColor
		sellButton.BackgroundColor3 = (hasSelection and hasAmount) and enabledColor or disabledColor
	end
end

local function selectStock(stock, row)
	if selectedStock and selectedStock.row then
		selectedStock.row.BackgroundColor3 = Color3.new(1, 1, 1)
	end

	selectedStock = {
		symbol = stock.Symbol,
		name = stock.Name,
		price = stock.CurrentPrice,
		row = row
	}
	row.BackgroundColor3 = Color3.new(0.8, 0.9, 1)

	if selectedStockLabel then
		selectedStockLabel.Text = string.format("Selected: %s - %s", stock.Symbol, stock.Name)
	end

	selectedAmount = 0
	updateActionAreaState()
end

local function setAmount(amount)
	selectedAmount = amount
	updateActionAreaState()
end

local function onBuyStock(symbol, quantity)
	if quantity <= 0 then
		displayMessage("Please select an amount")
		return
	end

	print(string.format("Attempting to buy %d %s...", quantity, symbol))
	local buyStockFunc = ReplicatedStorage:WaitForChild("BuyStock")
	local success, result = pcall(function()
		return buyStockFunc:InvokeServer(symbol, quantity)
	end)

	if success and result then
		displayMessage(result.message)
		if result.success then
			selectedAmount = 0
			updateActionAreaState()
			if currencyLabel then
				updateCurrency()
			end
			if portfolioValueLabel then
				updatePortfolioValue()
			end
		end
	else
		displayMessage("Transaction failed")
		warn("Buy stock error:", result)
	end
end

local function onSellStock(symbol, quantity)
	if quantity <= 0 then
		displayMessage("Please select an amount")
		return
	end

	print(string.format("Attempting to sell %d %s...", quantity, symbol))
	local sellStockFunc = ReplicatedStorage:WaitForChild("SellStock")
	local success, result = pcall(function()
		return sellStockFunc:InvokeServer(symbol, quantity)
	end)

	if success and result then
		displayMessage(result.message)
		if result.success then
			selectedAmount = 0
			updateActionAreaState()
			if currencyLabel then
				updateCurrency()
			end
			if portfolioValueLabel then
				updatePortfolioValue()
			end
		end
	else
		displayMessage("Transaction failed")
		warn("Sell stock error:", result)
	end
end

local function executeBuy()
	if not selectedStock or selectedAmount <= 0 then
		displayMessage("Please select a stock and amount")
		return
	end

	onBuyStock(selectedStock.symbol, selectedAmount)
end

local function executeSell()
	if not selectedStock or selectedAmount <= 0 then
		displayMessage("Please select a stock and amount")
		return
	end

	onSellStock(selectedStock.symbol, selectedAmount)
end

local function validateQuantityInput(quantityText)
	local quantity = tonumber(quantityText)
	if not quantity then
		return false, nil, "Please enter a valid quantity"
	end
	if quantity <= 0 then
		return false, nil, "Quantity must be greater than 0"
	end
	if quantity ~= math.floor(quantity) then
		return false, nil, "Fractional shares not allowed"
	end
	return true, quantity, ""
end

local function createStockRowLegacy(stock, index)
	if not stockRowTemplate or not stockListFrame then
		warn("Template or container not found")
		return
	end

	print(string.format("Creating legacy row for %s (index %d)", stock.Symbol, index))

	local row = stockRowTemplate:Clone()
	row.Name = stock.Symbol .. "Row"
	row.Visible = true
	row.LayoutOrder = index
	row.Parent = stockListFrame

	local symbolLabel = row:FindFirstChild("SymbolLabel")
	local nameLabel = row:FindFirstChild("NameLabel")
	local priceLabel = row:FindFirstChild("PriceLabel")
	local quantityBox = row:FindFirstChild("QuantityBox")
	local buyBtn = row:FindFirstChild("BuyButton")
	local sellBtn = row:FindFirstChild("SellButton")

	if symbolLabel then
		symbolLabel.Text = stock.Symbol
	end
	if nameLabel then
		nameLabel.Text = stock.Name
	end
	if priceLabel then
		priceLabel.Text = string.format("$%.2f", stock.CurrentPrice)
	end
	if quantityBox then
		quantityBox.Text = "0"
	end

	stockRows[stock.Symbol] = {
		row = row,
		symbolLabel = symbolLabel,
		nameLabel = nameLabel,
		priceLabel = priceLabel,
		quantityBox = quantityBox,
		buyBtn = buyBtn,
		sellBtn = sellBtn
	}

	if buyBtn and quantityBox then
		buyBtn.MouseButton1Click:Connect(function()
			local quantityText = quantityBox.Text
			local valid, quantity, errorMsg = validateQuantityInput(quantityText)

			if not valid then
				displayMessage(errorMsg)
				return
			end

			onBuyStock(stock.Symbol, quantity)
			if quantityBox then
				quantityBox.Text = "0"
			end
		end)
	end

	if sellBtn and quantityBox then
		sellBtn.MouseButton1Click:Connect(function()
			local quantityText = quantityBox.Text
			local valid, quantity, errorMsg = validateQuantityInput(quantityText)

			if not valid then
				displayMessage(errorMsg)
				return
			end

			onSellStock(stock.Symbol, quantity)
			if quantityBox then
				quantityBox.Text = "0"
			end
		end)
	end

	print(string.format("Legacy row complete for %s", stock.Symbol))
end

local function createStockRowNew(stock, index)
	if not stockRowTemplate or not stockListFrame then
		warn("Template or container not found")
		return
	end

	print(string.format("Creating new row for %s (index %d)", stock.Symbol, index))

	local row = stockRowTemplate:Clone()
	row.Name = stock.Symbol .. "Row"
	row.Visible = true
	row.LayoutOrder = index
	row.Parent = stockListFrame

	local symbolLabel = row:FindFirstChild("SymbolLabel")
	local nameLabel = row:FindFirstChild("NameLabel")
	local priceLabel = row:FindFirstChild("PriceLabel")

	if symbolLabel then
		symbolLabel.Text = stock.Symbol
	end
	if nameLabel then
		nameLabel.Text = stock.Name
	end
	if priceLabel then
		priceLabel.Text = string.format("$%.2f", stock.CurrentPrice)
	end

	stockRows[stock.Symbol] = {
		row = row,
		symbolLabel = symbolLabel,
		nameLabel = nameLabel,
		priceLabel = priceLabel
	}

	row.MouseButton1Click:Connect(function()
		selectStock(stock, row)
	end)

	print(string.format("New row complete for %s", stock.Symbol))
end

local function displayTransactionInterface()
	print("Fetching stock data for trading...")
	local getStockDataFunc = ReplicatedStorage:WaitForChild("GetStockData")
	local success, stockData = pcall(function()
		return getStockDataFunc:InvokeServer()
	end)

	if success and stockData then
		for symbol, elements in pairs(stockRows) do
			if elements.row then
				elements.row:Destroy()
			end
		end
		stockRows = {}

		for index, stock in ipairs(stockData) do
			if hasActionArea then
				createStockRowNew(stock, index)
			else
				createStockRowLegacy(stock, index)
			end
		end
		print("Trading interface displayed with", #stockData, "stocks")
	else
		warn("Failed to get stock data")
	end
end

local function initializeUIElements()
	print("Initializing UI elements...")
	closeButton = stockUI:FindFirstChild("CloseButton", true)
	mainFrame = stockUI:FindFirstChild("MainFrame", true)

	print("MainFrame found:", mainFrame ~= nil)
	if mainFrame then
		print("MainFrame visible:", mainFrame.Visible)
		local tabBar = mainFrame:FindFirstChild("TabBar", true)

		if tabBar then
			profileTab = tabBar:FindFirstChild("ProfileTab", true)
			stocksTab = tabBar:FindFirstChild("StocksTab", true)
			transactionsTab = tabBar:FindFirstChild("TransactionsTab", true)
		end

		profileContent = mainFrame:FindFirstChild("ProfileContent", true)
		stocksContent = mainFrame:FindFirstChild("StocksContent", true)
		transactionsContent = mainFrame:FindFirstChild("TransactionsContent", true)

		if profileContent then
			currencyLabel = profileContent:FindFirstChild("CurrencyLabel", true)
			portfolioValueLabel = profileContent:FindFirstChild("PortfolioValueLabel", true)
		end

		if stocksContent then
			portfolioLabel = stocksContent:FindFirstChild("PortfolioLabel", true)
		end

		if transactionsContent then
			statusLabel = transactionsContent:FindFirstChild("StatusLabel", true)
			stockListFrame = transactionsContent:FindFirstChild("StockListFrame", true)
			stockRowTemplate = transactionsContent:FindFirstChild("StockRowTemplate", true)
			actionArea = transactionsContent:FindFirstChild("ActionArea", true)

			if not stockListFrame then
				warn("StockListFrame not found - trading interface will not display")
			end
			if not stockRowTemplate then
				warn("StockRowTemplate not found - cannot create stock rows")
			end

			if actionArea then
				hasActionArea = true
				print("ActionArea found - using new UI mode")
				selectedStockLabel = actionArea:FindFirstChild("SelectedStockLabel", true)

				local quickAmountFrame = actionArea:FindFirstChild("QuickAmountFrame", true)
				if quickAmountFrame then
					amount1Btn = quickAmountFrame:FindFirstChild("Amount1Button", true)
					amount10Btn = quickAmountFrame:FindFirstChild("Amount10Button", true)
					amount50Btn = quickAmountFrame:FindFirstChild("Amount50Button", true)
					amount100Btn = quickAmountFrame:FindFirstChild("Amount100Button", true)
				end

				local tradeButtonFrame = actionArea:FindFirstChild("TradeButtonFrame", true)
				if tradeButtonFrame then
					buyButton = tradeButtonFrame:FindFirstChild("BuyButton", true)
					sellButton = tradeButtonFrame:FindFirstChild("SellButton", true)
				end
			else
				hasActionArea = false
				print("ActionArea not found - using legacy UI mode")
			end
		end
	end
end

local function setupTabButtons()
	if profileTab then
		profileTab.MouseButton1Click:Connect(function()
			switchTab("Profile")
			if currencyLabel then
				updateCurrency()
			end
			if portfolioValueLabel then
				updatePortfolioValue()
			end
		end)
	end

	if stocksTab then
		stocksTab.MouseButton1Click:Connect(function()
			switchTab("Stocks")
			displayStockData()
		end)
	end

	if transactionsTab then
		transactionsTab.MouseButton1Click:Connect(function()
			switchTab("Transactions")
			displayTransactionInterface()
		end)
	end
end

local function setupActionArea()
	if not hasActionArea then
		print("Skipping ActionArea setup - using legacy mode")
		return
	end

	if amount1Btn then
		amount1Btn.MouseButton1Click:Connect(function() setAmount(1) end)
	end
	if amount10Btn then
		amount10Btn.MouseButton1Click:Connect(function() setAmount(10) end)
	end
	if amount50Btn then
		amount50Btn.MouseButton1Click:Connect(function() setAmount(50) end)
	end
	if amount100Btn then
		amount100Btn.MouseButton1Click:Connect(function() setAmount(100) end)
	end

	if buyButton then
		buyButton.MouseButton1Click:Connect(executeBuy)
	end
	if sellButton then
		sellButton.MouseButton1Click:Connect(executeSell)
	end

	updateActionAreaState()
	print("ActionArea setup complete")
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

		if mainFrame then
			mainFrame.Visible = true
			print("Set MainFrame visible")
		end

		if profileTab and stocksTab then
			switchTab("Profile")
		end

		if currencyLabel then
			updateCurrency()
		end

		if portfolioValueLabel then
			updatePortfolioValue()
		end
	end)
end

-- If __name__ == "__main__":
local function main()
	initializeUIElements()
	setupTabButtons()
	setupActionArea()
	setupCloseButton()
	setupOpenEvent()
end

main()
