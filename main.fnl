(global NODE-LENGTH 15)
(global WIDTH 20)
(global HEIGHT 10)

(global STATE nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;; snake ;;;;;;;;;;;;;;;;;;;;;;;;;;;
(local Snake {})

(fn Snake.new [cls dir body speed]
    (local obj (setmetatable
                 {: dir : body : speed}
                 {:__index cls}))
    obj)

(fn Snake.eat [self]
    (let [{:body [[head-x head-y]] :dir [dir-x dir-y]} self
          new-x (+ head-x dir-x)
          new-y (+ head-y dir-y)]
      (table.insert self.body 1 [new-x new-y])))

(fn Snake.move [self]
    (let [{:body [[head-x head-y]] :dir [dir-x dir-y]} self
          new-x (+ head-x dir-x)
          new-y (+ head-y dir-y)]
      (table.insert self.body 1 [new-x new-y])
      (table.remove self.body)))

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

(local snake (Snake:new [1 0] [[0 (/ HEIGHT 2)]] 0.5))
(local apples [])

(fn all-but-last [x]
    (icollect [idx item (ipairs x)]
              (if (< idx (length x))
                item)))

(fn predicate-type [[x y]]
    (let [[{:pos [apple-x apple-y]}] apples
          body (all-but-last snake.body)]
      (if (or (< x 0)
              (>= x WIDTH)
              (< y 0)
              (>= y HEIGHT)) :wall
        (> (length (icollect [_ [ix iy] (ipairs body)] (if (and (= ix x) (= iy y)) 1))) 0) :body
        (and (= x apple-x) (= y apple-y)) :apple
        :else nil)))

(var total-dt 0)

(fn love.keypressed [key scancode isrepeat]
    (match key
           :j (snake:turn-left)
           :k (snake:turn-right)))

(fn love.update [dt]
    (set total-dt (+ total-dt dt))
    (if (= 0 (length apples)) (table.insert apples (Apple:new snake.body)))
    (if (> total-dt snake.speed)
      (do
        (set total-dt (- total-dt snake.speed))
        (let [{:body [[head-x head-y]] :dir [dir-x dir-y]} snake
              new-x (+ head-x dir-x)
              new-y (+ head-y dir-y)
              type (predicate-type [new-x new-y])]
          (match type
                 :wall (set STATE :GameOver)
                 :body (set STATE :GameOver)
                 :apple (do (snake:eat) (table.remove apples))
                 nil (snake:move)))))
    (if (= STATE :GameOver)
      (love.graphics.print "Game Over" 100 100)))

(fn love.draw []
    (love.graphics.setColor 0.8 0.2 0.2)
    (each [_ {:pos [x y]} (ipairs apples)]
          (love.graphics.rectangle :fill
                                   (* x NODE-LENGTH) (* y NODE-LENGTH)
                                   NODE-LENGTH NODE-LENGTH))
    (love.graphics.setColor 0.2 0.8 0.2)
    (snake:draw love.graphics.rectangle))
