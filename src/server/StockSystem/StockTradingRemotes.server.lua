-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Modules
local StockData = require(91072619691201)
local CurrencyManager = require(game.ServerScriptService.PlayerData.CurrencyManager)
local PortfolioManager = require(game.ServerScriptService.PlayerData.PortfolioManager)
local TransactionManager = require(game.ServerScriptService.PlayerData.TransactionManager)

-- Remote Functions
local BuyStock
local SellStock
local GetStockData

-- Helper Functions

local function getStockPrice(symbol)
	for _, stock in ipairs(StockData) do
		if stock.Symbol == symbol then
			return stock.CurrentPrice
		end
	end
	return nil
end

local function validateQuantity(quantity)
	if type(quantity) ~= "number" then
		return false, "Invalid quantity type"
	end
	if quantity <= 0 then
		return false, "Quantity must be greater than 0"
	end
	if quantity ~= math.floor(quantity) then
		return false, "Fractional shares not allowed"
	end
	return true, ""
end

-- Function Declarations

local function onBuyStock(player, symbol, quantity)
	-- Validate quantity
	local valid, errorMsg = validateQuantity(quantity)
	if not valid then
		return {success = false, message = errorMsg}
	end

	-- Get stock price
	local price = getStockPrice(symbol)
	if not price then
		return {success = false, message = "Invalid stock symbol"}
	end

	-- Calculate total cost
	local totalCost = price * quantity

	-- Check if player has sufficient funds
	local currentCurrency = CurrencyManager:GetCurrency(player)
	if currentCurrency < totalCost then
		return {
			success = false,
			message = string.format("Insufficient funds. Need $%.2f, have $%.2f", totalCost, currentCurrency)
		}
	end

	-- Execute transaction
	CurrencyManager:RemoveCurrency(player, totalCost)
	PortfolioManager:AddShares(player, symbol, quantity)
	TransactionManager:RecordTransaction(player, symbol, "buy", quantity, price)

	print(string.format("%s bought %d %s for $%.2f", player.Name, quantity, symbol, totalCost))

	return {
		success = true,
		message = string.format("Bought %d %s for $%.2f", quantity, symbol, totalCost)
	}
end

local function onSellStock(player, symbol, quantity)
	-- Validate quantity
	local valid, errorMsg = validateQuantity(quantity)
	if not valid then
		return {success = false, message = errorMsg}
	end

	-- Get stock price
	local price = getStockPrice(symbol)
	if not price then
		return {success = false, message = "Invalid stock symbol"}
	end

	-- Check if player has sufficient shares
	local currentShares = PortfolioManager:GetShares(player, symbol)
	if currentShares < quantity then
		return {
			success = false,
			message = string.format("Insufficient shares. Have %d shares, trying to sell %d", currentShares, quantity)
		}
	end

	-- Calculate total revenue
	local totalRevenue = price * quantity

	-- Execute transaction
	PortfolioManager:RemoveShares(player, symbol, quantity)
	CurrencyManager:AddCurrency(player, totalRevenue)
	TransactionManager:RecordTransaction(player, symbol, "sell", quantity, price)

	print(string.format("%s sold %d %s for $%.2f", player.Name, quantity, symbol, totalRevenue))

	return {
		success = true,
		message = string.format("Sold %d %s for $%.2f", quantity, symbol, totalRevenue)
	}
end

local function onGetStockData(player)
	return StockData
end

local function setupBuyStockFunction()
	BuyStock = Instance.new("RemoteFunction")
	BuyStock.Name = "BuyStock"
	BuyStock.Parent = ReplicatedStorage

	BuyStock.OnServerInvoke = onBuyStock
end

local function setupSellStockFunction()
	SellStock = Instance.new("RemoteFunction")
	SellStock.Name = "SellStock"
	SellStock.Parent = ReplicatedStorage

	SellStock.OnServerInvoke = onSellStock
end

local function setupGetStockDataFunction()
	GetStockData = Instance.new("RemoteFunction")
	GetStockData.Name = "GetStockData"
	GetStockData.Parent = ReplicatedStorage

	GetStockData.OnServerInvoke = onGetStockData
end

-- If __name__ == "__main__":

local function main()
	setupBuyStockFunction()
	setupSellStockFunction()
	setupGetStockDataFunction()
	print("StockTradingRemotes initialized")
end

main()
