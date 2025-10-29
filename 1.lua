local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local TextService = game:GetService("TextService")

local gui = Instance.new("ScreenGui")
gui.Name = "WinGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local function addRadius(frame, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = frame
end

local function makeButton(text, size, anchor)
	local b = Instance.new("TextButton")
	b.Size = size
	b.AnchorPoint = anchor or Vector2.new(0.5, 0.5)
	b.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	b.BackgroundTransparency = 0.4
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.Text = text
	b.Parent = gui
	return b
end

local function makeBox(size, anchor, default)
	local t = Instance.new("TextBox")
	t.Size = size
	t.AnchorPoint = anchor or Vector2.new(0.5, 0.5)
	t.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	t.BackgroundTransparency = 0.4
	t.TextColor3 = Color3.fromRGB(255, 255, 255)
	t.Font = Enum.Font.GothamBold
	t.TextScaled = true
	t.Text = default or "1"
	t.Parent = gui
	return t
end

local TEXT = {
	win = "Win: ",
	reset = "Reset",
	selectPart = "Select Win Part",
	confirm = "Confirm",
	cancel = "Cancel",
	notPart = "Not a part.",
	selecting = "Selecting Win Part",
	touched = "+1",
	winReset = "Win Reset!",
	part = "Part: "
}

local win = 0
local maxWinUncapped = true -- win จริงไม่จำกัด
local displayMaxWin = 10 -- ตัวเลขที่จะโชว์ใน GUI
local privacyMode = false

local function createWinLabel(text, pos)
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = pos
	frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
	frame.BackgroundTransparency = 0.4
	frame.BorderSizePixel = 0
	frame.ZIndex = 1
	frame.Parent = gui
	addRadius(frame, 8)

	local label = Instance.new("TextLabel")
	label.Text = text
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255,255,255)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = false
	label.TextSize = 48
	label.TextWrapped = true
	label.Size = UDim2.new(1,-20,1,-10)
	label.Position = UDim2.new(0.5,0,0.5,0)
	label.AnchorPoint = Vector2.new(0.5,0.5)
	label.Parent = frame

	local function resize()
		local textSize = TextService:GetTextSize(label.Text, 48, label.Font, Vector2.new(1000,1000))
		local width = math.max(textSize.X + 30, 200)
		local height = math.max(textSize.Y + 20, 70)
		frame.Size = UDim2.new(0, width, 0, height)
	end
	resize()
	label:GetPropertyChangedSignal("Text"):Connect(resize)
	return frame, label
end

local function createDynamicLabel(text, pos)
	local frame = Instance.new("Frame")
	frame.AnchorPoint = Vector2.new(0.5, 0)
	frame.Position = pos
	frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
	frame.BackgroundTransparency = 0.4
	frame.BorderSizePixel = 0
	frame.ZIndex = 1
	frame.Parent = gui
	addRadius(frame, 8)

	local label = Instance.new("TextLabel")
	label.Text = text
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(255,255,255)
	label.Font = Enum.Font.GothamBold
	label.TextScaled = true
	label.TextWrapped = true
	label.Size = UDim2.new(1,-20,1,-10)
	label.Position = UDim2.new(0.5,0,0.5,0)
	label.AnchorPoint = Vector2.new(0.5,0.5)
	label.Parent = frame

	local function resize()
		local textSize = TextService:GetTextSize(label.Text, 24, label.Font, Vector2.new(1000,1000))
		local width = math.max(textSize.X + 20, 120)
		local height = math.max(textSize.Y + 10, 40)
		frame.Size = UDim2.new(0, width, 0, height)
	end
	resize()
	label:GetPropertyChangedSignal("Text"):Connect(resize)
	return frame, label
end

local winFrame, winLabel = createWinLabel(TEXT.win..win.."/"..displayMaxWin, UDim2.new(0.5,0,0.05,0))
winFrame.Visible = false
local alertFrame, lastLabel = createDynamicLabel("", UDim2.new(0.5,0,0.15,0))
alertFrame.Visible = false

