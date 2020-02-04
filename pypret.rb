=begin

所属:     総合人間学部3回生
氏名:     
学生番号:  

概要: Pythonの翻訳機
操作法: ruby pypret.rb [Pythonの文法で書かれたプレーンテキスト]
動機: 似た課題を提出しそこねたため。
アピールポイント: 手間が掛かっている。
自己評価: 99点
改良すべき点: 下記のとおり機能に制限があるため、本物に寄せたい。
注意点: import文,raise文,try文,class文,yield文,async文,with文,
　　　　global文,nonlocal文には対応していません。
　　　　複素数に対応していません。
　　　　tuple,set,frozensetに対応していません。
　　　　"""hoge""", '''fuga'''に対応していません。
　　　　関数以外の属性参照、書き込みに対応していません。
　　　　イテレータとそうでないものをごっちゃにしています。
　　　　pythonの文としてエラーが生じる場合には対応していません。
　　　　classmethodに対応していません。
　　　　可変長引数、キーワード引数、デフォルト引数に対応していません。
　　　　組み込み関数ではascii,breakpoint,bytearray,bytes,
　　　　callable,classmethod,compile,complex,delattr,dir,eval,
　　　　exec,format,frozenset,getattr,globals,hasattr,help,id,
　　　　isinstance,issubclass,iter,locals,
　　　　memoryview,next,object,open,property,repr,set,setattr,
　　　　slice,staticmethod,super,tuple,type,varsには対応していません。
　　　　複数の記法に対応した関数ではそのうち一つしか使用できません。
　　　　組み込み定数ではNotImplementedと...(Ellipsis)には対応していません。
　　　　インデントは4字固定です。
　　　　その他バグ、実装漏れはいくらでもあると思われます、予めご了承下さい。
=end

require "securerandom"


filename = ARGV.shift


NullValues = [0, 0.0, [], {}, "", false, nil]

DefaultKey = lambda {|x| x}

BuiltinFunctions = {
    abs: lambda {|x| x.abs()},
    all: lambda {|x| (x.map() {|y| !NullValues.include?(y)}).all?()},
    any: lambda {|x| (x.map() {|y| !NullValues.include?(y)}).any?()},
    bin: lambda {|x| Pystr.new(x>=0 ? "0b"+x.to_s(2) : "-0b"+-x.to_s(2))},
    bool: lambda {|x=false| !NullValues.include?(x)},
    chr: lambda {|x| Pystr.new(x.chr())},
    dict: lambda {|**kwargs| kwargs},
    divmod: lambda {|x, a| x.divmod(a)},
    enumerate: lambda {|x, start:0| (start...start+x.length()).zip(x)},
    filter: lambda {|func, iter| iter.find_all() {|x| func.call(x)}},
    float: lambda {|x=0.0| x.to_f()},
    hash: lambda {|x| x.hash()},
    hex: lambda {|x| Pystr.new(x>=0 ? "0x"+x.to_s(16) : "-0x"+-x.to_s(16))},
    input: lambda {|x=""| print(x); Pystr.new(gets().chomp())},
    int: lambda {|x=0| x.to_i()},
    len: lambda {|x| x.length()},
    list: lambda {|x=[]| x.to_a()},
    map: lambda {|func, *iters| iters.transpose().map() {|x| func.call(*x)}},
    max: lambda {|*x, key:DefaultKey, default:nil| x = x[0] if x[0].is_a?(Array); (default ? x+[default] : x).max_by(&key)},
    min: lambda {|*x, key:DefaultKey, default:nil| x = x[0] if x[0].is_a?(Array); (default ? x+[default] : x).min_by(&key)},
    oct: lambda {|x| Pystr.new(x>=0 ? "0o"+x.to_s(8) : "-0o"+-x.to_s(8))},
    ord: lambda {|x| x.ord()},
    pow: lambda {|base, exp, mod=nil| base.pow(exp, modulo=mod)},
    print: lambda {|*o| print(o.map(&:to_s).join(" ")+"\n")},
    range: lambda {|*s| (case s.length() when 1; 0...s[0] when 2; s[0]...s[1] else (s[0]...s[1]).step(s[2]) end).to_a()},
    reversed: lambda {|x| x.reverse()},
    round: lambda {|x| x.round()},
    sorted: lambda {|x| x.sort()},
    str: lambda {|x=""| Pystr.new(x)},
    sum: lambda {|*x, init:0| x.sum(init)},
    zip: lambda {|*x| l = x.map(&:length).min(); (x.map() {|y| y.take(l)}).transpose()},
}

BuiltinConstants = {
    False: false,
    True: true,
    None: nil,
}


