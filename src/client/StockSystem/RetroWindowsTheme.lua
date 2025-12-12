-- Retro Windows 95/98 Theme Module
-- Provides styling functions for a classic Windows aesthetic

local RetroWindowsTheme = {}

-- Color palette
RetroWindowsTheme.Colors = {
	WindowGrey = Color3.fromRGB(192, 192, 192),
	DarkGrey = Color3.fromRGB(128, 128, 128),
	LightGrey = Color3.fromRGB(223, 223, 223),
	TitleBarBlue = Color3.fromRGB(0, 0, 128),
	TitleBarGradient = Color3.fromRGB(16, 132, 208),
	White = Color3.fromRGB(255, 255, 255),
	Black = Color3.fromRGB(0, 0, 0),
	SelectionBlue = Color3.fromRGB(0, 0, 128),
	SelectionText = Color3.fromRGB(255, 255, 255),
	ButtonFaceGrey = Color3.fromRGB(192, 192, 192),
	Red = Color3.fromRGB(255, 0, 0),
}

-- Remove all rounded corners from an element
local function removeCorners(element)
	for _, child in ipairs(element:GetDescendants()) do
		if child:IsA("UICorner") then
			child:Destroy()
		end
	end
end

-- Apply 3D raised button effect
function RetroWindowsTheme.ApplyRaisedBorder(element)
	element.BorderSizePixel = 0

	-- Create the 3D border effect using frames
	local topBorder = Instance.new("Frame")
	topBorder.Name = "TopBorder"
	topBorder.Size = UDim2.new(1, 0, 0, 2)
	topBorder.Position = UDim2.new(0, 0, 0, 0)
	topBorder.BackgroundColor3 = RetroWindowsTheme.Colors.White
	topBorder.BorderSizePixel = 0
	topBorder.ZIndex = element.ZIndex + 1
	topBorder.Parent = element

	local leftBorder = Instance.new("Frame")
	leftBorder.Name = "LeftBorder"
	leftBorder.Size = UDim2.new(0, 2, 1, 0)
	leftBorder.Position = UDim2.new(0, 0, 0, 0)
	leftBorder.BackgroundColor3 = RetroWindowsTheme.Colors.White
	leftBorder.BorderSizePixel = 0
	leftBorder.ZIndex = element.ZIndex + 1
	leftBorder.Parent = element

	local bottomBorder = Instance.new("Frame")
	bottomBorder.Name = "BottomBorder"
	bottomBorder.Size = UDim2.new(1, 0, 0, 2)
	bottomBorder.Position = UDim2.new(0, 0, 1, -2)
	bottomBorder.BackgroundColor3 = RetroWindowsTheme.Colors.DarkGrey
	bottomBorder.BorderSizePixel = 0
	bottomBorder.ZIndex = element.ZIndex + 1
	bottomBorder.Parent = element

	local rightBorder = Instance.new("Frame")
	rightBorder.Name = "RightBorder"
	rightBorder.Size = UDim2.new(0, 2, 1, 0)
	rightBorder.Position = UDim2.new(1, -2, 0, 0)
	rightBorder.BackgroundColor3 = RetroWindowsTheme.Colors.DarkGrey
	rightBorder.BorderSizePixel = 0
	rightBorder.ZIndex = element.ZIndex + 1
	rightBorder.Parent = element
end

-- Apply 3D sunken effect (for pressed buttons or input fields)
function RetroWindowsTheme.ApplySunkenBorder(element)
	element.BorderSizePixel = 0

	local topBorder = Instance.new("Frame")
	topBorder.Name = "TopBorder"
	topBorder.Size = UDim2.new(1, 0, 0, 2)
	topBorder.Position = UDim2.new(0, 0, 0, 0)
	topBorder.BackgroundColor3 = RetroWindowsTheme.Colors.DarkGrey
	topBorder.BorderSizePixel = 0
	topBorder.ZIndex = element.ZIndex + 1
	topBorder.Parent = element

	local leftBorder = Instance.new("Frame")
	leftBorder.Name = "LeftBorder"
	leftBorder.Size = UDim2.new(0, 2, 1, 0)
	leftBorder.Position = UDim2.new(0, 0, 0, 0)
	leftBorder.BackgroundColor3 = RetroWindowsTheme.Colors.DarkGrey
	leftBorder.BorderSizePixel = 0
	leftBorder.ZIndex = element.ZIndex + 1
	leftBorder.Parent = element

	local bottomBorder = Instance.new("Frame")
	bottomBorder.Name = "BottomBorder"
	bottomBorder.Size = UDim2.new(1, 0, 0, 2)
	bottomBorder.Position = UDim2.new(0, 0, 1, -2)
	bottomBorder.BackgroundColor3 = RetroWindowsTheme.Colors.White
	bottomBorder.BorderSizePixel = 0
	bottomBorder.ZIndex = element.ZIndex + 1
	bottomBorder.Parent = element

	local rightBorder = Instance.new("Frame")
	rightBorder.Name = "RightBorder"
	rightBorder.Size = UDim2.new(0, 2, 1, 0)
	rightBorder.Position = UDim2.new(1, -2, 0, 0)
	rightBorder.BackgroundColor3 = RetroWindowsTheme.Colors.White
	rightBorder.BorderSizePixel = 0
	rightBorder.ZIndex = element.ZIndex + 1
	rightBorder.Parent = element
