ModStuff = {}
ModStuff.destroyers = {}
ModStuff.idMaps = {}
ModStuff.stopOptimization = {}
ModStuff.nextCells = {}
ModStuff.toGenerates = {}
ModStuff.transparent = {}
ModStuff.unbreakable = {}
ModStuff.onPlace = {}
ModStuff.whenSelected = {}
ModStuff.idConversion = {}
ModStuff.flipmode = {}
ModStuff.nonexistant = {}
ModStuff.custompush = {}
ModStuff.onSetCell = {}
ModStuff.onCellDraw = {}
ModStuff.whenRotated = {}
ModStuff.acidic = {}
ModStuff.customprepush = {}
ModStuff.whenClicked = {}
ModStuff.specialTypes = {}

ModStuff.listeners = {}

ModStuff.audioCache = {}

function On(event, callback)
  if not ModStuff.listeners[event] then ModStuff.listeners[event] = {} end
  table.insert(ModStuff.listeners[event], callback)
end

function OnDraw(callback) On('render', callback) end
function OnTick(callback) On('tick', callback) end
function OnUpdate(callback) On('update', callback) end
function OnCellDraw(callback) On('cellrender', callback) end
function OnSubtickCycle(callback) On('tick-cycle', callback) end
function OnGridRender(callback) On('grid-render', callback) end

--- @param sound string
function PlaySound(sound)
  if not ModStuff.audioCache[sound] then
    ModStuff.audioCache[sound] = love.audio.newSource(sound, "static")
  end
  Play(ModStuff.audioCache[sound])
end

--- @param x number
--- @param y number
--- @param cell table
--- @param vars table
--- @param ptype "\"push\""|"\"pull\""|"\"grab\""|"\"swap\""|"\"nudge\""
-- Call this in your enemies push function to get the base effect of an enemy.
function DoBaseEnemy(x, y, cell, vars, ptype, replaceID)
  if ptype == "push" or ptype == "nudge" then
    cell.id = (replaceID or 0)
    vars.lastcell.id = 0
    enemyparticles:setPosition(x*20-10,y*20-10)
    if fancy then enemyparticles:emit(50) end
    Play(destroysound)
    return true
  else
    return false
  end
end

function GetFrontPos(x, y, dir, amount)
  amount = amount or 1
  -- Straight
  if dir == 0 then x = x + amount elseif dir == 2 then x = x - amount end
  if dir == 1 then y = y + amount elseif dir == 3 then y = y - amount end

  -- Diagonal
  if dir == 0.5 then
    return x+amount, y+amount
  elseif dir == 1.5 then
    return x-amount, y+amount
  elseif dir == 2.5 then
    return x-amount, y-amount
  elseif dir == 3.5 then
    return x+amount,y-amount
  end

  return x, y
end

function Trigger(event, ...)
  if type(ModStuff.listeners[event]) == "table" then
    for _, listener in ipairs(ModStuff.listeners[event]) do
      listener(...)
    end
  end
end

function RemoveButton(key)
  for k, button in pairs(buttons) do
    if key == k then
      buttons[key] = nil
      for i, btn in ipairs(buttonorder) do
        if btn == k then
          table.remove(buttonorder, i)
        end
      end
    end
  end
end

function ClearOldCellbarButtons()
  for i=0,#lists do
    local list = lists[i]
    RemoveButton("list"..i)
    for j=1,#list.cells do
      local cell = list.cells[j]
      if type(cell) == "table" then
        RemoveButton("list"..i.."sublist"..j)
        for k=1,#cell do
          local subcell = cell[k]
          RemoveButton("list"..i.."sublist"..j.."cell"..subcell)
        end
      else
        RemoveButton("list"..i.."cell"..cell)
      end
    end
  end
end

