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

local function displayMessage(message, isSuccess)
	if statusLabel then
		statusLabel.Text = message
	end
end

local function displayStockData()
	if not portfolioLabel then
		warn("PortfolioLabel not found - cannot display stock data")
		return
	end

	print("Fetching portfolio and stock data for display...")

	-- Get portfolio (owned stocks)
	local getPortfolioFunc = ReplicatedStorage:WaitForChild("GetPortfolio")
	local successPortfolio, portfolio = pcall(function()
		return getPortfolioFunc:InvokeServer()
	end)

	-- Get stock data (for prices)
	local getStockDataFunc = ReplicatedStorage:WaitForChild("GetStockData")
	local successStocks, stockData = pcall(function()
		return getStockDataFunc:InvokeServer()
	end)

	if successPortfolio and portfolio and successStocks and stockData then
		-- Create a price lookup table
		local stockPrices = {}
		local stockNames = {}
		for _, stock in ipairs(stockData) do
			stockPrices[stock.Symbol] = stock.CurrentPrice
			stockNames[stock.Symbol] = stock.Name
		end

		-- Format each owned stock on a new line
		local lines = {}
		for symbol, quantity in pairs(portfolio) do
			local name = stockNames[symbol] or symbol
			local price = stockPrices[symbol] or 0
			local line = string.format(
				'{"Symbol": "%s", "Name": "%s", "Quantity": %d, "Price": %.2f}',
				symbol,
				name,
				quantity,
				price
			)
			table.insert(lines, line)
		end

		if #lines == 0 then
			portfolioLabel.Text = "No stocks owned"
		else
			portfolioLabel.Text = table.concat(lines, "\n")
		end
		print("Portfolio displayed with owned stocks")
	else
		warn("Failed to get portfolio or stock data")
		portfolioLabel.Text = "Failed to load portfolio"
	end
end

local function createStockRow(stock, index)
	if not stockRowTemplate or not stockListFrame then
		warn("Template or container not found")
		return
	end

	print(string.format("Creating row for %s (index %d)", stock.Symbol, index))

	-- Clone the template
	local row = stockRowTemplate:Clone()
	row.Name = stock.Symbol .. "Row"
	row.Visible = true
	row.LayoutOrder = index
	row.Parent = stockListFrame

	print(string.format("  - Row created: %s, Visible: %s, Parent: %s", row.Name, tostring(row.Visible), row.Parent.Name))

	-- Get UI elements
	local symbolLabel = row:FindFirstChild("SymbolLabel")
	local nameLabel = row:FindFirstChild("NameLabel")
	local priceLabel = row:FindFirstChild("PriceLabel")
	local quantityBox = row:FindFirstChild("QuantityBox")
	local buyBtn = row:FindFirstChild("BuyButton")
	local sellBtn = row:FindFirstChild("SellButton")

	print(string.format("  - Found children: Symbol=%s, Name=%s, Price=%s, Qty=%s, Buy=%s, Sell=%s",
		tostring(symbolLabel ~= nil),
		tostring(nameLabel ~= nil),
		tostring(priceLabel ~= nil),
		tostring(quantityBox ~= nil),
		tostring(buyBtn ~= nil),
		tostring(sellBtn ~= nil)))

	-- Set values
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

	-- Store references
	stockRows[stock.Symbol] = {
		row = row,
		symbolLabel = symbolLabel,
		nameLabel = nameLabel,
		priceLabel = priceLabel,
		quantityBox = quantityBox,
		buyBtn = buyBtn,
		sellBtn = sellBtn
	}

	-- Connect buy/sell buttons
	if buyBtn and quantityBox then
		buyBtn.MouseButton1Click:Connect(function()
			onBuyStock(stock.Symbol, quantityBox)
		end)
	end

	if sellBtn and quantityBox then
		sellBtn.MouseButton1Click:Connect(function()
			onSellStock(stock.Symbol, quantityBox)
		end)
	end

	print(string.format("  - Row complete for %s", stock.Symbol))
end

local function displayTransactionInterface()
	print("Fetching stock data for trading...")
	local getStockDataFunc = ReplicatedStorage:WaitForChild("GetStockData")
	local success, stockData = pcall(function()
		return getStockDataFunc:InvokeServer()
	end)

	if success and stockData then
		-- Clear existing rows
		for symbol, elements in pairs(stockRows) do
			if elements.row then
				elements.row:Destroy()
			end
		end
		stockRows = {}

		-- Create rows for each stock
		for index, stock in ipairs(stockData) do
			createStockRow(stock, index)
		end
		print("Trading interface displayed with", #stockData, "stocks")
	else
		warn("Failed to get stock data")
	end
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

onBuyStock = function(symbol, quantityBox)
	local quantityText = quantityBox.Text
	local valid, quantity, errorMsg = validateQuantityInput(quantityText)

	if not valid then
		displayMessage(errorMsg, false)
		return
	end

	print(string.format("Attempting to buy %d %s...", quantity, symbol))
	local buyStockFunc = ReplicatedStorage:WaitForChild("BuyStock")
	local success, result = pcall(function()
		return buyStockFunc:InvokeServer(symbol, quantity)
	end)

	if success and result then
		displayMessage(result.message, result.success)
		if result.success then
			quantityBox.Text = "" 
			if currencyLabel then
				updateCurrency()
			end
			if portfolioValueLabel then
				updatePortfolioValue()
			end
		end
	else
		displayMessage("Transaction failed", false)
		warn("Buy stock error:", result)
	end
end

onSellStock = function(symbol, quantityBox)
	local quantityText = quantityBox.Text
	local valid, quantity, errorMsg = validateQuantityInput(quantityText)

	if not valid then
		displayMessage(errorMsg, false)
		return
	end

	print(string.format("Attempting to sell %d %s...", quantity, symbol))
	local sellStockFunc = ReplicatedStorage:WaitForChild("SellStock")
	local success, result = pcall(function()
		return sellStockFunc:InvokeServer(symbol, quantity)
	end)

	if success and result then
		displayMessage(result.message, result.success)
		if result.success then
			quantityBox.Text = ""
			if currencyLabel then
				updateCurrency()
			end
			if portfolioValueLabel then
				updatePortfolioValue()
			end
		end
	else
		displayMessage("Transaction failed", false)
		warn("Sell stock error:", result)
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
			portfolioValueLabel = profileContent:FindFirstChild("PortfolioValueLabel")
		end

		if stocksContent then
			portfolioLabel = stocksContent:FindFirstChild("PortfolioLabel")
		end

		if transactionsContent then
			statusLabel = transactionsContent:FindFirstChild("StatusLabel")

			stockListFrame = transactionsContent:FindFirstChild("StockListFrame")
			stockRowTemplate = transactionsContent:FindFirstChild("StockRowTemplate")

			if not stockListFrame then
				warn("StockListFrame not found - trading interface will not display")
			end
			if not stockRowTemplate then
				warn("StockRowTemplate not found - cannot create stock rows")
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

		if portfolioValueLabel then
			updatePortfolioValue()
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