local function showChange(text)
	local alertClone = alertFrame:Clone()
	alertClone.Parent = gui
	alertClone.Visible = true
	local labelClone = alertClone:FindFirstChildOfClass("TextLabel")
	labelClone.Text = text
	labelClone.Visible = true
	task.spawn(function()
		task.wait(1.2)
		alertClone:Destroy()
	end)
end

-- Bottom right buttons
local bottomRightFrame = Instance.new("Frame")
bottomRightFrame.Size = UDim2.new(0, 400, 0, 50)
bottomRightFrame.Position = UDim2.new(1, -10, 1, -10)
bottomRightFrame.AnchorPoint = Vector2.new(1,1)
bottomRightFrame.BackgroundTransparency = 1
bottomRightFrame.Parent = gui
bottomRightFrame.Visible = false

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)
layout.Parent = bottomRightFrame

local plusBtn = makeButton("+", UDim2.new(0,50,0,40))
local deltaBox = makeBox(UDim2.new(0,80,0,40), Vector2.new(0,0), "1")
local minusBtn = makeButton("-", UDim2.new(0,50,0,40))
local resetBtn = makeButton(TEXT.reset, UDim2.new(0,80,0,40))
local maxBox = makeBox(UDim2.new(0,80,0,40), Vector2.new(0,0), tostring(displayMaxWin))
maxBox.PlaceholderText = "Max"

for _, obj in pairs({plusBtn, deltaBox, minusBtn, resetBtn, maxBox}) do
	obj.Parent = bottomRightFrame
end

-- Select Win Part button
local selectBtn = makeButton(TEXT.selectPart, UDim2.new(0,250,0,60))
selectBtn.Position = UDim2.new(0.5,0,0.5,0)

-- Back button
local backBtn = makeButton("<-", UDim2.new(0,60,0,40))
backBtn.Position = UDim2.new(0,10,0,50)
backBtn.AnchorPoint = Vector2.new(0,0)
backBtn.Visible = false
backBtn.Parent = gui

-- Confirm frame
local confirmFrame = Instance.new("Frame")
confirmFrame.Size = UDim2.new(0, 260, 0, 120)
confirmFrame.AnchorPoint = Vector2.new(0.5, 0.5)
confirmFrame.Position = UDim2.new(0.5,0,0.5,0)
confirmFrame.BackgroundColor3 = Color3.fromRGB(20,20,20)
confirmFrame.BackgroundTransparency = 0.2
confirmFrame.Visible = false
confirmFrame.Parent = gui
addRadius(confirmFrame, 12)

local confirmLabel = Instance.new("TextLabel")
confirmLabel.BackgroundTransparency = 1
confirmLabel.TextColor3 = Color3.fromRGB(255,255,255)
confirmLabel.Font = Enum.Font.GothamBold
confirmLabel.TextScaled = true
confirmLabel.Text = TEXT.part.."None"
confirmLabel.Size = UDim2.new(1,-20,0.5,0)
confirmLabel.Position = UDim2.new(0.5,0,0.25,0)
confirmLabel.AnchorPoint = Vector2.new(0.5,0.5)
confirmLabel.Parent = confirmFrame

local confirmBtn = makeButton(TEXT.confirm, UDim2.new(0.45,0,0,40))
confirmBtn.AnchorPoint = Vector2.new(0,0)
confirmBtn.Position = UDim2.new(0.025,0,0.7,0)
confirmBtn.Parent = confirmFrame

local cancelBtn = makeButton(TEXT.cancel, UDim2.new(0.45,0,0,40))
cancelBtn.AnchorPoint = Vector2.new(0,0)
cancelBtn.Position = UDim2.new(0.525,0,0.7,0)
cancelBtn.Parent = confirmFrame

local selectionBox = Instance.new("SelectionBox")
selectionBox.LineThickness = 0.05
selectionBox.Color3 = Color3.fromRGB(255,255,0)
selectionBox.SurfaceTransparency = 0.5
selectionBox.Parent = gui

local function highlightPart(part)
	selectionBox.Adornee = part
	selectionBox.Parent = part
	selectionBox.Visible = true
end

local function clearHighlight()
	selectionBox.Adornee = nil
	selectionBox.Visible = false
