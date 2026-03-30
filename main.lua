_G.Key = "RENXY_VIP_01"
-- ==========================================
-- 🔒 ระบบตรวจสอบ Key
-- ==========================================
local WhitelistKeys = {
    ["RENXY_VIP_01"] = true,
    ["FREE_TEST_KEY"] = true
}

local userKey = _G.Key 

if not userKey or not WhitelistKeys[userKey] then
    game.Players.LocalPlayer:Kick("⛔ สคริปต์ถูกล็อก: Key ของคุณไม่ถูกต้อง หรือไม่ได้ลงทะเบียน!")
    return 
end

print("✅ ยืนยัน Key สำเร็จ! กำลังโหลด Auto Farm...")

-- ==========================================
-- ⚙️ ตั้งค่าสคริปต์ (Config)
-- ==========================================
if not getgenv().Config then
    getgenv().Config = {
        -- [ระบบความปลอดภัย]
        Require_Private_Server = {
            Kick = true,          -- ถ้าไม่ใช่เซิร์ฟวี ให้เตะออกทันที
            LeaveServer = false,  -- ถ้าไม่ใช่เซิร์ฟวี ให้ปิดเกมกลับหน้าโฮม (ใช้ Kick แทนได้ผลเหมือนกัน)
        },
        -- [ระบบฟาร์มเดิม]
        FarmStrongestShinobi = false, 
        FarmAtomicBoss = false,       
        AutoHaki = true,
        AutoOpenChest = true,
        AutoBuyMerchant = true,
    }
end

local cfg = getgenv().Config -- ดึงค่า config มาใช้งาน

-- ==========================================
-- 🛡️ ระบบ Solo Mode Enforcer (ต้องมีเราคนเดียวเท่านั้น)
-- ==========================================
local function EnforceSoloMode()
    local Players = game:GetService("Players")
    
    local function CheckAndKick()
        local allPlayers = Players:GetPlayers()
        if #allPlayers > 1 then
            -- ตรวจพบว่ามีคนอื่นนอกจากเรา
            warn("⚠️ [Safety Alert] ตรวจพบผู้เล่นอื่นเข้าเซิร์ฟเวอร์! กำลังเตะออก...")
            Players.LocalPlayer:Kick("\n\n🛡️ [RENXY SOLO SAFE]\nตรวจพบผู้เล่นคนที่ 2 เข้ามาในเซิร์ฟเวอร์\nเพื่อความปลอดภัย สคริปต์จึงดีดคุณออกทันที!")
        end
    end

    -- 1. เช็คทันทีที่รันสคริปต์
    CheckAndKick()

    -- 2. ตั้งระบบดักจับ (Event) ถ้ามีใครจอยเข้ามาทีหลัง ให้เตะออก "ทันที"
    Players.PlayerAdded:Connect(function(newPlayer)
        print("👤 มีผู้เล่นกำลังเข้า: " .. newPlayer.Name)
        CheckAndKick()
    end)
    
    print("✅ [Solo Mode] ระบบป้องกันทำงานแล้ว (ต้องอยู่คนเดียวเท่านั้น)")
    return true
end

-- เรียกใช้งานระบบ
if not EnforceSoloMode() then return end
-- ==========================================

-- ==========================================
-- 🚀 FPS Boost (ภาพดินน้ำมัน ลื่นสุด & มองเห็นเกม)
-- ==========================================
task.spawn(function()
    print("🧹 กำลังปรับกราฟิกให้ต่ำที่สุดเพื่อดัน FPS...")
    pcall(function() setfpscap(999) end)
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01

    local Lighting = game:GetService("Lighting")
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.Brightness = 0
    
    for _, v in pairs(Lighting:GetDescendants()) do
        if v:IsA("PostEffect") or v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("SunRaysEffect") or v:IsA("BloomEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") then
            v:Destroy()
        end
    end

    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Material = Enum.Material.SmoothPlastic
            v.CastShadow = false
            v.Reflectance = 0
        elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
            v:Destroy()
        end
    end

    local Terrain = workspace:FindFirstChildOfClass("Terrain")
    if Terrain then
        Terrain.WaterWaveSize = 0
        Terrain.WaterWaveSpeed = 0
        Terrain.WaterReflectance = 0
        Terrain.WaterTransparency = 0
        Terrain.Decoration = false
    end
end)
-- ==========================================

-- ==========================================
-- 🛑 ระบบล้างสคริปต์เก่า
-- ==========================================
if getgenv().Renxy_Active then
    getgenv().Renxy_Active = false 
    if getgenv().Renxy_Input then getgenv().Renxy_Input:Disconnect() end
    task.wait(0.5) 
