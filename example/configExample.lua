print("Example program for config.lua")
local Config = require "../config"
local args = {...}

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

Config:init(defaults)

-- The main program should not run when it is called with config as parameter
if args[1] == "config" then
    Config:command(args)
else
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


