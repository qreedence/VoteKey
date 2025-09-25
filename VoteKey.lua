local VoteKey = {}
local voteFrame
local artFrame

local function DisplayMyKeystoneInfo()
    print("--- Your Keystone Info ---")
    local challengeMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID()
    local keystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()

    local dungeonName, _, _, _, backgroundTextureID, _ = C_ChallengeMode.GetMapUIInfo(challengeMapID)

    if challengeMapID and challengeMapID ~= 0 and keystoneLevel and keystoneLevel ~= 0 then
        print(string.format("Your keystone: " .. (dungeonName or "Unknown Dungeon") .. " +" .. keystoneLevel))

        if artFrame and backgroundTextureID then
            voteFrame:SetSize(600, 600) 
            artFrame:SetTexture(backgroundTextureID)
            artFrame:SetTexCoord(0.1, 0.7, 0.1, 0.55)
            artFrame:SetSize(540, 400)
            artFrame:Show()
        elseif artFrame then
            artFrame:Hide() 
            voteFrame:SetSize(250, 150) 
        end
    else
        print("You: No owned keystone found (or API not ready).")
        print("Please ensure you have a Mythic Keystone in your bags.")
        if artFrame then artFrame:Hide() end
        voteFrame:SetSize(250, 150)
    end
end


-- Function to create the UI frame.
local function CreateVoteUI()
    voteFrame = CreateFrame("Frame", "VoteKeyFrame", UIParent, "BackdropTemplate")
    voteFrame:SetSize(250, 150) -- Initial size for the frame
    voteFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    voteFrame:SetMovable(true)
    voteFrame:EnableMouse(true)
    voteFrame:RegisterForDrag("LeftButton")
    voteFrame:SetScript("OnDragStart", voteFrame.StartMoving)
    voteFrame:SetScript("OnDragStop", voteFrame.StopMovingOrSizing)

    voteFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    voteFrame:SetBackdropColor(0, 0, 0, 0.7)

    voteFrame:SetFrameStrata("TOOLTIP")
    voteFrame:SetFrameLevel(100)

    local title = voteFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    title:SetPoint("TOP", voteFrame, "TOP", 0, -15)
    title:SetText("VoteKey")
    title:SetJustifyH("CENTER")

    artFrame = voteFrame:CreateTexture("VoteKeyArtTexture", "ARTWORK") -- Name, Layer
    artFrame:SetSize(220, 120)
    artFrame:SetPoint("TOP", title, "BOTTOM", 0, -10)
    artFrame:SetTexCoord(0, 1, 0, 1)
    artFrame:SetColorTexture(0.5, 0.5, 0.5, 1)
    artFrame:Hide()

    local startVoteButton = CreateFrame("Button", "VoteKeyStartVoteButton", voteFrame, "UIPanelButtonTemplate")
    startVoteButton:SetSize(120, 25)
    startVoteButton:SetPoint("BOTTOM", voteFrame, "BOTTOM", 0, 15) -- Reposition button to bottom
    startVoteButton:SetText("Start Vote")

    startVoteButton:SetScript("OnClick", function(self)
        DisplayMyKeystoneInfo()
    end)

    voteFrame:Hide()
    print("VoteKey frame created and hidden.")
end


-- --- Slash Command Handling ---
SLASH_VOTEKEY1 = "/vk"
SLASH_VOTEKEY2 = "/votekey"

SlashCmdList["VOTEKEY"] = function(msg)
    if not voteFrame then
        CreateVoteUI()
    end

    if voteFrame:IsShown() then
        voteFrame:Hide()
    else
        voteFrame:Show()
    end
end


-- --- Event Handler ---
VoteKey.eventFrame = CreateFrame("Frame")

local function OnAddonLoaded(self, event, name, ...)
    if event == "ADDON_LOADED" then
        if name == "VoteKey" then
            CreateVoteUI()
            -- Still need these requests for C_ChallengeMode.GetMapUIInfo to work
            C_MythicPlus.RequestCurrentAffixes()
            C_MythicPlus.RequestMapInfo()
            C_MythicPlus.RequestRewards()
            print("VoteKey: C_MythicPlus data requests sent on ADDON_LOADED.")
        end
    end
end

VoteKey.eventFrame:RegisterEvent("ADDON_LOADED")
VoteKey.eventFrame:SetScript("OnEvent", OnAddonLoaded)