end

getgenv().Renxy_Active = true 
getgenv().Renxy_IsFarming = true 
getgenv().Renxy_CurrentNPC = "" 
-- ==========================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local toggleKey = Enum.KeyCode.RightControl 

local FarmList = {
    {Portal = "Starter", NPC = "Thief4"},
    {Portal = "Jungle",  NPC = "Monkey2"},
    {Portal = "Desert",  NPC = "DesertBandit2"},
    {Portal = "Snow",    NPC = "FrostRogue3"},
    {Portal = "Sailor",  NPC = {"JinwooBoss", "AlucardBoss"}, WaitTime = 3},
    {Portal = "Shibuya", NPC = {"SukunaBoss", "YujiBoss", "GojoBoss"}},
    {Portal = "HollowIsland", NPC = {"Hollow2", "AizenBoss"}},
    {Portal = "Shinjuku", NPC = {"Curse3", "StrongSorcerer4"}},
    {Portal = "Slime", NPC = "Slime3"},
    {Portal = "Academy", NPC = "AcademyTeacher3"},
    {Portal = "Judgement", NPC = "Swordsman4"},
    {Portal = "SoulDominion", NPC = "Quincy4"},
    {Portal = "Ninja", NPC = {"Ninja4", "StrongestShinobiBoss"}},
    {Portal = "Lawless", NPC = {"ArenaFighter2", "AtomicBoss_Normal"}},
}

local weaponName = "Strongest In History" 

getgenv().Renxy_Input = UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == toggleKey then
        getgenv().Renxy_IsFarming = not getgenv().Renxy_IsFarming 
        if getgenv().Renxy_IsFarming then
            game.StarterGui:SetCore("SendNotification", {Title = "Auto Farm", Text = "✅ เปิดการทำงาน (ON)", Duration = 2})
        else
            game.StarterGui:SetCore("SendNotification", {Title = "Auto Farm", Text = "❌ ปิดการทำงาน (OFF)", Duration = 2})
        end
    end
end)

-- ==========================================
-- ⚔️ ระบบสวมใส่อาวุธ + บังคับถือ (Equip & Hold)
-- ==========================================
local function EquipWeapon(name)
    local character = player.Character
    if not character or not character:FindFirstChild("Humanoid") then return end
    
    local toolInBackpack = player.Backpack:FindFirstChild(name)
    local toolInCharacter = character:FindFirstChild(name)

    -- 1. ถ้ายังไม่ได้ใส่ (ไม่อยู่ในตัวและไม่อยู่ในกระเป๋า) ให้ส่ง Remote ไปเบิกของ
    if not toolInBackpack and not toolInCharacter then
        local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("EquipWeapon")
        local args = {"Equip", name}
        remote:FireServer(unpack(args))
        
        -- รอให้ของเข้า Backpack แป๊บเดียว
        task.wait(0.3) 
        toolInBackpack = player.Backpack:FindFirstChild(name)
    end

    -- 2. ถ้าของอยู่ใน Backpack (แต่ยังไม่ถือ) ให้สั่งหยิบมาไว้ที่มือ
    if toolInBackpack then
        character.Humanoid:EquipTool(toolInBackpack)
        print("👊 หยิบอาวุธ " .. name .. " มาไว้ที่มือแล้ว!")
    end
    
    -- 3. เรียกใช้ Haki ทันทีหลังจากถือของ (เพื่อให้มือดำ/มีออร่า)
    task.spawn(function()
        task.wait(0.1)
        if ActivateHaki then ActivateHaki() end
    end)
end

-- ==========================================
-- 📦 ระบบ Auto Open Chest (Sync Inventory + ทุก 10 นาที)
-- ==========================================
task.spawn(function()
    local useItemRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("UseItem")
    local reqInvRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RequestInventory")
    local chestList = {"Rare Chest", "Epic Chest"} 
    local checkInterval = 300 -- 10 นาที (600 วินาที)

    while getgenv().Renxy_Active do
        -- เช็คเงื่อนไขก่อนเริ่มทำงาน
        if cfg.AutoOpenChest and getgenv().Renxy_IsFarming then
            
            -- 1. ส่ง Remote ขอข้อมูลกระเป๋า (Sync ข้อมูลเพื่อให้ Client มองเห็นกล่อง)
            print("🔄 [Sync] กำลังขอข้อมูล Inventory จาก Server...")
            reqInvRemote:FireServer()
            
            -- รอ 2 วินาทีเพื่อให้ Server ส่งข้อมูลกลับมาให้เรียบร้อยก่อน
            task.wait(2) 

            -- 2. เริ่มลูปส่งคำสั่งเปิดกล่อง
            for _, chestName in ipairs(chestList) do
                print("📦 กำลังส่งคำสั่งเปิด: " .. chestName .. " จำนวน 10,000 กล่อง")
                
                pcall(function()
                    -- ส่งคำสั่งเปิด 10,000 กล่องต่อ 1 ชนิด
                    useItemRemote:FireServer("Use", chestName, 10000, false)
                end)
                
                task.wait(1) -- เว้นระยะห่างเล็กน้อยระหว่าง Rare และ Epic
            end
            
            print("✅ Sync ข้อมูลและส่งคำสั่งเปิดกล่องเสร็จสิ้น! รออีก 10 นาที...")
        end
        
        -- เข้าสู่โหมดพัก 10 นาที
        task.wait(checkInterval)
    end
end)

