-- Inspired by https://github.com/Nevcairiel/Bartender4/blob/master/locale/find-locale-strings.lua
local LUA_FILES = {}
-- Automatically find the TOC in the given path, set to false to disable
local outputFilename = arg and arg[1] or "exported-locale-strings.lua"
local PATHS = { "./" }
if arg and arg[2] then
    local i = 2
    while arg[i] do
        PATHS[i - 1] = arg[i]
        i = i + 1
    end
end

-- Patterns that should not be scrapped, case-insensitive
-- Anything between the no-lib-strip is automatically ignored
local FILE_BLACKLIST = { "/locale/", "/libs/", "/types.lua" }


-- No more modifying!
local OS_TYPE = os.getenv("HOME") and "linux" or "windows"
if OS_TYPE == "windows" then
    error("Only Linux is supported at this time.")
end

for _, path in ipairs(PATHS) do
    local pipe = io.popen(string.format("find \"%s\" -type f -name '*.lua'", path))
    if type(pipe) == "userdata" then
        for file in pipe:lines() do
            if string.match(file, "(.+)%.lua") then
                table.insert(LUA_FILES, file)
            end
        end

        pipe:close()
    else
        error("Failed to auto find lua files")
    end
end

if not next(LUA_FILES) then
    error("Failed to auto detect toc file.")
end

local localizedKeys = {}
for _, file in ipairs(LUA_FILES) do
    if string.match(file, "%.lua") and not string.match(file, "^%s*#") then
        -- Make sure it's a valid file
        local blacklist
        for _, check in pairs(FILE_BLACKLIST) do
            if string.match(string.lower(file), check) then
                blacklist = true
                break
            end
        end

        -- File checks out, scrap everything
        if not blacklist then
            -- Fix slashes
            if OS_TYPE == "linux" then
                file = string.gsub(file, "\\", "/")
            end

            local keys = 0
            local contents = io.open(file):read("*all")

            for match in string.gmatch(contents, "L%[\"(.-)\"]") do
                if not localizedKeys[match] then keys = keys + 1 end
                localizedKeys[match] = true
            end
            for match in string.gmatch(contents, "L%['(.-)']") do
                -- convert format from single to double quotes
                match = string.gsub(match, "\\'", "'")
                match = string.gsub(match, "\"", "\\\"")
                if not localizedKeys[match] then keys = keys + 1 end
                localizedKeys[match] = true
            end

            print(string.format("%s (%d keys)", file, keys))
        end
    end
end

-- Compile all of the localization we found into string form
local totalLocalizedKeys = 0
local localization = ""
for key in pairs(localizedKeys) do
    localization = string.format("%sL[\"%s\"] = true\n", localization, key)
    totalLocalizedKeys = totalLocalizedKeys + 1
end

if totalLocalizedKeys == 0 then
    print("Warning, failed to find any localizations, perhaps you messed up a configuration variable?")
    return
end

local file = assert(io.open(outputFilename, "w", "Error opening file"))
file:write(localization)
file:close()

print(string.format("Written %d keys to %s", totalLocalizedKeys, outputFilename))
