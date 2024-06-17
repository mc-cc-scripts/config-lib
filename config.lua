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
    self.suffix = overrideSuffix or debug.getinfo(2, "S").source
    -- define all (default) settings if not defined
    self:define()
end

function Config:define()
    local definedSettings = settings.getNames()
    for name, setting in pairs(self.defaults) do
        -- only define if it does not exist yet
        if not tableContainsString(definedSettings, name) then
            settings.define(name .. self.suffix, setting)
        end
    end
end

---@param name string
---@return string value
function Config:get(name)
    local value = settings.get(name .. self.suffix, self.defaults[name .. self.suffix].value or nil)
    if self.defaults[name].type == "boolean" then
        value = value == "true" or false
    elseif self.defaults[name].type == "number" then
        value = tonumber(value)
    end
    return value
end

---@param name string
---@param value string
function Config:set(name, value)
    -- @TODO: I think tables are supported, add those here
    value = tostring(value)

    -- make sure we don't override something that has changed since we initialised this library
    settings.load()

    -- set value and save global settings
    settings.set(name .. self.suffix, value)
    settings.save()
end

return Config