end

local selectedPart = nil
local selecting = false
local touchConnection = nil
local mouseConn = nil

local function getDelta()
	local d = tonumber(deltaBox.Text)
	return d or 1
end

-- Update win label (display only)
local function updateWin()
	if privacyMode then
		winLabel.Text = TEXT.win
	else
		winLabel.Text = TEXT.win..win.."/"..displayMaxWin
	end
end

-- Button logic
plusBtn.MouseButton1Click:Connect(function()
	local delta = getDelta()
	win = win + delta
	updateWin()
	showChange("+"..delta)
end)

minusBtn.MouseButton1Click:Connect(function()
	local delta = getDelta()
	win = math.max(win - delta, 0)
	updateWin()
	showChange("-"..delta)
end)

resetBtn.MouseButton1Click:Connect(function()
	win = 0
	updateWin()
	showChange(TEXT.winReset)
end)

-- Max box just display, do not cap win
maxBox.FocusLost:Connect(function()
	local txt = maxBox.Text
	txt = string.gsub(txt, "%s+", "")
	local val = tonumber(txt)
	if val and val > 0 then
		displayMaxWin = math.floor(val)
		maxBox.Text = tostring(displayMaxWin)
	else
		displayMaxWin = 10
		maxBox.Text = tostring(displayMaxWin)
	end
	showChange("Max win set (display only)")
	updateWin()
end)

-- Back button
backBtn.MouseButton1Click:Connect(function()
	selectedPart = nil
	selecting = false
	if touchConnection then
		touchConnection:Disconnect()
		touchConnection = nil
	end
	clearHighlight()
	confirmFrame.Visible = false
	bottomRightFrame.Visible = false
	winFrame.Visible = false
	selectBtn.Visible = true
	backBtn.Visible = false
	if mouseConn then
		mouseConn:Disconnect()
		mouseConn = nil
	end
	showChange("Select Win Part again")
end)

-- Select win part
selectBtn.MouseButton1Click:Connect(function()
	if selecting then return end
	selecting = true
	selectBtn.Text = TEXT.selecting
	showChange(TEXT.selecting)
	if mouseConn then
		mouseConn:Disconnect()
	end
	mouseConn = mouse.Button1Down:Connect(function()
		local target = mouse.Target
		if target and target:IsA("BasePart") then
			selectedPart = target
			selectBtn.Text = TEXT.selectPart
			selecting = false
			mouseConn:Disconnect()
			mouseConn = nil
			highlightPart(selectedPart)
			confirmLabel.Text = TEXT.part..target.Name
			confirmFrame.Visible = true
		else
			showChange(TEXT.notPart)
		end
	end)
end)

local function setupTouchListener()
	if not selectedPart then return end
	if touchConnection then
		touchConnection:Disconnect()
		touchConnection = nil
	end
	touchConnection = selectedPart.Touched:Connect(function(hit)
		local character = player.Character
		if character and hit:IsDescendantOf(character) then
			win = win + 1
			updateWin()
			showChange(TEXT.touched)
			character:BreakJoints()
			if touchConnection then
				touchConnection:Disconnect()
				touchConnection = nil
			end
		end
	end)
end

confirmBtn.MouseButton1Click:Connect(function()
	if not selectedPart then return end
	confirmFrame.Visible = false
	showChange(selectedPart.Name.." selected!")
	selectBtn.Visible = false
	clearHighlight()
	setupTouchListener()
	bottomRightFrame.Visible = true
	winFrame.Visible = true
	backBtn.Visible = true
	updateWin()
end)

cancelBtn.MouseButton1Click:Connect(function()
	selectedPart = nil
	selecting = false
	confirmFrame.Visible = false
	showChange("Cancelled")
	selectBtn.Visible = true
	backBtn.Visible = false
	clearHighlight()
end)

player.CharacterAdded:Connect(function()
	task.wait(0.1)
	setupTouchListener()
end)

local buttons = {plusBtn, minusBtn, resetBtn, selectBtn, confirmBtn, cancelBtn, maxBox, backBtn}
for _, btn in pairs(buttons) do addRadius(btn, 8) end
