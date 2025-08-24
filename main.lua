__fnl_global__NODE_2dLENGTH = 15
WIDTH = 20
HEIGHT = 10
local Snake = {}
Snake.new = function(cls, dir, nodes, speed)
  local obj = setmetatable({dir = dir, nodes = nodes, speed = speed}, {__index = cls})
  return obj
end
Snake.move = function(self, delta)
  do
    local tbl_21_ = {}
    local i_22_ = 0
    for _, _1_ in ipairs(self.nodes) do
      local x = _1_[1]
      local y = _1_[2]
      local val_23_ = {(x + (self.dir[1] * self.speed * delta)), (y + (self.dir[2] * self.speed * delta))}
      if (nil ~= val_23_) then
        i_22_ = (i_22_ + 1)
        tbl_21_[i_22_] = val_23_
      else
      end
    end
    self.nodes = tbl_21_
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
  for _, _3_ in ipairs(self.nodes) do
    local x = _3_[1]
    local y = _3_[2]
    rect("fill", (x * __fnl_global__NODE_2dLENGTH), (y * __fnl_global__NODE_2dLENGTH), __fnl_global__NODE_2dLENGTH, __fnl_global__NODE_2dLENGTH)
  end
  return nil
end
local snake = Snake:new({1, 0}, {{0, (HEIGHT / 2)}}, 2)
love.keypressed = function(key, scancode, isrepeat)
  if (key == "j") then
    return snake["turn-left"](snake)
  elseif (key == "k") then
    return snake["turn-right"](snake)
  else
    return nil
  end
end
love.update = function(delta)
  return snake:move(delta)
end
love.draw = function()
  return snake:draw(love.graphics.rectangle)
end
return love.draw
