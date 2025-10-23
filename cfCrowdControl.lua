-- cfCrowdControl: Simple CC display addon
cfCrowdControl = {}
local addon = cfCrowdControl

-- Create event frame
local eventFrame = CreateFrame("Frame")

-- Event handler
eventFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "LOSS_OF_CONTROL_ADDED" then
		-- Handle both payload formats (eventIndex only, or unitTarget + eventIndex)
		local eventIndexOrUnit, eventIndexOrNothing = ...
		local eventIndex = eventIndexOrNothing or eventIndexOrUnit

		local data = C_LossOfControl.GetActiveLossOfControlData(eventIndex)

		if data and data.displayText and data.duration then
			print(string.format("I'm %s for %.1f seconds", data.displayText, data.duration))
		end
	end
end)

-- Initialize
eventFrame:RegisterEvent("LOSS_OF_CONTROL_ADDED")