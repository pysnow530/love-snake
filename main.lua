__fnl_global__NODE_2dLENGTH = 15
WIDTH = 20
HEIGHT = 10
STATE = "Welcome"
__fnl_global__move_2dsound = nil
__fnl_global__eat_2dsound = nil
local Snake = {}
Snake.new = function(cls, dir, body, speed)
  local obj = setmetatable({dir = dir, body = body, speed = speed}, {__index = cls})
  return obj
end
Snake.eat = function(self, sound)
  local _let_1_ = self["body"]
  local _let_2_ = _let_1_[1]
  local head_x = _let_2_[1]
  local head_y = _let_2_[2]
  local _let_3_ = self["dir"]
  local dir_x = _let_3_[1]
  local dir_y = _let_3_[2]
  local new_x = (head_x + dir_x)
  local new_y = (head_y + dir_y)
  table.insert(self.body, 1, {new_x, new_y})
  return love.audio.play(sound)
end
Snake.move = function(self, sound)
  local _let_4_ = self["body"]
  local _let_5_ = _let_4_[1]
  local head_x = _let_5_[1]
  local head_y = _let_5_[2]
  local _let_6_ = self["dir"]
  local dir_x = _let_6_[1]
  local dir_y = _let_6_[2]
  local new_x = (head_x + dir_x)
  local new_y = (head_y + dir_y)
  table.insert(self.body, 1, {new_x, new_y})
  table.remove(self.body)
  return love.audio.play(sound)
end
Snake["turn-left"] = function(self)
  local x = self.dir[1]
  local y = self.dir[2]
  self.dir = {y, ( - x)}
  return nil
end
Snake["turn-right"] = function(self)
  local x = self.dir[1]
  local y = self.dir[2]
  self.dir = {( - y), x}
  return nil
end
local function draw_box(x, y)
  return love.graphics.rectangle("fill", (x * __fnl_global__NODE_2dLENGTH), (y * __fnl_global__NODE_2dLENGTH), __fnl_global__NODE_2dLENGTH, __fnl_global__NODE_2dLENGTH, (__fnl_global__NODE_2dLENGTH * 0.3), (__fnl_global__NODE_2dLENGTH * 0.3))
end
Snake.draw = function(self)
  for _, _7_ in ipairs(self.body) do
    local x = _7_[1]
    local y = _7_[2]
    draw_box(x, y)
  end
  return nil
