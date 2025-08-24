__fnl_global__NODE_2dLENGTH = 15
WIDTH = 20
HEIGHT = 10
local Snake = {}
Snake.new = function(cls, dir, body, speed)
  local obj = setmetatable({dir = dir, body = body, speed = speed}, {__index = cls})
  return obj
end
Snake.move = function(self, dt)
  do
    local tbl_21_ = {}
    local i_22_ = 0
    for _, _1_ in ipairs(self.body) do
      local x = _1_[1]
      local y = _1_[2]
      local val_23_ = {(x + (self.dir[1] * self.speed * dt)), (y + (self.dir[2] * self.speed * dt))}
      if (nil ~= val_23_) then
        i_22_ = (i_22_ + 1)
        tbl_21_[i_22_] = val_23_
      else
      end
    end
    self.body = tbl_21_
  end
  return nil
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
Snake.draw = function(self, rect)
  for _, _3_ in ipairs(self.body) do
    local x = _3_[1]
    local y = _3_[2]
    rect("fill", (x * __fnl_global__NODE_2dLENGTH), (y * __fnl_global__NODE_2dLENGTH), __fnl_global__NODE_2dLENGTH, __fnl_global__NODE_2dLENGTH)
  end
  return nil
end
local Apple = {}
Apple.new = function(cls, snake_body)
  local x = math.random(0, (WIDTH - 1))
  local y = math.random(0, (HEIGHT - 1))
  while true do
    local _4_
    do
      local tbl_21_ = {}
      local i_22_ = 0
      for _, _5_ in ipairs(snake_body) do
        local ix = _5_[1]
        local iy = _5_[2]
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
      _4_ = tbl_21_
    end
    if not (#_4_ > 0) then break end
    x = math.random(0, (WIDTH - 1))
    y = math.random(0, (HEIGHT - 1))
  end
  return setmetatable({pos = {x, y}}, {__index = cls})
end
local snake = Snake:new({1, 0}, {{0, (HEIGHT / 2)}}, 2)
local apples = {}
love.keypressed = function(key, scancode, isrepeat)
  if (key == "j") then
    return snake["turn-left"](snake)
  elseif (key == "k") then
    return snake["turn-right"](snake)
  else
    return nil
  end
end
love.update = function(dt)
  if (0 == #apples) then
    table.insert(apples, Apple:new(snake.body))
  else
  end
  return snake:move(dt)
end
love.draw = function()
  for _, _10_ in ipairs(apples) do
    local _each_11_ = _10_["pos"]
    local x = _each_11_[1]
    local y = _each_11_[2]
    love.graphics.rectangle("fill", (x * __fnl_global__NODE_2dLENGTH), (y * __fnl_global__NODE_2dLENGTH), __fnl_global__NODE_2dLENGTH, __fnl_global__NODE_2dLENGTH)
  end
  return snake:draw(love.graphics.rectangle)
end
return love.draw
