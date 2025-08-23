__fnl_global__NODE_2dLENGTH = 15
WIDTH = 20
HEIGHT = 10
local Snake = {}
Snake.new = function(cls, dir, nodes, speed)
  local obj = setmetatable({dir = dir, nodes = nodes, speed = speed}, {__index = cls})
  return obj
end
Snake.draw = function(self, rect)
  for _, _1_ in ipairs(self.nodes) do
    local x = _1_[1]
    local y = _1_[2]
    rect("fill", (x * __fnl_global__NODE_2dLENGTH), (y * __fnl_global__NODE_2dLENGTH), __fnl_global__NODE_2dLENGTH, __fnl_global__NODE_2dLENGTH)
  end
  return nil
end
local snake = Snake:new({1, 0}, {{0, (HEIGHT / 2)}}, 2)
love.update = function(delta)
  do
    local tbl_21_ = {}
    local i_22_ = 0
    for _, _2_ in ipairs(snake.nodes) do
      local x = _2_[1]
      local y = _2_[2]
      local val_23_ = {(x + (snake.dir[1] * snake.speed * delta)), (y + (snake.dir[2] * snake.speed * delta))}
      if (nil ~= val_23_) then
        i_22_ = (i_22_ + 1)
        tbl_21_[i_22_] = val_23_
      else
      end
    end
    snake.nodes = tbl_21_
  end
  return nil
end
love.draw = function()
  return snake:draw(love.graphics.rectangle)
end
return love.draw
