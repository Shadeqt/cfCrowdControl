cfCrowdControl = cfCrowdControl or {}
local addon = cfCrowdControl

addon.KEYS = {
	ENABLED = "Enabled",
}

local defaults = {
	[addon.KEYS.ENABLED] = true,
}

cfCrowdControlDB = cfCrowdControlDB or {}
for key, value in pairs(defaults) do
	if cfCrowdControlDB[key] == nil then
		cfCrowdControlDB[key] = value
	end
end
for key in pairs(cfCrowdControlDB) do
	if defaults[key] == nil then
		cfCrowdControlDB[key] = nil
	end
end

addon.db = cfCrowdControlDB

EventUtil.ContinueOnAddOnLoaded("cfCrowdControl", function()
	addon.InitSettings()
	if addon.db[addon.KEYS.ENABLED] then
		addon.EnableCCDisplay()
	end
end)
