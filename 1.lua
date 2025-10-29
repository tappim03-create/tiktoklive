-- Local Win GUI + Finish Selector + Touch Detection
-- by GPT-5

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

local gui = Instance.new("ScreenGui")
gui.Name = "WinGui"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

-- Helper functions
local function makeButton(text, size, pos)
	local b = Instance.new("TextButton")
	b.Size = size
	b.Position = pos
	b.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	b.BackgroundTransparency = 0.4
	b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.GothamBold
	b.TextScaled = true
	b.Text = text
	b.Parent = gui
	return b
end

local function makeLabel(text, size, pos, anchor)
	local l = Instance.new("TextLabel")
	l.Size = size
	l.Position = pos
	l.AnchorPoint = anchor or Vector2.new(0.5, 0)
	l.BackgroundTransparency = 0.3
	l.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	l.TextColor3 = Color3.fromRGB(255, 255, 255)
	l.Font = Enum.Font.GothamBold
	l.TextScaled = true
	l.Text = text
	l.Parent = gui
	return l
end

local function makeBox(size, pos, default)
	local t = Instance.new("TextBox")
	t.Size = size
	t.Position = pos
	t.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	t.BackgroundTransparency = 0.4
	t.TextColor3 = Color3.fromRGB(255, 255, 255)
	t.Font = Enum.Font.GothamBold
	t.TextScaled = true
	t.Text = default or "1"
	t.Parent = gui
	return t
end

-- Main UI
local win = 0
local winLabel = makeLabel("Win: 0", UDim2.new(0, 400, 0, 80), UDim2.new(0.5, 0, 0.02, 0))
local lastLabel = makeLabel("", UDim2.new(0, 200, 0, 40), UDim2.new(0.5, 0, 0.12, 0))
lastLabel.TextColor3 = Color3.fromRGB(255, 220, 100)
lastLabel.BackgroundTransparency = 1

-- Bottom-right UI: delta box and + / - buttons
local deltaBox = makeBox(UDim2.new(0, 80, 0, 40), UDim2.new(1, -190, 1, -50))
local plusBtn = makeButton("+", UDim2.new(0, 50, 0, 40), UDim2.new(1, -100, 1, -50))
local minusBtn = makeButton("-", UDim2.new(0, 50, 0, 40), UDim2.new(1, -50, 1, -50))

-- Centered Select Finish Button
local selectBtn = makeButton("🎯 Select Finish", UDim2.new(0, 150, 0, 40), UDim2.new(0.5, -75, 0.5, -20))

local confirmFrame = Instance.new("Frame")
confirmFrame.Size = UDim2.new(0, 260, 0, 120)
confirmFrame.Position = UDim2.new(0.5, -130, 0.4, 0)
confirmFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
confirmFrame.BackgroundTransparency = 0.2
confirmFrame.Visible = false
confirmFrame.Parent = gui

local confirmLabel = makeLabel("Part: None", UDim2.new(1, 0, 0.5, 0), UDim2.new(0.5, 0, 0, 0), Vector2.new(0.5, 0))
confirmLabel.Parent = confirmFrame

local confirmBtn = makeButton("✅ Confirm", UDim2.new(0.5, -10, 0, 40), UDim2.new(0, 10, 0.5, 30))
confirmBtn.Parent = confirmFrame
local cancelBtn = makeButton("❌ Cancel", UDim2.new(0.5, -10, 0, 40), UDim2.new(0.5, 0, 0.5, 30))
cancelBtn.Parent = confirmFrame

-- Functions
local function updateWin()
	winLabel.Text = "Win: " .. tostring(win)
end

local function showChange(t)
	lastLabel.Text = t
	lastLabel.Visible = true
	task.delay(1.2, function()
		lastLabel.Visible = false
	end)
end

local function getDelta()
	local d = tonumber(deltaBox.Text)
	return d or 1
end

plusBtn.MouseButton1Click:Connect(function()
	win += getDelta()
	updateWin()
	showChange("+" .. getDelta())
end)

minusBtn.MouseButton1Click:Connect(function()
	win -= getDelta()
	updateWin()
	showChange("-" .. getDelta())
end)

-- Highlight for selected part
local selectionBox = Instance.new("SelectionBox")
selectionBox.LineThickness = 0.05
selectionBox.Color3 = Color3.fromRGB(255, 255, 0) -- yellow
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

-- Select finish part
local selectedPart = nil
local selecting = false
local touchConnection = nil

selectBtn.MouseButton1Click:Connect(function()
	if selecting then return end
	selecting = true
	selectBtn.Text = "Click a Part..."
	showChange("Selecting Finish Part")

	local conn
	conn = mouse.Button1Down:Connect(function()
		local target = mouse.Target
		if target and target:IsA("BasePart") then
			selectedPart = target
			selectBtn.Text = "🎯 Select Finish"
			selecting = false
			conn:Disconnect()

			-- Highlight selected part temporarily
			highlightPart(selectedPart)

			-- Show confirm frame
			confirmLabel.Text = "Part: " .. target.Name
			confirmFrame.Visible = true
		else
			showChange("Not a part.")
		end
	end)
end)

-- Setup touch listener function
local function setupTouchListener()
	if not selectedPart then return end

	if touchConnection then
		touchConnection:Disconnect()
		touchConnection = nil
	end

	touchConnection = selectedPart.Touched:Connect(function(hit)
		local character = player.Character
		if character and hit:IsDescendantOf(character) then
			win += 1
			updateWin()
			showChange("+1 Win (Touched!)")
			character:BreakJoints()

			if touchConnection then
				touchConnection:Disconnect()
				touchConnection = nil
			end
		end
	end)
end

-- Confirm selection: hide highlight
confirmBtn.MouseButton1Click:Connect(function()
	if not selectedPart then return end
	confirmFrame.Visible = false
	showChange("✅ " .. selectedPart.Name .. " selected!")
	selectBtn.Visible = false
	clearHighlight()  -- remove highlight after confirmation
	setupTouchListener()
end)

-- Cancel selection: clear highlight
cancelBtn.MouseButton1Click:Connect(function()
	selectedPart = nil
	confirmFrame.Visible = false
	showChange("❌ Cancelled")
	selectBtn.Visible = true
	clearHighlight()
end)

-- Reconnect listener on respawn
player.CharacterAdded:Connect(function()
	task.wait(0.1)
	setupTouchListener()
end)
