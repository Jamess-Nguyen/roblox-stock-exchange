local DataStoreService = game:GetService("DataStoreService")

local TransactionDataStore = DataStoreService:GetDataStore("PlayerTransactions")

local TransactionManager = {}

local playerTransactions = {}

local function generateTransactionId(timestamp)
	return "txn_" .. tostring(timestamp) .. "_" .. tostring(math.random(1000, 9999))
end

function TransactionManager:GetPlayerKey(player)
	return "Player_" .. tostring(player.UserId)
end

function TransactionManager:LoadTransactions(player)
	local key = self:GetPlayerKey(player)
	local success, data = pcall(function()
		return TransactionDataStore:GetAsync(key)
	end)

	if success and data then
		playerTransactions[player.UserId] = data
		print("Loaded transaction history for", player.Name, "with", #data, "transactions")
	else
		playerTransactions[player.UserId] = {}
		print("No transaction history found for", player.Name)
	end

	return playerTransactions[player.UserId]
end

function TransactionManager:SaveTransactions(player)
	local key = self:GetPlayerKey(player)
	local transactions = playerTransactions[player.UserId]

	if not transactions then
		warn("No transactions to save for", player.Name)
		return false
	end

	local success, err = pcall(function()
		TransactionDataStore:SetAsync(key, transactions)
	end)

	if success then
		print("Saved", #transactions, "transactions for", player.Name)
		return true
	else
		warn("Failed to save transactions for", player.Name, ":", err)
		return false
	end
end

function TransactionManager:RecordTransaction(player, symbol, transactionType, quantity, pricePerShare)
	local transactions = playerTransactions[player.UserId]
	if not transactions then
		warn("Player transactions not loaded for", player.Name)
		return false
	end

	local timestamp = os.time()
	local transaction = {
		transactionId = generateTransactionId(timestamp),
		symbol = symbol,
		type = transactionType,
		quantity = quantity,
		pricePerShare = pricePerShare,
		totalAmount = quantity * pricePerShare,
		timestamp = timestamp
	}

	table.insert(transactions, transaction)
	print(string.format("Recorded %s: %s %d shares @ $%.2f", transactionType, symbol, quantity, pricePerShare))

	return true
end

function TransactionManager:GetTransactionHistory(player, symbol)
	local transactions = playerTransactions[player.UserId]
	if not transactions then
		return {}
	end

	if not symbol then
		return transactions
	end

	local filtered = {}
	for _, transaction in ipairs(transactions) do
		if transaction.symbol == symbol then
			table.insert(filtered, transaction)
		end
	end

	return filtered
end

function TransactionManager:GetCostBasis(player, symbol)
	local transactions = self:GetTransactionHistory(player, symbol)
	local totalCost = 0

	for _, transaction in ipairs(transactions) do
		if transaction.type == "buy" then
			totalCost = totalCost + transaction.totalAmount
		elseif transaction.type == "sell" then
			totalCost = totalCost - transaction.totalAmount
		end
	end

	return totalCost
end

function TransactionManager:GetAverageCost(player, symbol)
	local PortfolioManager = require(script.Parent.PortfolioManager)
	local quantity = PortfolioManager:GetShares(player, symbol)

	if quantity == 0 then
		return 0
	end

	local costBasis = self:GetCostBasis(player, symbol)
	return costBasis / quantity
end

function TransactionManager:CalculateUnrealizedPL(player, symbol, currentPrice)
	local PortfolioManager = require(script.Parent.PortfolioManager)
	local quantity = PortfolioManager:GetShares(player, symbol)
	local costBasis = self:GetCostBasis(player, symbol)
	local currentValue = quantity * currentPrice

	return currentValue - costBasis
end

function TransactionManager:MigrateExistingPortfolio(player)
	local PortfolioManager = require(script.Parent.PortfolioManager)
	local StockData = require(91072619691201)

	local portfolio = PortfolioManager:GetPortfolio(player)
	local currentTime = os.time()
	local stockPrices = {}

	for _, stock in ipairs(StockData) do
		stockPrices[stock.Symbol] = stock.CurrentPrice
	end

	for symbol, quantity in pairs(portfolio) do
		local price = stockPrices[symbol]
		if price and quantity > 0 then
			self:RecordTransaction(
				player,
				symbol,
				"buy",
				quantity,
				price
			)
		end
	end

	print("Migrated portfolio for", player.Name)
	return true
end

function TransactionManager:ClearData(player)
	playerTransactions[player.UserId] = nil
end

return TransactionManager
