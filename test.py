def deco(func):
    def wrapper(*args):
        print('--start--')
        func(*args)
        print('--end--')
    return wrapper

@deco
def test():
    print('Hello Decorator')

test()