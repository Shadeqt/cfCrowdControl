-- Module constants
local MAX_CC_SLOTS = 5 -- 5, maximum CC slots to check

local CC_PRIORITY = {
	STUN = {priority = 60, texture = "Interface\\Icons\\Ability_Warrior_WarCry"},
	FEAR = {priority = 60, texture = "Interface\\Icons\\Spell_Shadow_Possession"},
	CHARM = {priority = 60, texture = "Interface\\Icons\\Spell_Shadow_CharmingRoar"},
	CONFUSE = {priority = 60, texture = "Interface\\Icons\\Spell_Shadow_MindSteal"},
	POSSESS = {priority = 60, texture = "Interface\\Icons\\Spell_Shadow_ShadowWordDominate"},
	STUN_MECHANIC = {priority = 60, texture = "Interface\\Icons\\Ability_Warrior_Charge"},
	FEAR_MECHANIC = {priority = 60, texture = "Interface\\Icons\\Spell_Shadow_Charm"},
	SILENCE = {priority = 50, texture = "Interface\\Icons\\Ability_Mage_IceBlock"},
	PACIFYSILENCE = {priority = 50, texture = "Interface\\Icons\\Ability_Warrior_ShieldBash"},
	SCHOOL_INTERRUPT = {priority = 40, texture = "Interface\\Icons\\Spell_Frost_IceShock"},
	DISARM = {priority = 30, texture = "Interface\\Icons\\Ability_Warrior_Disarm"},
	PACIFY = {priority = 30, texture = "Interface\\Icons\\Ability_Hunter_BeastSoothe"},
	ROOT = {priority = 20, texture = "Interface\\Icons\\Spell_Nature_StrangleVines"},
}

-- Module states
local activeCCs = {}
local lastUpdateTime = 0

local iconFrame = CreateFrame("Frame", nil, UIParent)
iconFrame:SetSize(64, 64)
iconFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
iconFrame:Hide()

local texture = iconFrame:CreateTexture(nil, "ARTWORK")
texture:SetAllPoints()

local cooldown = CreateFrame("Cooldown", nil, iconFrame, "CooldownFrameTemplate")
cooldown:SetAllPoints()
cooldown:SetHideCountdownNumbers(true)

local function GetHighestPriorityCC()
	local selectedCC = nil
	local maxPriority = -1

	for _, cc in ipairs(activeCCs) do
		local ccConfig = CC_PRIORITY[cc.locType]
		local priority = ccConfig and ccConfig.priority or 0
		if priority > maxPriority then
			selectedCC = cc
			maxPriority = priority
		end
	end

	return selectedCC
end

-- Update icon display with selected CC
local function UpdateIconDisplay(cc)
	if not cc then
		iconFrame:Hide()
		return
	end

	-- Use spell icon if available, fallback to default texture
	local ccConfig = CC_PRIORITY[cc.locType]
	local defaultTexture = ccConfig and ccConfig.texture or "Interface\\Icons\\INV_Misc_QuestionMark"
	local spellIcon = cc.iconTexture or defaultTexture
	texture:SetTexture(spellIcon)

	-- Show frame before SetCooldown for timer addon visibility
	iconFrame:Show()

	cooldown:SetCooldown(cc.startTime, cc.duration)
end

-- Check if this is a redundant event in the same frame
local function IsRedundantUpdate()
	local currentTime = GetTime()
	if currentTime == lastUpdateTime then
		return true
	end
	lastUpdateTime = currentTime
	return false
end

-- Rebuild active CCs table from game data
local function RebuildActiveCCs()
	wipe(activeCCs)

	for i = 1, MAX_CC_SLOTS do
		local data = C_LossOfControl.GetActiveLossOfControlData(i)
		if data and data.duration and data.duration > 0 then
			if not CC_PRIORITY[data.locType] then
				print(format("WARNING: Unknown locType '%s' from spell '%s'",
					tostring(data.locType), tostring(data.displayText)))
			end

			activeCCs[i] = {
				locType = data.locType,
				iconTexture = data.iconTexture,
				startTime = data.startTime,
				duration = data.duration,
			}
		end
	end
end

-- Create event frame
local eventFrame = CreateFrame("Frame")

-- Event handler
eventFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "LOSS_OF_CONTROL_UPDATE" then
		if IsRedundantUpdate() then return end

		RebuildActiveCCs()

		local selectedCC = GetHighestPriorityCC()
		UpdateIconDisplay(selectedCC)
	end
end)

-- Initialize
eventFrame:RegisterEvent("LOSS_OF_CONTROL_UPDATE")