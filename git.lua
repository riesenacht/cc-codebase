local cmd, remote, dir = ...

if cmd == "help" then
  print("Use: git pull [github-repo] [local-path]")
  return
end
if cmd ~= "pull" then
  print("Command "..cmd.." unknown")
  return
end

local defaultRemote = "riesenacht/cc-codebase"
local defaultDir = "cb"
if remote == nil or remote == "" then
  remote = defaultRemote
end
if dir == nil or dir == "" then
  dir = defaultDir
end

local function ensureLibDir()
  local libDir = "/lib"
  if not fs.exists(libDir) then
    fs.makeDir(libDir)
  end
end

local function ensureJsonLib()
  ensureLibDir()
  local jsonLib = "/lib/json.lua"
  if not fs.exists(jsonLib) then
    local request = http.get("https://raw.githubusercontent.com/rxi/json.lua/master/json.lua")
    local content = request.readAll()
    request.close()
    file = fs.open(jsonLib, "w")
    file.write(content)
    file.close()
  end  
end

local function includePath(path)
  if string.sub(path, 1, 1) == "." then
    return false
  end
  if string.match(path, "/") then
    return false
  end
  return true
end

local function processFiles(repoTree)
  local files = {}
  for i, file in ipairs(repoTree) do
    local path = file.path
    if includePath(path) then        
      table.insert(files, path)
    end
  end
  return files
end

local function getRepoTree()  
  ensureJsonLib()
  local json = require("/lib/json")
  local repoUrl = "https://api.github.com/repos/"..remote.."/git/trees/main?recursive=1"
  local request = http.get(repoUrl)
  local raw = request.readAll()
  request.close()
  local repo = json.decode(raw)
  local tree = repo.tree
  return repo.tree
end

local function recreateLocalDir()
  if fs.exists(dir) then
    fs.delete(dir)
  end
  fs.makeDir(dir)
end

local repoTree = getRepoTree()
local files = processFiles(repoTree)
recreateLocalDir()
local repoUrl = "https://raw.githubusercontent.com/"..remote.."/main"
for k,v in pairs(files) do
  print(k, v)
  local request = http.get(repoUrl.."/"..v)
  local content = request.readAll()
  request.close()
  local file = fs.open(dir.."/"..v, "w")
  file.write(content)
  file.close()
end
