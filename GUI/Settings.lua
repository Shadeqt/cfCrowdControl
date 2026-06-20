local addon = cfCrowdControl
local K = addon.KEYS
local F = addon.GUI

function addon.InitSettings()
	local panel = CreateFrame("Frame", "cfCrowdControlSettingsPanel")
	panel.name = "cfCrowdControl"
	panel:Hide()

	local title = F.Title(panel, "cfCrowdControl")

	F.Checkbox(panel, title, "Show loss-of-control icon", K.ENABLED, {
		onEnable = addon.EnableCCDisplay,
		onDisable = addon.DisableCCDisplay,
	})

	panel:SetScript("OnShow", F.MakeSettingsPanelDraggable)

	local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name, panel.name)
	Settings.RegisterAddOnCategory(category)
end
