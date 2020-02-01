x = 1
def func(a, b, c):
    print(a*b*c)
    x = 2
    def funk(d, e, f):
        print(a*b*c+d*e*f)
        x = 3
        print(x)
    funk(4, 5, 6)
    print(x)
func(1, 2, 3)
print(x)

y = 0
def punc():
    print(y)
y = 1
punc()
y = 2
punc()