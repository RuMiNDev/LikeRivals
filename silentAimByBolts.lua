local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

local targetPlayer = nil
local ClickInterval = 0.10
local isLeftMouseDown = false
local isRightMouseDown = false

local function isLobbyVisible()
    return localPlayer.PlayerGui.MainGui.MainFrame.Lobby.Currency.Visible == true
end

local function getClosestPlayerToMouse()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local mousePosition = UserInputService:GetMouseLocation()

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
            local head = player.Character.Head
            local headPosition, onScreen = camera:WorldToViewportPoint(head.Position)

            if onScreen then
                local screenPosition = Vector2.new(headPosition.X, headPosition.Y)
                local distance = (screenPosition - mousePosition).Magnitude

                if distance < shortestDistance then
                    closestPlayer = player
                    shortestDistance = distance
                end
            end
        end
    end

    return closestPlayer
end

local function lockCameraToHead()
    if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
        local head = targetPlayer.Character.Head
        local headPosition = camera:WorldToViewportPoint(head.Position)
        if headPosition.Z > 0 then
            local cameraPosition = camera.CFrame.Position
            local direction = (head.Position - cameraPosition).Unit
            local ray = Ray.new(cameraPosition, direction * (head.Position - cameraPosition).Magnitude)
            local hit, hitPosition = workspace:FindPartOnRayWithIgnoreList(ray, {localPlayer.Character, camera})

            if hit and hit:IsDescendantOf(targetPlayer.Character) then
                local newPosition = cameraPosition + direction * 0.5
                camera.CFrame = CFrame.new(newPosition, head.Position)
            end
        end
    end
end

local function autoClick()
    while isLeftMouseDown or isRightMouseDown do
        if not isLobbyVisible() then
            mouse1click()
            task.wait(ClickInterval)
            if not isLeftMouseDown and not isRightMouseDown then
                break
            end
        else
            break
        end
    end
end

UserInputService.InputBegan:Connect(function(input, isProcessed)
    if Settings.SilentAimEnabled == true then
        if input.UserInputType == Enum.UserInputType.MouseButton1 and not isProcessed then
            if not isLeftMouseDown then
                isLeftMouseDown = true
                task.spawn(autoClick)
            end
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 and not isProcessed then
            if not isRightMouseDown then
                isRightMouseDown = true
                task.spawn(autoClick)
            end
        end
    end
end)

-- UserInputService.InputEnded:Connect(function(input, isProcessed)
--     if input.UserInputType == Enum.UserInputType.MouseButton1 and not isProcessed then
--         isLeftMouseDown = false
--     elseif input.UserInputType == Enum.UserInputType.MouseButton2 and not isProcessed then
--         isRightMouseDown = false
--     end
-- end)

RunService.Heartbeat:Connect(function()
    if not isLobbyVisible() then
        targetPlayer = getClosestPlayerToMouse()
        if targetPlayer then
            lockCameraToHead()
        end
    end
end)
