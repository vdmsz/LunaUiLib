local module = {}

-- ============================================================
-- Asset cache setup
-- ============================================================
local AssetFolder = "Luna/Assets/Icons"
local gca = getcustomasset or getsynasset

local function ensureFolder()
    if isfolder and not isfolder("Luna/Assets") then makefolder("Luna/Assets") end
    if isfolder and not isfolder(AssetFolder) then makefolder(AssetFolder) end
end

-- Download-once-then-cache a text file (the icon tables)
local function cachedText(url, cacheName)
    local path = AssetFolder .. "/" .. cacheName
    if isfile and isfile(path) then
        local ok, data = pcall(readfile, path)
        if ok and data and #data > 0 then return data end
    end

    local ok, data = pcall(function() return game:HttpGetAsync(url) end)
    if not ok or not data or #data == 0 then
        error("Failed to fetch " .. url .. ": " .. tostring(data))
    end

    if writefile then
        ensureFolder()
        pcall(writefile, path, data)
    end
    return data
end

-- Download-once-then-cache a Roblox asset by ID.
-- Returns a local custom-asset path if supported, otherwise the rbxassetid:// string.
local function cachedIcon(assetId)
    if not gca then
        return "rbxassetid://" .. tostring(assetId)
    end
    if not isfile or not writefile then
        return "rbxassetid://" .. tostring(assetId)
    end

    ensureFolder()

    local path = AssetFolder .. "/" .. tostring(assetId) .. ".png"
    if not isfile(path) then
        local url = "https://assetdelivery.roblox.com/v1/asset/?id=" .. tostring(assetId)
        local ok, data = pcall(function() return game:HttpGet(url) end)
        if not ok or not data or #data == 0 then
            return "rbxassetid://" .. tostring(assetId)
        end
        local wrote = pcall(writefile, path, data)
        if not wrote then
            return "rbxassetid://" .. tostring(assetId)
        end
    end

    local ok, result = pcall(gca, path)
    if not ok or not result then
        return "rbxassetid://" .. tostring(assetId)
    end
    return result
end

-- ============================================================
-- Load icon tables (now cached locally too)
-- ============================================================
local BASE = "https://raw.githubusercontent.com/Nebula-Softworks/Nebula-Icon-Library"

module.Material          = loadstring(cachedText(BASE .. "/master/MaterialIcons.luau",          "MaterialIcons.luau"))()
module.Lucide            = loadstring(cachedText(BASE .. "/master/LucideIcons.luau",            "LucideIcons.luau"))()
module.Phosphor          = loadstring(cachedText(BASE .. "/master/Phosphor.luau",               "Phosphor.luau"))()
module["Phosphor-Filled"]= loadstring(cachedText(BASE .. "/master/Phosphor%20Filled.luau",      "PhosphorFilled.luau"))()
module["SF"]             = loadstring(cachedText(BASE .. "/master/SFSymbols.luau",              "SFSymbols.luau"))()
module["Symbols"]        = loadstring(cachedText(BASE .. "/master/Symbols.luau",                "Symbols.luau"))()
module["Symbols-Filled"] = loadstring(cachedText(BASE .. "/master/Symbols-Filled.luau",         "Symbols-Filled.luau"))()
module["Lab"]            = loadstring(cachedText(BASE .. "/master/LucideLab.luau",              "LucideLab.luau"))()
module.Fluency           = loadstring(cachedText(BASE .. "/master/Fluency.luau",                "Fluency.luau"))()

-- ============================================================
-- Nebula's own custom icons
-- ============================================================
module.nebulaIcons = {
    stripes       = 8834748103,
    circles       = 73048796459024,
    nebula        = 76656741080367,
    home          = 111043355839507,
    keycache      = 13587387127,
    apps          = 13300918120,
    view_in_ar    = 113380429914565,
    home_material = 9080449299,
    location      = 6034996695,
    sparkle       = 4483362748,
}

-- ============================================================
-- GetIcon — returns a cached custom asset path when possible
-- ============================================================
function module:GetIcon(name, source)
    source = source or "Symbols"

    local sourceTable = module[source]
    if not sourceTable then
        warn("[Icons] Unknown source: " .. tostring(source))
        return nil
    end

    local id = sourceTable[name]
    if not id then
        warn("[Icons] Unknown icon: " .. tostring(name) .. " in source " .. tostring(source))
        return nil
    end

    return cachedIcon(id)
end

return module