function RebuildCellbar()
  for i=0,#lists do 
    local list = lists[i]
    NewButton(i*50+6,6,40,40,list.icon,"list"..i,list.name,list.desc,function() openedtab = openedtab == i and -1 or i; openedsubtab = -1; propertiesopen = 0 end,false,list.name == "Cheats" and function() return not puzzle and dodebug end or function() return not puzzle end,"bottomleft", hudrotation)
    for j=1,#list.cells do
      local cell = list.cells[j]
      if type(cell) == "table" then
        NewButton(i*50+16,j*20+34,20,20,cell.icon or cell[1],"list"..i.."sublist"..j,cell.name,cell.desc,function() openedsubtab = openedsubtab == j and -1 or j; propertiesopen = 0 end,false,function() return not puzzle and openedtab == i end,"bottomleft", hudrotation)
        for k=1,#cell do
          local subcell = cell[k]
          local m = cell.max or list.cells.max
          local x = (k-1)%m+1
          local y = math.floor((k-1)/m)
          cellinfo[subcell] = cellinfo[subcell] or {name="Placeholder A",desc="Cell info was not set for this id."}
          if not cellinfo[subcell].idadded then cellinfo[subcell].desc = cellinfo[subcell].desc.."\nID: "..subcell cellinfo[subcell].idadded = true end
          local b = NewButton(i*50+16+x*20,j*20+34+y*20,20,20,tex[subcell] and subcell or "X","list"..i.."sublist"..j.."cell"..subcell,cellinfo[subcell].name,cellinfo[subcell].desc,function(b) propertiesopen = 0; SetSelectedCell(subcell,b) end,false,function() return not puzzle and openedtab == i and openedsubtab == j end,"bottomleft", hudrotation)
        end
      else
        cellinfo[cell] = cellinfo[cell] or {name="Placeholder A",desc="Cell info was not set for this id."}
        if not cellinfo[cell].idadded then cellinfo[cell].desc = cellinfo[cell].desc.."\nID: "..cell cellinfo[cell].idadded = true end
        NewButton(i*50+16,j*20+34,20,20,tex[cell] and cell or "X","list"..i.."cell"..cell,cellinfo[cell].name,cellinfo[cell].desc,function(b) propertiesopen = 0; SetSelectedCell(cell,b); openedsubtab = -1 end,false,function() return not puzzle and openedtab == i end,"bottomleft", hudrotation)
      end
    end
  end
end

function CatToSub(category)
  local c = table.copy(category)
  for _, cell in ipairs(c.cells) do
    table.insert(c, cell)
  end
  c.cells = nil
  return c
end

function AddToCategory(category, item, index)
  if type(item) == "table" then
    if type(item.cells) == "table" then
      item = CatToSub(item)
    end
  end
  if type(category.cells) ~= "table" then
    return AddToSubcategory(category, item, index)
  end
  ClearOldCellbarButtons()
  if index == nil then
    table.insert(category.cells, item)
  else
    table.insert(category.cells, index, item)
  end
  RebuildCellbar()
end

function AddToSubcategory(category, item, index)
  ClearOldCellbarButtons()
  if index == nil then
    table.insert(category, item)
  else
    table.insert(category, index, item)
  end
  RebuildCellbar()
end

function CreateCategory(title, description, max, startingCells, icon)
  max = max or 4
  startingCells = startingCells or {}

  title = title or "Untitled"
  description = description or "No discription given"
  icon = icon or "mover"

  NewTex(icon, icon)

  return {
    name = title,
    desc = description,
    cells = startingCells,
    icon = icon,
    max = max,
  }
end

-- Adds to the bar
function AddRootCategory(category, index)
  ClearOldCellbarButtons()
  if index == nil then
    table.insert(lists, category)
  else
    table.insert(lists, index, category)
  end
  RebuildCellbar()
end

function GetCategory(title, category)
  category = category or {cells = lists}

  for _, cat in pairs(category.cells) do
    if type(cat) == "table" then
      if cat.name == title then
        return cat
      end
    end
  end
end

function MakeCustomIDConversion(toConvert, convertInto)
  ModStuff.idConversion[toConvert] = convertInto
end

