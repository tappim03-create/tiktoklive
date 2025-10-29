-- LocalScript ใส่ใน StarterPlayerScripts
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local redeemEvent = ReplicatedStorage:WaitForChild("RedeemKeyEvent")

-- สร้าง GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KeyGui"
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,450,0,220)
frame.Position = UDim2.new(0.5,-225,0.4,0)
frame.BackgroundColor3 = Color3.fromRGB(245,245,245)
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Text = "Daily Key from Website"
title.TextScaled = true
title.Parent = frame

local keyLabel = Instance.new("TextLabel")
keyLabel.Size = UDim2.new(0,300,0,50)
keyLabel.Position = UDim2.new(0.5,-150,0.25,0)
keyLabel.Text = "Loading key..."
keyLabel.TextScaled = true
keyLabel.BackgroundTransparency = 1
keyLabel.Parent = frame

local redeemBtn = Instance.new("TextButton")
redeemBtn.Size = UDim2.new(0,140,0,40)
redeemBtn.Position = UDim2.new(0.5,-70,0.6,0)
redeemBtn.Text = "Redeem Key"
redeemBtn.Parent = frame

local resultLabel = Instance.new("TextLabel")
resultLabel.Size = UDim2.new(1,0,0,30)
resultLabel.Position = UDim2.new(0,0,0.85,0)
resultLabel.BackgroundTransparency = 1
resultLabel.TextColor3 = Color3.new(0, 0.6, 0)
resultLabel.Text = ""
resultLabel.Parent = frame

-- URL ของ GitHub Pages (แก้เป็นของคุณ)
local keyURL = "https://<USERNAME>.github.io/<REPO>/key.json"

-- ดึง key จากเว็บ
local currentKey
spawn(function()
    local success, res = pcall(function()
        return HttpService:GetAsync(keyURL)
    end)
    if success then
        local ok, data = pcall(function()
            return HttpService:JSONDecode(res)
        end)
        if ok and data.key then
            currentKey = tostring(data.key)
            keyLabel.Text = currentKey
        else
            keyLabel.Text = "Failed to load key"
        end
    else
        keyLabel.Text = "Failed to fetch key"
    end
end)

-- กด redeem ส่ง server
redeemBtn.Activated:Connect(function()
    if not currentKey then
        resultLabel.Text = "Key not loaded yet"
        return
    end
    redeemEvent:FireServer(currentKey)
end)

-- รับผลลัพธ์จาก server
redeemEvent.OnClientEvent:Connect(function(resp)
    if resp.ok then
        screenGui:Destroy()
        -- โหลด GUI หลักด้วย loadstring (ตัวอย่าง)
        local ok, err = pcall(function()
            local guiCode = [[
                local player = game.Players.LocalPlayer
                local sg = Instance.new("ScreenGui")
                sg.Name = "MainGUI"
                sg.Parent = player:WaitForChild("PlayerGui")
                local lbl = Instance.new("TextLabel")
                lbl.Size = UDim2.new(0,500,0,100)
                lbl.Position = UDim2.new(0.5,-250,0.4,0)
                lbl.TextScaled = true
                lbl.Text = "Key accepted! Welcome!"
                lbl.Parent = sg
            ]]
            loadstring(guiCode)()
        end)
        if not ok then
            warn("Load main GUI failed:", err)
        end
    else
        resultLabel.Text = "Error: " .. tostring(resp.msg or "Invalid key")
    end
end)
