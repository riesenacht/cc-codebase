local main, side = ...

inventory = require("inventory")

local stride = 2
local numSides = main / stride
local torchDistance = 10
local torchCounter = 0

local function dumpInventoryInChest()
    local chest = inventory.selectSlotWithItem("minecraft:chest")
    if not chest then
        return false
    end
    turtle.turnLeft()
    turtle.dig()
    turtle.forward()
    turtle.digUp()
    turtle.back()
    turtle.place()
    local excludedItems = {
        "minecraft:coal",
        "minecraft:chest",
        "minecraft:torch"
    }
    inventory.dropAllBut(excludedItems)
    turtle.turnRight()
    return true
end

local function handleInventory()
  local inventoryFull = inventory.isFull()
  if inventoryFull then
    return dumpInventoryInChest()
  end
  return true
end

local function isInterrupt()
  local item = inventory.selectSlotWithItem("minecraft:stick")
  return item
end

local function placeTorch()
  torch = inventory.selectSlotWithItem("minecraft:torch")
  if not torch then
    print("Out of torches")
    return false
  end
  print("Placing torch")
  turtle.up()
  turtle.dig()
  turtle.down()
  turtle.turnRight()
  sleep(1)
  local placed = turtle.placeUp()
  turtle.turnLeft()
  return placed
end

local function autoRefuel()
  coal = inventory.selectSlotWithItem("minecraft:coal")
  if not coal then
      print("Failed to refuel")
    return false
  end
  print("Refueling with coal")
  turtle.refuel(1)
  return true
end

local function handleFuel()
  local fuelLevel = turtle.getFuelLevel()
  if fuelLevel == 0 then
    return autoRefuel()
  end
  return true
end

local function moveBack(n)
  for i = 0, n do
    turtle.back()
    local fueled = handleFuel()
    if not fueled then
        return
    end
  end
end

local function tunnelForwardStep()
  local interrupt = isInterrupt()
  if interrupt then
     print("Interrupting by STICK")
     return false
  end
  local fueled = handleFuel()
  if not fueled then
    print("Stop due to lack of fuel")
    return false
  end
  local inventoryOk = handleInventory()
  turtle.dig()
  if torchCounter >= torchDistance then
    local ok = placeTorch()
    if not ok then
      print("Could not place torch")
    end
    torchCounter = 0
  else
    torchCounter = torchCounter + 1
  end
  turtle.forward()
  turtle.digUp()
  return true
end

local function tunnelForward(n)
  for i = 0, n do
    ok = tunnelForwardStep()
    if not ok then
      return false
    end
  end
  return true
end

print("Main Tunnel: "..main)
print("Side Tunnels: "..numSides.." with stride "..stride)

for n = 0, numSides do
  print("Step "..n.." of "..numSides)
  local ok = tunnelForward(stride)
  if not ok then
      return
  end
  turtle.turnLeft()
  local ok = tunnelForward(side)
  if not ok then
    return
  end
  print("Moving back: "..side.." blocks")
  moveBack(side)
  local fueled = handleFuel()
  if not fueled then
    print("Interrupt. No fuel!")
    return
  end
  turtle.turnRight()
end
moveBack(main)