function CreateCell(title, description, texture, options)
  local id = (#tex + 1)
  options = options or {}

  NewTex(texture, id)
  cellinfo[id] = {
    name = title or "Unnamed",
    desc = description or "No description available",
  }
  ModStuff.destroyers[id] = options.isDestroyer -- 2.-1.5
  ModStuff.idMaps[id] = options.maptoID -- 2.-1.5
  ModStuff.stopOptimization[id] = options.shouldStopOptimization -- 2.-1.5
  ModStuff.nextCells[id] = options.bendNextCells
  ModStuff.toGenerates[id] = options.transformWhenGenerated -- 2.-1.5
  ModStuff.transparent[id] = options.isTransparent -- 2.-1.5
  ModStuff.unbreakable[id] = options.unbreakability -- 2.-1.5
  ModStuff.onPlace[id] = options.whenPlaced -- 2.-1.5
  ModStuff.whenSelected[id] = options.whenSelected -- 2.-1.5
  ModStuff.nonexistant[id] = options.isNonexistant -- 2.-1.5
  ModStuff.idConversion[id] = options.convertID -- 2.-1.5
  ModStuff.custompush[id] = options.push -- 2.-1.5
  ModStuff.onSetCell[id] = options.whenSet -- 2.-1.5
  ModStuff.onCellDraw[id] = options.whenRendered -- 2.-1.5
  ModStuff.whenRotated[id] = options.whenRotated -- 2.-1.5
  ModStuff.acidic[id] = options.isAcidic -- 2.-1.5
  ModStuff.whenClicked[id] = options.whenClicked
  ModStuff.specialTypes[id] = options.specialType
  ModStuff.customprepush[id] = options.prepush

  if options.convertID ~= nil then
    ModStuff.flipmode[id] = "none"
  else
    ModStuff.flipmode[id] = options.flipmode or "none"
  end

  if type(options.update) == "function" then
    local updatemode = options.updatemode or "normal"
    local updateindex = options.updateindex
    if type(updatemode) == "table" then
      for i, func in ipairs(updatemode) do
        if type(updateindex) == "number" then
          table.insert(subticks, updateindex + i - 1, func)
        else
          table.insert(subticks, func)
        end
      end
    elseif updatemode == "normal" then
      if type(updateindex) == "number" then
        table.insert(subticks, updateindex, function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == ConvertId(id) and c.rot == 0 end, options.update, "upleft", ConvertId(id)) end)
        table.insert(subticks, updateindex + 1, function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == ConvertId(id) and c.rot == 2 end, options.update, "upright", ConvertId(id)) end)
        table.insert(subticks, updateindex + 2, function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == ConvertId(id) and c.rot == 3 end, options.update, "rightdown", ConvertId(id)) end)
        table.insert(subticks, updateindex + 3, function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == ConvertId(id) and c.rot == 1 end, options.update, "rightup", ConvertId(id)) end)
      else
        table.insert(subticks, function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == ConvertId(id) and c.rot == 0 end, options.update, "upleft", ConvertId(id)) end)
        table.insert(subticks, function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == ConvertId(id) and c.rot == 2 end, options.update, "upright", ConvertId(id)) end)
        table.insert(subticks, function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == ConvertId(id) and c.rot == 3 end, options.update, "rightdown", ConvertId(id)) end)
        table.insert(subticks, function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == ConvertId(id) and c.rot == 1 end, options.update, "rightup", ConvertId(id)) end)
      end
    elseif updatemode == "static" then
      if type(updateindex) == "number" then
        table.insert(subticks, updateindex, function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == ConvertId(id) end, options.update, "rightup", ConvertId(id)) end)
      else
        table.insert(subticks, function() return RunOn(function(c) return not c.updated and ConvertId(c.id) == ConvertId(id) end, options.update, "rightup", ConvertId(id)) end)
      end
    end
  end

  return id
end

local renderStack = {}

function InitTestMod()
  local mods = love.filesystem.getDirectoryItems("Mods")
  for _, mod in ipairs(mods) do
    require("Mods/" .. mod .. "/main")
  end

  local m = CreateCell("F u", "no", "trash", {
    specialType = "background",
  })

  AddToCategory(GetCategory("Movers"), m)
end