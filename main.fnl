(global NODE-LENGTH 15)
(global WIDTH 20)
(global HEIGHT 10)

;;;;;;;;;;;;;;;;;;;;;;;;;;; snake ;;;;;;;;;;;;;;;;;;;;;;;;;;;
(local Snake {})

(fn Snake.new [cls dir body speed]
    (local obj (setmetatable
                 {: dir : body : speed}
                 {:__index cls}))
    obj)

(fn Snake.move [self dt]
    (set self.body
         (icollect [_ [x y] (ipairs self.body)]
                   [(+ x (* (. self.dir 1) self.speed dt))
                    (+ y (* (. self.dir 2) self.speed dt))])))

(fn Snake.turn-left [self]
    (let [[x y] self.dir]
      (set self.dir [y (- x)])))

(fn Snake.turn-right [self]
    (let [[x y] self.dir]
      (set self.dir [(- y) x])))

(fn Snake.draw [self rect]
    (each [_ [x y] (ipairs self.body)]
          (rect :fill
                (* x NODE-LENGTH) (* y NODE-LENGTH)
                NODE-LENGTH NODE-LENGTH)))
;;;;;;;;;;;;;;;;;;;;;;;;;;; /snake ;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;; apple ;;;;;;;;;;;;;;;;;;;;;;;;;;;
(local Apple {})

(fn Apple.new [cls snake-body]
    (var x (math.random 0 (- WIDTH 1)))
    (var y (math.random 0 (- HEIGHT 1)))
    (while (>
            (length (icollect [_ [ix iy] (ipairs snake-body)]
                              (if (and (= ix x) (= iy y))
                                1)))
            0)
           (set x (math.random 0 (- WIDTH 1)))
           (set y (math.random 0 (- HEIGHT 1))))
    (setmetatable {:pos [x y]} {:__index cls}))
;;;;;;;;;;;;;;;;;;;;;;;;;;; /apple ;;;;;;;;;;;;;;;;;;;;;;;;;;;

(local snake (Snake:new [1 0] [[0 (/ HEIGHT 2)]] 2))

(local apples [])

(fn love.keypressed [key scancode isrepeat]
    (match key
           :j (snake:turn-left)
           :k (snake:turn-right)))

(fn love.update [dt]
    (if (= 0 (length apples)) (table.insert apples (Apple:new snake.body)))
    (snake:move dt))

(fn love.draw []
    (love.graphics.setColor 0.8 0.2 0.2)
    (each [_ {:pos [x y]} (ipairs apples)]
          (love.graphics.rectangle :fill
                                   (* x NODE-LENGTH) (* y NODE-LENGTH)
                                   NODE-LENGTH NODE-LENGTH))
    (love.graphics.setColor 0.2 0.8 0.2)
    (snake:draw love.graphics.rectangle))