end

-- Remove existing border frames
local function removeBorders(element)
	local borders = {"TopBorder", "LeftBorder", "BottomBorder", "RightBorder"}
	for _, borderName in ipairs(borders) do
		local border = element:FindFirstChild(borderName)
		if border then
			border:Destroy()
		end
	end
end

-- Style a main window/frame
function RetroWindowsTheme.ApplyToWindow(frame)
	removeCorners(frame)
	removeBorders(frame)

	frame.BackgroundColor3 = RetroWindowsTheme.Colors.WindowGrey
	frame.BorderSizePixel = 2
	frame.BorderColor3 = RetroWindowsTheme.Colors.DarkGrey

	RetroWindowsTheme.ApplyRaisedBorder(frame)
end

-- Style a button
function RetroWindowsTheme.ApplyToButton(button, isActive)
	removeCorners(button)
	removeBorders(button)

	button.BackgroundColor3 = RetroWindowsTheme.Colors.ButtonFaceGrey
	button.BorderSizePixel = 0
	button.Font = Enum.Font.SourceSans
	button.TextColor3 = RetroWindowsTheme.Colors.Black

	if isActive == false then
		button.TextColor3 = RetroWindowsTheme.Colors.DarkGrey
	end

	RetroWindowsTheme.ApplyRaisedBorder(button)
end

-- Style a tab button
function RetroWindowsTheme.ApplyToTab(tab, isActive)
	removeCorners(tab)
	removeBorders(tab)

	tab.BackgroundColor3 = RetroWindowsTheme.Colors.WindowGrey
	tab.BorderSizePixel = 0
	tab.Font = Enum.Font.SourceSans
	tab.TextColor3 = RetroWindowsTheme.Colors.Black

	if isActive then
		RetroWindowsTheme.ApplySunkenBorder(tab)
		tab.BackgroundColor3 = RetroWindowsTheme.Colors.White
	else
		RetroWindowsTheme.ApplyRaisedBorder(tab)
	end
end

-- Style a text input box
function RetroWindowsTheme.ApplyToTextBox(textBox)
	removeCorners(textBox)
	removeBorders(textBox)

	textBox.BackgroundColor3 = RetroWindowsTheme.Colors.White
	textBox.BorderSizePixel = 0
	textBox.Font = Enum.Font.SourceSans
	textBox.TextColor3 = RetroWindowsTheme.Colors.Black

	RetroWindowsTheme.ApplySunkenBorder(textBox)
end

-- Style a label/text element
function RetroWindowsTheme.ApplyToLabel(label)
	removeCorners(label)

	label.BackgroundColor3 = RetroWindowsTheme.Colors.WindowGrey
	label.BorderSizePixel = 0
	label.Font = Enum.Font.SourceSans
	label.TextColor3 = RetroWindowsTheme.Colors.Black
end

-- Style a close button (red X)
function RetroWindowsTheme.ApplyToCloseButton(button, margin)
	margin = margin or 5

	removeCorners(button)
	removeBorders(button)

	button.BackgroundColor3 = RetroWindowsTheme.Colors.ButtonFaceGrey
	button.BorderSizePixel = 0
	button.Text = "X"
	button.Font = Enum.Font.SourceSansBold
	button.TextSize = 18
	button.TextColor3 = RetroWindowsTheme.Colors.Black

	-- Remove any UIPadding
	local existingPadding = button:FindFirstChildOfClass("UIPadding")
	if existingPadding then
		existingPadding:Destroy()
	end

	-- Position button in top-right corner with margin from edges
	button.AnchorPoint = Vector2.new(1, 0)  -- Anchor to top-right of button
	button.Position = UDim2.new(1, -margin, 0, margin)  -- 1 = right edge, 0 = top edge, with margin offset

	RetroWindowsTheme.ApplyRaisedBorder(button)
