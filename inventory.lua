local inventory = {}

local totalSlots = 16

function inventory.isFull()
    for slot = 1, totalSlots do
        if turtle.getItemCount(slot) == 0 then
            return false
        end
    end
    return true
end

function inventory.selectSlotWithItem(itemName)
    for slot = 1, totalSlots do
        if turtle.getItemCount(slot) > 0 then
            local item = turtle.getItemDetail(slot)
            if item.name == itemName then
                return turtle.select(slot)
            end
        end
    end
    return false
end

local function isItemExcluded(excludedItems, itemName)
    for k, v in pairs(excludedItems) do
        if v == itemName then
            return true
        end
    end
    return false
end

function inventory.dropAllBut(excludedItems)
    for slot = 1, totalSlots do
        if turtle.getItemCount(slot) > 0 then
            local item = turtle.getItemDetail(slot)
            if not isItemExcluded(excludedItems, item.name) then
                turtle.select(slot)
                turtle.drop()
            end
        end
    end
end

return inventory