$gd = BuiltinFunctions.merge(BuiltinConstants)
$gd[:Integer] = {
    as_integer_ratio: lambda {[where($address)[$name], 1]},
    bit_length: lambda {|x| where($address)[$name].bit_length()},
    from_bytes: nil, # 使えません
    to_bytes: nil, # 使えません
}
$gd[:Float] = {
    as_integer_ratio: lambda {f = where($address)[$name]; [f.numerator(), f.denominator()]},
    fromhex: nil, # 使えません
    hex: lambda {x=where($address)[$name]; x>=0 ? "0x"+x.to_s(16) : "-0x"+-x.to_s(16)},
    is_integer: lambda {f = where($address)[$name]; f == f.to_i()},
}
$gd[:Array] = {
    append: lambda {|x| where($address)[$name] <<= x},
    clear: lambda {where($address)[$name] = []},
    copy: lambda {where($address)[$name].clone()},
    count: lambda {|x| where($address)[$name].count(x)},
    extend: lambda {|t| where($address)[$name] += t},
    index: lambda {|x| i = where($address)[$name].index()},
    insert: lambda {|i, x| where($address)[$name][i, 0] = [x]},
    pop: lambda {|i=-1| w = where($address); n = w[$name]; a = n.slice!(i); w[$name] = n; a},
    remove: lambda {|x| w = where($address); n = w[$name]; i = n.index(x); n.slice!(i); w[$name] = n},
    reverse: lambda {w = where($address); w[$name] = w[$name].reverse()},
    sort: lambda {|x=DefaultKey| w = where($address); w[$name] = w[$name].sort_by(&x).to_a()},
}
$gd[:Pystr] = {
    capitalize: lambda {Pystr.new(where($address)[$name].to_s().capitalize())},
    casefold: lambda {Pystr.new(where($address)[$name].to_s().downcase(:fold))},
    center: lambda {|width, fillchar=" "| Pystr.new(where($address)[$name].to_s().center(width, fillchar.to_s()))},
    count: lambda {|sub| where($address)[$name].to_s().scan(sub.to_s()).length()},
    encode: nil, # 使えません
    endswith: lambda {|suffix| where($address)[$name].to_s().end_with?(suffix.to_s())},
    expandtabs: nil, # 使えません
    find: lambda {|sub| where($address)[$name].to_s().index(sub.to_s())},
    format: nil, # 使えません
    format_map: nil, # 使えません
    index: lambda {|sub| a = where($address)[$name].to_s().index(sub.to_s()) ? a : (raise ValueError.new("inappropriate value"))},
    isalnum: lambda {where($address)[$name].to_s().match?(/^\w+$/)},
    isalpha: lambda {where($address)[$name].to_s().match?(/^[A-Za-z]+$/)},
    isascii: lambda {where($address)[$name].to_s().ascii_only?()},
    isdecimal: lambda {where($address)[$name].to_s().match?(/^\d+$/)},
    isdigit: nil, # 使えません
    isidentidier: lambda {where($address)[$name].to_s().match?(/^[A-Za-z_][\w]*$/)},
    islower: lambda {where($address)[$name].to_s().match?(/^[a-z]+$/)},
    isprintable: nil, # 使えません
    isspace: lambda {where($address)[$name].to_s().match?(/^\s+$/)},
    istitle: lambda {(where($address)[$name].to_s().split().map() {|w| w.match?(/^[A-Z]/)}).all?},
    isupper: lambda {where($address)[$name].to_s().match?(/^[A-Z]+$/)},
    join: lambda {|iterable| iterable.join(where($address)[$name])},
    ljust: lambda {|width, padding=" "| Pystr.new(where($address)[$name].to_s().ljust(width, padding.to_s()))},
    lower: lambda {Pystr.new(where($address)[$name].to_s().downcase())},
    lstrip: lambda {Pystr.new(where($address)[$name].to_s().lstrip())},
    maketrans: nil, # 使えません
    partition: lambda {|sep| where($address)[$name].to_s().partition(sep.to_s()).map() {|s| Pystr.new(s)}},
    replace: lambda {|old, new| Pystr.new(where($address)[$name].to_s().gsub(old.to_s(), new.to_s()))},
    rfind: lambda {|sub| where($address)[$name].to_s().rindex(sub.to_s())},
    rindex: lambda {|sub| a = where($address)[$name].to_s().rindex(sub.to_s()) ? a : (raise ValueError.new("inappropriate value"))},
    rjust: lambda {|width, padding=" "| Pystr.new(where($address)[$name].to_s().rjust(width, padding.to_s()))},
    rpartition: lambda {|sep| where($address)[$name].to_s().rpartition(sep.to_s()).map() {|s| Pystr.new(s)}},
    rsplit: nil, # 使えません
    rstrip: lambda {Pystr.new(where($address)[$name].to_s().rstrip())},
    split: lambda {|sep=" ", maxsplit=0| where($address)[$name].to_s().split(sep.to_s(), maxsplit).map() {|x| Pystr.new(x)}},
    splitlines: lambda {|keepends=false| where($address)[$name].to_s().split(/[\n\r\v\f\x1c\x1d\x1e]/).map() {|x| Pystr.new(x)}},
    startswith: lambda {|prefix| where($address)[$name].to_s().start_with?(prefix)},
    strip: lambda {Pystr.new(where($address)[$name].to_s().strip())},
    swapcase: lambda {Pystr.new(where($address)[$name].to_s().swapcase())},
    title: nil, # 使えません
    translate: nil, # 使えません
    upper: lambda {Pystr.new(where($address)[$name].to_s().upcase())},
    zfill: nil # 使えません
}
$gd[:Hash] = {
    clear: lambda {where($address)[$name] = {}},
    copy: lambda {where($address)[$name].clone()},
    fromkeys: nil, # 使えません
    get: lambda {|key, default=nil| x = where($address)[$name][key] ? x : default},
    items: lambda {where($address)[$name].each()},
    keys: lambda {where($address)[$name].each_key()},
    pop: lambda {|key, default=nil|w = where($address); h = w[$name]; v = h.delete(key); w[name] = h; v ? v : default},
    popitem: lambda {w = where($address); h = w[$name]; v = h.shift(); w[name] = h; v},
    setdefault: lambda {|key, default=nil| h = where($address)[$name]; (v = h[key]) ? v : (h[key] = default)},
    update: lambda {|other| w = where($address); w[$name] = w[$name].merge(other)},
    values: lambda {where($address)[$name].each_value()},
}
$address = []
$name = "".to_sym()
$args = {}
$return = false
$break = false
$continue = false
$answer = nil
$deco = []


