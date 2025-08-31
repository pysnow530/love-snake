__fnl_global__NODE_2dLENGTH = 20
__fnl_global__CORNER_2dLENGTH = (__fnl_global__NODE_2dLENGTH * 0.3)
__fnl_global__SPEED_2dGAP_2dMAX = 0.5
__fnl_global__SPEED_2dGAP_2dMIN = 0.25
__fnl_global__FULL_2dSPEED_2dLENGTH = 20
__fnl_global__margin_2dleft = 1
__fnl_global__margin_2dtop = 1
__fnl_global__margin_2dright = 1
__fnl_global__margin_2dbottom = 1
__fnl_global__play_2dwidth = 20
__fnl_global__play_2dheight = 20
__fnl_global__board_2dwidth = 10
__fnl_global__board_2dheight = 20
local function sum(...)
  local total = 0
  for _, v in ipairs({...}) do
    total = (total + v)
  end
  return total
end
local function _24(...)
  return (__fnl_global__NODE_2dLENGTH * sum(...))
end
local win_width = _24(__fnl_global__margin_2dleft, __fnl_global__play_2dwidth, 1, __fnl_global__board_2dwidth, 1)
local win_height = _24(__fnl_global__margin_2dtop, __fnl_global__play_2dheight, __fnl_global__margin_2dbottom)
local function clamp(x, min, max)
  if (x < min) then
    return min
  elseif (x > max) then
    return max
  else
    return x
  end
end
local function speed(len)
  local y = (__fnl_global__SPEED_2dGAP_2dMAX - (((__fnl_global__SPEED_2dGAP_2dMAX - __fnl_global__SPEED_2dGAP_2dMIN) * len) / __fnl_global__FULL_2dSPEED_2dLENGTH))
  return clamp(y, __fnl_global__SPEED_2dGAP_2dMIN, __fnl_global__SPEED_2dGAP_2dMAX)
