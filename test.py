a=b=1
while a < 2**31:
    print(a)
    a, b = b, a+b