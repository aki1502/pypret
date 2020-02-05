NullValues = [0, 0.0, [], {}, "", false, nil]

def func(x)
    !NullValues.include?(x) ? func(x-1) : 0
end

p func(5)