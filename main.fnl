(global NODE-LENGTH 15)
(global WIDTH 20)
(global HEIGHT 10)

(local Snake {})

(fn Snake.new [cls dir nodes speed]
    (local obj (setmetatable
                 {: dir : nodes : speed}
                 {:__index cls}))
    obj)

(fn Snake.move [self delta]
    (set self.nodes
         (icollect [_ [x y] (ipairs self.nodes)]
                   [(+ x (* (. self.dir 1) self.speed delta))
                    (+ y (* (. self.dir 2) self.speed delta))])))

(fn Snake.turn-left [self]
    (let [[x y] self.dir]
      (set self.dir [y (- x)])))

(fn Snake.turn-right [self]
    (let [[x y] self.dir]
      (set self.dir [(- y) x])))

(fn Snake.draw [self rect]
    (each [_ [x y] (ipairs self.nodes)]
          (rect :fill
                (* x NODE-LENGTH) (* y NODE-LENGTH)
                NODE-LENGTH NODE-LENGTH)))

(local snake (Snake:new [1 0] [[0 (/ HEIGHT 2)]] 2))

(fn love.keypressed [key scancode isrepeat]
    (match key
           :j (snake:turn-left)
           :k (snake:turn-right)))

(fn love.update [delta]
    (snake:move delta))

(fn love.draw []
    (snake:draw love.graphics.rectangle))
