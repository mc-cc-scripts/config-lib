# config-lib
A small library for simple configuration management within your programs.

# How To Use
## Initialise
Require the config (ideally via scm):
```lua
local scm = require("./scm")
local Config = scm:load("config")
```
Or without scm:
```lua
local Config = require("config")
```

Then you have to set default values for your program config:
```lua
local defaults = {
    ["exampleNumber"] = {
        ["description"] = "exampleNumber description",
        ["default"] = 1,
        ["type"] = "number"
    },
    ["exampleTable"] = {
        ["description"] = "exampleTable description",
        ["default"] = {1, 2 ,3},
        ["type"] = "table"
    },
    -- ...
}
```
_Note: The description values are currently not being used._

With the default values set we can then initialise the config:
```lua
Config:init(defaults)
```

Optionally we could set the suffix, which is used to store the data in CC: Tweakeds settings, by passing it as a second parameter:
```lua
Config:init(defaults, "@programIdentifier")
```
_By default this value is generated from the filename in which the config gets initalised. If, for whatever reason, this does not work, you could pass the suffix to make sure everything is working as intended. You should be careful not to override existing configs of other programs though._

## Handle arguments
To utilise the commandline arguments you have to pass the args to the config:
```lua
local args = {...}
if args[1] == "config" then
    Config:command(args)
else
    -- (run your program normally)
end
```
This way the following commands are available via commandline:
- `set <name> <value>`
- `get <name>`
- `list`

_Note: You cannot set a value that has not been previously defined in the default values._

A call to change a `protocol` configuration to `abc123` might look like this:
```
program.lua config set protocol abc123
```

## Use internally
The same functions which you can use via the commandline, can also be used within your program.
- `Config:set(name <string>, value <table|string|number|boolean>)`
- `Config:get(name <string>) -> <table|string|number|boolean>`
- `Config:list() -> <table>`

_Note: Calling `list` via commandline will also internally call `get` to provide some further information. Using `Config:list()` will only return a list of names._ 


## Example
Please take a look at the example program in `examples/configExample.lua`