end
local Apple = {}
Apple.new = function(cls, snake_body)
  local x = math.random(0, (WIDTH - 1))
  local y = math.random(0, (HEIGHT - 1))
  while true do
    local _8_
    do
      local tbl_21_ = {}
      local i_22_ = 0
      for _, _9_ in ipairs(snake_body) do
        local ix = _9_[1]
        local iy = _9_[2]
        local val_23_
        if ((ix == x) and (iy == y)) then
          val_23_ = 1
        else
          val_23_ = nil
        end
        if (nil ~= val_23_) then
          i_22_ = (i_22_ + 1)
          tbl_21_[i_22_] = val_23_
        else
        end
      end
      _8_ = tbl_21_
    end
    if not (#_8_ > 0) then break end
    x = math.random(0, (WIDTH - 1))
    y = math.random(0, (HEIGHT - 1))
  end
  return setmetatable({pos = {x, y}}, {__index = cls})
end
local snake = Snake:new({1, 0}, {{0, (HEIGHT / 2)}}, 0.5)
local apples = {}
local function all_but_last(x)
  local tbl_21_ = {}
  local i_22_ = 0
  for idx, item in ipairs(x) do
    local val_23_
    if (idx < #x) then
      val_23_ = item
    else
      val_23_ = nil
    end
    if (nil ~= val_23_) then
      i_22_ = (i_22_ + 1)
      tbl_21_[i_22_] = val_23_
    else
    end
  end
  return tbl_21_
end
local function predicate_type(_14_)
  local x = _14_[1]
  local y = _14_[2]
  local _let_15_ = apples[1]
  local _let_16_ = _let_15_["pos"]
  local apple_x = _let_16_[1]
  local apple_y = _let_16_[2]
  local body = all_but_last(snake.body)
  if ((x < 0) or (x >= WIDTH) or (y < 0) or (y >= HEIGHT)) then
    return "wall"
  else
    local _17_
    do
      local tbl_21_ = {}
      local i_22_ = 0
      for _, _18_ in ipairs(body) do
        local ix = _18_[1]
        local iy = _18_[2]
        local val_23_
        if ((ix == x) and (iy == y)) then
          val_23_ = 1
        else
          val_23_ = nil
        end
        if (nil ~= val_23_) then
          i_22_ = (i_22_ + 1)
          tbl_21_[i_22_] = val_23_
        else
        end
      end
      _17_ = tbl_21_
    end
    if (#_17_ > 0) then
      return "body"
    elseif ((x == apple_x) and (y == apple_y)) then
      return "apple"
    elseif "else" then
      return nil
    else
      return nil
    end
  end
end
local total_dt = 0
love.load = function()
  do
    local font = love.graphics.newFont(32)
    love.graphics.setFont(font)
  end
  __fnl_global__move_2dsound = love.audio.newSource("audio/move.wav", "static")
  __fnl_global__eat_2dsound = love.audio.newSource("audio/eat.wav", "static")
  return nil
end
love.keypressed = function(key, _, _0)
  if (STATE == "Welcome") then
    if (key == "j") then
      STATE = "Playing"
      return nil
    else
      return nil
    end
  elseif (STATE == "Playing") then
    if (key == "j") then
      return snake["turn-left"](snake)
    elseif (key == "k") then
      return snake["turn-right"](snake)
    else
      return nil
    end
  else
    return nil
  end
end
love.update = function(dt)
  if (STATE == "Playing") then
    if (0 == #apples) then
      table.insert(apples, Apple:new(snake.body))
    else
    end
    total_dt = (total_dt + dt)
    if (total_dt > snake.speed) then
      total_dt = (total_dt - snake.speed)
      local _let_26_ = snake["body"]
      local _let_27_ = _let_26_[1]
      local head_x = _let_27_[1]
      local head_y = _let_27_[2]
      local _let_28_ = snake["dir"]
      local dir_x = _let_28_[1]
      local dir_y = _let_28_[2]
      local new_x = (head_x + dir_x)
      local new_y = (head_y + dir_y)
      local next_pos_type = predicate_type({new_x, new_y})
      if (next_pos_type == "wall") then
        STATE = "GameOver"
        return nil
      elseif (next_pos_type == "body") then
        STATE = "GameOver"
        return nil
      elseif (next_pos_type == "apple") then
        snake:eat(__fnl_global__eat_2dsound)
        return table.remove(apples)
      elseif (next_pos_type == nil) then
        return snake:move(__fnl_global__move_2dsound)
      else
        return nil
      end
    else
      return nil
    end
  else
    return nil
  end
end
local function show_welcome()
  love.graphics.print("Welcome to snake, powered by love2d!", 100, 100)
  return love.graphics.print("Press j to start game :-p", 100, 200)
end
local function show_game_over()
  local text = "Game Over!"
  local font = love.graphics.getFont()
  local fontWidth = font:getWidth(text)
  local fontHeight = font:getHeight()
  local winWidth, winHeight = love.graphics.getDimensions()
  return love.graphics.print("Game Over!", ((winWidth / 2) - (fontWidth / 2)), ((winHeight / 2) - (fontHeight / 2)))
end
local function draw_apples()
  love.graphics.setColor(0.8, 0.2, 0.2)
  for _, _32_ in ipairs(apples) do
    local _each_33_ = _32_["pos"]
    local x = _each_33_[1]
    local y = _each_33_[2]
    draw_box(x, y)
  end
  return nil
end
local function draw_snake()
  love.graphics.setColor(0.2, 0.8, 0.2)
  return snake:draw()
end
love.draw = function()
  if (STATE == "Welcome") then
    return show_welcome()
  elseif (STATE == "Playing") then
    draw_apples()
    return draw_snake()
  elseif (STATE == "GameOver") then
    return show_game_over()
  else
    return nil
  end
end
return love.draw