-- ==========================================
-- 🛒 ระบบ Auto Buy Merchant (ซื้อของพ่อค้าอัตโนมัติ)
-- ==========================================
task.spawn(function()
    local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
    local merchantRemote = Remotes:WaitForChild("MerchantRemotes"):WaitForChild("PurchaseMerchantItem")
    
    -- ใส่ชื่อไอเทมที่ต้องการซื้อตรงนี้ (เพิ่มกี่อันก็ได้)
    local itemsToBuy = {
        "Passive Shard",
        "Dungeon Key",
        "Boss Key",
        "Race Reroll",
        "Trait Reroll",
        "Clan Reroll",
        -- "ไอเทมอื่นๆ", 
    }
    
    local buyInterval = 60 -- เช็คทุกๆ 60 วินาที (เปลี่ยนตัวเลขได้)

    while getgenv().Renxy_Active do
        -- เช็คเงื่อนไขจาก Config
        if getgenv().Config and getgenv().Config.AutoBuyMerchant and getgenv().Renxy_IsFarming then
            for _, itemName in ipairs(itemsToBuy) do
                -- ใช้ pcall ป้องกันสคริปต์ค้าง เนื่องจากเป็น InvokeServer (รอ Server ตอบกลับ)
                local success, result = pcall(function()
                    return merchantRemote:InvokeServer(itemName, 20)
                end)

                if success then
                    print("🛒 [Merchant] ส่งคำสั่งซื้อ: " .. itemName)
                else
                    warn("❌ [Merchant] ซื้อล้มเหลว หรือพ่อค้าไม่มีของ: " .. tostring(result))
                end
                
                task.wait(1) -- หน่วงเวลาเล็กน้อยก่อนซื้อชิ้นต่อไป กันโดนเตะ
            end
        end
        
        -- รอเวลาก่อนเช็ครอบถัดไป
        task.wait(buyInterval)
    end
end)

-- ==========================================
-- 🛡️ ระบบ Auto Haki (กด G อัตโนมัติ)
-- ==========================================
local function ActivateHaki()
    if cfg.AutoHaki and getgenv().Renxy_Active and getgenv().Renxy_IsFarming then
        task.wait(1.5) 
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.G, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.G, false, game)
    end
end
task.spawn(ActivateHaki)
player.CharacterAdded:Connect(function()
    task.wait(2)
    ActivateHaki()
end)

local teleportRemote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("TeleportToPortal")
local npcsFolder = workspace:WaitForChild("NPCs")

-- ==========================================
-- 🎯 ฟังก์ชันช่วยหาเป้าหมาย (แก้บัคล็อกศพมอนสเตอร์)
-- ==========================================
local function GetAliveMob(targetName)
    for _, v in pairs(npcsFolder:GetChildren()) do
        if v.Name == targetName and v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") then
            if v.Humanoid.Health > 0 then
                return v -- คืนค่ามอนสเตอร์ที่ยังมีชีวิตอยู่เท่านั้น
            end
        end
    end
    return nil
end

