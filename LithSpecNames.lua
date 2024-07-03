-- LithSpecNames.lua

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ADDON_LOADED")

local primarySpecNameInput
local secondarySpecNameInput
local settingsPanel
local talentButton
local activeSpec
local activeTalentGroup
local tempSpecNames = {}
local customSpecNameText

-- Function to create or update the custom spec name text
local function CreateOrUpdateCustomSpecNameText()
    if not customSpecNameText then
        customSpecNameText = PlayerTalentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        customSpecNameText:SetPoint("TOP", PlayerTalentFrame, "TOP", 0, -3)
    end
    return customSpecNameText
end

local function setCustomSpecName(displayedTalentGroup, primarySpecName, secondarySpecName)
    local customText = CreateOrUpdateCustomSpecNameText()
    if displayedTalentGroup == 1 then
        customText:SetText(primarySpecName or "")
    else
        customText:SetText(secondarySpecName or "")
    end
    customText:Show()
    
    -- Adjust the position of the original title text
    PlayerTalentFrameTitleText:SetPoint("TOP", customText, "BOTTOM", 0, -5)
end

local function setCustomSpecNameGlyphs(displayedTalentGroup, primarySpecName, secondarySpecName)
    local customText = CreateOrUpdateCustomSpecNameText()
    if displayedTalentGroup == 1 then
        customText:SetText(primarySpecName or "")
    else
        customText:SetText(secondarySpecName or "")
    end
    customText:Show()
    
    -- Adjust the position of the original glyph title text
    PlayerTalentFrameTitleText:SetPoint("TOP", customText, "BOTTOM", 0, -5)
end

local function CreateTalentButton(activeSpec)
    local numTabs = GetNumTalentTabs()

    -- Create the talent button
    talentButton = CreateFrame("Button", "SpecNames_TalentButton", PlayerTalentFrame, "UIPanelButtonTemplate")
    talentButton:SetSize(130, 18)  -- Increased width to accommodate padding
    talentButton:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPLEFT", 55, -1)
    talentButton:SetText("Name your spec")
    
    -- Set smaller text size and add padding
    talentButton:GetFontString():SetFontObject("GameFontNormal")
    talentButton:GetFontString():SetPoint("LEFT", 6, 0)  -- 2px padding on the left
    talentButton:GetFontString():SetPoint("RIGHT", -6, 0)  -- 2px padding on the right

    -- Set the button's click behavior
    talentButton:SetScript("OnClick", function()
        -- Set the input box values based on saved spec names
        primarySpecNameInput:SetText(tempSpecNames.primary or "")
        secondarySpecNameInput:SetText(tempSpecNames.secondary or "")
        
        -- Disable secondary spec input if not available
        if GetNumTalentGroups() < 2 then
            secondarySpecNameInput:Disable()
            secondarySpecNameInput:SetText("Secondary spec not available")
        else
            secondarySpecNameInput:Enable()
        end
        
        settingsPanel:Show() -- Show the settings panel
    end)

    activeSpec = GetActiveTalentGroup()
    -- Update the talent frame title based on active tab and saved spec names
    setCustomSpecName(activeSpec, tempSpecNames.primary, tempSpecNames.secondary)
end

function GetSavedSpecNames()
    local playerName = UnitName("player")
    local serverName = GetRealmName()

    if LithSpecNames and LithSpecNames[serverName] and LithSpecNames[serverName][playerName] then
        return LithSpecNames[serverName][playerName].primary, LithSpecNames[serverName][playerName].secondary
    end

    return "", ""
end

local function HideRenameButton()
    if talentButton then
        talentButton:Hide()
        settingsPanel:Hide()
    end
    if customSpecNameText then
        customSpecNameText:Hide()
    end
end

local function ShowRenameButton()
    if talentButton then
        talentButton:Show()
        activeSpec = GetActiveTalentGroup()
        setCustomSpecName(activeSpec, tempSpecNames.primary, tempSpecNames.secondary)
    end
end

local function SaveSpecNames()
    local playerName = UnitName("player")
    local serverName = GetRealmName()

    tempSpecNames.primary = primarySpecNameInput:GetText()
    tempSpecNames.secondary = secondarySpecNameInput:GetText()

    if not LithSpecNames then
        LithSpecNames = {}
    end
    if not LithSpecNames[serverName] then
        LithSpecNames[serverName] = {}
    end
    LithSpecNames[serverName][playerName] = {
        primary = tempSpecNames.primary,
        secondary = tempSpecNames.secondary
    }

    settingsPanel:Hide()

    local activeSpec = GetActiveTalentGroup()
    setCustomSpecName(activeSpec, tempSpecNames.primary, tempSpecNames.secondary)