class Integer
    def div(other)
        other.is_a?(Float) ? super(other).to_f() : super(other)
    end
end

class Float
    def div(other)
        super(other).to_f()
    end
end

class Array
    def to_s()
        "[#{map(&:to_s).join(", ")}]"
    end

    def foldr(m = nil, &o)
        reverse().inject(m) {|m, i| m ? o.call(i, m) : i}
    end
end

class Hash
    def each()
        each_key()
    end
end

class String
    # カッコ外にstrが含まれているか判定する
    def include_outside?(str)
        honest = gsub(
            /(?=(?:(?:([\"\'`])(?:(?:(?!\1)[^\\\n])|(?:\\[^\n])|(?:\1\1))*?\1)(?:(?:(?!\1)[^\\\n])|(?:\\[^\n])|(?:\1\1))*?)+\n?$)(?:\1(?:(?:(?!\1)[^\\\n])|(?:\\[^\n])|(?:\1\1))*?(?:\1))/,
            "_"
        ) # "", '' とその内部にマッチする
        while honest =~ /[\(\{\[]/
            honest.gsub!(/\([^\(\)\{\}\[\]]*?\)/, "_")
            honest.gsub!(/\{[^\(\)\{\}\[\]]*?\}/, "_")
            honest.gsub!(/\[[^\(\)\{\}\[\]]*?\]/, "_") # (), {}, []とその内部にマッチする
        end
        honest.include?(str)
    end

    # 詰まった書き方の文字列にゆとりを与える
    def spacia()
        gsub(
            /([\)\]\}\d])([^\.\{\}\[\]\(\) \n,])/,
            '\1 \2',
        ).gsub(
            /(\W(?:False|else|pass|None|break|in|True|is|return|and|continue|for|lambda|def|while|assert|del|not|elif|if|or))([\(\{\[])/,
            '\1 \2',
        )
    end
end

class NilClass
    def to_s()
        "None"
    end
end

class TrueClass
    def to_s()
        "True"
    end

    def to_i()
        1
    end
end

class FalseClass
    def to_s()
        "False"
    end

    def to_i()
        0
    end
end


# lambda式の中身、関数を文字列の形で保持する。
class Pylamb
    def initialize(argstr, funcstr)
        argstrs = argstr.split(",").map(&:strip).find_all() {|s| s!=""}
        @argsyms = argstrs.map(&:to_sym)
        @funcstr = funcstr
        @key = ("l"+SecureRandom.alphanumeric()).to_sym()
    end
    
    def call(*args)
        ary = [@argsyms, args].transpose()
        ld = Hash[*ary.flatten()]
        where($address)[@key] = ld
        $address << @key
        r = read_expression(@funcstr)
        $address.pop()
        r
    end
end

# 関数定義の中身、関数を文字列の形で保持する。
class Pyfunc
    def initialize(argstr, funcstr)
        argstrs = argstr.split(",").map(&:strip).find_all() {|s| s!=""}
        @argsyms = argstrs.map(&:to_sym)
        @funcstr = funcstr
        @key = ("d"+SecureRandom.alphanumeric()).to_sym()
    end

    def call(*args)
        ary = [@argsyms, args].transpose()
        ld = Hash[*ary.flatten()]
        where($address)[@key] = ld
        $address << @key
        p $address
        read_suite(@funcstr)
        $address.pop()
        if $return
            $return = false
            return $answer
        end
        nil
    end
end

# 内包表記の中身、式を文字列の形で保持する。
class Pycomp
    def initialize(compstr)
        @compstr = compstr
        @key = ("c"+SecureRandom.alphanumeric()).to_sym()
    end

    def call()
        where($address)[@key] = {}
        $address << @key
        /^(.+?) (for .+? in .+)$/ =~ @compstr[1...-1]
        r = recursion($1, $2, "True")
        $address.pop()
        r
    end

    def recursion(head, rest, cond)
        case rest
        when /^for (.+?) in (.+?)( (?:if|for) .+)?$/
            multiple = $1.include_outside?(",")
            argstrs = $1.split(",").map(&:strip).find_all() {|s| s!=""}
            argsyms = argstrs.map(&:to_sym)
            rest = $3 ? $3.strip() : ""
            arr = []
            read_expression($2).each() do |args|
                args = [args] unless multiple
                argsyms.zip(args) do |k, v|
                    where($address)[k] = v
                end
                arr += recursion(head, rest, cond)
            end
            arr
        when /^if (.+?)( (?:if|for) .+)?$/
            rest = $2 ? $2.strip() : ""
            recursion(head, rest, "#{cond}&bool(#{$1})")
        else
            read_expression(cond) ? [read_expression(head)] : []
        end
    end
end

# pythonにおける挙動を模した文字列、ほとんどchars。
class Pystr < Array
    def initialize(str)
        self.replace(str.to_s().chars())
    end

    def [](index)
        Pystr.new(self.to_s()[index])
    end

    def +(other)
        Pystr.new((to_a()+other.to_a()).join())
    end

    def *(other)
        Pystr.new((to_a()*other).join())
    end

    def include?(ps)
        sl = length()
        pl = ps.length()
        0.upto(sl-pl) do |i|
            return true if slice(i, pl) == ps
        end
        false
    end

    def to_s()
        join()
    end

    def to_i()
        to_s().to_i()
    end

    def to_sym()
        to_s().to_sym()
    end

    freeze
end

# エラー二種
class AssertionError < StandardError
end

class ValueError < StandardError
end


# ファイルを一行ずつ読み込んで文(statement)に分ける。
def read_file(file)
    stmt = ""
    bracket_level = 0
    while line = file.gets()
        line.sub!(/#.*$/, "") # コメントを外す
        indent = count_indent(line)
        ls = line.spacia().split(";")
        ls.each_with_index() do |l, i|
            l = " "*indent+l.strip()+"\n" if i > 0
            bracket_level += bracket(l)
            if l.strip() == ""
                nil
            elsif /^(.+?)\\$/ =~ l
                stmt += $1
                flag = true
            elsif bracket_level > 0
                stmt += l.chomp()
                flag = true
            elsif /^    .+?/ =~ l
                stmt += l
                flag = false
            elsif /^else\s*:/ =~ l
                stmt += l
                flag = false
            elsif /^elif\s*.+:/ =~ l
                stmt += l
                flag = false
            elsif flag
                read_statement(stmt+l)
                stmt = ""
                flag = false
            else
                read_statement(stmt)
                stmt = l
            end
        end
    end
    read_statement(stmt)
    raise SyntaxError.new("using return/break/continue inappropriately") if $return || $break || $continue
end

# 文の塊を読み解く。文(statement)に分ける。
def read_suite(suite)
    stmt = ""
    flag = false
    bracket_level = 0
    suite.split("\n").each() do |line|
        line += "\n"
        line.sub!(/#.*$/, "")
        line.delete_prefix!(" "*4)
        indent = count_indent(line)
        ls = line.spacia().split(";")
        ls.each_with_index() do |l, i|
            l = " "*indent+l.strip()+"\n" if i > 0
            bracket_level += bracket(l)
            if l.strip() == ""
                nil
            elsif /^(.+)\\$/ =~ l
                stmt += $1
                flag = true
            elsif bracket_level > 0
                stmt += l.chomp()
                flag = true
            elsif /^    / =~ l
                stmt += l
                flag = false
            elsif /^else\s/ =~ l
                stmt += l
                flag = false
            elsif /^elif\s/ =~ l
                stmt += l
                flag = false
            elsif flag
                read_statement(stmt+l)
                stmt = ""
                flag = false
            else
                read_statement(stmt)
                stmt = l
            end
        end
    end
    read_statement(stmt)
end

# 文を読み解く。
def read_statement(stmt)
    return nil if $return || $break || $continue
    stmt.strip!()
    /^(.+?)\s+(.*)$/ =~ stmt+" "
    case $1
    when "assert"
        if read_expression("bool(#{$2})")
            nil
        else
            raise AssertionError.new("assertion failed: #{$2.strip()}")
        end
    when "pass"
        nil
    when "del"
        dol2 = $2.split(",").map() {|x| x.strip().to_sym()}
        dol2.each() do |k|
            where($address)[k] = nil
        end
    when "return"
        $answer = read_expression($2)
        $return = true
    when "break"
        $break = true
    when "continue"
        $continue = true
    when "if"
        flag = false
        suite = ""
        stmt.split("\n").each() do |line|
            case line
            when /^if(.+):(.*?)$/ # if lst[:2]==[1,2]:lst[:2]=[2,1] みたいな例に対応できない。
                dol2 = $2
                if read_expression("bool(#{$1})")
                    if /^\s*$/ =~ dol2
                        flag = true
                    else
                        return read_statement(dol2)
                    end
                end
            when /^elif(.+):(.*?)$/
                return read_suite(suite) if flag
                flag = false
                dol2 = $2
                if read_expression("bool(#{$1})")
                    if /^\s*$/ =~ dol2
                        flag = true
                    else
                        return read_statement(dol2)
                    end
                end
            when /^else\s*?:(.*)$/
                return read_suite(suite) if flag
                flag = false
                dol2 = $1
                if /^\s*$/ =~ dol2
                    flag = true
                else
                    return read_statement(dol2)
                end
            else
                suite += line+"\n" if flag
            end
        end
        read_suite(suite) if flag
    when "while"
        flag = false
        expr = ""
        suite = ""
        stmt.split("\n").each() do |line|
            case line
            when /^while\s+(.+):(.*?)$/
                flag = true
                expr = "bool(#{$1})"
                suite = "    #{$2.strip()}\n"
            when /^else\s*?:(.*)$/
                while read_expression(expr)
                    $continue = false
                    read_suite(suite)
                end
                flag = false
                suite = "    #{$1.strip()}\n"
            else
                suite += line+"\n"
            end
        end
        if flag
            while read_expression(expr)
                $continue = false
                read_suite(suite)
            end
        else
            read_suite(suite)
        end
        $break = false
    when "for"
        flag = false
        argsyms = []
        iterable = []
        suite = ""
        multiple = false
        stmt.split("\n").each() do |line|
            case line
            when /^for (.+?) in (.+):(.*?)$/
                flag = true
                argstrs = $1.split(",").map(&:strip).find_all() {|s| s!=""}
                argsyms = argstrs.map(&:to_sym)
                iterable = read_expression($2)
                suite = "    #{$3.strip()}\n"
                multiple = $1.include_outside?(",")
            when /^else\s*?:(.*?)$/
                iterable.each() do |args|
                    $continue = false
                    args = [args] unless multiple
                    argsyms.zip(args) do |k, v|
                        where($address)[k] = v
                    end
                    read_suite(suite)
                end
                flag = false
                suite = "    #{$1.strip()}\n"
            else
                suite += line+"\n"
            end
        end
        if flag
            iterable.each() do |args|
                $continue = false
                args = [args] unless multiple
                argsyms.zip(args) do |k, v|
                    where($address)[k] = v
                end
                read_suite(suite)
            end
        else
            read_suite(suite)
        end
        $break = false
    when "def"
        funcname = ""
        argstr = ""
        suite = ""
        stmt.split("\n").each() do |line|
            case line
            when /^def\s+([A-Za-z_][\w]*)\((.*)\)\s*:(.*)$/
                funcname = $1
                argstr = $2
                suite = "    #{$3.lstrip()}\n"
            else
                suite += line+"\n"
            end
        end
        d, $deco = $deco, []
        where($address)[funcname.to_sym()] = d.foldr(Pyfunc.new(argstr, suite), &:call)
    else
        w = where($address)
        case stmt
        when /^@(.+)$/ # decorator
            $deco << read_expression($1)
        when /^(.+?)(\*\*=|\/\/=|>>=|<<=)(.+)$/ # 累算代入文(3字のもの)
            augop = $2
            ser, val = $1.strip(), read_expression($3)
            h, k = assignment_hash_and_key(ser)
            case augop
            when "**="
                h[k] **= val
            when "//="
                h[k] /= val
            when ">>="
                h[k] >>= val
            when "<<="
                h[k] <<= val
            end
        when /^(.+?)(\+=|\-=|\*=|\/=|%=|&=|\^=|\|=)(.+)$/ # 累算代入文(2字のもの)
            augop = $2 
            ser, val = $1.strip(), read_expression($3)
            h, k = assignment_hash_and_key(ser)
            case augop
            when "+="
                h[k] += val
            when "-="
                h[k] -= val
            when "*="
                h[k] *= val
            when "/="
                h[k] /= val.to_f()
            when "%="
                h[k] %= val
            when "&="
                h[k] &= val
            when "^="
                h[k] ^= val
            when "|="
                h[k] |= val
            end
        else 
            if stmt.include_outside?("=") # 代入文 # *に対応していない
                serval = stmt.split("=").map(&:strip)
                unite = []
                serval.each_with_index() do |ser, i|
                    unite << i if ser == ""
                end
                unite.reverse().each() do |i|
                    serval[i-1..i+1] = "#{serval[i-1]}==#{serval[i+1]}"
                end
                unite = []
                serval.each_with_index() do |ser, i|
                    unite << i if ser.end_with?("!", ">", "<")
                end
                unite.reverse().each() do |i|
                    serval[i..i+1] = "#{serval[i]}=#{serval[i+1]}"
                end
                val = read_expression(serval[-1].include_outside?(",") ? "[#{serval[-1]}]" : serval[-1])
                serval[0..-2].each() do |x|
                    if x =~ /^(.+)\[(.+?)\]$/
                        read_expression($1)[read_expression($2)] = val
                    elsif x.include_outside?(",")
                        argstrs = x.split(",").map(&:strip).find_all() {|k| k!=""}
                        argsyms = argstrs.map(&:to_sym)
                        argsyms.zip(val) do |k, v|
                            case k
                            when /^(.+)\[(.+?)\]$/
                                read_expression($1)[read_expression($2)] = v
                            else
                                where($address)[k] = v
                            end
                        end
                    else
                        where($address)[x.to_sym()] = val
                    end
                end
            else #式文
                read_expression(stmt)
            end
        end
    end
    nil
end

# '', "", (), [], {}を主に内側から先に評価し、dictに格納していく。
def rename_quotes(expr)
    return nil if expr == nil
    
    # 文字列リテラルを先に評価し、dictに格納する。
    expr.gsub!(
        /(?=(?:(?:([\"\'`])(?:(?:(?!\1)[^\\\n])|(?:\\[^\n])|(?:\1\1))*?\1)(?:(?:(?!\1)[^\\\n])|(?:\\[^\n])|(?:\1\1))*?)+\n?$)(?:\1(?:(?:(?!\1)[^\\\n])|(?:\\[^\n])|(?:\1\1))*?(?:\1))/
    ) do |matched|
        key = "c"+SecureRandom.alphanumeric()
        where($address)[key.to_sym()] = read_atom(matched)
        key
    end

    # (), [], {}を先に評価し、dictに格納していく。
    while /[\(\[\{]/ =~ expr
        expr = rename_brackets(expr)
        expr = rename_parentheses(expr)
        expr = rename_braces(expr)
    end
    expr
end

def rename_parentheses(expr)
    while /\([^\(\)\[\]\{\}]*?\)/ =~ expr
        while /[A-Za-z_][\w\._]*\([^\(\)\[\]\{\}]*?\)/ =~ expr
            while /([A-Za-z_][\w\._]*)\.([A-Za-z_][\w]*?)\(([^\(\)\[\]\{\}]*?)\)/ =~ expr
                # method_callを先に評価し、dictに格納する。
                expr.gsub!(/([A-Za-z_][\w\._]*)\.([A-Za-z_][\w]*?)\(([^\(\)\[\]\{\}]*?)\)/) do
                    key = "m"+SecureRandom.alphanumeric()
                    argstrs = $3.split(",").find_all() {|x| x!=""}
                    args = []
                    kwargs = {}
                    argstrs.each() do |x|
                        if x.include_outside?("=")
                            if x[x.index("=")+1] == "="
                                args << read_expression(x)
                            else
                                k, v = x.split("=", 2)
                                kwargs[k.strip().to_sym()] = read_expression(v)
                            end
                        elsif x.strip().start_with?("*")
                            read_expression(x).each() do |v|
                                args << v
                            end
                        else
                            args << read_expression(x)
                        end
                    end
                    args << kwargs unless kwargs.empty?()
                    m = $gd[read_expression($1).class()::name.to_sym()][$2.strip().to_sym()]
                    $name = $1.to_sym()
                    where($address)[key.to_sym()] = m.call(*args)
                    key
                end
            end

            # function_callを先に評価し、dictに格納する。
            expr.sub!(/([A-Za-z_][\w_]*)\(([^\(\)\[\]\{\}]*?)\)/) do
                key = "f"+SecureRandom.alphanumeric()
                argstrs = $2.split(",").find_all() {|x| x!=""}
                args = []
                kwargs = {}
                argstrs.each() do |x|
                    if x.include_outside?("=")
                        if x[x.index("=")+1] =~ /\=/
                            args << read_expression(x)
                        elsif
                            x[x.index("=")-1] =~ /!|>|</
                        else
                            k, v = x.split("=", 2)
                            kwargs[k.strip().to_sym()] = read_expression(v)
                        end
                    elsif x.strip().start_with?("*")
                        read_expression(x).each() do |v|
                            args << v
                        end
                    else
                        args << read_expression(x)
                    end
                end
                args << kwargs unless kwargs.empty?()
                where($address)[key.to_sym()] = read_atom($1).call(*args)
                key
            end
        end

        # ()内を先に評価し、dictに格納する。
        expr.sub!(/\(([^\(\)\[\]\{\}]+?)\)/) do
            key = "b"+SecureRandom.alphanumeric()
            where($address)[key.to_sym()] = read_expression($1)
            key
        end
    end
    expr
end

def rename_brackets(expr)
    while /\[[^\[\]\{\}]*?\]/ =~ expr
        while /[a-zA-Z_][\w\._]*\[[^\[\]\{\}]+?\]/ =~ expr || /\[[^\[\]]+? for [^\[\]]+\]/ =~ expr
            while /\[[^\[\]]+? for [^\[\]]+\]/ =~ expr
                # リスト内包表記を先に評価し、dictに格納する。
                expr.gsub!(/\[[^\[\]]+? for [^\[\]]+\]/) do |matched|
                    key = "a"+SecureRandom.alphanumeric()
                    where($address)[key.to_sym()] = Pycomp.new(matched)
                    key+"()"
                end
            end

            # x[index]を先に評価し、dictに格納する。
            expr.gsub!(/([A-Za-z_][\w\._]*)\[([^\[\]\{\}]+?)\]/) do
                key = "i"+SecureRandom.alphanumeric()
                dol1 = read_atom($1)
                where($address)[key.to_sym()] =
                    case $2
                    when /^(.*?)\:(.*?)\:(.*?)$/
                        dol2 = read_expression($1) || 0
                        dol3 = (read_expression($2) || 0)-1
                        dol4 = read_expression($3) || 1
                        dol1[dol2..dol3].each_slice(dol4).map(&:first)
                    when /^(.*?)\:(.*?)$/
                        dol2 = read_expression($1) || 0
                        dol3 = (read_expression($2) || 0)-1
                        dol1[dol2..dol3]
                    when /^(.+?)$/
                        case dol1
                        when Array
                            dol1[read_expression($1)]
                        when Hash
                            dol1[read_expression($1).to_sym()]
                        else
                            return dol1
                        end
                    else
                        raise expr
                    end
                key
            end
        end

        # [expressions...](list)を先に評価し、dictに格納する。
        expr.gsub!(/\[([^\[\]\{\}]*?)\]/) do
            key = "a"+SecureRandom.alphanumeric()
            dol1 = rename_parentheses($1)
            where($address)[key.to_sym()] = dol1.split(",").map() {|x| read_expression(x)}
            key
        end
    end
    expr
end

def rename_braces(expr)
    while /\{([^\(\)\[\]\{\}]*?)\}/ =~ expr
        # dict内包表記を先に評価し、dictに格納する。 # まだ実装していない。

        # {key: value...}(dict)を先に評価し、dictに格納する。
        expr.gsub!(/\{([^\(\)\[\]\{\}]*?)\}/) do
            key = "h"+SecureRandom.alphanumeric()
            d = {}
            $1.split(",").map() do |kv|
                k, v = kv.split(":").map() {|x| read_expression(x)}
                d[k] = v
            end
            where($address)[key.to_sym()] = d
            key
        end
    end
    expr
end

# 式を読み解く。
def read_expression(expr)
    return false if $break
    return nil if expr == nil
    expr = rename_quotes(expr.strip())

    case expr
    when /^lambda (.+?):(.+)/ #lambda
        Pylamb.new($1, $2)
    when /^(.+) if (.+?) else (.+?)$/ # if_else
        read_expression("bool(#{$2})") ? read_expression($1) : read_expression($3)
    when /^(.+) or (.+)$/ # or
        read_expression("bool(#{$1})") ? read_expression($1) : read_expression($2)
    when /^(.+) and (.+?)$/ # and
        read_expression("bool(#{$1})") ? read_expression($2) : read_expression($1)
    when /^not (.+?)$/ # not
        !read_expression("bool(#{$1})")
    when /^(.+)(\sin\s|\sis\s|<=|<|>=|>|!=|==)(.+?)$/ # 所属や同一性のテストを含む比較
        dol1, dol3 = $1, $3
        case $2.strip()
        when "in"
            case dol1.strip()
            when /\Wnot$/
                !read_expression(dol3).include?(read_expression(dol1[0..-4]))
            else
                read_expression(dol3).include?(read_expression(dol1))
            end
        when "is"
            case dol3.strip()
            when /^not\W/
                !read_expression(dol1).equal?(read_expression(dol3[3..-1]))
            else
                read_expression(dol1).equal?(read_expression(dol3))
            end
        when "<"
            read_expression(dol1) < read_expression(dol3)
        when "<="
            read_expression(dol1) <= read_expression(dol3)
        when ">"
            read_expression(dol1) > read_expression(dol3)
        when ">="
            read_expression(dol1) >= read_expression(dol3)
        when "!="
            read_expression(dol1) != read_expression(dol3)
        when "=="
            read_expression(dol1) == read_expression(dol3)
        else
            raise expr
        end
    when /^(.+)\|(.+?)$/ # |
        read_expression($1) | read_expression($2)
    when /^(.+)\^(.+?)$/ # ^
        read_expression($1) ^ read_expression($2)
    when /^(.+)&(.+?)$/ # &
        read_expression($1) & read_expression($2)
    when /^(.+)[(<<)(>>)](.+?)$/ # <<, >>
        case $2
        when "<<"
            read_expression($1) << read_expression($3)
        when ">>"
            read_expression($1) >> read_expression($3)
        else
            raise expr
        end
    when /^(.+)(\+|\-)(.+?)$/ # add, sub
        case $2
        when "+"
            read_expression($1) + read_expression($3)
        when "-"
            read_expression($1) - read_expression($3)
        else
            raise expr
        end
    when /^(.*[^\*\/%])(\*|\/|\/\/|%)([^\*\/%].*?)$/ # mul, div, mod
        case $2
        when "*"
            read_expression($1) * read_expression($3)
        when "/"
            read_expression($1) / read_expression($3).to_f()
        when "//"
            read_expression($1).div(read_expression($3))
        when "%"
            read_expression($1) % read_expression($3)
        else
            raise expr
        end
    when /^(\+|\-|~)(.+)$/ # add, sub
        case $1
        when "+"
            +read_expression($2)
        when "-"
            -read_expression($2)
        when "~"
            ~read_expression($2)
        else
            raise expr
        end
    when /^(.+?)\*\*(.+)$/ # exp
        read_expression($1) ** read_expression($2)
    when /^\s*$/ # blank
        nil
    else
        read_atom(expr)
    end
end

# アトムと属性参照を読み解く。
def read_atom(atom)
    return nil if atom == nil
    atom = atom.strip()
    case atom
    # literal
    when /^"(.*?)"$/
        Pystr.new($1)
    when /^'(.*?)'$/
        Pystr.new($1)
    when /^([\d]+?)$/
        $1.to_i()
    when /^([\d\.]+?)$/
        $1.to_f()
    # attribute
    when /^(.+)\.(.+?)$/
        dol1 = read_expression($1)
        what($address, dol1.class()::name.to_sym())[$2.to_sym()]
    # identifier
    else
        what($address, atom.to_sym())
    end
end

# global_dict(変数全体のハッシュ)のaddressに示された番地の中身(主に局所変数のハッシュ)を呼び出す。
def where(address)
    d = $gd
    address.each() do |a|
        d = d[a]
    end
    d
end

# global_dict(変数全体のハッシュ)のaddressに示された番地のから参照できる中身を呼び出す。
def what(address, key)
    address.length().downto(0) do |i|
        v = where(address[0..i])[key]
        return v if v
    end
    where([])[key]
end

def bracket(line)
    l = line.gsub(
        /(?=(?:(?:([\"\'`])(?:(?:(?!\1)[^\\\n])|(?:\\[^\n])|(?:\1\1))*?\1)(?:(?:(?!\1)[^\\\n])|(?:\\[^\n])|(?:\1\1))*?)+\n?$)(?:\1(?:(?:(?!\1)[^\\\n])|(?:\\[^\n])|(?:\1\1))*?(?:\1))/,
        "_"
    )
    l.count("([{")-l.count(")]}")
end

def assignment_hash_and_key(ser)
    case ser
    when /^(.+)\[(.+?)\]$/
        return read_expression($1), read_expression($2)
    else
        return where($address), ser.to_sym()
    end
end

def count_indent(line)
    c = 0
    l = line.chars()
    while l.shift() == " "
        c += 1
    end
    c
end

File.open(filename, "r") do |fin|
    read_file(fin)
end