(global NODE-LENGTH 15)
(global WIDTH 20)
(global HEIGHT 10)

(local Snake {})

(fn Snake.new [cls dir nodes speed]
    (local obj (setmetatable
                 {: dir : nodes : speed}
                 {:__index cls}))
    obj)

(fn Snake.draw [self rect]
    (each [_ [x y] (ipairs self.nodes)]
          (rect :fill
                                   (* x NODE-LENGTH) (* y NODE-LENGTH)
                                   NODE-LENGTH NODE-LENGTH)))

(local snake (Snake:new [1 0] [[0 (/ HEIGHT 2)]] 2))

(fn love.update [delta]
    (set snake.nodes
         (icollect [_ [x y] (ipairs snake.nodes)]
                     [(+ x (* (. snake.dir 1) snake.speed delta))
                      (+ y (* (. snake.dir 2) snake.speed delta))])))

(fn love.draw []
    (snake:draw love.graphics.rectangle))
