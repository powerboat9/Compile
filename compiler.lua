local tArgs = {...}

local function usage()
    print([[Usage: compile <dir> [excludefiles]]])
end

local start = [[--powerboat9's file extractor--

local lst = {]]
local exe = [[for p, d in pairs(lst) do
    local i, s = 0, ""
    for i, #d do
        local char = d:sub(i, i)
        if i <= (d - 2) then
            if d:sub(i, i + 2) == "|||" then
                s = s .. "|"
                i += 3
            elseif d:sub(i, i + 1) == "|+" then
                s = s .. d:sub(i + 2, i + 2):byte() + 128
                i += 3
            else
                s = s .. char
                i++
            end
        else
            s = s .. d:sub(i)
            s += 3
        end
    end
    local f = fs.open(p, "wb")
    for i, #s do
        f.write(string.byte(s:sub(i, i)))
    end
    f.close()
end]]

local function addFile(path, data)
    if type(path) ~= "string" then
        error("Invalid path", 2)
    elseif type(data) ~= "string" then
        error("Invalid data", 2)
    end
    local ePath = ""
    while true do
        if not path:find("]" .. e .. "]") then
            break
        end
        ePath = ePath .. "="
    end
    local s = "[" .. ePath .. "[" .. path .. "]" .. ePath .. "]=["
    local eData = ""
    while true do
        if not data:find("]" .. e2 .. "]") then
            break
        end
        eData = eData .. "="
    end
    local newData = ""
    for i, #data do
        local char = data:sub(i, i)
        local byte = string.byte(char)
        if char == "|" then
            newData = newData .. "|||"
        elseif byte > 127 then
            newData = newData .. "|+" .. string.char(byte - 128)
        else
            newData = newData .. char
        end
    end
    s = s .. eData .. "[" .. newData .. "]" .. eData .. "],"
    start = start .. s
end

if #tArgs < 1 then
    usage()
    return
end

local dir, exclude = tArgs[1]:gsub("/$", ""), tArgs
table.remove(exclude)
do
    local t = {}
    for _, v in ipairs(exclude) do
        t[v] = true
    end
    exclude = t
end

local toDo = {dir}
while #toDo > 0 do
    local d = toDo[1]
    for _, n in ipairs(fs.list(d)) do
        local p = d .. "/" .. n
        if not exclude[p] then
            if fs.isDir(p) then
                toDo[#toDo + 1] = p
            else
                local f, s = fs.open(p, "rb"), ""
                while true do
                    local i = f.read()
                    if not i then
                        break
                    end
                    s = s .. string.char(i)
                end
                f.close()
                addFile(p, s)
            end
        end
    end
    table.remove(toDo, 1)
end
start = start .. "}"

local f = fs.open(fs.getName(dir) .. ".xtract", "w")
f.write(start .. "\n" .. exe)
f.close()
