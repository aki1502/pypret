p = lambda {|x, y=5| p x, y}

p.call(*[1, 2])
p.call([1, 2])
p.call(*[[1, 2]])