end
STATE = "Welcome"
__fnl_global__move_2dsound = nil
__fnl_global__move2_2dsound = nil
__fnl_global__eat_2dsound = nil
__fnl_global__gg_2dsound = nil
__fnl_global__move_2dcount = 0
DIRS = {up = {0, -1}, right = {1, 0}, down = {0, 1}, left = {-1, 0}}
local function lst_3d(lst1, lst2)
  local and_2_ = (#lst1 == #lst2)
  if and_2_ then
    local _3_
    do
      local tbl_21_ = {}
      local i_22_ = 0
      for k, v in ipairs(lst1) do
        local val_23_
        if (lst2[k] == v) then
          val_23_ = true
        else
          val_23_ = nil
        end
        if (nil ~= val_23_) then
          i_22_ = (i_22_ + 1)
          tbl_21_[i_22_] = val_23_
        else
        end
      end
      _3_ = tbl_21_
    end
    and_2_ = (#lst1 == #_3_)
  end
  return and_2_
end
local function _in(x, lst)
  local eq
  if (type(x) == "table") then
    eq = lst_3d
  else
    local function _6_(x0, y)
      return (x0 == y)
    end
    eq = _6_
  end
  local _8_
  do
    local tbl_21_ = {}
    local i_22_ = 0
    for _, v in ipairs(lst) do
      local val_23_
      if eq(x, v) then
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
  return (#_8_ > 0)
end
local Snake = {}
Snake.new = function(cls, dir, body, speed0)
  local obj = setmetatable({dir = dir, body = body, speed = speed0, ["new-dir"] = dir}, {__index = cls})
  return obj
end
Snake.eat = function(self, sound)
  self.dir = self["new-dir"]
  local _let_11_ = self["body"]
  local _let_12_ = _let_11_[1]
  local head_x = _let_12_[1]
  local head_y = _let_12_[2]
  local _let_13_ = self["dir"]
  local dir_x = _let_13_[1]
  local dir_y = _let_13_[2]
  local new_x = (head_x + dir_x)
  local new_y = (head_y + dir_y)
  table.insert(self.body, 1, {new_x, new_y})
  self.speed = speed(#self.body)
  return love.audio.play(sound)
end
Snake.move = function(self, sound)
  self.dir = self["new-dir"]
  local _let_14_ = self["body"]
  local _let_15_ = _let_14_[1]
  local head_x = _let_15_[1]
  local head_y = _let_15_[2]
  local _let_16_ = self["dir"]
  local dir_x = _let_16_[1]
  local dir_y = _let_16_[2]
  local new_x = (head_x + dir_x)
  local new_y = (head_y + dir_y)
  table.insert(self.body, 1, {new_x, new_y})
  table.remove(self.body)
  return love.audio.play(sound)
end
Snake["turn-left"] = function(self)
  local x = self.dir[1]
  local y = self.dir[2]
  self["new-dir"] = {y, ( - x)}
  return nil
end
Snake["turn-right"] = function(self)
  local x = self.dir[1]
  local y = self.dir[2]
  self["new-dir"] = {( - y), x}
  return nil
end
local function draw_box(x, y)
  return love.graphics.rectangle("fill", ((x * __fnl_global__NODE_2dLENGTH) + _24(__fnl_global__margin_2dleft)), ((y * __fnl_global__NODE_2dLENGTH) + _24(__fnl_global__margin_2dtop)), __fnl_global__NODE_2dLENGTH, __fnl_global__NODE_2dLENGTH, __fnl_global__CORNER_2dLENGTH, __fnl_global__CORNER_2dLENGTH)
end
Snake.draw = function(self)
  for _, _17_ in ipairs(self.body) do
    local x = _17_[1]
    local y = _17_[2]
    draw_box(x, y)
  end
  return nil
end
local Apple = {}
Apple.new = function(cls, snake_body)
  local x = math.random(0, (__fnl_global__play_2dwidth - 1))
  local y = math.random(0, (__fnl_global__play_2dheight - 1))
  while true do
    local _18_
    do
      local tbl_21_ = {}
      local i_22_ = 0
      for _, _19_ in ipairs(snake_body) do
        local ix = _19_[1]
        local iy = _19_[2]
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
      _18_ = tbl_21_
    end
    if not (#_18_ > 0) then break end
    x = math.random(0, (__fnl_global__play_2dwidth - 1))
    y = math.random(0, (__fnl_global__play_2dheight - 1))
  end
  return setmetatable({pos = {x, y}}, {__index = cls})
end
local snake = Snake:new({1, 0}, {{0, (__fnl_global__play_2dheight / 2)}}, __fnl_global__SPEED_2dGAP_2dMAX)
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
local function predicate_type(_24_)
  local x = _24_[1]
  local y = _24_[2]
  local _let_25_ = apples[1]
  local _let_26_ = _let_25_["pos"]
  local apple_x = _let_26_[1]
  local apple_y = _let_26_[2]
  local body = all_but_last(snake.body)
  if ((x < 0) or (x >= __fnl_global__play_2dwidth) or (y < 0) or (y >= __fnl_global__play_2dheight)) then
    return "wall"
  else
    local _27_
    do
      local tbl_21_ = {}
      local i_22_ = 0
      for _, _28_ in ipairs(body) do
        local ix = _28_[1]
        local iy = _28_[2]
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
      _27_ = tbl_21_
    end
    if (#_27_ > 0) then
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
  love.window.setMode(win_width, win_height)
  __fnl_global__move_2dsound = love.audio.newSource("audio/move.wav", "static")
  __fnl_global__move2_2dsound = love.audio.newSource("audio/move2.wav", "static")
  __fnl_global__eat_2dsound = love.audio.newSource("audio/eat.wav", "static")
  __fnl_global__gg_2dsound = love.audio.newSource("audio/gg.wav", "static")
  return nil
end
love.keypressed = function(key, _, _0)
  local up = DIRS["up"]
  local right = DIRS["right"]
  local down = DIRS["down"]
  local left = DIRS["left"]
  local dir = snake["dir"]
  if (STATE == "Welcome") then
    if (key == "space") then
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
    elseif (key == "up") then
      if _in(dir, {left, up, right}) then
        snake["new-dir"] = up
        return nil
      else
        return nil
      end
    elseif (key == "right") then
      if _in(dir, {up, right, down}) then
        snake["new-dir"] = right
        return nil
      else
        return nil
      end
    elseif (key == "down") then
      if _in(dir, {right, down, left}) then
        snake["new-dir"] = down
        return nil
      else
        return nil
      end
    elseif (key == "left") then
      if _in(dir, {down, left, up}) then
        snake["new-dir"] = left
        return nil
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
love.update = function(dt)
  if (STATE == "Playing") then
    if (0 == #apples) then
      table.insert(apples, Apple:new(snake.body))
    else
    end
    total_dt = (total_dt + dt)
    if (total_dt > snake.speed) then
      total_dt = (total_dt - snake.speed)
      local _let_40_ = snake["body"]
      local _let_41_ = _let_40_[1]
      local head_x = _let_41_[1]
      local head_y = _let_41_[2]
      local _let_42_ = snake["new-dir"]
      local new_dir_x = _let_42_[1]
      local new_dir_y = _let_42_[2]
      local new_x = (head_x + new_dir_x)
      local new_y = (head_y + new_dir_y)
      local next_pos_type = predicate_type({new_x, new_y})
      if (next_pos_type == "wall") then
        love.audio.play(__fnl_global__gg_2dsound)
        STATE = "GameOver"
        return nil
      elseif (next_pos_type == "body") then
        love.audio.play(__fnl_global__gg_2dsound)
        STATE = "GameOver"
        return nil
      elseif (next_pos_type == "apple") then
        __fnl_global__move_2dcount = (__fnl_global__move_2dcount + 1)
        snake:eat(__fnl_global__eat_2dsound)
        return table.remove(apples)
      elseif (next_pos_type == nil) then
        __fnl_global__move_2dcount = (__fnl_global__move_2dcount + 1)
        local function _43_()
          if (0 == (__fnl_global__move_2dcount % 4)) then
            return __fnl_global__move2_2dsound
          else
            return __fnl_global__move_2dsound
          end
        end
        return snake:move(_43_())
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
local function print_text(str, x, y, h_mode, v_mode, size, _47_)
  local r = _47_[1]
  local g = _47_[2]
  local b = _47_[3]
  local a = _47_[4]
  local font = love.graphics.newFont(size)
  local width = font:getWidth(str)
  local height = font:getHeight(str)
  local new_x
  if (h_mode == "left") then
    new_x = x
  elseif (h_mode == "center") then
    new_x = (x - (width * 0.5))
  else
    new_x = nil
  end
  local new_y
  if (v_mode == "top") then
    new_y = y
  elseif (v_mode == "middle") then
    new_y = (y - (height * 0.5))
  else
    new_y = nil
  end
  love.graphics.setColor(r, g, b, a)
  love.graphics.setFont(font)
  return love.graphics.print(str, new_x, new_y)
end
local function show_welcome()
  local size = 18
  local color = {0.8, 0.8, 0.8, 1}
  local line_space = 0.4
  print_text("Welcome to snake, powered by love2d!", (win_width * 0.5), ((win_height * 0.5) - (size * 0.5) - (size * line_space * 0.5)), "center", "middle", size, color)
  return print_text("Press <<<SPACE>>> to start game", (win_width * 0.5), ((win_height * 0.5) + (size * 0.5) + (size * line_space * 0.5)), "center", "middle", size, color)
end
local function show_game_over()
  return print_text("Game Over!", (win_width * 0.5), (win_height * 0.5), "center", "middle", 18, {0.8, 0.2, 0.2, 1})
end
local function draw_grid()
  love.graphics.setColor(0.4, 0.4, 0.4)
  love.graphics.rectangle("line", _24(__fnl_global__margin_2dleft), _24(__fnl_global__margin_2dtop), _24(__fnl_global__play_2dwidth), _24(__fnl_global__play_2dheight), __fnl_global__CORNER_2dLENGTH, __fnl_global__CORNER_2dLENGTH)
  for x = 1, (__fnl_global__play_2dwidth - 1) do
    for y = 1, (__fnl_global__play_2dheight - 1) do
      love.graphics.points(_24(x, __fnl_global__margin_2dleft), _24(y, __fnl_global__margin_2dtop))
    end
  end
  return nil
end
local function draw_apples()
  love.graphics.setColor(0.8, 0.2, 0.2)
  for _, _50_ in ipairs(apples) do
    local _each_51_ = _50_["pos"]
    local x = _each_51_[1]
    local y = _each_51_[2]
    draw_box(x, y)
  end
  return nil
end
local function draw_snake()
  love.graphics.setColor(0.2, 0.8, 0.2)
  return snake:draw()
end
local function draw_board()
  love.graphics.setColor(0.4, 0.4, 0.4)
  return love.graphics.rectangle("line", _24(__fnl_global__margin_2dleft, 1, __fnl_global__play_2dwidth), _24(__fnl_global__margin_2dtop), _24(__fnl_global__board_2dwidth), _24(__fnl_global__board_2dheight), __fnl_global__CORNER_2dLENGTH, __fnl_global__CORNER_2dLENGTH)
end
love.draw = function()
  print_text(("fps: " .. love.timer.getFPS()), 0, 0, "left", "top", 14, {0.8, 0.8, 0.8, 1})
  if (STATE == "Welcome") then
    return show_welcome()
  elseif (STATE == "Playing") then
    draw_grid()
    draw_apples()
    draw_snake()
    return draw_board()
  elseif (STATE == "GameOver") then
    return show_game_over()
  else
    return nil
  end
end
return love.draw