end

local function DisplayedTalentGroup()
    local displayedTalentGroup = PlayerTalentFrame.talentGroup
    setCustomSpecName(displayedTalentGroup, tempSpecNames.primary, tempSpecNames.secondary)
end

local function DisplayedTalentGroupGlyphs()
    if GlyphFrame then
        local displayedTalentGroup = PlayerTalentFrame.talentGroup
        setCustomSpecNameGlyphs(displayedTalentGroup, tempSpecNames.primary, tempSpecNames.secondary)
    end
end

local function Initialize(self, event, ...)
    if event == "ADDON_LOADED" and ... == "Blizzard_TalentUI" then
        local playerName = UnitName("player")
        local serverName = GetRealmName()
        tempSpecNames.primary, tempSpecNames.secondary = GetSavedSpecNames()
        
        -- Create the settings panel
        settingsPanel = CreateFrame("Frame", "SpecNames_SettingsPanel", PlayerTalentFrame, "BasicFrameTemplate")
        settingsPanel:SetSize(220, 160)
        settingsPanel:SetPoint("TOP", 0, -10)
        settingsPanel:SetFrameStrata("HIGH")  
        -- Create the title
        local title = settingsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOP", 0, -6)
        title:SetText("Name your specs")
        settingsPanel:Hide()

        -- Create the label for primary spec
        local primaryLabel = settingsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        primaryLabel:SetPoint("TOPLEFT", 10, -30)
        primaryLabel:SetText("Primary Spec")

        -- Create the text input box for naming the primary spec
        primarySpecNameInput = CreateFrame("EditBox", "SpecNames_PrimarySpecNameInput", settingsPanel, "InputBoxTemplate")
        primarySpecNameInput:SetSize(200, 20)
        primarySpecNameInput:SetPoint("TOPLEFT", primaryLabel, "BOTTOMLEFT", 0, -5)
        primarySpecNameInput:SetAutoFocus(false)
        primarySpecNameInput:SetMaxLetters(40)

        -- Create the label for secondary spec
        local secondaryLabel = settingsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        secondaryLabel:SetPoint("TOPLEFT", primarySpecNameInput, "BOTTOMLEFT", 0, -10)
        secondaryLabel:SetText("Secondary Spec")

        -- Create the text input box for naming the secondary spec
        secondarySpecNameInput = CreateFrame("EditBox", "SpecNames_SecondarySpecNameInput", settingsPanel, "InputBoxTemplate")
        secondarySpecNameInput:SetSize(200, 20)
        secondarySpecNameInput:SetPoint("TOPLEFT", secondaryLabel, "BOTTOMLEFT", 0, -5)
        secondarySpecNameInput:SetAutoFocus(false)
        secondarySpecNameInput:SetMaxLetters(40)

        -- Create the "Save" button
        local saveButton = CreateFrame("Button", "SpecNames_SaveButton", settingsPanel, "UIPanelButtonTemplate")
        saveButton:SetSize(90, 25)
        saveButton:SetPoint("BOTTOMLEFT", 10, 10)
        saveButton:SetText("Save")
        saveButton:SetScript("OnClick", SaveSpecNames)

        -- Create the "Close" button
        local closeButton = CreateFrame("Button", "SpecNames_CloseButton", settingsPanel, "UIPanelButtonTemplate")
        closeButton:SetSize(90, 25)
        closeButton:SetPoint("BOTTOMRIGHT", -10, 10)
        closeButton:SetText("Cancel")
        closeButton:SetScript("OnClick", function()
            settingsPanel:Hide()
        end)

        self:UnregisterEvent(event)
        if not talentButton then
            CreateTalentButton(activeSpec)
        end
        if PlayerTalentFrame then
            PlayerTalentFrame:HookScript("OnShow", ShowRenameButton)
            PlayerTalentFrame:HookScript("OnHide", HideRenameButton)
            
            PlayerTalentFrame:HookScript("OnShow", DisplayedTalentGroup)
            PlayerSpecTab1:HookScript("OnClick", DisplayedTalentGroup)
            PlayerSpecTab2:HookScript("OnClick", DisplayedTalentGroup)
            PlayerTalentFrameTab1:HookScript("OnClick", DisplayedTalentGroup) -- Talents
            PlayerTalentFrameTab2:HookScript("OnClick", DisplayedTalentGroup) -- Pet Talents (if applicable)
            PlayerTalentFrameTab3:HookScript("OnClick", DisplayedTalentGroupGlyphs) -- Glyphs
        end
    end
end

frame:SetScript("OnEvent", Initialize)