-- Adapted from https://github.com/Nevcairiel/Bartender4/blob/master/locale/find-locale-strings.lua
local TOC_FILES = {}
-- Automatically find the TOC in the given path, set to false to disable
local outputFilename = arg and arg[1] or "exported-locale-strings.lua"
local AUTO_FIND_TOC = { "./" }
if arg and arg[2] then
    local i = 2
    while arg[i] do
        AUTO_FIND_TOC[i-1] = arg[i]
        i = i + 1
    end
end

-- Patterns that should not be scrapped, case-insensitive
-- Anything between the no-lib-strip is automatically ignored
local FILE_BLACKLIST = {"^locale", "^libs"}


-- No more modifying!
local OS_TYPE = os.getenv("HOME") and "linux" or "windows"

-- Find the TOC now
for _, path in ipairs(AUTO_FIND_TOC) do
    local pipe = OS_TYPE == "windows" and io.popen(string.format("dir /B \"%s\"", path)) or io.popen(string.format("ls -1 \"%s\"", path))
    if( type(pipe) == "userdata" ) then
        for file in pipe:lines() do
            if( string.match(file, "(.+)%.toc") ) then
                table.insert(TOC_FILES, { path = path, toc = path .. file })
                break
            end
        end

        pipe:close()
        if( not TOC_FILES ) then print("Failed to auto detect toc file.") end
    else
        print("Failed to auto find toc, cannot run dir /B or ls -1")
    end
end

if( not next(TOC_FILES) ) then
    return
end

local ignore
local localizedKeys = {}
for _, tocFile in ipairs(TOC_FILES) do
    local toc, path = tocFile.toc, tocFile.path
    print(string.format("Using TOC file %s", toc))
    print("")
    -- Parse through the TOC file so we know what to scan
    for line in io.lines(toc) do
        line = path .. string.gsub(line, "\r", "")

        if( string.match(line, "#@no%-lib%-strip@") ) then
            ignore = true
        elseif( string.match(line, "#@end%-no%-lib%-strip@") ) then
            ignore = nil
        end

        if( not ignore and string.match(line, "%.lua") and not string.match(line, "^%s*#")) then
            -- Make sure it's a valid file
            local blacklist
            for _, check in pairs(FILE_BLACKLIST) do
                if( string.match(string.lower(line), check) ) then
                    blacklist = true
                    break
                end
            end

            -- File checks out, scrap everything
            if( not blacklist ) then
                -- Fix slashes
                if( OS_TYPE == "linux" ) then
                    line = string.gsub(line, "\\", "/")
                end

                local keys = 0
                local contents = io.open(line):read("*all")

                for match in string.gmatch(contents, "L%[\"(.-)\"]") do
                    if( not localizedKeys[match] ) then keys = keys + 1 end
                    localizedKeys[match] = true
                end
                for match in string.gmatch(contents, "L%['(.-)']") do
                    -- convert format from single to double quotes
                    match = string.gsub(match, "\\'", "'")
                    match = string.gsub(match, "\"", "\\\"")
                    if( not localizedKeys[match] ) then keys = keys + 1 end
                    localizedKeys[match] = true
                end

                print(string.format("%s (%d keys)", line, keys))
            end
        end
    end
    print("")
end

-- Compile all of the localization we found into string form
local totalLocalizedKeys = 0
local localization = ""
for key in pairs(localizedKeys) do
    localization = string.format("%sL[\"%s\"] = true\n", localization, key)
    totalLocalizedKeys = totalLocalizedKeys + 1
end

if( totalLocalizedKeys == 0 ) then
    print("Warning, failed to find any localizations, perhaps you messed up a configuration variable?")
    return
end

local file = assert(io.open(outputFilename, "w", "Error opening file"))
file:write(localization)
file:close()

print(string.format("Written %d keys to %s", totalLocalizedKeys, outputFilename))
