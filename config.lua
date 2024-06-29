---@class Config
local Config = {}

-- helper function
local function tableContainsString(tbl, str)
    for _, s in ipairs(tbl) do
        if s == str then return true end
    end
    return false
end

--- Should be defined in the same way as the settings in CC Tweaked: https://tweaked.cc/module/settings.html (Usage)
---
--- `type` is a string of the type of `default`
---@class defaults
---@field description string
---@field default any
---@field type string

---@param defaults defaults
---@param overrideSuffix string | nil
function Config:init(defaults, overrideSuffix)
    -- used if a setting is not found in global settings
    self.defaults = defaults
    -- set suffix to filename
    -- @config.lua if you run it here but since you run the Config:init()
    -- from your program the suffix will be their name
    -- gsub removes the path in front of the file name
    self.suffix = overrideSuffix or debug.getinfo(2, "S").source:gsub('.*%/', '@')
    -- define all (default) settings if not defined
    self:define()
end

function Config:define()
    local definedSettings = settings.getNames()
    for name, setting in pairs(self.defaults) do
        -- only define if it does not exist yet
        if not tableContainsString(definedSettings, name .. self.suffix) then
            settings.define(name .. self.suffix, setting)
        end
    end
end

---@param name string
---@return any value
function Config:get(name)
    settings.load()
    local value = settings.get(name .. self.suffix, self.defaults[name].default or nil)
    return value
end

---@param name string
---@param value string
function Config:set(name, value)
    if not self.defaults[name] then
        print("Cannot configure: " .. name)
        return
    end
    local vtype = self.defaults[name].type
    if vtype == "boolean" then
        -- @TODO: Find a way to do this in a way that the language-server likes.
        ---@cast value +boolean
        ---@type boolean
        ---@diagnostic disable-next-line
        value = value == "true"
    elseif vtype == "number" then
        ---@cast value +number
        ---@type number
        ---@diagnostic disable-next-line
        value = tonumber(value)
    elseif vtype == "table" then
        ---@cast value +table
        ---@type table
        ---@diagnostic disable-next-line
        value = textutils.unserialise(value)
    end

    -- make sure we don't override something that has changed since we initialised this library
    settings.load()

    -- set value and save global settings
    settings.set(name .. self.suffix, value)
    settings.save()
end

---@return table
function Config:list()
    local list = {}
    
    local definedSettings = settings.getNames()
    for i=1, #definedSettings do
        if string.find(definedSettings[i], self.suffix) then
            local val = definedSettings[i]:gsub(self.suffix, "")
            table.insert(list, val)
        end
    end

    return list
end

---@param args table
---@returns boolean
function Config:command(args)
    if args[1] == "config" then
        args = {unpack(args, 2)}
    end

    local action = args[1]
    local name = args[2]
    local value = args[3]
    if not action then
        print("Usage: <action> [<name>] [<value>]\n" ..
              "Actions:\n" ..
              "- set <name> <value>\n" ..
              "- get <name>\n" ..
              "- list"
        )
        return false
    end

    if action == "set" then
        if not value then
            print("Usage: set <name> <value>")
            return false
        end
        self:set(name, value)
        return true
    elseif action == "get" then
        local val = self:get(name)
        if type(val) == "table" then
            print(textutils.serialise(val) .. " <" .. type(val) .. ">")
        else
            print(tostring(val) .. " <" .. type(val) .. ">")
        end
        return true
    elseif action == "list" then
        local list = self:list()
        for i = 1, #list do
            local val = self:get(list[i])
            local type = type(val)
            print(list[i] .. " <" .. type .. ">" .. " " .. tostring(val))
        end
        return true
    end
    
    print("Unknown action: " .. action)
    return false
end

return Config