-- ==========================================
-- ⚔️ ลูปกดสกิล (แยกระบบ Remote และ กดปุ่ม)
-- ==========================================
task.spawn(function()
    while getgenv().Renxy_Active do
        if getgenv().Renxy_IsFarming then 
            local currentNPC = getgenv().Renxy_CurrentNPC
            
            if currentNPC == "AtomicBoss_Normal" or currentNPC == "StrongestShinobiBoss" then
                pcall(function()
                    game:GetService("ReplicatedStorage")
                        :WaitForChild("CombatSystem")
                        :WaitForChild("Remotes")
                        :WaitForChild("RequestHit")
                        :FireServer()
                end)
                -- [จุดที่ 1] ความเร็วการตีของ Boss (Remote Hit)
                -- ปรับน้อยลง = ตีรัวขึ้น เช่น 0.05 หรือ 0.1
                task.wait(0.15) 
            else
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.X, false, game)
                -- [จุดที่ 2] ระยะเวลาที่กดปุ่มค้างไว้ (Hold Time)
                task.wait(0.05) 
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.X, false, game)
                
                -- [จุดที่ 3] ความเร็วการใช้สกิล X ของมอนทั่วไป
                -- ปรับน้อยลง = กดสกิลรัวขึ้น
                task.wait() 
            end
        end
        -- ลูปหลักกันค้าง
        task.wait() 
    end
end)

-- ==========================================
-- 🚀 ลูปหลัก - แก้ไขบัคค้างที่ Lawless (Farm Loop)
-- ==========================================
task.spawn(function()
    while getgenv().Renxy_Active do
        if getgenv().Renxy_IsFarming then
            -- ใช้ ipairs วนลูปจาก FarmList ลำดับที่ 1 ถึงสุดท้าย
            for i = 1, #FarmList do
                local target = FarmList[i]
                
                -- ตรวจสอบก่อนวาปทุกครั้งว่ายังเปิดฟาร์มอยู่ไหม
                if not getgenv().Renxy_IsFarming or not getgenv().Renxy_Active then break end 
                
                -- [ใช้ pcall เพื่อกันสคริปต์เด้งหลุด]
                pcall(function()
                    -- 1. วาปไปด่าน
                    teleportRemote:FireServer(target.Portal)
                    task.wait(target.WaitTime or 0.8) -- เพิ่มเวลาวาปนิดหน่อยกันด่านโหลดไม่ทัน
                    
                    -- 2. เช็คอาวุธ
                    EquipWeapon(weaponName)
                    
                    -- 3. เตรียมรายชื่อ NPC
                    local npcList = type(target.NPC) == "table" and target.NPC or { target.NPC }
                    
                    for _, npcName in ipairs(npcList) do
                        if not getgenv().Renxy_IsFarming or not getgenv().Renxy_Active then break end
                        
                        -- เช็ค Config บอส
                        local skipNPC = false
                        if npcName == "StrongestShinobiBoss" and not cfg.FarmStrongestShinobi then
                            skipNPC = true
                        elseif npcName == "AtomicBoss_Normal" and not cfg.FarmAtomicBoss then
                            skipNPC = true
                        end

                        if not skipNPC then
                            getgenv().Renxy_CurrentNPC = npcName
                            
                            -- ระบบเสกบอส Atomic
                            if npcName == "AtomicBoss_Normal" then
                                pcall(function()
                                    game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents"):WaitForChild("RequestSpawnAtomic"):FireServer("Normal")
                                end)
                            end
                            
                            -- รอ NPC เกิด (ลดเวลาลงเหลือ 2 วินาทีเพื่อให้วนลูปไวขึ้น)
                            local targetNPC = GetAliveMob(npcName)
                            local waitForSpawn = 0
                            while not targetNPC and waitForSpawn < 20 do 
                                task.wait(0.1)
                                targetNPC = GetAliveMob(npcName)
                                waitForSpawn = waitForSpawn + 1
                            end
                            
                            -- ถ้าเจอ NPC ให้ตี
                            if targetNPC then
                                local timeout = 0
                                local isBoss = (npcName == "StrongestShinobiBoss" or npcName == "AtomicBoss_Normal")
                                local maxTimeout = isBoss and 1200 or 150 -- บอสรอ 2 นาที, มอนปกติรอ 15 วิ

                                while getgenv().Renxy_IsFarming and getgenv().Renxy_Active and targetNPC.Parent and targetNPC:FindFirstChild("Humanoid") and targetNPC.Humanoid.Health > 0 and timeout < maxTimeout do
                                    local char = player.Character
                                    if char and char:FindFirstChild("HumanoidRootPart") then
                                        char.HumanoidRootPart.CFrame = targetNPC.HumanoidRootPart.CFrame * CFrame.new(0, 8, 0)
                                    end
                                    task.wait(0.1)
                                    timeout = timeout + 1
                                end
                            end
                        end
                    end
                end)
                
                -- หน่วงเวลาเล็กน้อยก่อนไปด่านถัดไป
                task.wait(0.2)
            end
        else
            -- ถ้าปิดฟาร์ม ให้รอเช็คใหม่ทุก 1 วินาที
            task.wait(1)
        end
        task.wait(0.1)
    end
end)
