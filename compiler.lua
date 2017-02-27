local tArgs = {...}

local function usage()
    print([[Usage: compile <dir> [excludefile]]])
end

local exe = [[for k, v in ipairs(lst) do local f = fs.open(k, "w"); f.write(v); f.close() end]]

local function getFileSnip(fName, data)
    return fName:gsub("\\", "\\\\"):gsub("([])", "\\%1")
end

if #tArgs < 1 then
    usage()
    return
end

local dir, exclude = tArgs[1], tArgs
table.remove(exclude)

local toDo = {dir}
while true do
    local d = toDo[1]
    for _, n in ipairs(fs.list(d)) do
        toDo[#toDo + 1] = 
