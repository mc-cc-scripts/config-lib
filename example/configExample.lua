print("Example program for config.lua")
local Config = require "../config"
local args = {...}

-- The defaults are used whenever a value is not yet set.
-- Values that are not set as a default cannot be used in the config.
local defaults = {
    ["tset"] = {
        ["description"] = "tset value desc",
        ["default"] = 1,
        ["type"] = "number"
    },
    ["tbl"] = {
        ["description"] = "tbl value desc",
        ["default"] = {3, 4 ,5},
        ["type"] = "table"
    },
    ["tbool"] = {
        ["description"] = "tbool value desc",
        ["default"] = false,
        ["type"] = "boolean"
    },
    ["tstr"] = {
        ["description"] = "tstr value desc",
        ["default"] = "abc",
        ["type"] = "string"
    }
}

-- Always initialise the Config with the default values
-- You can (optionally) add a suffix as second parameter
-- which will be used internally to store the values.
Config:init(defaults)

-- The main program should not run when it is called with config as parameter
if args[1] == "config" then
    -- To automatically handle all commands, just pass the args to the command method
    -- and it will provide all prints etc.
    Config:command(args)
else
    -- This is not needed, just an example on how you could print all configurations
    local list = Config:list()
    for i = 1, #list do
        local val = Config:get(list[i])
        local type = type(val)
        if type == "table" then
            print(list[i] .. " <" .. type .. ">" .. " " .. textutils.serialise(val))
        else
            print(list[i] .. " <" .. type .. ">" .. " " .. tostring(val))
        end
    end
end


