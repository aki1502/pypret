def f(x):
    def g(y):
        return x*y
    return g

print(f(5)(2))



def mydecolater(func):        # デコレータを定義する
    def wrapper():
        print("start")         # 前処理を実行する
        func()                # デコレート対象の関数を実行する
        print("end")           # 後処理を実行する
    return wrapper

@mydecolater
def hello():
    print("hello")

hello()  