end

-- Style a title bar
function RetroWindowsTheme.ApplyToTitleBar(titleBar)
	removeCorners(titleBar)

	titleBar.BackgroundColor3 = RetroWindowsTheme.Colors.TitleBarBlue
	titleBar.BorderSizePixel = 0

	-- Style any text in the title bar
	for _, child in ipairs(titleBar:GetChildren()) do
		if child:IsA("TextLabel") then
			child.TextColor3 = RetroWindowsTheme.Colors.White
			child.Font = Enum.Font.SourceSansBold
			child.BackgroundTransparency = 1
		end
	end
end

-- Style a stock row
function RetroWindowsTheme.ApplyToStockRow(row, isSelected)
	removeCorners(row)
	removeBorders(row)

	if isSelected then
		row.BackgroundColor3 = RetroWindowsTheme.Colors.SelectionBlue
		-- Update text color for all labels in the row
		for _, child in ipairs(row:GetChildren()) do
			if child:IsA("TextLabel") then
				child.TextColor3 = RetroWindowsTheme.Colors.SelectionText
			end
		end
	else
		row.BackgroundColor3 = RetroWindowsTheme.Colors.White
		for _, child in ipairs(row:GetChildren()) do
			if child:IsA("TextLabel") then
				child.TextColor3 = RetroWindowsTheme.Colors.Black
			end
		end
	end

	row.BorderSizePixel = 1
	row.BorderColor3 = RetroWindowsTheme.Colors.DarkGrey
end

-- Style a tab bar with flexbox-like layout
function RetroWindowsTheme.ApplyToTabBar(tabBar, tabWidth, tabHeight, margin)
	tabWidth = tabWidth or 98
	tabHeight = tabHeight or 42
	margin = margin or 5

	-- Remove existing layout
	local existingLayout = tabBar:FindFirstChildOfClass("UIListLayout")
	if existingLayout then
		existingLayout:Destroy()
	end

	-- Create horizontal layout (flexbox-like)
	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Horizontal
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	listLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	listLayout.Padding = UDim.new(0, margin)  -- Space between tabs
	listLayout.Parent = tabBar

	-- Size all tab children consistently and add margin around each
	for _, child in ipairs(tabBar:GetChildren()) do
		if child:IsA("TextButton") and child.Name:match("Tab$") then
			child.Size = UDim2.new(0, tabWidth, 0, tabHeight)

			-- Remove existing UIPadding
			local existingPadding = child:FindFirstChildOfClass("UIPadding")
			if existingPadding then
				existingPadding:Destroy()
			end

			-- Add margin around each tab (using Position offset won't work with UIListLayout)
			-- Instead we add the margin as padding inside the tab bar itself
		end
	end

	-- Add margin around the entire tab bar content
	local existingPadding = tabBar:FindFirstChildOfClass("UIPadding")
	if existingPadding then
		existingPadding:Destroy()
	end

	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, margin)
	uiPadding.PaddingRight = UDim.new(0, margin)
	uiPadding.PaddingTop = UDim.new(0, margin)
	uiPadding.PaddingBottom = UDim.new(0, margin)
	uiPadding.Parent = tabBar
end

-- Apply theme to entire UI hierarchy
function RetroWindowsTheme.ApplyToAll(rootElement)
	removeCorners(rootElement)

	-- Apply to all frames
	for _, element in ipairs(rootElement:GetDescendants()) do
		if element:IsA("Frame") then
			if element.Name:match("Content$") then
				-- Content areas
				element.BackgroundColor3 = RetroWindowsTheme.Colors.WindowGrey
				element.BorderSizePixel = 0
			elseif element.Name == "TitleBar" then
				RetroWindowsTheme.ApplyToTitleBar(element)
			elseif element.Name == "TabBar" then
				-- Apply flexbox-like layout to tab bar
				RetroWindowsTheme.ApplyToTabBar(element)
			end
		elseif element:IsA("TextButton") then
			if element.Name:match("Tab$") then
				-- Will be styled dynamically based on active state
				RetroWindowsTheme.ApplyToTab(element, false)
			elseif element.Name == "CloseButton" then
				RetroWindowsTheme.ApplyToCloseButton(element)
			else
				RetroWindowsTheme.ApplyToButton(element, true)
			end
		elseif element:IsA("TextBox") then
			RetroWindowsTheme.ApplyToTextBox(element)
		elseif element:IsA("TextLabel") then
			RetroWindowsTheme.ApplyToLabel(element)
		end
	end
end

return RetroWindowsTheme
