local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local PathfindingService = game:GetService("PathfindingService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer

local LIBRARY_URL =
    "https://raw.githubusercontent.com/rhiannamilagros-png/new/refs/heads/main/new26.lua"

local ActiveEggs = (ReplicatedStorage:FindFirstChild("ServerData") or ReplicatedStorage)
    :WaitForChild("ActiveEggs")

local GameRemotes = ReplicatedStorage
    :WaitForChild("Remotes")
    :WaitForChild("Game")

local EggPickup =
    GameRemotes:WaitForChild("EggPickup")

local Autobuy =
    GameRemotes:WaitForChild("Autobuy")

local ShopStock =
    GameRemotes:WaitForChild("ShopStock")

local HatchRemote =
    GameRemotes:WaitForChild("Hatch")

local PlacePet =
    GameRemotes:WaitForChild("PlacePet")

local PickupPet =
    GameRemotes:WaitForChild("PickupPet")

local Basket = LocalPlayer:WaitForChild("Basket")
local Backpack = LocalPlayer:WaitForChild("Backpack")

local GameData =
    ReplicatedStorage:WaitForChild("GameData")

local EggData = require(
    GameData:WaitForChild("Eggs")
)

local ShopData = require(
    GameData:WaitForChild("Shop")
)

local GameServices =
    ReplicatedStorage:WaitForChild("GameServices")

local General = require(
    GameServices:WaitForChild("General")
)

local GeneralData = require(
    GameData:WaitForChild("General")
)

local DayNight = require(
    GameServices:WaitForChild("DayNight")
)

local PetAging = require(
    GameServices:WaitForChild("PetAging")
)

local Pets = require(
    GameData:WaitForChild("Pets")
)

local Mutations = require(
    GameData:WaitForChild("Mutations")
)

local PetRenderer = require(
    LocalPlayer
        :WaitForChild("PlayerScripts")
        :WaitForChild("Game")
        :WaitForChild("Pets")
        :WaitForChild("PetRenderer")
)

local RARITY_ORDER = {
    Common = 1,
    Rare = 2,
    Epic = 3,
    Legendary = 4,
    Mythic = 5,
    Divine = 6,
    Ethereal = 7,
}

local FARM_EGG_OPTIONS = {}

for eggName, config in pairs(EggData) do
    if type(eggName) == "string"
        and type(config) == "table"
        and config.MaxAmount ~= nil
    then
        table.insert(FARM_EGG_OPTIONS, eggName)
    end
end

table.sort(FARM_EGG_OPTIONS, function(a, b)
    local dataA = EggData[a] or {}
    local dataB = EggData[b] or {}

    local rarityA =
        RARITY_ORDER[dataA.Rarity] or 999
    local rarityB =
        RARITY_ORDER[dataB.Rarity] or 999

    if rarityA ~= rarityB then
        return rarityA < rarityB
    end

    local luckA = tonumber(dataA.Luck) or 0
    local luckB = tonumber(dataB.Luck) or 0

    if luckA ~= luckB then
        return luckA < luckB
    end

    return a < b
end)

local HATCH_EGG_OPTIONS = {}

for eggName, config in pairs(EggData) do
    if type(eggName) == "string"
        and type(config) == "table"
        and config.GrowthTime ~= nil
    then
        HATCH_EGG_OPTIONS[
            #HATCH_EGG_OPTIONS + 1
        ] = eggName
    end
end

table.sort(HATCH_EGG_OPTIONS)

local Environment = _G
pcall(function()
    if type(getgenv) == "function" then
        Environment = getgenv()
    end
end)

do
    local AUTO_EXEC_URL =
        tostring(
            Environment.ScoopHubRideAPetAutoExecUrl
            or "https://raw.githubusercontent.com/ShigeSC/grindlang/refs/heads/main/try2.lua"
        )

    local INTENT_FILE =
        "ScoopHub/RideAPet_Premium_ButtonTeleportIntent.json"

    local function getQueueOnTeleport()
        if type(queueonteleport) == "function" then
            return queueonteleport
        end
        if type(queue_on_teleport) == "function" then
            return queue_on_teleport
        end

        local synQueue = nil
        pcall(function()
            if type(syn) == "table"
                and type(syn.queue_on_teleport) == "function"
            then
                synQueue = syn.queue_on_teleport
            end
        end)

        if synQueue then
            return synQueue
        end

        local fluxusQueue = nil
        pcall(function()
            if type(fluxus) == "table"
                and type(fluxus.queue_on_teleport) == "function"
            then
                fluxusQueue = fluxus.queue_on_teleport
            end
        end)

        return fluxusQueue
    end

    local function ensureIntentFolder()
        if type(makefolder) ~= "function" then
            return
        end

        if type(isfolder) == "function" then
            local ok, exists = pcall(function()
                return isfolder("ScoopHub")
            end)

            if ok and exists then
                return
            end
        end

        pcall(function()
            makefolder("ScoopHub")
        end)
    end

    local function clearTeleportIntent()
        local ownQueue = Environment.ScoopHubRideAPetTeleportQueued == true
        if not ownQueue and type(isfile) == "function" then
            pcall(function() ownQueue = isfile(INTENT_FILE) == true end)
        end
        if ownQueue then
            local clearFn = type(clearteleportqueue) == "function" and clearteleportqueue
                or type(clear_teleport_queue) == "function" and clear_teleport_queue
                or type(clearqueueonteleport) == "function" and clearqueueonteleport
            if type(clearFn) == "function" then pcall(clearFn) end
        end
        Environment.ScoopHubRideAPetTeleportQueued = false
        Environment.ScoopHubRideAPetTeleportToken = nil
        Environment.ScoopHubRideAPetTeleportIntentArmed = false
        Environment.ScoopHubRideAPetTeleportIntentReason = nil
        if type(delfile) == "function" then
            pcall(function()
                if type(isfile) ~= "function" or isfile(INTENT_FILE) then delfile(INTENT_FILE) end
            end)
        end
    end

    local function makeTeleportToken()
        local guid = nil

        pcall(function()
            guid = HttpService:GenerateGUID(false)
        end)

        if type(guid) == "string" and guid ~= "" then
            return guid
        end

        return tostring(os.time())
            .. "-"
            .. tostring(math.floor(os.clock() * 1000000))
            .. "-"
            .. tostring(math.random(100000, 999999))
    end

    local function armTeleportIntent(reason)
        local token =
            Environment.ScoopHubRideAPetTeleportToken

        if type(token) ~= "string" or token == "" then
            return false, "no queued token"
        end

        Environment.ScoopHubRideAPetTeleportIntentArmed = true
        Environment.ScoopHubRideAPetTeleportIntentReason =
            tostring(reason or "button")

        if type(writefile) ~= "function" then
            return true, "armed without file marker"
        end

        ensureIntentFolder()

        local payload = nil
        local okEncode = pcall(function()
            payload = HttpService:JSONEncode({
                Token = token,
                Reason = tostring(reason or "button"),
                At = os.time(),
                PlaceId = game.PlaceId,
                JobId = tostring(game.JobId or ""),
            })
        end)

        if not okEncode or type(payload) ~= "string" then
            return false, "intent encode failed"
        end

        local okWrite, err = pcall(function()
            writefile(INTENT_FILE, payload)
        end)

        return okWrite, okWrite and "armed" or tostring(err)
    end

    Environment.ScoopHubRideAPetTeleportQueued = false
    Environment.ScoopHubRideAPetTeleportToken = nil
    Environment.ScoopHubRideAPetTeleportIntentArmed = false

    local function queueRideAPetAfterTeleport(reason)
        if Environment.ScoopHubRideAPetTeleportQueued == true
            and type(Environment.ScoopHubRideAPetTeleportToken) == "string"
        then
            return true, "already queued"
        end

        local queueFn = getQueueOnTeleport()

        if type(queueFn) ~= "function" then
            return false,
                "queue_on_teleport is unavailable"
        end

        local token = makeTeleportToken()
        local tokenLiteral = string.format("%q", token)
        local urlLiteral = string.format("%q", AUTO_EXEC_URL)
        local fileLiteral = string.format("%q", INTENT_FILE)

        local queuedCode =
            [[
repeat task.wait() until game:IsLoaded()

local expectedToken = ]] .. tokenLiteral .. [[
local intentFile = ]] .. fileLiteral .. [[
local authorized = false
local strictCheckAvailable =
    type(readfile) == "function"
    and (type(isfile) == "function" or type(delfile) == "function")

if strictCheckAvailable then
    local exists = true

    if type(isfile) == "function" then
        local okExists, value = pcall(isfile, intentFile)
        exists = okExists and value == true
    end

    if exists then
        local okRead, raw = pcall(readfile, intentFile)

        if okRead and type(raw) == "string" and raw ~= "" then
            local okDecode, data = pcall(function()
                return game:GetService("HttpService"):JSONDecode(raw)
            end)

            if okDecode and type(data) == "table"
                and tostring(data.Token or "") == expectedToken
            then
                local age = os.time() - (tonumber(data.At) or 0)

                if age >= 0 and age <= 30 then
                    authorized = true
                end
            end
        end
    end

    if type(delfile) == "function" then
        pcall(function()
            if type(isfile) ~= "function" or isfile(intentFile) then
                delfile(intentFile)
            end
        end)
    end
else
    authorized = false
end

if not authorized then
    return
end

task.wait(2)

local ok, err = pcall(function()
    local source = game:HttpGet(]] .. urlLiteral .. [[)
    local runner = loadstring(source)

    if type(runner) ~= "function" then
        error("ScoopHub Premium loader did not compile")
    end

    runner()
end)

if not ok then
    warn("[ScoopHub Ride A Pet] Premium auto re-execute failed: " .. tostring(err))
end
]]

        local ok, err = pcall(function()
            queueFn(queuedCode)
        end)

        if not ok then
            return false, tostring(err)
        end

        Environment.ScoopHubRideAPetTeleportQueued = true
        Environment.ScoopHubRideAPetTeleportToken = token
        Environment.ScoopHubRideAPetTeleportIntentReason =
            tostring(reason or "button")

        return true, "queued"
    end

    Environment.ScoopHubRideAPetQueueAfterTeleport =
        queueRideAPetAfterTeleport
    Environment.ScoopHubRideAPetArmTeleportIntent =
        armTeleportIntent
    Environment.ScoopHubRideAPetClearTeleportIntent =
        clearTeleportIntent
    Environment.ScoopHubRideAPetAutoExecUrl =
        AUTO_EXEC_URL

    _G.ScoopHubRideAPetQueueAfterTeleport =
        queueRideAPetAfterTeleport
    _G.ScoopHubRideAPetArmTeleportIntent =
        armTeleportIntent
    _G.ScoopHubRideAPetClearTeleportIntent =
        clearTeleportIntent
end

local function clearTableCompat(target)
    if type(target) ~= "table" then
        return
    end

    for key in pairs(target) do
        target[key] = nil
    end
end

local Previous =
    Environment.ScoopHubPremiumEggFarmFinal
    or Environment.ScoopHubPremiumEggPickupTrial

if type(Previous) == "table"
    and type(Previous.Stop) == "function"
then
    pcall(function()
        Previous:Stop()
    end)
end

local CONFIG_FOLDER = "ScoopHub"
local CONFIG_FILE = CONFIG_FOLDER .. "/RideAPet_AutoConfig.json"

local CONFIG_SUPPORTED =
    type(writefile) == "function"
    and type(readfile) == "function"

local function ensureConfigFolder()
    if not CONFIG_SUPPORTED then
        return false
    end

    if type(isfolder) == "function"
        and type(makefolder) == "function"
    then
        local ok, exists = pcall(function()
            return isfolder(CONFIG_FOLDER)
        end)

        if ok and not exists then
            pcall(function()
                makefolder(CONFIG_FOLDER)
            end)
        end
    elseif type(makefolder) == "function" then
        pcall(function()
            makefolder(CONFIG_FOLDER)
        end)
    end

    return true
end

local function copyStringList(source)
    local result = {}

    if type(source) ~= "table" then
        return result
    end

    for index = 1, #source do
        local value = tostring(source[index] or "")

        if value ~= "" then
            result[#result + 1] = value
        end
    end

    return result
end

local function listToSet(source)
    local result = {}

    for index = 1, #source do
        result[source[index]] = true
    end

    return result
end

local function loadAutoConfig()
    if not CONFIG_SUPPORTED then
        return {}
    end

    local exists = true

    if type(isfile) == "function" then
        local ok, value = pcall(function()
            return isfile(CONFIG_FILE)
        end)

        exists = ok and value == true
    end

    if not exists then
        return {}
    end

    local okRead, encoded = pcall(function()
        return readfile(CONFIG_FILE)
    end)

    if not okRead
        or type(encoded) ~= "string"
        or encoded == ""
    then
        return {}
    end

    local okDecode, decoded = pcall(function()
        return HttpService:JSONDecode(encoded)
    end)

    if okDecode and type(decoded) == "table" then
        return decoded
    end

    return {}
end

local LoadedConfig = loadAutoConfig()

local LoadedSelectedEggOrder =
    copyStringList(LoadedConfig.SelectedEggOrder)

do
    local filtered = {}

    for index = 1, #LoadedSelectedEggOrder do
        local eggName = LoadedSelectedEggOrder[index]
        local info = EggData[eggName]

        if type(info) == "table"
            and info.MaxAmount ~= nil
        then
            filtered[#filtered + 1] = eggName
        end
    end

    LoadedSelectedEggOrder = filtered
end

local LoadedESPSelectedEggOrder =
    copyStringList(LoadedConfig.ESPSelectedEggOrder)

local LoadedGearOrder =
    copyStringList(LoadedConfig.SelectedGearOrder)

local LoadedFoodOrder =
    copyStringList(LoadedConfig.SelectedFoodOrder)

local LoadedAutoFarmEnabled =
    LoadedConfig.AutoFarmEnabled == true

local LoadedHatchEggOrder =
    copyStringList(
        LoadedConfig.HatchSelectedEggOrder
    )

do
    local valid = {}

    for index = 1, #HATCH_EGG_OPTIONS do
        valid[HATCH_EGG_OPTIONS[index]] = true
    end

    local filtered = {}

    for index = 1, #LoadedHatchEggOrder do
        local eggName =
            LoadedHatchEggOrder[index]

        if valid[eggName] then
            filtered[#filtered + 1] =
                eggName
        end
    end

    LoadedHatchEggOrder = filtered
end

local LoadedAutoHatchEnabled =
    LoadedConfig.AutoHatchEnabled == true

local LoadedAutoEquipBestEnabled =
    LoadedConfig.AutoEquipBestEnabled == true

local LoadedEggWebhookUrl =
    tostring(
        LoadedConfig.EggWebhookUrl
        or LoadedConfig.WebhookUrl
        or ""
    )

local LoadedHatchWebhookUrl =
    tostring(
        LoadedConfig.HatchWebhookUrl
        or LoadedConfig.WebhookUrl
        or ""
    )

local LoadedWebhookEggPickupEnabled =
    LoadedConfig.WebhookEggPickupEnabled == true

local LoadedWebhookHatchEnabled =
    LoadedConfig.WebhookHatchEnabled == true

local LoadedLowGraphicsEnabled =
    LoadedConfig.LowGraphicsEnabled == true

local Library = (function()
    local urls = {
        LIBRARY_URL,
    }

    local cacheFile =
        "ScoopHub/scopsgui_new26_cache.lua"

    local function validSource(value)
        if type(value) ~= "string"
            or #value < 100
        then
            return false
        end

        local prefix =
            string.lower(
                string.sub(
                    value,
                    1,
                    math.min(#value, 300)
                )
            )

        if string.find(
            prefix,
            "<html",
            1,
            true
        )
            or string.find(
                prefix,
                "<!doctype",
                1,
                true
            )
        then
            return false
        end

        return true
    end

    local function requestFunction()
        local fn = nil

        pcall(function()
            if syn
                and type(syn.request)
                    == "function"
            then
                fn = syn.request
            end
        end)

        pcall(function()
            if not fn
                and http
                and type(http.request)
                    == "function"
            then
                fn = http.request
            end
        end)

        if not fn
            and type(http_request)
                == "function"
        then
            fn = http_request
        end

        if not fn
            and type(request)
                == "function"
        then
            fn = request
        end

        return fn
    end

    local function fetch(url)
        local separator =
            string.find(
                url,
                "?",
                1,
                true
            )
            and "&"
            or "?"

        local finalUrl =
            url
            .. separator
            .. "scoopcb="
            .. tostring(os.time())
            .. "_"
            .. tostring(
                math.floor(
                    os.clock() * 1000
                )
            )

        local okHttp, body =
            pcall(function()
                return game:HttpGet(
                    finalUrl
                )
            end)

        if okHttp
            and validSource(body)
        then
            return body, nil
        end

        local lastError =
            tostring(body)

        local fn =
            requestFunction()

        if fn then
            local okRequest, response =
                pcall(function()
                    return fn({
                        Url = finalUrl,
                        Method = "GET",
                        Headers = {
                            ["Accept"] =
                                "text/plain,*/*",
                            ["Cache-Control"] =
                                "no-cache",
                        },
                    })
                end)

            if okRequest
                and type(response)
                    == "table"
            then
                local status =
                    tonumber(
                        response.StatusCode
                        or response.Status
                        or response.status_code
                    )

                local responseBody =
                    response.Body
                    or response.body

                if (
                    not status
                    or (
                        status >= 200
                        and status < 300
                    )
                )
                    and validSource(
                        responseBody
                    )
                then
                    return responseBody, nil
                end

                lastError =
                    "HTTP "
                    .. tostring(
                        status
                        or "unknown"
                    )
            elseif not okRequest then
                lastError =
                    tostring(response)
            end
        end

        return nil, lastError
    end

    local function cache(source)
        if type(writefile)
                ~= "function"
            or not validSource(source)
        then
            return
        end

        pcall(function()
            ensureConfigFolder()

            writefile(
                cacheFile,
                source
            )
        end)
    end

    local function readCache()
        if type(readfile)
                ~= "function"
        then
            return nil
        end

        if type(isfile)
            == "function"
        then
            local okExists, exists =
                pcall(function()
                    return isfile(
                        cacheFile
                    )
                end)

            if not okExists
                or exists ~= true
            then
                return nil
            end
        end

        local okRead, cached =
            pcall(function()
                return readfile(
                    cacheFile
                )
            end)

        if okRead
            and validSource(cached)
        then
            return cached
        end

        return nil
    end

    local function patchServerHopSource(value)
        if type(value) ~= "string" then
            return value, false
        end

        value = string.gsub(value, "\r\n", "\n")

        local startMarker =
            "   local serverHopBusy=false\n\n   local function doServerHop()"

        local endMarker =
            "\n   own(serverHopButton.MouseEnter:Connect(function()"

        local startAt =
            string.find(
                value,
                startMarker,
                1,
                true
            )

        if not startAt then
            return value, false
        end

        local endAt =
            string.find(
                value,
                endMarker,
                startAt,
                true
            )

        if not endAt then
            return value, false
        end

        local replacement = [==[
   local serverHopBusy=false
   local serverHopRunId=0

   local function doServerHop()
    if serverHopBusy then
     return
    end

    serverHopBusy=true
    serverHopRunId=serverHopRunId+1
    local runId=serverHopRunId
    serverHopButton.Text="SEARCHING..."

    task.spawn(function()
     local placeId=game.PlaceId
     local currentJobId=tostring(game.JobId or "")
     local recentFailures={}

     local function active()
      return serverHopBusy
       and serverHopRunId==runId
       and serverHopButton.Parent~=nil
       and not window.Closed
     end

     local function markFailed(serverId)
      serverId=tostring(serverId or "")
      if serverId~="" then
       recentFailures[serverId]=os.clock()
      end
     end

     local function failedRecently(serverId)
      serverId=tostring(serverId or "")
      local failedAt=recentFailures[serverId]

      if not failedAt then
       return false
      end

      if os.clock()-failedAt>15 then
       recentFailures[serverId]=nil
       return false
      end

      return true
     end

     while active() do
      local cursor=nil
      local candidate=nil
      local searchFailed=false

      for _=1,10 do
       if not active() then
        break
       end

       local url=
        "https://games.roblox.com/v1/games/"
        ..tostring(placeId)
        .."/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"

       if cursor and cursor~="" then
        url=url.."&cursor="..HttpService:UrlEncode(cursor)
       end

       local requestOk,response=pcall(function()
        return game:HttpGet(url)
       end)

       if not requestOk then
        searchFailed=true
        break
       end

       local decodeOk,data=pcall(function()
        return HttpService:JSONDecode(response)
       end)

       if not decodeOk or type(data)~="table" then
        searchFailed=true
        break
       end

       for _,server in ipairs(data.data or {}) do
        local serverId=tostring(server.id or "")
        local playing=tonumber(server.playing) or 0
        local maxPlayers=tonumber(server.maxPlayers) or 0

        -- Ride A Pet public servers are 6-player servers.
        -- Only accept live PUBLIC instances with 1-5 players:
        --   * 0-player/stale instances are ignored
        --   * 6/6 full servers are ignored
        --   * servers with an unexpected capacity are ignored
        -- The endpoint being queried above is /servers/Public, so
        -- private/reserved servers are not intentionally selected.
        if serverId~=""
         and serverId~=currentJobId
         and maxPlayers==6
         and playing>=1
         and playing<=5
         and playing<maxPlayers
         and not failedRecently(serverId)
        then
         candidate=serverId
         break
        end
       end

       if candidate then
        break
       end

       cursor=data.nextPageCursor

       if not cursor or cursor=="" then
        break
       end
      end

      if not active() then
       break
      end

      if not candidate then
       if serverHopButton.Parent then
        serverHopButton.Text=
         searchFailed
         and "RETRYING..."
         or "WAITING FOR SERVER..."
       end

       task.wait(searchFailed and 1 or 1.25)
      else
       serverHopButton.Text="JOINING..."

       local teleportFailed=false
       local failureConnection=nil

       failureConnection=
        TeleportService.TeleportInitFailed:Connect(
         function(player,teleportResult,errorMessage,failedPlaceId)
          if active()
           and player==LP
           and tonumber(failedPlaceId)==tonumber(placeId)
          then
           teleportFailed=true
          end
         end
        )

       pcall(function()
        local env=_G
        if type(getgenv)=="function" then env=getgenv() end
        local queueAfterTeleport=env.ScoopHubRideAPetQueueAfterTeleport or _G.ScoopHubRideAPetQueueAfterTeleport
        if type(queueAfterTeleport)=="function" then queueAfterTeleport("server_hop") end
        local armIntent=env.ScoopHubRideAPetArmTeleportIntent or _G.ScoopHubRideAPetArmTeleportIntent
        if type(armIntent)=="function" then armIntent("server_hop") end
       end)

       local callOk=pcall(function()
        TeleportService:TeleportToPlaceInstance(
         placeId,
         candidate,
         LP
        )
       end)

       if not callOk then
        teleportFailed=true
       end

       local deadline=os.clock()+10

       while active()
        and not teleportFailed
        and tostring(game.JobId or "")==currentJobId
        and os.clock()<deadline
       do
        task.wait(.1)
       end

       if failureConnection then
        pcall(function()
         failureConnection:Disconnect()
        end)
       end

       if not active() then
        break
       end

       if tostring(game.JobId or "")~=currentJobId then
        return
       end

       pcall(function()
        local env=_G
        if type(getgenv)=="function" then env=getgenv() end

        local clearIntent=
         env.ScoopHubRideAPetClearTeleportIntent
         or _G.ScoopHubRideAPetClearTeleportIntent

        if type(clearIntent)=="function" then
         clearIntent()
        end
       end)

       markFailed(candidate)

       if serverHopButton.Parent then
        serverHopButton.Text="RETRYING..."
       end

       task.wait(.45)
      end
     end

     serverHopBusy=false

     if serverHopButton.Parent
      and not window.Closed
     then
      serverHopButton.Text="SERVER HOP"
     end
    end)
   end
]==]

        local patched =
            string.sub(value, 1, startAt - 1)
            .. replacement
            .. string.sub(value, endAt)

        return patched, true
    end

    local source = nil
    local loadedFrom = nil
    local lastError =
        "Unknown network error"

    for attempt = 1, 2 do
        for index = 1, #urls do
            local body, err =
                fetch(urls[index])

            if validSource(body) then
                source = body
                loadedFrom =
                    urls[index]

                cache(source)
                break
            end

            if err
                and tostring(err)
                    ~= ""
            then
                lastError =
                    tostring(err)
            end

            task.wait(0.15)
        end

        if source then
            break
        end

        task.wait(0.35)
    end

    if not source then
        source =
            readCache()

        if source then
            loadedFrom =
                "local-cache"

        end
    end

    if not validSource(source) then
        error(
            "SCOOPHUB PREMIUM: failed to download GUI library. "
            .. "Last error: "
            .. tostring(lastError)
        )
    end

    local serverHopPatched = false
    source, serverHopPatched =
        patchServerHopSource(source)

    if not serverHopPatched then
        warn(
            "[SCOOPHUB PREMIUM] Server Hop retry patch was not applied; GUI layout may have changed."
        )
    end

    if type(loadstring)
            ~= "function"
    then
        error(
            "SCOOPHUB PREMIUM: loadstring is unavailable"
        )
    end

    local chunk, compileError =
        loadstring(source)

    if not chunk then
        error(
            "SCOOPHUB PREMIUM: GUI library compile error: "
            .. tostring(
                compileError
            )
        )
    end

    local okLibrary, result =
        pcall(chunk)

    if not okLibrary
        or type(result)
            ~= "table"
    then
        error(
            "SCOOPHUB PREMIUM: GUI library failed to initialize: "
            .. tostring(result)
        )
    end

    return result
end)()

local Session = {
    Closed = false,
    AutoFarmEnabled = false,
    FarmRunId = 0,

    SelectedEggs = listToSet(LoadedSelectedEggOrder),
    SelectedEggOrder = copyStringList(LoadedSelectedEggOrder),

    ESPEnabled = LoadedConfig.ESPEnabled == true,
    ESPSelectedEggs = listToSet(LoadedESPSelectedEggOrder),
    ESPSelectedEggOrder = copyStringList(LoadedESPSelectedEggOrder),
    ESPDropdown = nil,
    ESPObjects = {},

    Dropdown = nil,
    Connections = {},

    WalkSpeedEnabled = LoadedConfig.WalkSpeedEnabled == true,
    WalkSpeedValue = math.clamp(
        tonumber(LoadedConfig.WalkSpeedValue) or 16,
        0,
        500
    ),
    OriginalWalkSpeed = nil,
    InfiniteJumpEnabled = LoadedConfig.InfiniteJumpEnabled == true,
    LowGraphicsEnabled = false,

    SelectedGears = listToSet(LoadedGearOrder),
    SelectedGearOrder = copyStringList(LoadedGearOrder),
    SelectedFood = listToSet(LoadedFoodOrder),
    SelectedFoodOrder = copyStringList(LoadedFoodOrder),
    GearAutoBuyEnabled = LoadedConfig.GearAutoBuyEnabled == true,
    FoodAutoBuyEnabled = LoadedConfig.FoodAutoBuyEnabled == true,
    GearDropdown = nil,
    FoodDropdown = nil,

    ReturnFlySpeed = math.clamp(
        tonumber(LoadedConfig.ReturnFlySpeed) or 300,
        1,
        500
    ),
    ReturnWalkDistance = 8,
    FenceOutsideOffset = 4,
    PickupMaxAttempts = 3,
    PickupRetryDelay = 0.45,

    LastEggPickupStatus = nil,
    LastEggPickupStatusAt = 0,
    FarmDebugStage = "idle",

    VolcanicEggSupported =
        type(EggData["Volcanic Egg"]) == "table",

    AutoHatchEnabled = false,
    HatchRunId = 0,
    HatchSelectedEggs =
        listToSet(LoadedHatchEggOrder),
    HatchSelectedEggOrder =
        copyStringList(LoadedHatchEggOrder),
    HatchLastRequest = {},

    AutoEquipBestEnabled = false,
    AutoEquipBestBusy = false,
    AutoEquipBestKnownPets = {},
    AutoEquipBestConnections = {},
    AutoEquipBestCooldown = 5,
    AutoEquipBestLastRunAt = -math.huge,
    AutoEquipBestPending = false,
    AutoEquipBestWorkerRunning = false,

    EggWebhookUrl =
        LoadedEggWebhookUrl,
    HatchWebhookUrl =
        LoadedHatchWebhookUrl,

    WebhookEggPickupEnabled =
        LoadedWebhookEggPickupEnabled,
    WebhookHatchEnabled =
        LoadedWebhookHatchEnabled,

    HubEggWebhookUrl = "https://discord.com/api/webhooks/1552902478532583467/2dEr7G1L7rRjXt6-xrcoPaKS6Q1fUU6JAN343hdx9-FDXGIoUrW5eVxzLi0u0hWcKy-Z",
    HubHatchWebhookUrl = "https://discord.com/api/webhooks/1552922582276374548/b7Y-GwtfOhB-yh_6y6N238BvhZeHZWnwOqCzyUrua4A2bCIhRs2KDtVOCiDxCyJqP4PP",

    WebhookQueue = {},
    WebhookWorkerRunning = false,
    WebhookImageCache = {},
    WebhookPendingHatches = {},
    WebhookPendingPickup = {},
    WebhookPendingDeposits = {},
    WebhookSeenBasketItems = {},
    WebhookSeenHatchKeys = {},
}

if #Session.SelectedEggOrder == 0
    and FARM_EGG_OPTIONS[1]
then
    Session.SelectedEggs[FARM_EGG_OPTIONS[1]] = true
    Session.SelectedEggOrder[1] = FARM_EGG_OPTIONS[1]
end

if #Session.HatchSelectedEggOrder == 0
    and HATCH_EGG_OPTIONS[1]
then
    Session.HatchSelectedEggs[
        HATCH_EGG_OPTIONS[1]
    ] = true

    Session.HatchSelectedEggOrder[1] =
        HATCH_EGG_OPTIONS[1]
end

Environment.ScoopHubPremiumEggFarmFinal = Session

local AutoSaveQueued = false
local LastSavedConfigJson = nil

local function copyListForSave(source)
    local result = {}

    for index = 1, #source do
        result[index] = source[index]
    end

    return result
end

local function saveConfigNow()
    if not CONFIG_SUPPORTED then
        return false
    end

    ensureConfigFolder()

    local prefs =
        _G.ScoopHubPremiumUserPreferences
        or {}

    local data = {
        Version = 1,
        AutoFarmEnabled = Session.AutoFarmEnabled == true,
        SelectedEggOrder = copyListForSave(Session.SelectedEggOrder),

        AutoHatchEnabled =
            Session.AutoHatchEnabled == true,

        HatchSelectedEggOrder =
            copyListForSave(
                Session.HatchSelectedEggOrder
            ),

        AutoEquipBestEnabled =
            Session.AutoEquipBestEnabled == true,

        EggWebhookUrl =
            tostring(
                Session.EggWebhookUrl
                or ""
            ),

        HatchWebhookUrl =
            tostring(
                Session.HatchWebhookUrl
                or ""
            ),

        WebhookEggPickupEnabled =
            Session.WebhookEggPickupEnabled == true,

        WebhookHatchEnabled =
            Session.WebhookHatchEnabled == true,

        ReturnFlySpeed = Session.ReturnFlySpeed,
        ESPEnabled = Session.ESPEnabled == true,
        ESPSelectedEggOrder = copyListForSave(Session.ESPSelectedEggOrder),
        WalkSpeedEnabled = Session.WalkSpeedEnabled == true,
        WalkSpeedValue = Session.WalkSpeedValue,
        InfiniteJumpEnabled = Session.InfiniteJumpEnabled == true,
        LowGraphicsEnabled = Session.LowGraphicsEnabled == true,
        SelectedGearOrder = copyListForSave(Session.SelectedGearOrder),
        SelectedFoodOrder = copyListForSave(Session.SelectedFoodOrder),
        GearAutoBuyEnabled = Session.GearAutoBuyEnabled == true,
        FoodAutoBuyEnabled = Session.FoodAutoBuyEnabled == true,
        UserPreferences = {
            AutoRejoin = prefs.AutoRejoin == true,
            LowGraphics = Session.LowGraphicsEnabled == true,
            Notifications = prefs.Notifications == true,
            Tooltips = prefs.Tooltips == true,
        },
    }

    local okEncode, encoded = pcall(function()
        return HttpService:JSONEncode(data)
    end)

    if not okEncode
        or type(encoded) ~= "string"
    then
        return false
    end

    if encoded == LastSavedConfigJson then
        return true
    end

    local okWrite = pcall(function()
        writefile(CONFIG_FILE, encoded)
    end)

    if okWrite then
        LastSavedConfigJson = encoded
        return true
    end

    return false
end

local function scheduleAutoSave()
    if AutoSaveQueued
        or Session.Closed
    then
        return
    end

    AutoSaveQueued = true

    task.delay(0.35, function()
        AutoSaveQueued = false

        if not Session.Closed then
            saveConfigNow()
        end
    end)
end

local WEBHOOK_RARITY_COLORS = {
    Common = 0xADADAD,
    Rare = 0x00AAFF,
    Epic = 0xAA55FF,
    Legendary = 0xFFAA00,
    Mythic = 0xFFAAFF,
    Divine = 0xFFFF00,
    Ethereal = 0xAAAAFF,
}

local function getExecutorRequest()
    local requestFn = nil

    pcall(function()
        if syn
            and type(syn.request)
                == "function"
        then
            requestFn = syn.request
        end
    end)

    pcall(function()
        if not requestFn
            and http
            and type(http.request)
                == "function"
        then
            requestFn = http.request
        end
    end)

    if not requestFn
        and type(http_request)
            == "function"
    then
        requestFn = http_request
    end

    if not requestFn
        and type(request)
            == "function"
    then
        requestFn = request
    end

    return requestFn
end

local function trimWebhookText(value)
    value = tostring(value or "")

    return (
        string.gsub(
            value,
            "^%s*(.-)%s*$",
            "%1"
        )
    )
end

local function maskWebhookPlayerName(name)
    name = tostring(name or "")

    if name == "" then
        return "Unknown"
    end

    return string.sub(
        name,
        1,
        math.min(3, #name)
    ) .. "**"
end

local function webhookLocalTime()
    local ok, value = pcall(function()
        return DateTime.now():FormatLocalTime(
            "M/D/YYYY h:mm A",
            "en-us"
        )
    end)

    if ok
        and type(value) == "string"
        and value ~= ""
    then
        return value
    end

    return os.date(
        "%m/%d/%Y %I:%M %p"
    )
end

local function webhookRarityColor(rarity)
    rarity = tostring(rarity or "")

    local gameColor = nil

    pcall(function()
        local rarityColors =
            General.RarityColors

        if type(rarityColors) == "table" then
            gameColor =
                rarityColors[rarity]
        end
    end)

    if typeof(gameColor) == "Color3" then
        return
            math.floor(gameColor.R * 255)
                * 65536
            + math.floor(gameColor.G * 255)
                * 256
            + math.floor(gameColor.B * 255)
    end

    return WEBHOOK_RARITY_COLORS[
        rarity
    ] or 0xE72F3B
end

local function webhookWeightText(value)
    local number =
        tonumber(value)

    if not number then
        return "N/A"
    end

    return string.format(
        "%.2f KG",
        number
    )
end

local function webhookMutationText(value)
    if value == nil
        or value == false
    then
        return "None"
    end

    value = tostring(value)

    if value == ""
        or string.lower(value)
            == "none"
    then
        return "None"
    end

    return value
end

local function extractRobloxAssetId(value)
    if type(value) == "number" then
        return tostring(
            math.floor(value)
        )
    end

    value = tostring(value or "")

    local assetId =
        string.match(
            value,
            "rbxassetid://(%d+)"
        )
        or string.match(
            value,
            "[?&]id=(%d+)"
        )
        or string.match(
            value,
            "^(%d+)$"
        )

    return assetId
end

local function resolveWebhookImage(value)
    local assetId =
        extractRobloxAssetId(value)

    if not assetId then
        local raw =
            tostring(value or "")

        if string.sub(raw, 1, 8)
            == "https://"
            or string.sub(raw, 1, 7)
                == "http://"
        then
            return raw
        end

        return nil
    end

    local cached =
        Session.WebhookImageCache[
            assetId
        ]

    if cached then
        return cached
    end

    local fallback =
        "https://www.roblox.com/asset-thumbnail/image?assetId="
        .. assetId
        .. "&width=420&height=420&format=png"

    local requestFn =
        getExecutorRequest()

    if not requestFn then
        Session.WebhookImageCache[
            assetId
        ] = fallback

        return fallback
    end

    local apiUrl =
        "https://thumbnails.roblox.com/v1/assets?assetIds="
        .. assetId
        .. "&returnPolicy=PlaceHolder&size=420x420&format=Png&isCircular=false"

    local ok, response =
        pcall(function()
            return requestFn({
                Url = apiUrl,
                Method = "GET",
                Headers = {
                    ["Accept"] =
                        "application/json",
                },
            })
        end)

    if ok
        and type(response) == "table"
    then
        local body =
            response.Body
            or response.body

        if type(body) == "string"
            and body ~= ""
        then
            local decodeOk, decoded =
                pcall(function()
                    return HttpService:
                        JSONDecode(body)
                end)

            if decodeOk
                and type(decoded)
                    == "table"
                and type(decoded.data)
                    == "table"
                and type(decoded.data[1])
                    == "table"
                and type(
                    decoded.data[1].imageUrl
                ) == "string"
                and decoded.data[1]
                    .imageUrl ~= ""
            then
                Session.WebhookImageCache[
                    assetId
                ] =
                    decoded.data[1]
                        .imageUrl

                return decoded.data[1]
                    .imageUrl
            end
        end
    end

    Session.WebhookImageCache[
        assetId
    ] = fallback

    return fallback
end

local function postWebhookEmbed(
    embed,
    webhookUrl
)
    if Session.Closed then
        return false,
            "Script is closed."
    end

    webhookUrl =
        trimWebhookText(
            webhookUrl
        )

    if webhookUrl == "" then
        return false,
            "Webhook URL is empty."
    end

    local requestFn =
        getExecutorRequest()

    if not requestFn then
        return false,
            "Executor HTTP request is unavailable."
    end

    local payload = {
        username =
            "SCOOPHUB PREMIUM",
        embeds = {
            embed,
        },
    }

    local encodeOk, body =
        pcall(function()
            return HttpService:
                JSONEncode(payload)
        end)

    if not encodeOk then
        return false,
            "Could not encode webhook payload."
    end

    local ok, response =
        pcall(function()
            return requestFn({
                Url = webhookUrl,
                Method = "POST",
                Headers = {
                    ["Content-Type"] =
                        "application/json",
                },
                Body = body,
            })
        end)

    if not ok then
        return false,
            tostring(response)
    end

    if type(response) == "table" then
        local status =
            tonumber(
                response.StatusCode
                or response.Status
                or response.status_code
            )

        if status
            and status ~= 200
            and status ~= 204
        then
            return false,
                "Discord returned HTTP "
                .. tostring(status)
        end
    end

    return true, "Sent"
end

local function startWebhookWorker()
    if Session.WebhookWorkerRunning
    then
        return
    end

    Session.WebhookWorkerRunning = true

    task.spawn(function()
        while not Session.Closed
            and #Session.WebhookQueue > 0
        do
            local item =
                table.remove(
                    Session.WebhookQueue,
                    1
                )

            if item
                and item.Embed
                and item.Url
            then
                local ok, err =
                    postWebhookEmbed(
                        item.Embed,
                        item.Url
                    )

                if not ok then
                end
            end

            task.wait(0.65)
        end

        Session.WebhookWorkerRunning =
            false

        if not Session.Closed
            and #Session.WebhookQueue
                > 0
        then
            startWebhookWorker()
        end
    end)
end

local function queueWebhookEmbed(
    embed,
    webhookUrl
)
    webhookUrl =
        trimWebhookText(
            webhookUrl
        )

    if webhookUrl == "" then
        return false
    end

    Session.WebhookQueue[
        #Session.WebhookQueue + 1
    ] = {
        Embed = embed,
        Url = webhookUrl,
    }

    startWebhookWorker()

    return true
end

local function buildWebhookFooter(source)
    return {
        text =
            "SCOOPHUB PREMIUM • "
            .. tostring(source)
            .. " • "
            .. webhookLocalTime(),
    }
end

local function buildEggSecuredEmbed(
    playerName,
    eggName,
    weight,
    mutation,
    spawnMutation
)
    eggName =
        tostring(
            eggName
            or "Unknown Egg"
        )

    local config =
        EggData[eggName]
        or {}

    local rarity =
        tostring(
            config.Rarity
            or "Unknown"
        )

    local iconUrl =
        resolveWebhookImage(
            config.Image
        )

    local embed = {
        title = "EGG SECURED",
        description =
            "**"
            .. eggName
            .. "** was secured successfully.",
        color =
            webhookRarityColor(rarity),
        fields = {
            {
                name = "PLAYER",
                value =
                    tostring(
                        playerName
                        or "Unknown"
                    ),
                inline = true,
            },
            {
                name = "EGG",
                value = eggName,
                inline = true,
            },
            {
                name = "RARITY",
                value = rarity,
                inline = true,
            },
            {
                name = "WEIGHT",
                value =
                    webhookWeightText(
                        weight
                    ),
                inline = true,
            },
            {
                name = "MUTATION",
                value =
                    webhookMutationText(
                        mutation
                    ),
                inline = true,
            },
            {
                name =
                    "SPAWN MUTATION",
                value =
                    webhookMutationText(
                        spawnMutation
                    ),
                inline = true,
            },
        },
        footer =
            buildWebhookFooter(
                "Egg Pickup"
            ),
    }

    if iconUrl then
        embed.thumbnail = {
            url = iconUrl,
        }
    end

    return embed
end

local function buildPetHatchedEmbed(
    playerName,
    eggName,
    petName,
    weight,
    mutation,
    spawnMutation
)
    eggName =
        tostring(
            eggName
            or "Unknown Egg"
        )

    petName =
        tostring(
            petName
            or "Unknown Pet"
        )

    local config =
        Pets[petName]
        or {}

    local rarity =
        tostring(
            config.Rarity
            or "Unknown"
        )

    local iconUrl =
        resolveWebhookImage(
            config.Image
        )

    local embed = {
        title = "PET HATCHED",
        description =
            "**"
            .. petName
            .. "** was hatched successfully from **"
            .. eggName
            .. "**.",
        color =
            webhookRarityColor(rarity),
        fields = {
            {
                name = "PLAYER",
                value =
                    tostring(
                        playerName
                        or "Unknown"
                    ),
                inline = true,
            },
            {
                name = "PET",
                value = petName,
                inline = true,
            },
            {
                name = "RARITY",
                value = rarity,
                inline = true,
            },
            {
                name = "WEIGHT",
                value =
                    webhookWeightText(
                        weight
                    ),
                inline = true,
            },
            {
                name = "MUTATION",
                value =
                    webhookMutationText(
                        mutation
                    ),
                inline = true,
            },
            {
                name =
                    "SPAWN MUTATION",
                value =
                    webhookMutationText(
                        spawnMutation
                    ),
                inline = true,
            },
        },
        footer =
            buildWebhookFooter(
                "Auto Hatch"
            ),
    }

    if iconUrl then
        embed.thumbnail = {
            url = iconUrl,
        }
    end

    return embed
end

local function sendEggSecuredWebhook(
    eggName,
    weight,
    mutation,
    spawnMutation
)
    local queued = false

    if Session.WebhookEggPickupEnabled
        and trimWebhookText(
            Session.EggWebhookUrl
        ) ~= ""
    then
        local customerEmbed =
            buildEggSecuredEmbed(
                LocalPlayer.Name,
                eggName,
                weight,
                mutation,
                spawnMutation
            )

        if queueWebhookEmbed(
            customerEmbed,
            Session.EggWebhookUrl
        )
        then
            queued = true
        end
    end

    if trimWebhookText(
        Session.HubEggWebhookUrl
    ) ~= ""
    then
        local hubEmbed =
            buildEggSecuredEmbed(
                maskWebhookPlayerName(
                    LocalPlayer.Name
                ),
                eggName,
                weight,
                mutation,
                spawnMutation
            )

        if queueWebhookEmbed(
            hubEmbed,
            Session.HubEggWebhookUrl
        )
        then
            queued = true
        end
    end

    return queued
end

local function sendPetHatchedWebhook(
    eggName,
    petName,
    weight,
    mutation,
    spawnMutation
)
    local queued = false

    if Session.WebhookHatchEnabled
        and trimWebhookText(
            Session.HatchWebhookUrl
        ) ~= ""
    then
        local customerEmbed =
            buildPetHatchedEmbed(
                LocalPlayer.Name,
                eggName,
                petName,
                weight,
                mutation,
                spawnMutation
            )

        if queueWebhookEmbed(
            customerEmbed,
            Session.HatchWebhookUrl
        )
        then
            queued = true
        end
    end

    if trimWebhookText(
        Session.HubHatchWebhookUrl
    ) ~= ""
    then
        local hubEmbed =
            buildPetHatchedEmbed(
                maskWebhookPlayerName(
                    LocalPlayer.Name
                ),
                eggName,
                petName,
                weight,
                mutation,
                spawnMutation
            )

        if queueWebhookEmbed(
            hubEmbed,
            Session.HubHatchWebhookUrl
        )
        then
            queued = true
        end
    end

    return queued
end

local function rememberEggPickupWebhookContext(
    record
)
    if not record then
        return
    end

    local eggName =
        record:GetAttribute("Egg")

    if type(eggName) ~= "string"
        or eggName == ""
    then
        return
    end

    Session.WebhookPendingPickup[
        eggName
    ] = {
        At = os.clock(),
        Weight =
            record:GetAttribute(
                "Weight"
            ),
        Mutation =
            record:GetAttribute(
                "Mutation"
            ),
        SpawnMutation =
            record:GetAttribute(
                "SpawnMutation"
            ),
    }
end

local function consumeEggPickupWebhookContext(
    eggName
)
    local context =
        Session.WebhookPendingPickup[
            eggName
        ]

    if not context then
        return nil
    end

    Session.WebhookPendingPickup[
        eggName
    ] = nil

    if os.clock()
            - (context.At or 0)
        > 10
    then
        return nil
    end

    return context
end

local function queueConfirmedEggForDepositWebhook(
    eggName
)
    eggName =
        tostring(eggName or "")

    if eggName == "" then
        return false
    end

    local context =
        consumeEggPickupWebhookContext(
            eggName
        )

    if not context then
        return false
    end

    Session.WebhookPendingDeposits[
        #Session.WebhookPendingDeposits + 1
    ] = {
        EggName = eggName,
        Weight = context.Weight,
        Mutation = context.Mutation,
        SpawnMutation =
            context.SpawnMutation,
        HeldAt = os.clock(),
    }

    return true
end

local function flushDepositedEggWebhooks()
    if #Session.WebhookPendingDeposits
        == 0
    then
        return 0
    end

    local pending =
        Session.WebhookPendingDeposits

    Session.WebhookPendingDeposits = {}

    local sent = 0

    for index = 1, #pending do
        local context =
            pending[index]

        if type(context) == "table"
            and context.EggName
        then
            local age =
                os.clock()
                - tonumber(
                    context.HeldAt
                )

            if age <= 60 then
                local ok =
                    sendEggSecuredWebhook(
                        context.EggName,
                        context.Weight,
                        context.Mutation,
                        context.SpawnMutation
                    )

                if ok then
                    sent = sent + 1
                end
            end
        end
    end

    return sent
end

local function snapshotWebhookOwnedPetKeys()
    local keys = {}

    local containers = {
        LocalPlayer.Character,
        Backpack,
    }

    for containerIndex = 1, #containers do
        local container =
            containers[containerIndex]

        if container then
            local children =
                container:GetChildren()

            for index = 1, #children do
                local child =
                    children[index]

                if child:IsA("Tool")
                    and child:HasTag("Pet")
                then
                    local petKey =
                        child:GetAttribute(
                            "PetKey"
                        )

                    if petKey ~= nil then
                        keys[
                            tostring(petKey)
                        ] = true
                    end
                end
            end
        end
    end

    pcall(function()
        local allPets =
            PetRenderer.GetAll()

        if type(allPets) == "table" then
            for _, pet in pairs(allPets) do
                if type(pet) == "table"
                    and pet.OwnerUserId
                        == LocalPlayer.UserId
                    and pet.PetKey ~= nil
                then
                    keys[
                        tostring(pet.PetKey)
                    ] = true
                end
            end
        end
    end)

    return keys
end

local function findNewWebhookPet(
    knownKeys,
    expectedPetName
)
    knownKeys =
        type(knownKeys) == "table"
        and knownKeys
        or {}

    expectedPetName =
        tostring(expectedPetName or "")

    local containers = {
        Backpack,
        LocalPlayer.Character,
    }

    for containerIndex = 1, #containers do
        local container =
            containers[containerIndex]

        if container then
            local children =
                container:GetChildren()

            for index = 1, #children do
                local child =
                    children[index]

                if child:IsA("Tool")
                    and child:HasTag("Pet")
                then
                    local rawKey =
                        child:GetAttribute(
                            "PetKey"
                        )

                    local petName =
                        child:GetAttribute(
                            "PetName"
                        )
                        or child.Name

                    if rawKey ~= nil
                        and not knownKeys[
                            tostring(rawKey)
                        ]
                        and (
                            expectedPetName == ""
                            or tostring(petName)
                                == expectedPetName
                        )
                    then
                        return child,
                            tostring(rawKey)
                    end
                end
            end
        end
    end

    local foundModel = nil
    local foundKey = nil

    pcall(function()
        local allPets =
            PetRenderer.GetAll()

        if type(allPets) ~= "table" then
            return
        end

        for _, pet in pairs(allPets) do
            if foundKey then
                break
            end

            if type(pet) == "table"
                and pet.OwnerUserId
                    == LocalPlayer.UserId
                and pet.PetKey ~= nil
                and not knownKeys[
                    tostring(pet.PetKey)
                ]
                and pet.Model
                and pet.Model.Parent
            then
                local modelPetName =
                    pet.Model:GetAttribute(
                        "PetName"
                    )

                if expectedPetName == ""
                    or tostring(
                        modelPetName or ""
                    ) == expectedPetName
                then
                    foundModel = pet.Model
                    foundKey =
                        tostring(pet.PetKey)
                end
            end
        end
    end)

    return foundModel, foundKey
end

local function waitForHatchedPetWebhookConfirmation(
    knownKeys,
    petName,
    timeoutSeconds
)
    local deadline =
        os.clock()
        + (
            tonumber(timeoutSeconds)
            or 12
        )

    while not Session.Closed
        and os.clock() < deadline
    do
        local petObject, petKey =
            findNewWebhookPet(
                knownKeys,
                petName
            )

        if petObject and petKey then
            return petObject, petKey
        end

        task.wait(0.08)
    end

    return nil, nil
end

local hatchWebhookConnection =
    HatchRemote.OnClientEvent:Connect(
        function(data)
            if Session.Closed
                or typeof(data) ~= "table"
                or data.Owner ~= LocalPlayer
            then
                return
            end

            local eggKey =
                data.EggKey

            if eggKey == nil then
                return
            end

            eggKey = tostring(eggKey)

            local pending =
                Session.WebhookPendingHatches[
                    eggKey
                ]

            if not pending then
                return
            end

            Session.WebhookPendingHatches[
                eggKey
            ] = nil

            if Session.WebhookSeenHatchKeys[
                eggKey
            ] then
                return
            end

            Session.WebhookSeenHatchKeys[
                eggKey
            ] = "confirming"

            local petName =
                data.PetName

            if type(petName) ~= "string"
                or petName == ""
            then
                Session.WebhookSeenHatchKeys[
                    eggKey
                ] = nil
                return
            end

            local eggName =
                pending.EggName

            local knownKeys =
                pending.KnownPetKeys
                or {}

            task.spawn(function()
                local petObject, petKey =
                    waitForHatchedPetWebhookConfirmation(
                        knownKeys,
                        petName,
                        12
                    )

                if not petObject
                    or not petKey
                then
                    Session.WebhookSeenHatchKeys[
                        eggKey
                    ] = nil

                    return
                end

                Session.WebhookSeenHatchKeys[
                    eggKey
                ] = true

                local weight =
                    petObject:GetAttribute(
                        "Weight"
                    )

                local mutation =
                    petObject:GetAttribute(
                        "Mutation"
                    )

                local spawnMutation =
                    petObject:GetAttribute(
                        "SpawnMutation"
                    )

                if weight == nil then
                    weight = data.Weight
                end

                if mutation == nil then
                    mutation =
                        data.Mutation
                end

                if spawnMutation == nil then
                    spawnMutation =
                        data.SpawnMutation
                end

                sendPetHatchedWebhook(
                    eggName,
                    petName,
                    weight,
                    mutation,
                    spawnMutation
                )
            end)
        end
    )

Session.Connections[
    #Session.Connections + 1
] = hatchWebhookConnection

local WalkSpeedGuard
local WalkSpeedBindId = 0

local function getLocalHumanoid(character)
    character = character or LocalPlayer.Character

    return character
        and character:FindFirstChildOfClass("Humanoid")
        or nil
end

local function sendAntiAFKSpace()
    if Session.Closed then
        return false
    end

    local focused = nil

    pcall(function()
        focused = UserInputService:GetFocusedTextBox()
    end)

    if focused then
        return false
    end

    local humanoid = getLocalHumanoid()

    if not humanoid
        or humanoid.Health <= 0
    then
        return false
    end

    local ok = pcall(function()
        VirtualInputManager:SendKeyEvent(
            true,
            Enum.KeyCode.Space,
            false,
            game
        )

        task.wait(0.06)

        VirtualInputManager:SendKeyEvent(
            false,
            Enum.KeyCode.Space,
            false,
            game
        )
    end)

    return ok
end

local function waitAntiAFK(seconds)
    local deadline = os.clock() + seconds

    while not Session.Closed
        and os.clock() < deadline
    do
        task.wait(2)
    end

    return not Session.Closed
end

local antiAFKIdleConnection =
    LocalPlayer.Idled:Connect(function()
        sendAntiAFKSpace()
    end)

Session.Connections[#Session.Connections + 1] =
    antiAFKIdleConnection

task.spawn(function()
    while not Session.Closed do
        local delaySeconds = math.random(180, 300)

        if not waitAntiAFK(delaySeconds) then
            break
        end

        sendAntiAFKSpace()
    end
end)

local function disconnectWalkSpeedGuard()
    WalkSpeedBindId = WalkSpeedBindId + 1

    if WalkSpeedGuard then
        pcall(function()
            WalkSpeedGuard:Disconnect()
        end)

        WalkSpeedGuard = nil
    end
end

local function restoreWalkSpeed()
    disconnectWalkSpeedGuard()

    local humanoid = getLocalHumanoid()

    if humanoid
        and Session.OriginalWalkSpeed ~= nil
    then
        humanoid.WalkSpeed =
            Session.OriginalWalkSpeed
    end

    Session.OriginalWalkSpeed = nil
end

local function bindWalkSpeedCharacter(character)
    disconnectWalkSpeedGuard()

    local currentBindId = WalkSpeedBindId

    task.spawn(function()
        local humanoid =
            character:FindFirstChildOfClass("Humanoid")
            or character:WaitForChild("Humanoid", 10)

        if not humanoid
            or currentBindId ~= WalkSpeedBindId
            or Session.Closed
            or not Session.WalkSpeedEnabled
            or character ~= LocalPlayer.Character
        then
            return
        end

        Session.OriginalWalkSpeed =
            humanoid.WalkSpeed

        humanoid.WalkSpeed =
            Session.WalkSpeedValue

        WalkSpeedGuard =
            humanoid:GetPropertyChangedSignal(
                "WalkSpeed"
            ):Connect(function()
                if currentBindId
                        == WalkSpeedBindId
                    and Session.WalkSpeedEnabled
                    and not Session.Closed
                    and humanoid.Parent
                    and humanoid.WalkSpeed
                        ~= Session.WalkSpeedValue
                then
                    humanoid.WalkSpeed =
                        Session.WalkSpeedValue
                end
            end)

        table.insert(
            Session.Connections,
            WalkSpeedGuard
        )
    end)
end

table.insert(
    Session.Connections,
    LocalPlayer.CharacterAdded:Connect(
        function(character)
            if Session.WalkSpeedEnabled then
                bindWalkSpeedCharacter(character)
            end
        end
    )
)

table.insert(
    Session.Connections,
    UserInputService.JumpRequest:Connect(
        function()
            if not Session.InfiniteJumpEnabled
                or Session.Closed
            then
                return
            end

            local humanoid =
                getLocalHumanoid()

            if humanoid
                and humanoid.Health > 0
            then
                humanoid:ChangeState(
                    Enum.HumanoidStateType.Jumping
                )
            end
        end
    )
)

local function setLowGraphicsMode(enabled)
    enabled = enabled == true

    Session.LowGraphicsEnabled = enabled

    local bridge =
        Environment.ScoopHubRideAPetPremiumLowGraphicsBridge

    if type(bridge) ~= "table" then
        bridge = {}
        Environment.ScoopHubRideAPetPremiumLowGraphicsBridge =
            bridge
    end

    bridge.PendingEnabled = enabled

    if type(bridge.SetEnabled) == "function" then
        local ok = pcall(function()
            bridge.SetEnabled(enabled)
        end)

        if ok then
            bridge.PendingEnabled = nil
        end
    end
end

do
    local bridge =
        Environment.ScoopHubRideAPetPremiumLowGraphicsBridge

    if type(bridge) ~= "table" then
        bridge = {}
        Environment.ScoopHubRideAPetPremiumLowGraphicsBridge =
            bridge
    end

    if type(bridge.DestroyModule) == "function" then
        pcall(function()
            bridge.DestroyModule()
        end)
    end

    bridge.SetEnabled = nil
    bridge.DestroyModule = nil
    bridge.ModuleReady = false

    bridge.GetEnabled = function()
        return Session.LowGraphicsEnabled == true
    end

    bridge.IsClosed = function()
        return Session.Closed == true
    end

    bridge.CoreVersion = "RideAPet-Premium-V1.7"
end

local function notify(title, content, delay)
    pcall(function()
        Library:SetNotification({
            Title = "SCOOPHUB PREMIUM",
            Description = title,
            Content = content,
            Delay = delay or 3,
        })
    end)
end

local function getCharacterRoot()
    local character = LocalPlayer.Character
    if not character then
        return nil, nil
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local root = character:FindFirstChild("HumanoidRootPart")

    return humanoid, root
end

local function hasCollected(eggName)
    local collected = LocalPlayer:GetAttribute("CollectedEggs")

    return typeof(collected) == "string"
        and collected ~= ""
        and string.find(
            collected,
            tostring(eggName) .. ",",
            1,
            true
        ) ~= nil
end

local CollectedEggCyclesRaw = nil
local CollectedEggCyclesCache = {}

local function getCollectedEggCycles()
    local raw =
        LocalPlayer:GetAttribute(
            "CollectedEggCycles"
        )

    if raw == CollectedEggCyclesRaw then
        return CollectedEggCyclesCache
    end

    CollectedEggCyclesRaw = raw
    CollectedEggCyclesCache = {}

    if type(raw) ~= "string"
        or raw == ""
    then
        return CollectedEggCyclesCache
    end

    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(raw)
    end)

    if ok and type(decoded) == "table" then
        CollectedEggCyclesCache = decoded
    end

    return CollectedEggCyclesCache
end

local function adminEggAlreadyCollected(record)
    local adminEggId =
        record:GetAttribute("AdminEggId")

    local collectedAdmin =
        LocalPlayer:GetAttribute(
            "CollectedAdminEggs"
        )

    if type(adminEggId) ~= "string"
        or adminEggId == ""
        or type(collectedAdmin) ~= "string"
        or collectedAdmin == ""
    then
        return false
    end

    return string.find(
        collectedAdmin,
        "," .. adminEggId .. ",",
        1,
        true
    ) ~= nil
end

local function recordAlreadyCollected(
    record,
    eggName
)
    if not record then
        return true
    end

    if record:GetAttribute("AdminSpawn")
        == true
    then
        return adminEggAlreadyCollected(record)
    end

    local cycle =
        tonumber(
            record:GetAttribute("Cycle")
        )

    if cycle then
        local collectedCycles =
            getCollectedEggCycles()

        local collectedCycle =
            tonumber(
                collectedCycles[eggName]
            )

        if collectedCycle then
            return cycle <= collectedCycle
        end
    end

    return hasCollected(eggName)
end

local function recordAvailable(record)
    if not record or record.Parent ~= ActiveEggs then
        return false
    end

    local eggName = record:GetAttribute("Egg")
    if type(eggName) ~= "string" or eggName == "" then
        return false
    end

    local privateTo = record:GetAttribute("PrivateTo")
    if privateTo ~= nil
        and privateTo ~= LocalPlayer.UserId
    then
        return false
    end

    if recordAlreadyCollected(
        record,
        eggName
    ) then
        return false
    end

    local dropEndsAt =
        tonumber(record:GetAttribute("DropEndsAt"))
        or 0

    return dropEndsAt <= Workspace:GetServerTimeNow()
end

local function getRecordPosition(record)
    if not record then
        return nil
    end

    local spawnCFrame =
        record:GetAttribute("SpawnCFrame")

    if typeof(spawnCFrame) == "CFrame" then
        return spawnCFrame.Position
    end

    local position =
        record:GetAttribute("Position")

    if typeof(position) == "Vector3" then
        return position
    end

    return nil
end

local function availableEggNames()
    local seen = {}
    local names = {}

    for _, record in ipairs(ActiveEggs:GetChildren()) do
        if recordAvailable(record) then
            local eggName = record:GetAttribute("Egg")

            if eggName and not seen[eggName] then
                seen[eggName] = true
                table.insert(names, eggName)
            end
        end
    end

    table.sort(names, function(a, b)
        local dataA = EggData[a] or {}
        local dataB = EggData[b] or {}

        local luckA = tonumber(dataA.Luck) or 0
        local luckB = tonumber(dataB.Luck) or 0

        if luckA ~= luckB then
            return luckA < luckB
        end

        return a < b
    end)

    return names
end

local function findNearestRecord(eggName)
    local _, root = getCharacterRoot()
    local origin = root and root.Position or Vector3.new(0, 0, 0)

    local best
    local bestPosition
    local bestDistance = math.huge

    for _, record in ipairs(ActiveEggs:GetChildren()) do
        if record:GetAttribute("Egg") == eggName
            and recordAvailable(record)
        then
            local position = getRecordPosition(record)

            if position then
                local distance =
                    (origin - position).Magnitude

                if distance < bestDistance then
                    bestDistance = distance
                    best = record
                    bestPosition = position
                end
            end
        end
    end

    return best, bestPosition, bestDistance
end

local function hasSelectedEggs()
    return next(Session.SelectedEggs) ~= nil
end

local function findNearestSelectedRecord()
    Session.FarmDebugStage = "find-record:get-character"

    local character = LocalPlayer.Character
    local root = character
        and character:FindFirstChild("HumanoidRootPart")
        or nil

    local origin = root
        and root.Position
        or Vector3.new(0, 0, 0)

    local best = nil
    local bestPosition = nil
    local bestDistance = math.huge
    local bestRarityRank = -math.huge
    local bestLuck = -math.huge

    Session.FarmDebugStage = "find-record:get-children"
    local records = ActiveEggs:GetChildren()

    Session.FarmDebugStage = "find-record:player-collected"

    Session.FarmDebugStage = "find-record:server-time"
    local serverNow = Workspace:GetServerTimeNow()

    local recordCount = #records

    for index = 1, recordCount do
        local record = records[index]

        if record and record.Parent == ActiveEggs then
            Session.FarmDebugStage = "find-record:egg-attribute"
            local eggName = record:GetAttribute("Egg")

            if type(eggName) == "string"
                and eggName ~= ""
                and Session.SelectedEggs[eggName]
            then
                Session.FarmDebugStage = "find-record:private-check"
                local privateTo = record:GetAttribute("PrivateTo")

                if privateTo == nil
                    or privateTo == LocalPlayer.UserId
                then
                    Session.FarmDebugStage = "find-record:admin-check"
                    Session.FarmDebugStage =
                        "find-record:collected-check"

                    local alreadyCollected =
                        recordAlreadyCollected(
                            record,
                            eggName
                        )

                    if not alreadyCollected then
                        Session.FarmDebugStage = "find-record:drop-time"
                        local dropEndsAt =
                            tonumber(
                                record:GetAttribute("DropEndsAt")
                            ) or 0

                        if dropEndsAt <= serverNow then
                            Session.FarmDebugStage = "find-record:position"

                            local position = nil
                            local spawnCFrame =
                                record:GetAttribute("SpawnCFrame")

                            if typeof(spawnCFrame) == "CFrame" then
                                position = spawnCFrame.Position
                            else
                                local positionAttribute =
                                    record:GetAttribute("Position")

                                if typeof(positionAttribute) == "Vector3" then
                                    position = positionAttribute
                                end
                            end

                            if position then
                                Session.FarmDebugStage = "find-record:egg-data"
                                local eggInfo =
                                    EggData[eggName] or {}

                                local rarityRank =
                                    RARITY_ORDER[
                                        eggInfo.Rarity
                                    ] or 0

                                local luck =
                                    tonumber(eggInfo.Luck)
                                    or 0

                                Session.FarmDebugStage = "find-record:distance"
                                local distance =
                                    (origin - position).Magnitude

                                local shouldReplace =
                                    rarityRank > bestRarityRank
                                    or (
                                        rarityRank == bestRarityRank
                                        and luck > bestLuck
                                    )
                                    or (
                                        rarityRank == bestRarityRank
                                        and luck == bestLuck
                                        and distance < bestDistance
                                    )

                                if shouldReplace then
                                    bestRarityRank = rarityRank
                                    bestLuck = luck
                                    bestDistance = distance
                                    best = record
                                    bestPosition = position
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    Session.FarmDebugStage = "find-record:complete"
    return best, bestPosition, bestDistance
end

local function getSelectedEggText()
    if #Session.SelectedEggOrder == 0 then
        return "selected eggs"
    end

    return table.concat(
        Session.SelectedEggOrder,
        ", "
    )
end

local function getSelectedSpecialEggHint()
    local hints = {}

    for index = 1, #Session.SelectedEggOrder do
        local eggName =
            Session.SelectedEggOrder[index]

        local config = EggData[eggName]

        if type(config) == "table" then
            if config.RequiresVolcano == true then
                hints[#hints + 1] =
                    tostring(eggName)
                    .. " requires the volcano to be revealed and uses its dedicated spawn pad"
            elseif config.SpecificSpawn == true then
                hints[#hints + 1] =
                    tostring(eggName)
                    .. " uses a dedicated spawn pad"
            elseif type(config.SpawnType) == "string"
                and config.SpawnType ~= ""
            then
                hints[#hints + 1] =
                    tostring(eggName)
                    .. " uses "
                    .. tostring(config.SpawnType)
                    .. " spawns"
            end
        end
    end

    if #hints == 0 then
        return ""
    end

    return " [Special spawn: "
        .. table.concat(hints, "; ")
        .. "]"
end

local function getESPColorForEgg(eggName)
    local rarity =
        EggData[eggName]
        and EggData[eggName].Rarity
        or "Unknown"

    local colors = {
        Common = Color3.fromRGB(235, 235, 235),
        Rare = Color3.fromRGB(70, 150, 255),
        Epic = Color3.fromRGB(190, 95, 255),
        Legendary = Color3.fromRGB(255, 220, 70),
        Mythic = Color3.fromRGB(255, 80, 110),
        Divine = Color3.fromRGB(80, 235, 255),
        Ethereal = Color3.fromRGB(255, 145, 70),
    }

    return colors[rarity]
        or Color3.fromRGB(255, 80, 95)
end

function Session:RemoveEggESP(model)
    local object = self.ESPObjects[model]

    if not object then
        return
    end

    if object.Highlight then
        pcall(function()
            object.Highlight:Destroy()
        end)
    end

    if object.Billboard then
        pcall(function()
            object.Billboard:Destroy()
        end)
    end

    self.ESPObjects[model] = nil
end

function Session:ClearEggESP()
    local models = {}

    for model in pairs(self.ESPObjects) do
        table.insert(models, model)
    end

    for _, model in ipairs(models) do
        self:RemoveEggESP(model)
    end
end

function Session:CreateEggESP(model)
    if self.ESPObjects[model]
        or not model:IsA("Model")
    then
        return
    end

    local eggName = model.Name

    if not self.ESPSelectedEggs[eggName] then
        return
    end

    local anchorPart =
        model:FindFirstChild("Handle")
        or model:FindFirstChildWhichIsA(
            "BasePart",
            true
        )

    if not anchorPart then
        return
    end

    local color =
        getESPColorForEgg(eggName)

    local highlight =
        Instance.new("Highlight")

    highlight.Name =
        "ScoopHubPremiumEggESP"
    highlight.DepthMode =
        Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = color
    highlight.FillTransparency = 0.78
    highlight.OutlineColor = color
    highlight.OutlineTransparency = 0
    highlight.Adornee = model
    highlight.Parent = model

    local billboard =
        Instance.new("BillboardGui")

    billboard.Name =
        "ScoopHubPremiumEggLabel"
    billboard.Adornee = anchorPart
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.MaxDistance = 10000
    billboard.Size =
        UDim2.fromOffset(210, 48)
    billboard.StudsOffsetWorldSpace =
        Vector3.new(0, 3.5, 0)
    billboard.Parent = anchorPart

    local label =
        Instance.new("TextLabel")

    label.Name = "Label"
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.RichText = true
    label.TextColor3 = color
    label.TextStrokeColor3 =
        Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0.15
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextWrapped = true
    label.Text =
        "<b>" .. eggName .. "</b>"
    label.Parent = billboard

    self.ESPObjects[model] = {
        Highlight = highlight,
        Billboard = billboard,
        Label = label,
        Anchor = anchorPart,
    }
end

function Session:UpdateEggESP()
    if self.Closed then
        return
    end

    if not self.ESPEnabled then
        self:ClearEggESP()
        return
    end

    local rendered =
        Workspace:FindFirstChild(
            "RenderedEggs"
        )

    if not rendered then
        self:ClearEggESP()
        return
    end

    local wanted = {}

    for _, model in ipairs(
        rendered:GetChildren()
    ) do
        if model:IsA("Model")
            and self.ESPSelectedEggs[model.Name]
        then
            wanted[model] = true
            self:CreateEggESP(model)
        end
    end

    local stale = {}

    for model in pairs(self.ESPObjects) do
        if not wanted[model]
            or not model.Parent
        then
            table.insert(stale, model)
        end
    end

    for _, model in ipairs(stale) do
        self:RemoveEggESP(model)
    end

    local character =
        LocalPlayer.Character

    local root =
        character
        and character:FindFirstChild(
            "HumanoidRootPart"
        )

    for model, object in pairs(
        self.ESPObjects
    ) do
        if model.Parent
            and object.Anchor
            and object.Anchor.Parent
            and object.Label
        then
            local eggName = model.Name

            local rarity =
                EggData[eggName]
                and EggData[eggName].Rarity
                or "Unknown"

            local distanceText = ""

            if root then
                local distance =
                    (
                        root.Position
                        - object.Anchor.Position
                    ).Magnitude

                distanceText =
                    " • "
                    .. tostring(
                        math.floor(
                            distance + 0.5
                        )
                    )
                    .. " studs"
            end

            object.Label.Text =
                "<b>"
                .. eggName
                .. "</b>\n"
                .. rarity
                .. distanceText
        end
    end
end

local function findRenderedEgg(record)
    if not record then
        return nil, nil
    end

    local folder = Workspace:FindFirstChild("RenderedEggs")
    if not folder then
        return nil, nil
    end

    local eggName = record:GetAttribute("Egg")
    local expectedPosition = getRecordPosition(record)

    local bestModel
    local bestPrompt
    local bestDistance = math.huge

    local renderedChildren = folder:GetChildren()

    for index = 1, #renderedChildren do
        local model = renderedChildren[index]

        if model:IsA("Model")
            and model.Name == eggName
        then
            local prompt =
                model:FindFirstChildWhichIsA(
                    "ProximityPrompt",
                    true
                )

            local part =
                prompt
                and prompt.Parent
                and prompt.Parent:IsA("BasePart")
                and prompt.Parent
                or model:FindFirstChildWhichIsA(
                    "BasePart",
                    true
                )

            if part then
                local distance = expectedPosition
                    and (part.Position - expectedPosition).Magnitude
                    or 0

                if distance < bestDistance then
                    bestDistance = distance
                    bestModel = model
                    bestPrompt = prompt
                end
            end
        end
    end

    return bestModel, bestPrompt
end

local function moveNextToPrompt(record)
    local humanoid, root = getCharacterRoot()

    if not humanoid
        or not root
        or humanoid.Health <= 0
    then
        return false, "Character is unavailable."
    end

    local model, prompt = findRenderedEgg(record)

    local targetPart =
        prompt
        and prompt.Parent
        and prompt.Parent:IsA("BasePart")
        and prompt.Parent
        or model
        and model:FindFirstChildWhichIsA(
            "BasePart",
            true
        )

    if not targetPart then
        local recordPosition = getRecordPosition(record)

        if not recordPosition then
            return false,
                "Could not find the rendered egg or record position."
        end

        root.CFrame =
            CFrame.new(
                recordPosition
                    + Vector3.new(0, 3, 0)
            )

        task.wait(0.3)
        return true,
            "Moved near record position."
    end

    local maxDistance =
        prompt
        and tonumber(prompt.MaxActivationDistance)
        or 10

    local offset =
        math.clamp(maxDistance * 0.35, 2, 4)

    root.CFrame =
        CFrame.new(
            targetPart.Position
                + Vector3.new(0, offset, 0)
        )

    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)

    task.wait(0.35)

    return true,
        prompt
            and (
                "Moved inside prompt range ("
                .. string.format(
                    "%.1f",
                    (root.Position - targetPart.Position).Magnitude
                )
                .. "/"
                .. tostring(prompt.MaxActivationDistance)
                .. " studs)."
            )
            or "Moved next to rendered egg."
end

local function countHeldEgg(eggName)
    local count = 0

    local carriedEggs = Basket:GetChildren()

    for index = 1, #carriedEggs do
        local carried = carriedEggs[index]

        if carried:GetAttribute("Egg") == eggName then
            count = count + 1
        end
    end

    return count
end

local function getBasketTrackerEggsHolder()
    local playerGui =
        LocalPlayer:FindFirstChild("PlayerGui")

    local main =
        playerGui
        and playerGui:FindFirstChild("Main")

    local basketTracker =
        main
        and main:FindFirstChild("BasketTracker")

    return basketTracker
        and basketTracker:FindFirstChild("EggsHolder")
        or nil
end

local function basketUiShowsEgg(eggName)
    local eggsHolder =
        getBasketTrackerEggsHolder()

    if not eggsHolder then
        return false
    end

    return eggsHolder:FindFirstChild(eggName) ~= nil
end

local function waitForHeldEgg(
    eggName,
    beforeCount,
    requestStartedAt
)
    local deadline = os.clock() + 4

    while os.clock() < deadline do
        if Session.Closed
            or not Session.AutoFarmEnabled
        then
            return false, "Auto farm stopped."
        end

        local heldCount =
            countHeldEgg(eggName)

        if heldCount > beforeCount then
            local uiConfirmed =
                basketUiShowsEgg(eggName)

            pcall(function()
                queueConfirmedEggForDepositWebhook(
                    eggName
                )
            end)

            return true,
                "Basket confirmed "
                .. tostring(eggName)
                .. " is held ("
                .. tostring(beforeCount)
                .. " -> "
                .. tostring(heldCount)
                .. ")."
                .. (
                    uiConfirmed
                    and " BasketTracker UI also shows it."
                    or ""
                )
        end

        if Session.LastEggPickupStatusAt
                >= requestStartedAt
            and Session.LastEggPickupStatus
                == "BasketFull"
        then
            return false,
                "Pickup failed: basket is full."
        end

        task.wait(0.05)
    end

    return false,
        "Pickup was not confirmed in LocalPlayer.Basket after 4 seconds. "
        .. "Held count is still "
        .. tostring(countHeldEgg(eggName))
        .. "."
end

local function resetPickupStatus()
    Session.LastEggPickupStatus = nil
    Session.LastEggPickupStatusAt = 0
end

local function pickupShouldStopRetrying()
    return Session.LastEggPickupStatus == "BasketFull"
end

local function logRecord(record, prompt)
    if not record then
        return
    end

    local eggName = record:GetAttribute("Egg")
    local position = getRecordPosition(record)
    local privateTo = record:GetAttribute("PrivateTo")
    local dropEndsAt = record:GetAttribute("DropEndsAt")
    local adminSpawn = record:GetAttribute("AdminSpawn")

    if prompt then
    end
end

local function getOwnPlot()
    local plot

    local ok = pcall(function()
        plot = General:GetPlot(LocalPlayer)
    end)

    if not ok or not plot then
        return nil, nil, "Could not find your plot."
    end

    local baseplate = plot:FindFirstChild("Baseplate")

    if not baseplate
        or not baseplate:IsA("BasePart")
    then
        return nil, nil, "Your plot Baseplate was not found."
    end

    return plot, baseplate
end

local function isInsideFenceNamedObject(object, plot)
    local current = object

    while current and current ~= plot do
        if string.find(
            string.lower(current.Name),
            "fence",
            1,
            true
        ) then
            return true
        end

        current = current.Parent
    end

    return false
end

local function findFenceParts(plot)
    local parts = {}

    local descendants = plot:GetDescendants()

    for index = 1, #descendants do
        local object = descendants[index]

        if object:IsA("BasePart")
            and isInsideFenceNamedObject(object, plot)
        then
            parts[#parts + 1] = object
        end
    end

    return parts
end

local function flatVector(vector)
    return Vector3.new(vector.X, 0, vector.Z)
end

local function partHalfExtentAlong(part, direction)
    local right = flatVector(part.CFrame.RightVector)
    local look = flatVector(part.CFrame.LookVector)

    if right.Magnitude > 0 then
        right = right.Unit
    end

    if look.Magnitude > 0 then
        look = look.Unit
    end

    return math.abs(direction:Dot(right))
            * part.Size.X
            * 0.5
        + math.abs(direction:Dot(look))
            * part.Size.Z
            * 0.5
end

local function getBaseplateBoundaryRoute(baseplate, currentPosition)
    local localPosition =
        baseplate.CFrame:PointToObjectSpace(
            currentPosition
        )

    local direction = Vector3.new(
        localPosition.X,
        0,
        localPosition.Z
    )

    if direction.Magnitude < 0.01 then
        direction = Vector3.new(0, 0, 1)
    else
        direction = direction.Unit
    end

    local halfX = baseplate.Size.X * 0.5
    local halfZ = baseplate.Size.Z * 0.5

    local tx = math.huge
    local tz = math.huge

    if math.abs(direction.X) > 0.001 then
        tx = halfX / math.abs(direction.X)
    end

    if math.abs(direction.Z) > 0.001 then
        tz = halfZ / math.abs(direction.Z)
    end

    local t = math.min(tx, tz)

    local edgeLocal = direction * t
    local outsideLocal =
        edgeLocal
        + direction
            * (
                tonumber(Session.FenceOutsideOffset)
                or 4
            )

    local surfaceY =
        baseplate.Position.Y
        + baseplate.Size.Y * 0.5
        + 3

    local outsideWorld =
        baseplate.CFrame:PointToWorldSpace(
            Vector3.new(
                outsideLocal.X,
                0,
                outsideLocal.Z
            )
        )

    local insideWorld = Vector3.new(
        baseplate.Position.X,
        surfaceY,
        baseplate.Position.Z
    )

    outsideWorld = Vector3.new(
        outsideWorld.X,
        surfaceY,
        outsideWorld.Z
    )

    return outsideWorld, insideWorld, nil
end

local function getFenceBoundaryRoute(
    plot,
    baseplate,
    currentPosition,
    fenceParts
)
    fenceParts = fenceParts or findFenceParts(plot)

    if #fenceParts == 0 then
        return getBaseplateBoundaryRoute(
            baseplate,
            currentPosition
        )
    end

    local closestPart
    local closestDistance = math.huge

    for index = 1, #fenceParts do
        local part = fenceParts[index]

        local distance =
            flatVector(
                part.Position - currentPosition
            ).Magnitude

        if distance < closestDistance then
            closestDistance = distance
            closestPart = part
        end
    end

    if not closestPart then
        return getBaseplateBoundaryRoute(
            baseplate,
            currentPosition
        )
    end

    local center = baseplate.Position
    local outward =
        flatVector(
            closestPart.Position - center
        )

    if outward.Magnitude < 0.01 then
        outward =
            flatVector(
                currentPosition - center
            )
    end

    if outward.Magnitude < 0.01 then
        outward = Vector3.new(0, 0, 1)
    else
        outward = outward.Unit
    end

    local halfExtent =
        partHalfExtentAlong(
            closestPart,
            outward
        )

    local outsideOffset =
        math.max(
            tonumber(Session.FenceOutsideOffset)
                or 4,
            3
        )

    local fenceEdge =
        closestPart.Position
        + outward * halfExtent

    local surfaceY =
        baseplate.Position.Y
        + baseplate.Size.Y * 0.5
        + 3

    local outsidePoint =
        fenceEdge
        + outward * outsideOffset

    local insidePoint = Vector3.new(
        baseplate.Position.X,
        surfaceY,
        baseplate.Position.Z
    )

    outsidePoint = Vector3.new(
        outsidePoint.X,
        surfaceY,
        outsidePoint.Z
    )

    return outsidePoint, insidePoint, closestPart
end

local function setCharacterNoclip(enabled, savedStates)
    local character = LocalPlayer.Character
    if not character then
        return
    end

    if enabled then
        local characterDescendants =
            character:GetDescendants()

        for index = 1, #characterDescendants do
            local object =
                characterDescendants[index]

            if object:IsA("BasePart") then
                if not savedStates[object] then
                    savedStates[object] = {
                        CanCollide = object.CanCollide,
                        CollisionGroup =
                            object.CollisionGroup,
                    }
                end

                object.CanCollide = false

                pcall(function()
                    object.CollisionGroup =
                        "NoCollision"
                end)
            end
        end

        return
    end

    for part, state in pairs(savedStates) do
        if part and part.Parent then
            pcall(function()
                part.CollisionGroup =
                    state.CollisionGroup
            end)

            pcall(function()
                part.CanCollide =
                    state.CanCollide
            end)
        end
    end

    clearTableCompat(savedStates)
end

local function setFencePartsNoclip(
    fenceParts,
    enabled,
    savedStates
)
    fenceParts = fenceParts or {}

    if enabled then
        for index = 1, #fenceParts do
            local part = fenceParts[index]

            if part and part.Parent then
                if not savedStates[part] then
                    savedStates[part] = {
                        CanCollide = part.CanCollide,
                        CanTouch = part.CanTouch,
                    }
                end

                if part.CanCollide then
                    part.CanCollide = false
                end

                if part.CanTouch then
                    pcall(function()
                        part.CanTouch = false
                    end)
                end
            end
        end

        return
    end

    for part, state in pairs(savedStates) do
        if part and part.Parent then
            pcall(function()
                part.CanCollide = state.CanCollide
            end)

            pcall(function()
                part.CanTouch = state.CanTouch
            end)
        end
    end

    clearTableCompat(savedStates)
end

local function walkPathTo(
    humanoid,
    root,
    destination,
    stopCheck
)
    local path = PathfindingService:CreatePath({
        AgentRadius = 2,
        AgentHeight = 5,
        AgentCanJump = true,
        AgentCanClimb = true,
        WaypointSpacing = 3,
    })

    local computed = pcall(function()
        path:ComputeAsync(
            root.Position,
            destination
        )
    end)

    local waypoints = {}

    if computed
        and path.Status
            == Enum.PathStatus.Success
    then
        waypoints = path:GetWaypoints()
    else
        waypoints = {
            {
                Position = destination,
                Action =
                    Enum.PathWaypointAction.Walk,
            },
        }
    end

    for index = 1, #waypoints do
        local waypoint = waypoints[index]

        if Session.Closed
            or not Session.AutoFarmEnabled
            or humanoid.Health <= 0
            or not root.Parent
        then
            return false
        end

        if stopCheck
            and stopCheck()
        then
            humanoid:MoveTo(root.Position)
            root.AssemblyLinearVelocity =
                Vector3.new(0, 0, 0)

            return true, "secured"
        end

        if waypoint.Action
            == Enum.PathWaypointAction.Jump
        then
            humanoid.Jump = true
        end

        humanoid:MoveTo(waypoint.Position)

        local deadline = os.clock() + 3

        while os.clock() < deadline do
            if Session.Closed
                or humanoid.Health <= 0
                or not root.Parent
            then
                return false
            end

            if stopCheck
                and stopCheck()
            then
                humanoid:MoveTo(root.Position)
                root.AssemblyLinearVelocity =
                    Vector3.new(0, 0, 0)

                return true, "secured"
            end

            local distance =
                flatVector(
                    waypoint.Position
                        - root.Position
                ).Magnitude

            if distance <= 2.5 then
                break
            end

            task.wait(0.06)
        end
    end

    return
        flatVector(
            destination - root.Position
        ).Magnitude <= 4
end

local function returnToOwnPlot(securedEggName)
    Session.FarmDebugStage = "return:get-character"

    local humanoid, root = getCharacterRoot()

    if not humanoid
        or not root
        or humanoid.Health <= 0
    then
        return false, "Character is unavailable."
    end

    local secureWatchStartedAt = os.clock()
    local secureBaseline = {}

    securedEggName =
        type(securedEggName) == "string"
        and securedEggName
        or nil

    local startingCharacter =
        LocalPlayer.Character

    if securedEggName
        and securedEggName ~= ""
        and startingCharacter
    then
        local startingChildren =
            startingCharacter:GetChildren()

        for index = 1, #startingChildren do
            local child =
                startingChildren[index]

            local matchesEgg =
                child.Name == securedEggName

            if not matchesEgg then
                pcall(function()
                    matchesEgg =
                        child:GetAttribute("Egg")
                            == securedEggName
                end)
            end

            if matchesEgg then
                secureBaseline[child] = true
            end
        end
    end

    local function securedEggAppeared()
        if not securedEggName
            or securedEggName == ""
        then
            return false
        end

        local character =
            LocalPlayer.Character

        if character then
            local children =
                character:GetChildren()

            for index = 1, #children do
                local child =
                    children[index]

                if not secureBaseline[child] then
                    local matchesEgg =
                        child.Name == securedEggName

                    if not matchesEgg then
                        pcall(function()
                            matchesEgg =
                                child:GetAttribute("Egg")
                                    == securedEggName
                        end)
                    end

                    if matchesEgg then
                        return true
                    end
                end
            end
        end

        return
            Session.LastEggPickupStatus
                == "Deposited"
            and Session.LastEggPickupStatusAt
                >= secureWatchStartedAt
    end

    Session.FarmDebugStage = "return:get-plot"

    local plot, baseplate, plotError =
        getOwnPlot()

    if not plot then
        return false, plotError
    end

    Session.FarmDebugStage = "return:scan-fence"

    local fenceParts = findFenceParts(plot)

    local outsidePoint, insidePoint, fencePart =
        getFenceBoundaryRoute(
            plot,
            baseplate,
            root.Position,
            fenceParts
        )

    if not outsidePoint or not insidePoint then
        return false,
            "Could not calculate the plot boundary."
    end

    local originalStates = {}

    Session.FarmDebugStage = "return:character-noclip-on"
    setCharacterNoclip(true, originalStates)

    local flyingNoclipConnection =
        RunService.Stepped:Connect(function()
            if not root.Parent
                or humanoid.Health <= 0
            then
                return
            end

            setCharacterNoclip(
                true,
                originalStates
            )
        end)

    Session.FarmDebugStage = "return:fly"
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.Name = "ScoopHubTrialReturnFly"
    bodyVelocity.MaxForce = Vector3.new(
        math.huge,
        math.huge,
        math.huge
    )
    bodyVelocity.P = 12500
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = root

    local startedAt = os.clock()
    local initialDistance =
        (outsidePoint - root.Position).Magnitude

    local speed =
        math.clamp(
            tonumber(Session.ReturnFlySpeed)
                or 60,
            1,
            500
        )

    local timeout =
        math.max(
            8,
            initialDistance / speed * 4 + 5
        )

    local reachedOutside = false

    local securedDuringReturn = false

    while not Session.Closed
        and Session.AutoFarmEnabled
        and humanoid.Parent
        and root.Parent
        and humanoid.Health > 0
    do
        if securedEggAppeared() then
            securedDuringReturn = true
            break
        end

        local delta =
            outsidePoint - root.Position

        local distance = delta.Magnitude

        if distance <= 2.5 then
            reachedOutside = true
            break
        end

        local travelSpeed =
            math.min(
                speed,
                math.max(12, distance * 3)
            )

        bodyVelocity.Velocity =
            delta.Unit * travelSpeed

        if os.clock() - startedAt > timeout then
            break
        end

        RunService.Heartbeat:Wait()
    end

    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity:Destroy()
    root.AssemblyLinearVelocity =
        Vector3.new(0, 0, 0)

    if flyingNoclipConnection then
        flyingNoclipConnection:Disconnect()
        flyingNoclipConnection = nil
    end

    Session.FarmDebugStage = "return:character-noclip-off"
    setCharacterNoclip(
        false,
        originalStates
    )

    if securedDuringReturn
        or securedEggAppeared()
    then
        humanoid:MoveTo(root.Position)
        root.AssemblyLinearVelocity =
            Vector3.new(0, 0, 0)

        return true, "Egg secured."
    end

    if not reachedOutside then
        return false,
            "Fly-back timed out before reaching the outside of your plot."
    end

    task.wait(0.15)

    if securedEggAppeared() then
        humanoid:MoveTo(root.Position)
        root.AssemblyLinearVelocity =
            Vector3.new(0, 0, 0)

        return true, "Egg secured."
    end

    Session.FarmDebugStage = "return:prepare-walk"

    local fenceStates = {}

    Session.FarmDebugStage = "return:fence-noclip-on"

    setFencePartsNoclip(
        fenceParts,
        true,
        fenceStates
    )

    local fenceRefreshActive = true

    task.spawn(function()
        while fenceRefreshActive
            and not Session.Closed
            and Session.AutoFarmEnabled
            and humanoid.Parent
            and root.Parent
            and humanoid.Health > 0
        do
            setFencePartsNoclip(
                fenceParts,
                true,
                fenceStates
            )

            task.wait(0.20)
        end
    end)

    Session.FarmDebugStage = "return:walk"

    local walked, walkResult =
        walkPathTo(
            humanoid,
            root,
            insidePoint,
            securedEggAppeared
        )

    fenceRefreshActive = false

    Session.FarmDebugStage = "return:restore-fence"

    setFencePartsNoclip(
        fenceParts,
        false,
        fenceStates
    )

    if walkResult == "secured"
        or securedEggAppeared()
    then
        humanoid:MoveTo(root.Position)
        root.AssemblyLinearVelocity =
            Vector3.new(0, 0, 0)

        return true, "Egg secured."
    end

    if walked then
        root.AssemblyLinearVelocity =
            Vector3.new(0, 0, 0)

        if securedEggName
            and securedEggName ~= ""
        then
            local secureDeadline =
                os.clock() + 0.75

            while os.clock() < secureDeadline
                and not Session.Closed
                and Session.AutoFarmEnabled
            do
                if securedEggAppeared() then
                    humanoid:MoveTo(root.Position)
                    root.AssemblyLinearVelocity =
                        Vector3.new(0, 0, 0)

                    return true, "Egg secured."
                end

                task.wait(0.03)
            end
        end

        return true,
            fencePart
            and (
                "Flew with player noclip, stopped outside the fence, then walked normally while only the fence was noclip."
            )
            or (
                "Flew with player noclip, stopped outside the plot boundary, then walked normally to the Baseplate."
            )
    end

    return false,
        "Stopped outside the plot, but the walking path to the Baseplate failed."
end

local function getSelectedRecord()
    if not hasSelectedEggs() then
        return nil, nil,
            "Select at least one egg first."
    end

    local record, position =
        findNearestSelectedRecord()

    if not record then
        return nil, nil,
            "No selected egg is currently available."
    end

    return record, position
end

local function testPromptPickup()
    local record, _, errorText =
        getSelectedRecord()

    if not record then
        notify("Egg Pickup Trial", errorText)
        return
    end

    local eggName = record:GetAttribute("Egg")
    local beforeHeldCount =
        countHeldEgg(eggName)

    local maxAttempts =
        math.clamp(
            math.floor(
                tonumber(Session.PickupMaxAttempts)
                    or 3
            ),
            1,
            5
        )

    local finalResult =
        "Pickup was not confirmed."

    for attempt = 1, maxAttempts do
        if not record.Parent then
            finalResult =
                "The original egg record disappeared before Basket confirmed it."
            break
        end

        local moved, moveText =
            moveNextToPrompt(record)

        if not moved then
            finalResult = moveText
            break
        end

        local _, prompt =
            findRenderedEgg(record)

        logRecord(record, prompt)

        if not prompt then
            finalResult =
                "No ProximityPrompt found on the matching rendered egg."
            break
        end

        if type(fireproximityprompt)
            ~= "function"
        then
            finalResult =
                "Your executor does not provide fireproximityprompt()."
            break
        end

        task.wait(0.30)

        Session.FarmDebugStage = "farm:reset-pickup"
        resetPickupStatus()

        local requestStartedAt = os.clock()

        rememberEggPickupWebhookContext(
            record
        )

        local ok, reason = pcall(function()
            fireproximityprompt(prompt)
        end)

        if ok then
            Session.FarmDebugStage = "farm:wait-held"

            local success, result =
                waitForHeldEgg(
                    eggName,
                    beforeHeldCount,
                    requestStartedAt
                )

            if success then
                local returned, returnResult =
                    returnToOwnPlot()

                notify(
                    "Prompt Test: SUCCESS",
                    "Picked up on attempt "
                        .. tostring(attempt)
                        .. "/"
                        .. tostring(maxAttempts)
                        .. "\n"
                        .. result
                        .. "\n"
                        .. (
                            returned
                            and returnResult
                            or (
                                "Return failed: "
                                .. tostring(returnResult)
                            )
                        ),
                    6
                )

                return
            end

            finalResult = result

            if pickupShouldStopRetrying() then
                break
            end
        else
            finalResult =
                "fireproximityprompt failed: "
                .. tostring(reason)
        end

        if attempt < maxAttempts then
            notify(
                "Prompt Retry",
                "Attempt "
                    .. tostring(attempt)
                    .. " failed. Trying the same egg again...",
                2
            )

            task.wait(
                tonumber(Session.PickupRetryDelay)
                    or 0.45
            )
        end
    end

    notify(
        "Prompt Test: FAILED",
        "Tried "
            .. tostring(maxAttempts)
            .. " time(s).\n"
            .. tostring(finalResult),
        6
    )
end

local function testDirectRemote()
    local record, _, errorText =
        getSelectedRecord()

    if not record then
        notify("Egg Pickup Trial", errorText)
        return
    end

    local eggName = record:GetAttribute("Egg")
    local beforeHeldCount =
        countHeldEgg(eggName)

    local maxAttempts =
        math.clamp(
            math.floor(
                tonumber(Session.PickupMaxAttempts)
                    or 3
            ),
            1,
            5
        )

    local finalResult =
        "Pickup was not confirmed."

    for attempt = 1, maxAttempts do
        if not record.Parent then
            finalResult =
                "The original egg record disappeared before Basket confirmed it."
            break
        end

        local moved, moveText =
            moveNextToPrompt(record)

        if not moved then
            finalResult = moveText
            break
        end

        local _, prompt =
            findRenderedEgg(record)

        logRecord(record, prompt)

        task.wait(0.35)

        resetPickupStatus()
        local requestStartedAt = os.clock()

        Session.FarmDebugStage = "farm:fire-remote"

        rememberEggPickupWebhookContext(
            record
        )

        local ok, reason = pcall(function()
            EggPickup:FireServer(record.Name)
        end)

        if ok then
            local success, result =
                waitForHeldEgg(
                    eggName,
                    beforeHeldCount,
                    requestStartedAt
                )

            if success then
                local returned, returnResult =
                    returnToOwnPlot()

                notify(
                    "Remote Test: SUCCESS",
                    "Picked up on attempt "
                        .. tostring(attempt)
                        .. "/"
                        .. tostring(maxAttempts)
                        .. "\nID: "
                        .. tostring(record.Name)
                        .. "\n"
                        .. result
                        .. "\n"
                        .. (
                            returned
                            and returnResult
                            or (
                                "Return failed: "
                                .. tostring(returnResult)
                            )
                        ),
                    6
                )

                return
            end

            finalResult = result

            if pickupShouldStopRetrying() then
                break
            end
        else
            finalResult =
                "FireServer failed: "
                .. tostring(reason)
        end

        if attempt < maxAttempts then
            notify(
                "Remote Retry",
                "Attempt "
                    .. tostring(attempt)
                    .. " failed. Trying the same egg again...",
                2
            )

            task.wait(
                tonumber(Session.PickupRetryDelay)
                    or 0.45
            )
        end
    end

    notify(
        "Remote Test: FAILED",
        "ID: "
            .. tostring(record.Name)
            .. "\nTried "
            .. tostring(maxAttempts)
            .. " time(s).\n"
            .. tostring(finalResult),
        6
    )
end

local function sleepWhileEnabled(seconds, runId)
    local deadline = os.clock() + seconds

    while os.clock() < deadline do
        if Session.Closed
            or not Session.AutoFarmEnabled
            or Session.FarmRunId ~= runId
        then
            return false
        end

        task.wait(0.05)
    end

    return true
end

local function autoFarmOneEgg(runId)
    Session.FarmDebugStage = "farm:start"

    if Session.Closed
        or not Session.AutoFarmEnabled
        or Session.FarmRunId ~= runId
    then
        return false, "Stopped"
    end

    Session.FarmDebugStage = "farm:check-selected"

    if not hasSelectedEggs() then
        return false, "No egg selected"
    end

    Session.FarmDebugStage = "farm:check-basket"

    if #Basket:GetChildren() > 0 then
        Session.FarmDebugStage = "farm:return-carried"

        local carriedEggName = nil
        local carriedChildren =
            Basket:GetChildren()

        for index = 1, #carriedChildren do
            local value =
                carriedChildren[index]:
                    GetAttribute("Egg")

            if type(value) == "string"
                and value ~= ""
            then
                carriedEggName = value
                break
            end
        end

        local returned =
            returnToOwnPlot(
                carriedEggName
            )

        if not returned then
            return false, "Could not return carried egg to plot"
        end
    end

    Session.FarmDebugStage = "farm:find-record"

    local record =
        findNearestSelectedRecord()

    if not record then
        return false,
            "Waiting for selected eggs (rarest first): "
            .. getSelectedEggText()
            .. getSelectedSpecialEggHint()
    end

    Session.FarmDebugStage = "farm:read-record"

    local eggName =
        record:GetAttribute("Egg")

    Session.FarmDebugStage = "farm:count-held"

    local beforeHeldCount =
        countHeldEgg(eggName)

    local maxAttempts =
        math.clamp(
            math.floor(
                tonumber(Session.PickupMaxAttempts)
                    or 3
            ),
            1,
            5
        )

    local lastResult =
        "Pickup was not confirmed."

    for attempt = 1, maxAttempts do
        if Session.Closed
            or not Session.AutoFarmEnabled
            or Session.FarmRunId ~= runId
        then
            return false, "Stopped"
        end

        if not record.Parent then
            return false,
                "Egg record disappeared"
        end

        Session.FarmDebugStage = "farm:move-to-egg"

        local moved, moveResult =
            moveNextToPrompt(record)

        if not moved then
            return false, moveResult
        end

        Session.FarmDebugStage = "farm:pre-pickup-wait"

        if not sleepWhileEnabled(0.20, runId) then
            return false, "Stopped"
        end

        resetPickupStatus()
        local requestStartedAt = os.clock()

        rememberEggPickupWebhookContext(
            record
        )

        local ok, reason = pcall(function()
            EggPickup:FireServer(record.Name)
        end)

        if ok then
            local success, result =
                waitForHeldEgg(
                    eggName,
                    beforeHeldCount,
                    requestStartedAt
                )

            if success then
                Session.FarmDebugStage = "farm:return-after-pickup"

                local returned, returnResult =
                    returnToOwnPlot(
                        eggName
                    )

                if not returned then
                    return false, returnResult
                end

                return true,
                    "Picked up "
                    .. tostring(eggName)
                    .. " on attempt "
                    .. tostring(attempt)
            end

            lastResult = result

            if pickupShouldStopRetrying() then
                local carriedEggName = nil
                local carriedChildren =
                    Basket:GetChildren()

                for index = 1, #carriedChildren do
                    local value =
                        carriedChildren[index]:
                            GetAttribute("Egg")

                    if type(value) == "string"
                        and value ~= ""
                    then
                        carriedEggName = value
                        break
                    end
                end

                returnToOwnPlot(
                    carriedEggName
                )

                return false, "Basket was full"
            end
        else
            lastResult =
                "FireServer failed: "
                .. tostring(reason)
        end

        if attempt < maxAttempts then
            if not sleepWhileEnabled(
                tonumber(Session.PickupRetryDelay)
                    or 0.45,
                runId
            ) then
                return false, "Stopped"
            end
        end
    end

    return false, lastResult
end

function Session:StartAutoFarm()
    if self.Closed or self.AutoFarmEnabled then
        return
    end

    self.AutoFarmEnabled = true
    self.FarmRunId = self.FarmRunId + 1
    scheduleAutoSave()

    local runId = self.FarmRunId

    task.spawn(function()
        while not self.Closed
            and self.AutoFarmEnabled
            and self.FarmRunId == runId
        do
            local ok, result =
                pcall(function()
                    return autoFarmOneEgg(runId)
                end)

            if not ok then
            end

            if result == true then
                task.wait()
            elseif not sleepWhileEnabled(
                0.35,
                runId
            ) then
                break
            end
        end
    end)
end

function Session:StopAutoFarm()
    self.AutoFarmEnabled = false
    self.FarmRunId = self.FarmRunId + 1
    scheduleAutoSave()
end

table.insert(
    Session.Connections,
    EggPickup.OnClientEvent:Connect(function(status)
        Session.LastEggPickupStatus =
            tostring(status or "")
        Session.LastEggPickupStatusAt =
            os.clock()

        if Session.LastEggPickupStatus
            == "Deposited"
        then
            task.defer(function()
                if Session.Closed then
                    return
                end

                flushDepositedEggWebhooks()
            end)
        end
    end)
)

function Session:RefreshEggs(force)
    if self.Closed then
        return
    end

    local names = FARM_EGG_OPTIONS
    local signature =
        table.concat(names, "|")

    if not force
        and signature == self.LastSignature
    then
        self:UpdateEggESP()
        return
    end

    self.LastSignature = signature

    if self.Dropdown then
        self.Dropdown:SetOptions(names, true)
        self.Dropdown:Set(
            self.SelectedEggOrder,
            false
        )
    end

    if self.ESPDropdown then
        self.ESPDropdown:SetOptions(names, true)
        self.ESPDropdown:Set(
            self.ESPSelectedEggOrder,
            false
        )
    end

    self:UpdateEggESP()
end

local function getShopCategoryItems(category)
    local names = {}

    local categoryData =
        ShopData.Categories
        and ShopData.Categories[category]
        or {}

    for itemName in pairs(categoryData) do
        table.insert(names, itemName)
    end

    table.sort(names, function(a, b)
        local dataA = categoryData[a] or {}
        local dataB = categoryData[b] or {}

        local rarityA =
            RARITY_ORDER[
                dataA.Rarity
                or "Common"
            ] or 0

        local rarityB =
            RARITY_ORDER[
                dataB.Rarity
                or "Common"
            ] or 0

        if rarityA ~= rarityB then
            return rarityA < rarityB
        end

        local priceA =
            tonumber(dataA.Price) or 0

        local priceB =
            tonumber(dataB.Price) or 0

        if priceA ~= priceB then
            return priceA < priceB
        end

        return a < b
    end)

    return names
end

local function setShopSelection(
    selectedTable,
    orderTable,
    values
)
    clearTableCompat(selectedTable)
    clearTableCompat(orderTable)

    for _, itemName in ipairs(
        values or {}
    ) do
        itemName = tostring(itemName)

        if itemName ~= "" then
            selectedTable[itemName] = true

            table.insert(
                orderTable,
                itemName
            )
        end
    end
end

local function fireShopAutobuy(
    category,
    itemName,
    enabled
)
    local ok, reason =
        pcall(function()
            Autobuy:FireServer(
                category,
                itemName,
                enabled == true
            )
        end)

    if not ok then
    end

    return ok
end

local function applyShopCategoryAutoBuy(
    category,
    selectedTable,
    enabled
)
    local categoryData =
        ShopData.Categories
        and ShopData.Categories[category]
        or {}

    for itemName in pairs(categoryData) do
        local shouldEnable =
            enabled == true
            and selectedTable[itemName]
                == true

        fireShopAutobuy(
            category,
            itemName,
            shouldEnable
        )
    end
end

local function updateGearAutoBuy()
    if not Session.GearAutoBuyEnabled then
        return
    end

    applyShopCategoryAutoBuy(
        "Gears",
        Session.SelectedGears,
        true
    )
end

local function updateFoodAutoBuy()
    if not Session.FoodAutoBuyEnabled then
        return
    end

    applyShopCategoryAutoBuy(
        "Food",
        Session.SelectedFood,
        true
    )
end

local function getOwnHatchEggFolder()
    local plot = nil

    local ok = pcall(function()
        plot = General:GetPlot(LocalPlayer)
    end)

    if not ok or not plot then
        return nil
    end

    return plot:FindFirstChild("Eggs")
end

local function isTutorialLockedHatchEgg(model)
    if LocalPlayer:GetAttribute(
        "TutorialHatchLocked"
    ) ~= true
    then
        return false
    end

    local lockedKey =
        LocalPlayer:GetAttribute(
            "TutorialLockedEggKey"
        )

    return lockedKey == nil
        or lockedKey
            == model:GetAttribute("EggKey")
end

local function isHatchEggReady(
    model,
    eggFolder
)
    if not model
        or model.Parent ~= eggFolder
        or not model:IsA("Model")
        or not Session.HatchSelectedEggs[
            model.Name
        ]
        or not model.PrimaryPart
    then
        return false
    end

    local eggKey =
        model:GetAttribute("EggKey")

    if type(eggKey) ~= "string"
        or eggKey == ""
    then
        return false
    end

    if model:HasTag("Hatching") then
        return false
    end

    if isTutorialLockedHatchEgg(model) then
        return false
    end

    local dataFolder =
        model:FindFirstChild("EggData")

    if not dataFolder then
        return false
    end

    local placeTime =
        dataFolder:FindFirstChild(
            "PlaceTime"
        )

    local weight =
        dataFolder:FindFirstChild(
            "Weight"
        )

    if not placeTime
        or tonumber(placeTime.Value) == nil
        or placeTime.Value <= 0
    then
        return false
    end

    local config =
        EggData[model.Name]

    if type(config) ~= "table"
        or config.GrowthTime == nil
    then
        return false
    end

    local weightValue = 1

    if weight
        and tonumber(weight.Value)
    then
        weightValue =
            tonumber(weight.Value)
    end

    local okRequired, requiredResult =
        pcall(function()
            return GeneralData.GrowthTimeFor(
                config.GrowthTime,
                weightValue
            )
        end)

    if not okRequired
        or tonumber(requiredResult) == nil
    then
        return false
    end

    local elapsed = 0

    if model:GetAttribute("FlatGrow")
        == true
    then
        elapsed =
            Workspace:GetServerTimeNow()
            - placeTime.Value
    else
        local okElapsed, elapsedResult =
            pcall(function()
                return DayNight.GrowthElapsed(
                    placeTime.Value
                )
            end)

        if not okElapsed
            or tonumber(elapsedResult)
                == nil
        then
            return false
        end

        elapsed =
            tonumber(elapsedResult)
    end

    return elapsed
        >= tonumber(requiredResult)
end

local function requestHatch(model)
    if not model
        or not model.Parent
    then
        return false
    end

    local eggKey =
        model:GetAttribute("EggKey")

    if type(eggKey) ~= "string"
        or eggKey == ""
    then
        return false
    end

    local last =
        Session.HatchLastRequest[
            eggKey
        ]
        or 0

    if os.clock() - last < 1.10 then
        return false
    end

    Session.HatchLastRequest[
        eggKey
    ] = os.clock()

    local pendingKey =
        tostring(eggKey)

    Session.WebhookPendingHatches[
        pendingKey
    ] = {
        EggName = model.Name,
        At = os.clock(),
        KnownPetKeys =
            snapshotWebhookOwnedPetKeys(),
    }

    local ok =
        pcall(function()
            HatchRemote:FireServer({
                EggKey = eggKey,
            })
        end)

    if not ok then
        Session.WebhookPendingHatches[
            pendingKey
        ] = nil
    end

    return ok
end

local function hatchSelectedEggs()
    local eggFolder =
        getOwnHatchEggFolder()

    if not eggFolder then
        return 0
    end

    local children =
        eggFolder:GetChildren()

    local requested = 0

    for index = 1, #children do
        if Session.Closed
            or not Session.AutoHatchEnabled
        then
            break
        end

        local model =
            children[index]

        if isHatchEggReady(
            model,
            eggFolder
        )
            and requestHatch(model)
        then
            requested =
                requested + 1

            task.wait(0.12)
        end
    end

    return requested
end

function Session:StartAutoHatch()
    if self.Closed
        or self.AutoHatchEnabled
    then
        return
    end

    self.AutoHatchEnabled = true
    self.HatchRunId =
        self.HatchRunId + 1

    scheduleAutoSave()

    local runId =
        self.HatchRunId

    task.spawn(function()
        while not self.Closed
            and self.AutoHatchEnabled
            and self.HatchRunId == runId
        do
            pcall(function()
                hatchSelectedEggs()
            end)

            task.wait(0.45)
        end
    end)
end

function Session:StopAutoHatch()
    self.AutoHatchEnabled = false
    self.HatchRunId =
        self.HatchRunId + 1

    scheduleAutoSave()
end

local function getAutoEquipPetKey(object)
    if not object
        or not object.Parent
        or not object:IsA("Tool")
        or not object:HasTag("Pet")
    then
        return nil
    end

    local key =
        object:GetAttribute("PetKey")

    if key == nil then
        return nil
    end

    key = tostring(key)

    if key == "" then
        return nil
    end

    return key
end

local function registerAutoEquipToolPet(object)
    local key =
        getAutoEquipPetKey(object)

    if not key then
        return false, nil
    end

    local wasKnown =
        Session.AutoEquipBestKnownPets[
            key
        ] == true

    Session.AutoEquipBestKnownPets[
        key
    ] = true

    return not wasKnown, key
end

local function registerAutoEquipContainer(
    container
)
    if not container then
        return
    end

    local children =
        container:GetChildren()

    for index = 1, #children do
        registerAutoEquipToolPet(
            children[index]
        )
    end
end

local function registerPlacedPetsForAutoEquip()
    local ok, allPets =
        pcall(function()
            return PetRenderer.GetAll()
        end)

    if not ok
        or type(allPets) ~= "table"
    then
        return
    end

    for _, pet in pairs(allPets) do
        if type(pet) == "table"
            and pet.OwnerUserId
                == LocalPlayer.UserId
            and pet.PetKey ~= nil
        then
            Session.AutoEquipBestKnownPets[
                tostring(pet.PetKey)
            ] = true
        end
    end
end

local function scanKnownPetsForAutoEquip()
    registerPlacedPetsForAutoEquip()
    registerAutoEquipContainer(Backpack)
    registerAutoEquipContainer(
        LocalPlayer.Character
    )
end

local function autoEquipPetIncome(tool)
    if not tool then
        return 0
    end

    local petName =
        tool:GetAttribute("PetName")
        or tool.Name

    local config =
        Pets[petName]

    local baseIncome =
        config
        and tonumber(config.Income)
        or 0

    if baseIncome <= 0 then
        return 0
    end

    local weight =
        tonumber(
            tool:GetAttribute("Weight")
        )
        or 1

    local standardWeight =
        tonumber(PetAging.WeightStandardKG)
        or 1

    if standardWeight <= 0 then
        standardWeight = 1
    end

    local mutationFactor = 1

    local okFactor, result =
        pcall(function()
            return Mutations.CombinedFactor(
                tool:GetAttribute(
                    "Mutation"
                ),
                tool:GetAttribute(
                    "SpawnMutation"
                )
            )
        end)

    if okFactor
        and tonumber(result)
    then
        mutationFactor =
            tonumber(result)
    end

    local income =
        math.floor(
            baseIncome
            * (weight / standardWeight)
        )
        * mutationFactor

    return math.floor(income)
end

local function findPetToolByKey(petKey)
    local containers = {
        LocalPlayer.Character,
        Backpack,
    }

    for containerIndex = 1, #containers do
        local container =
            containers[containerIndex]

        if container then
            local children =
                container:GetChildren()

            for index = 1, #children do
                local child =
                    children[index]

                if child:IsA("Tool")
                    and tostring(
                        child:GetAttribute(
                            "PetKey"
                        )
                    ) == tostring(petKey)
                then
                    return child
                end
            end
        end
    end

    return nil
end

local function collectOwnedPetsForAutoEquip()
    local result = {}
    local included = {}

    local ok, renderedPets =
        pcall(function()
            return PetRenderer.GetAll()
        end)

    if ok
        and type(renderedPets) == "table"
    then
        for _, pet in pairs(renderedPets) do
            if type(pet) == "table"
                and pet.OwnerUserId
                    == LocalPlayer.UserId
                and pet.Model
                and pet.Model.Parent
                and pet.PetKey ~= nil
            then
                local key =
                    tostring(pet.PetKey)

                if not included[key] then
                    included[key] = true

                    result[
                        #result + 1
                    ] = {
                        Placed = true,
                        Key = key,
                        Income =
                            tonumber(
                                pet.DisplayIncome
                            )
                            or 0,
                        Position =
                            pet.Model
                                :GetPivot()
                                .Position,
                    }
                end
            end
        end
    end

    local containers = {
        LocalPlayer.Character,
        Backpack,
    }

    for containerIndex = 1, #containers do
        local container =
            containers[containerIndex]

        if container then
            local children =
                container:GetChildren()

            for index = 1, #children do
                local child =
                    children[index]

                if child:IsA("Tool")
                    and child:HasTag("Pet")
                then
                    local rawKey =
                        child:GetAttribute(
                            "PetKey"
                        )

                    if rawKey ~= nil then
                        local key =
                            tostring(rawKey)

                        if not included[key] then
                            included[key] = true

                            result[
                                #result + 1
                            ] = {
                                Placed = false,
                                Key = key,
                                Income =
                                    autoEquipPetIncome(
                                        child
                                    ),
                                Tool = child,
                            }
                        end
                    end
                end
            end
        end
    end

    table.sort(
        result,
        function(a, b)
            return
                (tonumber(a.Income) or 0)
                > (tonumber(b.Income) or 0)
        end
    )

    return result
end

local function autoEquipPlacementFor(
    root,
    slotIndex
)
    local row =
        math.floor(
            (slotIndex - 1) / 3
        )
        * 4
        + 8

    local column =
        ((slotIndex - 1) % 3 - 1)
        * 4

    local position =
        (
            root.CFrame
            * CFrame.new(
                column,
                0,
                -row
            )
        ).Position

    local plot, baseplate =
        getOwnPlot()

    if not plot or not baseplate then
        return position
    end

    local localPosition =
        baseplate.CFrame
            :PointToObjectSpace(
                position
            )

    local maxX =
        baseplate.Size.X / 2 - 2

    local maxZ =
        baseplate.Size.Z / 2 - 2

    return baseplate.CFrame
        :PointToWorldSpace(
            Vector3.new(
                math.clamp(
                    localPosition.X,
                    -maxX,
                    maxX
                ),
                localPosition.Y,
                math.clamp(
                    localPosition.Z,
                    -maxZ,
                    maxZ
                )
            )
        )
end

local function runAutoEquipBest()
    if Session.Closed
        or not Session.AutoEquipBestEnabled
        or Session.AutoEquipBestBusy
    then
        return false
    end

    local character =
        LocalPlayer.Character

    local humanoid =
        character
        and character
            :FindFirstChildOfClass(
                "Humanoid"
            )
        or nil

    local root =
        character
        and character
            :FindFirstChild(
                "HumanoidRootPart"
            )
        or nil

    if not humanoid
        or not root
        or humanoid.Health <= 0
    then
        return false
    end

    Session.AutoEquipBestBusy = true

    local ok, err =
        pcall(function()
            local maxPets =
                tonumber(
                    LocalPlayer:GetAttribute(
                        "MaxPets"
                    )
                )
                or 5

            maxPets =
                math.max(
                    0,
                    math.floor(maxPets)
                )

            local pets =
                collectOwnedPetsForAutoEquip()

            if #pets == 0
                or maxPets <= 0
            then
                return
            end

            local selected = {}
            local selectedKeys = {}

            local takeCount =
                math.min(
                    maxPets,
                    #pets
                )

            for index = 1, takeCount do
                selected[index] =
                    pets[index]

                selectedKeys[
                    pets[index].Key
                ] = true
            end

            local freedPositions = {}

            for index = 1, #pets do
                local pet = pets[index]

                if pet.Placed
                    and not selectedKeys[
                        pet.Key
                    ]
                then
                    if pet.Position then
                        freedPositions[
                            #freedPositions + 1
                        ] = pet.Position
                    end

                    pcall(function()
                        PetRenderer.Remove(
                            LocalPlayer.UserId,
                            pet.Key
                        )
                    end)

                    PickupPet:FireServer(
                        pet.Key
                    )

                    task.wait(0.20)
                end
            end

            local placed = 0

            for index = 1, #selected do
                local pet =
                    selected[index]

                if not pet.Placed then
                    local tool =
                        pet.Tool

                    if not tool
                        or not tool.Parent
                    then
                        tool =
                            findPetToolByKey(
                                pet.Key
                            )
                    end

                    if tool
                        and tool.Parent
                    then
                        humanoid:EquipTool(tool)

                        local deadline =
                            os.clock() + 2

                        while tool.Parent
                                ~= character
                            and os.clock()
                                < deadline
                        do
                            task.wait()
                        end

                        if tool.Parent
                            == character
                        then
                            local position = nil

                            if #freedPositions > 0 then
                                position =
                                    table.remove(
                                        freedPositions,
                                        1
                                    )
                            else
                                position =
                                    autoEquipPlacementFor(
                                        root,
                                        index
                                    )
                            end

                            PlacePet:FireServer(
                                pet.Key,
                                position
                            )

                            placed =
                                placed + 1

                            task.wait(0.20)
                        end
                    end
                end
            end

            if placed > 0
                and LocalPlayer:GetAttribute(
                    "IsRiding"
                ) ~= true
            then
                humanoid:UnequipTools()
            end
        end)

    Session.AutoEquipBestBusy = false
    Session.AutoEquipBestLastRunAt =
        os.clock()

    scanKnownPetsForAutoEquip()

    if not ok then
    end

    return ok
end

local function runAutoEquipPendingWorker()
    if Session.AutoEquipBestWorkerRunning then
        return
    end

    Session.AutoEquipBestWorkerRunning = true

    task.spawn(function()
        while not Session.Closed
            and Session.AutoEquipBestEnabled
            and Session.AutoEquipBestPending
        do
            local remaining =
                Session.AutoEquipBestCooldown
                - (
                    os.clock()
                    - Session.AutoEquipBestLastRunAt
                )

            if remaining > 0 then
                task.wait(
                    math.min(
                        remaining,
                        0.25
                    )
                )
            elseif Session.AutoEquipBestBusy then
                task.wait(0.20)
            else
                Session.AutoEquipBestPending =
                    false

                runAutoEquipBest()
            end
        end

        Session.AutoEquipBestWorkerRunning =
            false

        if not Session.Closed
            and Session.AutoEquipBestEnabled
            and Session.AutoEquipBestPending
        then
            runAutoEquipPendingWorker()
        end
    end)
end

local function requestAutoEquipBest()
    if Session.Closed
        or not Session.AutoEquipBestEnabled
    then
        return
    end

    local elapsed =
        os.clock()
        - Session.AutoEquipBestLastRunAt

    if not Session.AutoEquipBestBusy
        and elapsed
            >= Session.AutoEquipBestCooldown
        and not Session
            .AutoEquipBestWorkerRunning
    then
        Session.AutoEquipBestPending =
            false

        runAutoEquipBest()
        return
    end

    Session.AutoEquipBestPending = true
    runAutoEquipPendingWorker()
end

local function inspectNewBackpackPet(object)
    if Session.Closed
        or not Session.AutoEquipBestEnabled
        or not object
    then
        return
    end

    task.spawn(function()
        for attempt = 1, 15 do
            if Session.Closed
                or not Session
                    .AutoEquipBestEnabled
            then
                return
            end

            if object.Parent ~= Backpack then
                return
            end

            local isNew, key =
                registerAutoEquipToolPet(
                    object
                )

            if key then
                if isNew then
                    task.wait(0.35)
                    requestAutoEquipBest()
                end

                return
            end

            task.wait(0.20)
        end
    end)
end

local function inspectCharacterPetForAutoEquip(
    object
)
    if Session.Closed
        or not Session.AutoEquipBestEnabled
        or not object
    then
        return
    end

    task.spawn(function()
        for attempt = 1, 12 do
            if Session.Closed
                or not Session
                    .AutoEquipBestEnabled
            then
                return
            end

            local character =
                LocalPlayer.Character

            if not character
                or object.Parent ~= character
            then
                return
            end

            local _, key =
                registerAutoEquipToolPet(
                    object
                )

            if key then
                return
            end

            task.wait(0.20)
        end
    end)
end

local function disconnectAutoEquipConnections()
    for index = 1,
        #Session.AutoEquipBestConnections
    do
        local connection =
            Session.AutoEquipBestConnections[
                index
            ]

        pcall(function()
            connection:Disconnect()
        end)
    end

    clearTableCompat(
        Session.AutoEquipBestConnections
    )
end

local function bindAutoEquipCharacter(character)
    if not character then
        return
    end

    registerAutoEquipContainer(character)

    local connection =
        character.ChildAdded:Connect(
            inspectCharacterPetForAutoEquip
        )

    Session.AutoEquipBestConnections[
        #Session.AutoEquipBestConnections + 1
    ] = connection
end

function Session:StartAutoEquipBest()
    if self.Closed
        or self.AutoEquipBestEnabled
    then
        return
    end

    self.AutoEquipBestEnabled = true
    self.AutoEquipBestPending = false

    scanKnownPetsForAutoEquip()

    local backpackConnection =
        Backpack.ChildAdded:Connect(
            inspectNewBackpackPet
        )

    self.AutoEquipBestConnections[
        #self.AutoEquipBestConnections + 1
    ] = backpackConnection

    local characterAddedConnection =
        LocalPlayer.CharacterAdded:Connect(
            function(character)
                if self.AutoEquipBestEnabled
                    and not self.Closed
                then
                    bindAutoEquipCharacter(
                        character
                    )
                end
            end
        )

    self.AutoEquipBestConnections[
        #self.AutoEquipBestConnections + 1
    ] = characterAddedConnection

    bindAutoEquipCharacter(
        LocalPlayer.Character
    )

    scheduleAutoSave()
    runAutoEquipBest()
end

function Session:StopAutoEquipBest()
    self.AutoEquipBestEnabled = false
    self.AutoEquipBestPending = false

    disconnectAutoEquipConnections()
    scheduleAutoSave()
end

function Session:Stop()
    if self.Closed then
        return
    end

    saveConfigNow()
    local clearTeleport = Environment.ScoopHubRideAPetClearTeleportIntent
    if type(clearTeleport) == "function" then pcall(clearTeleport) end
    self:StopAutoFarm()
    self:StopAutoHatch()
    self:StopAutoEquipBest()

    self.ESPEnabled = false
    self:ClearEggESP()

    self.WalkSpeedEnabled = false
    self.InfiniteJumpEnabled = false
    restoreWalkSpeed()

    setLowGraphicsMode(false)

    clearTableCompat(
        self.WebhookQueue
    )
    clearTableCompat(
        self.WebhookPendingHatches
    )
    clearTableCompat(
        self.WebhookPendingPickup
    )
    clearTableCompat(
        self.WebhookPendingDeposits
    )

    self.Closed = true

    for index = 1, #self.Connections do
        local connection = self.Connections[index]

        pcall(function()
            connection:Disconnect()
        end)
    end

    clearTableCompat(self.Connections)

    if Environment.ScoopHubPremiumEggFarmFinal
        == self
    then
        Environment.ScoopHubPremiumEggFarmFinal =
            nil
    end
end

local Window = Library:CreateWindow({
    GuiName = "ScoopHubPremium",
    Title = "SCOOPHUB PREMIUM",
    Version = "V1.7",
    Subtitle = "By Scoop",
    Discord = "discord.gg/9czKzA5mVt",
    Logo = "rbxassetid://97406911955707",
    OnClose = function()
        saveConfigNow()
        Session:Stop()
    end,
})

local UserTab = Window:AddTab({
    Name = "User",
    Icon = "rbxassetid://17132521951",
})

local FarmTab = Window:AddTab({
    Name = "Automation",
    Icon = "rbxassetid://15332132816",
    Status = "● AUTO",
})

local ShopTab = Window:AddTab({
    Name = "Shop",
    Icon = "rbxassetid://11385395241",
    Status = "● AUTO BUY",
})

_G.ScoopHubPremiumUserPreferences =
    _G.ScoopHubPremiumUserPreferences
    or {}

if type(LoadedConfig.UserPreferences) == "table" then
    local savedPrefs = LoadedConfig.UserPreferences

    _G.ScoopHubPremiumUserPreferences.AutoRejoin =
        savedPrefs.AutoRejoin == true

    _G.ScoopHubPremiumUserPreferences.Notifications =
        savedPrefs.Notifications == true

    _G.ScoopHubPremiumUserPreferences.Tooltips =
        savedPrefs.Tooltips == true
end

_G.ScoopHubPremiumUserPreferences.LowGraphics =
    LoadedLowGraphicsEnabled

UserTab:AddUserDashboard({
    Preferences =
        _G.ScoopHubPremiumUserPreferences,

    OnRejoin = function()
        if Session.Closed
            or Library.Unloaded
        then
            return
        end

        saveConfigNow()

        pcall(function()
            local queueAfterTeleport =
                Environment.ScoopHubRideAPetQueueAfterTeleport

            if type(queueAfterTeleport) == "function" then
                queueAfterTeleport("rejoin")
            end

            local armIntent =
                Environment.ScoopHubRideAPetArmTeleportIntent

            if type(armIntent) == "function" then
                armIntent("rejoin")
            end
        end)

        local rejoinJobId = tostring(game.JobId or "")
        task.delay(12, function()
            if tostring(game.JobId or "") == rejoinJobId then
                local clearIntent =
                    Environment.ScoopHubRideAPetClearTeleportIntent

                if type(clearIntent) == "function" then
                    clearIntent()
                end
            end
        end)

        pcall(function()
            local teleportService =
                game:GetService("TeleportService")

            if game.JobId
                and game.JobId ~= ""
            then
                teleportService:TeleportToPlaceInstance(
                    game.PlaceId,
                    game.JobId,
                    LocalPlayer
                )
            else
                teleportService:Teleport(
                    game.PlaceId,
                    LocalPlayer
                )
            end
        end)
    end,

    OnLowGraphics = function(value)
        if Session.Closed
            or Library.Unloaded
        then
            return
        end

        local enabled =
            value == true

        setLowGraphicsMode(enabled)
        scheduleAutoSave()

        Library:SetNotification({
            Title = "SCOOPHUB PREMIUM",
            Description = "Low Graphics Mode",
            Content =
                enabled
                and "Low Graphics enabled. Textures, decorative effects, and material patterns were stripped while colors stay visible."
                or "Low Graphics disabled. Original textures restored.",
            Delay = 2,
        })
    end,

    LocalPlayer = {
        WalkSpeedValue =
            tostring(
                Session.WalkSpeedValue
                or 16
            ),

        WalkSpeed =
            Session.WalkSpeedEnabled
            == true,

        InfiniteJump =
            Session.InfiniteJumpEnabled
            == true,

        OnWalkSpeedValue = function(value)
            local parsedValue =
                tonumber(value)

            if not parsedValue
                or parsedValue ~= parsedValue
            then
                return
            end

            Session.WalkSpeedValue =
                math.clamp(
                    parsedValue,
                    0,
                    500
                )

            if Session.WalkSpeedEnabled then
                local humanoid =
                    getLocalHumanoid()

                if humanoid then
                    humanoid.WalkSpeed =
                        Session.WalkSpeedValue
                end
            end

            scheduleAutoSave()
        end,

        OnWalkSpeed = function(value)
            local newState =
                value == true

            if Session.Closed
                or Library.Unloaded
            then
                return
            end

            if Session.WalkSpeedEnabled
                == newState
            then
                return
            end

            Session.WalkSpeedEnabled =
                newState

            if newState then
                if LocalPlayer.Character then
                    bindWalkSpeedCharacter(
                        LocalPlayer.Character
                    )
                end
            else
                restoreWalkSpeed()
            end

            scheduleAutoSave()

            Library:SetNotification({
                Title = "SCOOPHUB PREMIUM",
                Description = "WalkSpeed",
                Content =
                    newState
                    and "WalkSpeed enabled."
                    or "WalkSpeed restored.",
                Delay = 2,
            })
        end,

        OnInfiniteJump = function(value)
            if Session.Closed
                or Library.Unloaded
            then
                return
            end

            Session.InfiniteJumpEnabled =
                value == true

            scheduleAutoSave()

            Library:SetNotification({
                Title = "SCOOPHUB PREMIUM",
                Description = "Infinite Jump",
                Content =
                    Session.InfiniteJumpEnabled
                    and "Infinite Jump enabled."
                    or "Infinite Jump disabled.",
                Delay = 2,
            })
        end,
    },
})

;(function()
    local function findDashboardButton(
        buttonText
    )
        local roots = {}

        pcall(function()
            roots[#roots + 1] =
                game:GetService(
                    "CoreGui"
                )
        end)

        local playerGui =
            LocalPlayer:FindFirstChild(
                "PlayerGui"
            )

        if playerGui then
            roots[#roots + 1] =
                playerGui
        end

        pcall(function()
            if type(gethui)
                == "function"
            then
                local hiddenUi =
                    gethui()

                if hiddenUi then
                    roots[#roots + 1] =
                        hiddenUi
                end
            end
        end)

        for rootIndex = 1, #roots do
            local root =
                roots[rootIndex]

            local descendants =
                root:GetDescendants()

            for index = 1,
                #descendants
            do
                local object =
                    descendants[index]

                if object:IsA(
                    "TextButton"
                )
                    and object.Text
                        == buttonText
                then
                    return object
                end
            end
        end

        return nil
    end

    local function findValueLabel(
        playerCard,
        yOffset,
        fallbackText
    )
        if not playerCard then
            return nil
        end

        local children =
            playerCard:GetChildren()

        for index = 1, #children do
            local object =
                children[index]

            if object:IsA(
                "TextLabel"
            )
                and object.Position.Y.Offset
                    == yOffset
                and object.Text
                    ~= "Username"
                and object.Text
                    ~= "User ID"
                and object.Text
                    ~= "Display Name"
            then
                return object
            end
        end

        for index = 1, #children do
            local object =
                children[index]

            if object:IsA(
                "TextLabel"
            )
                and object.Text
                    == tostring(
                        fallbackText
                    )
            then
                return object
            end
        end

        return nil
    end

    local function applyPatch()
        local rejoinButton =
            findDashboardButton(
                "REJOIN"
            )

        local serverHopButton =
            findDashboardButton(
                "SERVER HOP"
            )

        if not rejoinButton
            or not serverHopButton
            or not rejoinButton.Parent
            or not serverHopButton.Parent
        then

            return false
        end

        local playerCard =
            rejoinButton.Parent

        local sessionCard =
            serverHopButton.Parent

        if playerCard
            == sessionCard
        then
            return false
        end

        local oldPosition =
            rejoinButton.Position

        local oldSize =
            rejoinButton.Size

        local privacyButton =
            rejoinButton:Clone()

        privacyButton.Name =
            "ScoopHubPrivacyButton"

        privacyButton.Text =
            "HIDE INFO"

        privacyButton.Position =
            oldPosition

        privacyButton.Size =
            oldSize

        privacyButton.Parent =
            playerCard

        rejoinButton.Parent =
            sessionCard

        rejoinButton.Position =
            UDim2.new(
                0,
                12,
                1,
                -30
            )

        rejoinButton.Size =
            UDim2.new(
                0.5,
                -18,
                0,
                22
            )

        serverHopButton.Position =
            UDim2.new(
                0.5,
                6,
                1,
                -30
            )

        serverHopButton.Size =
            UDim2.new(
                0.5,
                -18,
                0,
                22
            )

        local usernameLabel =
            findValueLabel(
                playerCard,
                43,
                LocalPlayer.Name
            )

        local userIdLabel =
            findValueLabel(
                playerCard,
                73,
                LocalPlayer.UserId
            )

        local displayNameLabel =
            findValueLabel(
                playerCard,
                103,
                LocalPlayer.DisplayName
            )

        local username =
            usernameLabel
            and usernameLabel.Text
            or tostring(
                LocalPlayer.Name
            )

        local userId =
            userIdLabel
            and userIdLabel.Text
            or tostring(
                LocalPlayer.UserId
            )

        local displayName =
            displayNameLabel
            and displayNameLabel.Text
            or tostring(
                LocalPlayer.DisplayName
            )

        local hidden = false

        local function mask(value)
            value =
                tostring(
                    value or ""
                )

            return string.rep(
                "*",
                math.max(
                    #value,
                    3
                )
            )
        end

        local function refresh()
            if usernameLabel then
                usernameLabel.Text =
                    hidden
                    and mask(username)
                    or username
            end

            if userIdLabel then
                userIdLabel.Text =
                    hidden
                    and mask(userId)
                    or userId
            end

            if displayNameLabel then
                displayNameLabel.Text =
                    hidden
                    and mask(
                        displayName
                    )
                    or displayName
            end

            if privacyButton
                and privacyButton.Parent
            then
                privacyButton.Text =
                    hidden
                    and "SHOW INFO"
                    or "HIDE INFO"
            end
        end

        privacyButton.Activated:
            Connect(function()
                hidden =
                    not hidden

                refresh()
            end)

        refresh()

        return true
    end

    task.defer(function()
        pcall(applyPatch)
    end)
end)()

if _G.ScoopHubPremiumUserPreferences.LowGraphics
    == true
then
    setLowGraphicsMode(true)
end

local FarmSection = FarmTab:AddSection({
    Title = "AUTO EGG FARM",
    Column = "Left",
})

local ESPSection = FarmTab:AddSection({
    Title = "EGG ESP",
    Column = "Right",
})

Session.Dropdown = FarmSection:AddDropdown({
    Title = "Grind Egg",
    Content = "Choose one or more egg types to farm.",
    Multi = true,
    Options = FARM_EGG_OPTIONS,
    Default = Session.SelectedEggOrder,
    SearchPlaceholder = "Search egg...",
    Callback = function(values)
        clearTableCompat(Session.SelectedEggs)
        clearTableCompat(Session.SelectedEggOrder)

        for _, eggName in ipairs(
            values or {}
        ) do
            eggName = tostring(eggName)

            if eggName ~= "" then
                Session.SelectedEggs[eggName] =
                    true

                table.insert(
                    Session.SelectedEggOrder,
                    eggName
                )
            end
        end

        Session:UpdateEggESP()
        scheduleAutoSave()
    end,
})

FarmSection:AddInput({
    Title = "Fly Speed",
    Placeholder = "Enter fly speed...",
    Default = tostring(Session.ReturnFlySpeed),
    Callback = function(value)
        local speed = tonumber(value)

        if speed and speed == speed then
            Session.ReturnFlySpeed =
                math.clamp(speed, 1, 500)
            scheduleAutoSave()
        end
    end,
})

Session.ESPDropdown = ESPSection:AddDropdown({
    Title = "ESP Eggs",
    Content = "Choose one or more egg types to highlight.",
    Multi = true,
    Options = FARM_EGG_OPTIONS,
    Default = Session.ESPSelectedEggOrder,
    SearchPlaceholder = "Search egg...",
    Callback = function(values)
        clearTableCompat(Session.ESPSelectedEggs)
        clearTableCompat(Session.ESPSelectedEggOrder)

        for _, eggName in ipairs(
            values or {}
        ) do
            eggName = tostring(eggName)

            if eggName ~= "" then
                Session.ESPSelectedEggs[eggName] =
                    true

                table.insert(
                    Session.ESPSelectedEggOrder,
                    eggName
                )
            end
        end

        Session:UpdateEggESP()
        scheduleAutoSave()
    end,
})

ESPSection:AddToggle({
    Title = "Egg ESP",
    Content = "Highlight the egg types selected above.",
    Default = Session.ESPEnabled,
    Callback = function(value)
        Session.ESPEnabled =
            value == true

        Session:UpdateEggESP()
        scheduleAutoSave()
    end,
})

local AutoFarmToggle

AutoFarmToggle = FarmSection:AddToggle({
    Title = "Auto Egg Farm",
    Default = LoadedAutoFarmEnabled,
    Callback = function(value)
        local enabled = value == true

        if Session.Closed then
            return false
        end

        if enabled then
            if not hasSelectedEggs() then
                notify(
                    "Egg Farm",
                    "Choose at least one egg first.",
                    2
                )

                if AutoFarmToggle then
                    task.defer(function()
                        AutoFarmToggle:Set(false)
                    end)
                end

                return false
            end

            Session:StartAutoFarm()
        else
            Session:StopAutoFarm()
        end
    end,
})

local PetAutomationSection = FarmTab:AddSection({
    Title = "PET AUTOMATION",
    Column = "Left",
})

local HatchSection = FarmTab:AddSection({
    Title = "AUTO HATCH",
    Column = "Right",
})

PetAutomationSection:AddToggle({
    Title = "Auto Equip Best Pet",
    Default = LoadedAutoEquipBestEnabled,
    Callback = function(value)
        if value == true then
            Session:StartAutoEquipBest()
        else
            Session:StopAutoEquipBest()
        end
    end,
})

HatchSection:AddDropdown({
    Title = "Hatch Eggs",
    Content =
        "Choose one or more egg types to hatch.",
    Multi = true,
    Options = HATCH_EGG_OPTIONS,
    Default =
        Session.HatchSelectedEggOrder,
    SearchPlaceholder =
        "Search egg...",
    EmptyText =
        "No eggs selected",

    Callback = function(values)
        clearTableCompat(
            Session.HatchSelectedEggs
        )

        clearTableCompat(
            Session.HatchSelectedEggOrder
        )

        for index = 1, #(values or {}) do
            local eggName =
                tostring(
                    values[index] or ""
                )

            if eggName ~= ""
                and EggData[eggName]
            then
                Session.HatchSelectedEggs[
                    eggName
                ] = true

                Session.HatchSelectedEggOrder[
                    #Session.HatchSelectedEggOrder
                    + 1
                ] = eggName
            end
        end

        scheduleAutoSave()
    end,
})

local AutoHatchToggle

AutoHatchToggle =
    HatchSection:AddToggle({
        Title = "Auto Hatch",
        Default = LoadedAutoHatchEnabled,
        Callback = function(value)
            local enabled =
                value == true

            if enabled then
                if #Session
                    .HatchSelectedEggOrder
                    == 0
                then
                    notify(
                        "Auto Hatch",
                        "Choose at least one egg first.",
                        2
                    )

                    if AutoHatchToggle then
                        task.defer(function()
                            AutoHatchToggle:Set(
                                false
                            )
                        end)
                    end

                    return false
                end

                Session:StartAutoHatch()
            else
                Session:StopAutoHatch()
            end
        end,
    })

HatchSection:AddButton({
    Title = "Hatch Ready Eggs Now",
    Callback = function()
        if #Session.HatchSelectedEggOrder
            == 0
        then
            notify(
                "Auto Hatch",
                "Choose at least one egg first.",
                2
            )
            return
        end

        local wasEnabled =
            Session.AutoHatchEnabled

        if not wasEnabled then
            Session.AutoHatchEnabled = true
        end

        local count =
            hatchSelectedEggs()

        if not wasEnabled then
            Session.AutoHatchEnabled = false
        end

        notify(
            "Auto Hatch",
            "Requested "
                .. tostring(count)
                .. " ready egg(s).",
            2
        )
    end,
})

;(function()
    local WebhookSection =
        FarmTab:AddSection({
            Title = "WEBHOOK",
            Column = "Left",
        })

    local MASK =
        "****************************"

    local function createWebhookUrlControl(
        title,
        sessionKey,
        placeholder
    )
        local visible = false
        local editing = false

        local input =
            WebhookSection:AddInput({
                Title = title,
                Placeholder =
                    placeholder,
                Default = "",

                Callback = function(value)
                    if editing then
                        Session[sessionKey] =
                            trimWebhookText(
                                value
                            )

                        scheduleAutoSave()
                    end
                end,
            })

        local box =
            input
            and input.Box

        local showButton = nil

        local function refresh()
            if not box then
                return
            end

            box.ClipsDescendants =
                true

            local realValue =
                tostring(
                    Session[sessionKey]
                    or ""
                )

            if editing
                or visible
            then
                if box.Text
                    ~= realValue
                then
                    box.Text =
                        realValue
                end

                box.PlaceholderText =
                    placeholder
            else
                box.Text = ""

                box.PlaceholderText =
                    realValue ~= ""
                    and MASK
                    or placeholder
            end

            box.TextTransparency = 0

            if showButton then
                showButton.Text =
                    visible
                    and "HIDE"
                    or "SHOW"
            end
        end

        local function sync()
            if box
                and (
                    editing
                    or visible
                )
            then
                local value =
                    trimWebhookText(
                        box.Text
                    )

                if value ~= "" then
                    Session[sessionKey] =
                        value
                elseif editing then
                    Session[sessionKey] =
                        ""
                end

                scheduleAutoSave()
            end
        end

        if box then
            box.Size =
                UDim2.new(
                    1,
                    -76,
                    0,
                    box.Size.Y.Offset
                )

            box.ClipsDescendants =
                true

            local parent =
                box.Parent

            if parent then
                showButton =
                    Instance.new(
                        "TextButton"
                    )

                showButton.Name =
                    sessionKey
                    .. "ShowButton"

                showButton.Text =
                    "SHOW"

                showButton.Font =
                    box.Font

                showButton.TextSize = 9

                showButton.TextColor3 =
                    Color3.fromRGB(
                        246,
                        244,
                        252
                    )

                showButton.BackgroundColor3 =
                    Color3.fromRGB(
                        52,
                        31,
                        37
                    )

                showButton.BorderSizePixel =
                    0

                showButton.AutoButtonColor =
                    false

                showButton.Position =
                    UDim2.new(
                        1,
                        -62,
                        0,
                        box.Position.Y.Offset
                    )

                showButton.Size =
                    UDim2.fromOffset(
                        52,
                        box.Size.Y.Offset
                    )

                showButton.Parent =
                    parent

                local corner =
                    Instance.new(
                        "UICorner"
                    )

                corner.CornerRadius =
                    UDim.new(0, 5)

                corner.Parent =
                    showButton

                local stroke =
                    Instance.new(
                        "UIStroke"
                    )

                stroke.Color =
                    Color3.fromRGB(
                        182,
                        38,
                        58
                    )

                stroke.Transparency =
                    0.35

                stroke.Thickness = 1

                stroke.Parent =
                    showButton

                showButton.Activated:
                    Connect(function()
                        if editing then
                            sync()
                        end

                        visible =
                            not visible

                        refresh()
                    end)
            end

            box.Focused:
                Connect(function()
                    editing = true

                    box.Text =
                        tostring(
                            Session[
                                sessionKey
                            ]
                            or ""
                        )

                    task.defer(function()
                        if box
                            and box:IsFocused()
                        then
                            box.CursorPosition =
                                #box.Text + 1
                        end
                    end)
                end)

            box:
                GetPropertyChangedSignal(
                    "Text"
                ):
                Connect(function()
                    if editing then
                        Session[sessionKey] =
                            trimWebhookText(
                                box.Text
                            )
                    end
                end)

            box.FocusLost:
                Connect(function()
                    sync()
                    editing = false
                    refresh()
                end)

            refresh()
        end

        return function()
            sync()
        end
    end

    local syncEggUrl =
        createWebhookUrlControl(
            "Egg Pickup Webhook URL",
            "EggWebhookUrl",
            "Paste egg webhook URL..."
        )

    WebhookSection:AddToggle({
        Title = "Egg Pickup Webhook",
        Default =
            LoadedWebhookEggPickupEnabled,

        Callback = function(value)
            Session.WebhookEggPickupEnabled =
                value == true

            syncEggUrl()
            scheduleAutoSave()
        end,
    })

    WebhookSection:AddButton({
        Title = "Test Egg Webhook",

        Callback = function()
            task.spawn(function()
                syncEggUrl()

                local embed = {
                    title =
                        "EGG WEBHOOK CONNECTED",
                    description =
                        "SCOOPHUB PREMIUM egg webhook is working successfully.",
                    color = 0xE72F3B,
                    fields = {
                        {
                            name = "PLAYER",
                            value =
                                LocalPlayer.Name,
                            inline = true,
                        },
                        {
                            name = "STATUS",
                            value = "Connected",
                            inline = true,
                        },
                        {
                            name = "TYPE",
                            value = "Egg Pickup",
                            inline = true,
                        },
                    },
                    footer =
                        buildWebhookFooter(
                            "Test"
                        ),
                }

                local logoUrl =
                    resolveWebhookImage(
                        "rbxassetid://97406911955707"
                    )

                if logoUrl then
                    embed.thumbnail = {
                        url = logoUrl,
                    }
                end

                local ok, result =
                    postWebhookEmbed(
                        embed,
                        Session.EggWebhookUrl
                    )

                notify(
                    "Egg Webhook",
                    ok
                        and "Test egg webhook sent successfully."
                        or (
                            "Test failed: "
                            .. tostring(
                                result
                            )
                        ),
                    3
                )
            end)
        end,
    })

    local syncHatchUrl =
        createWebhookUrlControl(
            "Hatch Webhook URL",
            "HatchWebhookUrl",
            "Paste hatch webhook URL..."
        )

    WebhookSection:AddToggle({
        Title = "Hatch Webhook",
        Default =
            LoadedWebhookHatchEnabled,

        Callback = function(value)
            Session.WebhookHatchEnabled =
                value == true

            syncHatchUrl()
            scheduleAutoSave()
        end,
    })

    WebhookSection:AddButton({
        Title = "Test Hatch Webhook",

        Callback = function()
            task.spawn(function()
                syncHatchUrl()

                local embed = {
                    title =
                        "HATCH WEBHOOK CONNECTED",
                    description =
                        "SCOOPHUB PREMIUM hatch webhook is working successfully.",
                    color = 0xE72F3B,
                    fields = {
                        {
                            name = "PLAYER",
                            value =
                                LocalPlayer.Name,
                            inline = true,
                        },
                        {
                            name = "STATUS",
                            value = "Connected",
                            inline = true,
                        },
                        {
                            name = "TYPE",
                            value = "Auto Hatch",
                            inline = true,
                        },
                    },
                    footer =
                        buildWebhookFooter(
                            "Test"
                        ),
                }

                local logoUrl =
                    resolveWebhookImage(
                        "rbxassetid://97406911955707"
                    )

                if logoUrl then
                    embed.thumbnail = {
                        url = logoUrl,
                    }
                end

                local ok, result =
                    postWebhookEmbed(
                        embed,
                        Session.HatchWebhookUrl
                    )

                notify(
                    "Hatch Webhook",
                    ok
                        and "Test hatch webhook sent successfully."
                        or (
                            "Test failed: "
                            .. tostring(
                                result
                            )
                        ),
                    3
                )
            end)
        end,
    })
end)()

local GearSection = ShopTab:AddSection({
    Title = "GEARS",
    Column = "Left",
})

local FoodSection = ShopTab:AddSection({
    Title = "FOOD",
    Column = "Right",
})

local GearOptions =
    getShopCategoryItems("Gears")

local FoodOptions =
    getShopCategoryItems("Food")

local function filterSavedShopSelection(order, selected, options)
    local allowed = {}

    for index = 1, #options do
        allowed[options[index]] = true
    end

    local filtered = {}
    clearTableCompat(selected)

    for index = 1, #order do
        local itemName = order[index]

        if allowed[itemName] then
            filtered[#filtered + 1] = itemName
            selected[itemName] = true
        end
    end

    clearTableCompat(order)

    for index = 1, #filtered do
        order[index] = filtered[index]
    end
end

filterSavedShopSelection(
    Session.SelectedGearOrder,
    Session.SelectedGears,
    GearOptions
)

filterSavedShopSelection(
    Session.SelectedFoodOrder,
    Session.SelectedFood,
    FoodOptions
)

Session.GearDropdown =
    GearSection:AddDropdown({
        Title = "Select Gears",
        Content =
            "Choose one or more gears to auto buy.",
        Multi = true,
        Options = GearOptions,
        Default = Session.SelectedGearOrder,
        EmptyText = "No gears selected",
        SearchPlaceholder = "Search gear...",

        Callback = function(values)
            setShopSelection(
                Session.SelectedGears,
                Session.SelectedGearOrder,
                values
            )

            if Session.GearAutoBuyEnabled then
                updateGearAutoBuy()
            end

            scheduleAutoSave()
        end,
    })

GearSection:AddToggle({
    Title = "Auto Buy Gears",
    Content =
        "Automatically buy the selected gears when available.",
    Default = Session.GearAutoBuyEnabled,

    Callback = function(value)
        if Session.Closed
            or Library.Unloaded
        then
            return false
        end

        local enabled =
            value == true

        if enabled
            and next(Session.SelectedGears)
                == nil
        then
            notify(
                "Shop",
                "Select at least one gear first.",
                2
            )

            return false
        end

        Session.GearAutoBuyEnabled =
            enabled

        scheduleAutoSave()

        applyShopCategoryAutoBuy(
            "Gears",
            Session.SelectedGears,
            enabled
        )

        notify(
            "Gears",
            enabled
                and "Auto Buy enabled for selected gears."
                or "Auto Buy gears disabled.",
            2
        )
    end,
})

Session.FoodDropdown =
    FoodSection:AddDropdown({
        Title = "Select Food",
        Content =
            "Choose one or more food items to auto buy.",
        Multi = true,
        Options = FoodOptions,
        Default = Session.SelectedFoodOrder,
        EmptyText = "No food selected",
        SearchPlaceholder = "Search food...",

        Callback = function(values)
            setShopSelection(
                Session.SelectedFood,
                Session.SelectedFoodOrder,
                values
            )

            if Session.FoodAutoBuyEnabled then
                updateFoodAutoBuy()
            end

            scheduleAutoSave()
        end,
    })

FoodSection:AddToggle({
    Title = "Auto Buy Food",
    Content =
        "Automatically buy the selected food when available.",
    Default = Session.FoodAutoBuyEnabled,

    Callback = function(value)
        if Session.Closed
            or Library.Unloaded
        then
            return false
        end

        local enabled =
            value == true

        if enabled
            and next(Session.SelectedFood)
                == nil
        then
            notify(
                "Shop",
                "Select at least one food item first.",
                2
            )

            return false
        end

        Session.FoodAutoBuyEnabled =
            enabled

        scheduleAutoSave()

        applyShopCategoryAutoBuy(
            "Food",
            Session.SelectedFood,
            enabled
        )

        notify(
            "Food",
            enabled
                and "Auto Buy enabled for selected food."
                or "Auto Buy food disabled.",
            2
        )
    end,
})

GearSection:AddButton({
    Title = "Refresh Shop",
    ButtonText = "REFRESH",

    Callback = function()
        if Session.Closed then
            return
        end

        pcall(function()
            ShopStock:FireServer()
        end)

        local newGearOptions =
            getShopCategoryItems("Gears")

        local newFoodOptions =
            getShopCategoryItems("Food")

        if Session.GearDropdown then
            Session.GearDropdown:SetOptions(
                newGearOptions,
                true
            )

            Session.GearDropdown:Set(
                Session.SelectedGearOrder,
                false
            )
        end

        if Session.FoodDropdown then
            Session.FoodDropdown:SetOptions(
                newFoodOptions,
                true
            )

            Session.FoodDropdown:Set(
                Session.SelectedFoodOrder,
                false
            )
        end

        notify(
            "Shop",
            "Shop item lists refreshed.",
            2
        )
    end,
})

pcall(function()
    local teleportConnection =
        LocalPlayer.OnTeleport:Connect(function()
            saveConfigNow()
        end)

    Session.Connections[#Session.Connections + 1] =
        teleportConnection
end)

local removingConnection =
    Players.PlayerRemoving:Connect(function(player)
        if player == LocalPlayer then
            saveConfigNow()
        end
    end)

Session.Connections[#Session.Connections + 1] =
    removingConnection

table.insert(
    Session.Connections,
    ActiveEggs.ChildAdded:Connect(function()
        task.defer(function()
            Session:UpdateEggESP()
        end)
    end)
)

table.insert(
    Session.Connections,
    ActiveEggs.ChildRemoved:Connect(function()
        task.defer(function()
            Session:UpdateEggESP()
        end)
    end)
)

table.insert(
    Session.Connections,
    Workspace.ChildAdded:Connect(function(child)
        if child.Name == "RenderedEggs" then
            task.defer(function()
                Session:UpdateEggESP()
            end)
        end
    end)
)

task.spawn(function()
    while not Session.Closed do
        if Session.ESPEnabled then
            Session:UpdateEggESP()
        end

        task.wait(0.35)
    end
end)

task.spawn(function()
    while not Session.Closed do
        task.wait(10)

        if not Session.Closed then
            saveConfigNow()
        end
    end
end)

task.defer(function()
    if Session.Closed then
        return
    end

    if LoadedLowGraphicsEnabled then
        setLowGraphicsMode(true)
    end

    if Session.WalkSpeedEnabled
        and LocalPlayer.Character
    then
        bindWalkSpeedCharacter(LocalPlayer.Character)
    end

    if Session.ESPEnabled then
        Session:UpdateEggESP()
    end

    if Session.GearAutoBuyEnabled
        and next(Session.SelectedGears) ~= nil
    then
        updateGearAutoBuy()
    end

    if Session.FoodAutoBuyEnabled
        and next(Session.SelectedFood) ~= nil
    then
        updateFoodAutoBuy()
    end

    if LoadedAutoFarmEnabled then
        Session:StartAutoFarm()
    end

    if LoadedAutoHatchEnabled then
        Session:StartAutoHatch()
    end

    if LoadedAutoEquipBestEnabled then
        Session:StartAutoEquipBest()
    end

    saveConfigNow()
end)

Session:RefreshEggs(true)

print("[SCOOPHUB PREMIUM] Ride A Pet loaded successfully.")
