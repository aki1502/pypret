=begin

所属:     総合人間学部3回生
氏名:     
学生番号:  

概要: Pythonの翻訳機
操作法: ruby pypret.rb [Pythonの文法で書かれたプレーンテキスト]
動機: 似た課題を提出しそこねたため。
アピールポイント: 手間が掛かっている。
自己評価: 1000000000点
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
　　　　組み込み関数ではascii,breakpoint,bytearray,bytes,
　　　　callable,classmethod,compile,complex,delattr,dir,eval,
　　　　exec,format,frozenset,getattr,globals,hasattr,help,id,
　　　　isinstance,issubclass,iter,locals,
　　　　memoryview,next,object,open,property,repr,set,setattr,
　　　　slice,staticmethod,super,tuple,varsには対応していません。
　　　　複数の記法に対応した関数ではそのうち一つしか使用できません。
　　　　printの引数には機能に制限があります。
　　　　組み込み定数ではNotImplementedと...(Ellipsis)には対応していません。
　　　　インデントは4字固定です。
　　　　その他実装漏れはいくらでもあると思われます、予めご了承下さい。
=end

require "securerandom"

require "pp"
Debug = true

filename = ARGV.shift


NullValues = [0, 0.0, [], {}, "", false, nil]

DefaultKey = proc {|x| x}

BuiltinFunctions = {
    abs: proc {|x| x.abs},
    all: proc {|x| (x.map() {|y| !NullValues.include?(y)}).all?},
    any: proc {|x| (x.map() {|y| !NullValues.include?(y)}).any?},
    bin: proc {|x| x>=0 ? "0b"+x.to_s(2) : "-0b"+-x.to_s(2)},
    bool: proc {|x=false| !NullValues.include?(x)},
    chr: proc {|x| x.chr()},
    dict: proc {|**kwargs| kwargs},
    divmod: proc {|x, a| x.divmod(a)},
    enumerate: proc {|x, start=0| x.each().with_index(start)},
    filter: proc {|func, iter| iter.find_all(&func)},
    float: proc {|x=0.0| x.to_f()},
    hash: proc {|x| x.hash()},
    hex: proc {|x| x>=0 ? "0x"+x.to_s(16) : "-0x"+-x.to_s(16)},
    input: proc {|x=""| print(x); gets.to_s()},
    int: proc {|x=0| x.to_i()},
    len: proc {|x| x.length()},
    list: proc {|x=[]| x.to_a()},
    map: proc {|func, *iters| iters.zip().map(&func)},
    max: proc {|*x, key:DefaultKey, default:nil| if x[0].is_a?(Array) then x=x[0] end; (default ? x+[default] : x).max(&key)},
    min: proc {|*x, key:DefaultKey, default:nil| if x[0].is_a?(Array) then x=x[0] end; (default ? x+[default] : x).min(&key)},
    oct: proc {|x| x>=0 ? "0o"+x.to_s(8) : "-0o"+-x.to_s(8)},
    ord: proc {|x| x.ord()},
    pow: proc {|base, exp, mod=nil| base.pow(exp, modulo=mod)},
    print: proc {|*o| print(*o) ;print("\n")},
    range: proc {|*s| case s.length() when 1; 0...s[0] when 2; s[0]...s[1] else (s[0]...s[1]).step(s[2]) end},
    reversed: proc {|x| x.reverse()},
    round: proc {|x| x.round()},
    sorted: proc {|x| x.sort()},
    str: proc {|x=""| Pystr.new(x.to_s())},
    sum: proc {|x, init=0| x.sum(init)},
    type: proc {|x| x.type()},
    zip: proc {|*x| x[0].zip(*x[1..-1])},
}

BuiltinConstants = {
    False: false,
    True: true,
    None: nil,
}


$gd = BuiltinFunctions.merge(BuiltinConstants)
# 時間があったらクラス定義からやり直す, 辞書を作らずクラスメソッドを動的に呼び出す
$gd[:Integer] = {
    as_integer_ratio: proc {[where($address)[$name], 1]},
    bit_length: proc {|x| where($address)[$name].bit_length()},
    from_bytes: nil, # 使えません
    to_bytes: nil, # 使えません
}
$gd[:Float] = {
    as_integer_ratio: proc {f = where($address)[$name]; [f.numerator(), f.denominator()]},
    fromhex: nil, # 使えません
    hex: proc {x=where($address)[$name]; x>=0 ? "0x"+x.to_s(16) : "-0x"+-x.to_s(16)},
    is_integer: proc {f = where($address)[$name]; f == f.to_i()},
}
$gd[:Array] = {
    append: proc {|x| where($address)[$name] += [x]},
    clear: proc {where($address)[$name] = []},
    copy: proc {where($address)[$name].clone()},
    count: proc {|x| where($address)[$name].count(x)},
    extend: proc {|t| where($address)[$name] += t},
    index: proc {|x| i = where($address)[$name].index()},
    insert: proc {|i, x| where($address)[$name][i, 0] = [x]},
    pop: proc {|i=-1| w = where($address); n = w[$name]; a = n.slice!(i); w[$name] = n; a},
    remove: proc {|x| w = where($address); n = w[$name]; i = n.index(x); n.slice!(i); w[$name] = n},
    reverse: proc {w = where($address); w[$name] = w[$name].reverse()},
    sort: proc {|x=DefaultKey| w = where($address); w[$name] = w[$name].sort_by(&x).to_a()},
}
$gd[:Pystr] = {
    capitalize: proc {Pystr.new(where($address)[$name].to_s().capitalize())},
    casefold: proc {Pystr.new(where($address)[$name].to_s().downcase(:fold))},
    center: proc {|width, fillchar=" "| Pystr.new(where($address)[$name].to_s().center(width, fillchar.to_s()))},
    count: proc {|sub| where($address)[$name].to_s().scan(sub.to_s()).length()},
    encode: nil, # 使えません
    endswith: proc {|suffix| where($address)[$name].to_s().end_with?(suffix.to_s())},
    expandtabs: nil, # 使えません
    find: proc {|sub| where($address)[$name].to_s().index(sub.to_s())},
    format: nil, # 使えません
    format_map: nil, # 使えません
    index: proc {|sub| a = where($address)[$name].to_s().index(sub.to_s()) ? a : (raise ValueError.new("inappropriate value"))},
    isalnum: proc {where($address)[$name].to_s().match?(/^\w+$/)},
    isalpha: proc {where($address)[$name].to_s().match?(/^[A-z]+$/)},
    isascii: proc {where($address)[$name].to_s().ascii_only?()},
    isdecimal: proc {where($address)[$name].to_s().match?(/^\d+$/)},
    isdigit: nil, # 使えません
    isidentidier: proc {where($address)[$name].to_s().match?(/^[A-z_]^[\w_]*$/)},
    islower: proc {where($address)[$name].to_s().match?(/^[a-z]+$/)},
    isprintable: nil, # 使えません
    isspace: proc {where($address)[$name].to_s().match?(/^\s+$/)},
    istitle: proc {(where($address)[$name].to_s().split().map {|w| w.match?(/^[A-Z]/)}).all?},
    isupper: proc {where($address)[$name].to_s().match?(/^[A-Z]+$/)},
    join: proc {|iterable| iterable.join(where($address)[$name])},
    ljust: proc {|width, padding=" "| Pystr.new(where($address)[$name].to_s().ljust(width, padding.to_s()))},
    lower: proc {Pystr.new(where($address)[$name].to_s().downcase())},
    lstrip: proc {Pystr.new(where($address)[$name].to_s().lstrip())},
    maketrans: nil, # 使えません
    partition: proc {|sep| where($address)[$name].to_s().partition(sep.to_s()).map() {|s| Pystr.new(s)}},
    replace: proc {|old, new| Pystr.new(where($address)[$name].to_s().gsub(old.to_s(), new.to_s()))},
    rfind: proc {|sub| where($address)[$name].to_s().rindex(sub.to_s())},
    rindex: proc {|sub| a = where($address)[$name].to_s().rindex(sub.to_s()) ? a : (raise ValueError.new("inappropriate value"))},
    rjust: proc {|width, padding=" "| Pystr.new(where($address)[$name].to_s().rjust(width, padding.to_s()))},
    rpartition: proc {|sep| where($address)[$name].to_s().rpartition(sep.to_s()).map() {|s| Pystr.new(s)}},
    rsplit: nil, # 使えません
    rstrip: proc {Pystr.new(where($address)[$name].to_s().rstrip())},
    split: proc {|sep=nil, maxsplit=0| where($address)[$name].to_s().split(sep.to_s(), maxsplit)},
    splitlines: proc {|keepends=false| where($address)[$name].to_s().split(/[\n\r\v\f\x1c\x1d\x1e]/)},
    startswith: proc {|prefix| where($address)[$name].to_s().start_with?(prefix)},
    strip: proc {Pystr.new(where($address)[$name].to_s().strip())},
    swapcase: proc {Pystr.new(where($address)[$name].to_s().swapcase())},
    title: nil, # 使えません
    translate: nil, # 使えません
    upper: proc {Pystr.new(where($address)[$name].to_s().upcase())},
    zfill: nil # 使えません
}
$gd[:Hash] = {
    clear: proc {where($address)[$name] = {}},
    copy: proc {where($address)[$name].clone()},
    fromkeys: nil, # 使えません
    get: proc {|key, default=nil| x = where($address)[$name][key] ? x : default},
    items: proc {where($address)[$name].each()},
    keys: proc {where($address)[$name].each_key()},
    pop: proc {|key, default=nil|w = where($address); h = w[$name]; v = h.delete(key); w[name] = h; v ? v : default},
    popitem: proc {w = where($address); h = w[$name]; v = h.shift(); w[name] = h; v},
    setdefault: proc {|key, default=nil| h = where($address)[$name]; (v = h[key]) ? v : (h[key] = default)},
    update: proc {|other| w = where($address); w[$name] = w[$name].merge(other)},
    values: proc {where($address)[$name].each_value()},
}
$address = []
$name = "".to_sym()
$args = {}
$return = false
$break = false
$continue = false
$answer = nil

class Pylamb
    def initialize(argstr, funcstr)
        @argsyms = argstr.split(",").map() {|s| s.strip().to_sym()}
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

class Pyfunc
    def initialize(argstr, funcstr)
        @argsyms = argstr.split(",").map() {|s| s.strip().to_sym()}
        @funcstr = funcstr
        @key = ("d"+SecureRandom.alphanumeric()).to_sym()
    end

    def call(*args)
        ary = [@argsyms, args].transpose()
        ld = Hash[*ary.flatten()]
        where($address)[@key] = ld
        $address << @key
        r = read_suite(@funcstr)
        $address.pop()
        r
    end
end

class Array
    def to_s()
        "[#{map(&:to_s).join(", ")}]"
    end
end

class Pystr < Array
    def initialize(str)
        self.replace(str.chars())
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
        self.join()
    end

    freeze
end

class AssertionError < StandardError
end

class ValueError < StandardError
end

# ファイルを一行ずつ読み込んで文に分ける。
def read_file(file) #まだ;に対応してない
    stmt = ""
    bracket_level = 0
    while line = file.gets()
        line.sub!(/#.*$/, "")
        bracket_level += bracket(line)
        if line.strip() == ""
            nil
        elsif /^(.+?)\\$/ =~ line
            stmt += $1
            flag = true
        elsif bracket_level > 0
            stmt += line.chomp()
            flag = true
        elsif /^    .+?/ =~ line
            stmt += line
        elsif /^else\s*:/ =~ line
            stmt += line
        elsif /^elif\s*.+:/ =~ line
            stmt += line
        elsif flag
            read_statement(stmt+line)
            stmt = ""
            flag = false
        else
            read_statement(stmt)
            stmt = line
        end
    end
    read_statement(stmt)
    raise SyntaxError.new("using return/break/continue inappropriately") if $return || $break || $continue
end

# 文の塊を読み解く。
def read_suite(suite) #まだ;に対応してない
    stmt = ""
    flag = false
    bracket_level = 0
    suite.split("\n").each() do |line|
        line += "\n"
        line.sub!(/#.*$/, "")
        line.delete_prefix!(" "*4)
        bracket_level += bracket(line)
        if line.strip() == ""
            nil
        elsif  /^(.+?)\\$/ =~ line
            stmt += $1
            flag = true
        elsif bracket_level > 0
            stmt += line.chomp()
            flag = true
        elsif /^    .+?/ =~ line
            stmt += line
        elsif /^else\s.+?/ =~ line
            stmt += line
        elsif /^elif\s.+?/ =~ line
            stmt += line
        elsif flag
            read_statement(stmt+line)
            stmt = ""
            flag = false
        else
            read_statement(stmt)
            stmt = line
        end
    end
    read_statement(stmt)
end

# 文を読み解く。
def read_statement(stmt)
    return nil if $return || $break || $continue
    stmt.lstrip!()
    /^(.+?)\s+(.*)$/ =~ stmt+" " # まだ if(i>5): みたいなのに対応できない
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
        $return = true
        $answer = read_expression($2)
    when "break"
        $break = true
    when "continue"
        $continue = true
    when "if"
        flag = false
        suite = ""
        stmt.split("\n").each() do |line|
            case line
            when /^if(.+?):(.*)$/
                dol2 = $2
                if read_expression("bool(#{$1})")
                    if /^\s*$/ =~ dol2
                        flag = true
                    else
                        return read_statement(dol2)
                    end
                end
            when /^elif(.+?):(.*)$/
                return read_suite(suite) if flag
                dol2 = $2
                if read_expression("bool(#{$1})")
                    if /^\s*$/ =~ dol2
                        flag = true
                    else
                        return read_statement(dol2)
                    end
                end
            when /^else\s*:(.*)$/
                return read_suite(suite) if flag
                dol2 = $1
                if /^\s*$/ =~ dol2
                    flag = true
                else
                    return read_statement(dol2)
                end
            else
                suite += line+"\n" if flag
            end
            read_suite(suite) if flag
        end
    when "while"
        flag = false
        expr = ""
        suite = ""
        stmt.split("\n").each() do |line|
            case line
            when /^while\s+(.+?):(.*)$/
                flag = true
                expr = "bool(#{$1})"
                suite = $2
            when /^else\s*:(.*)$/
                while read_expression(expr) do
                    $continue = false
                    read_suite(suite)
                end
                flag = false
                suite = "    #{$1.lstrip()}\n"
            else
                suite += line+"\n"
            end
        end
        if flag
            while read_expression(expr) do
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
        stmt.split("\n").each() do |line|
            case line
            when /^for (.+?) in (.+):(.*?)$/
                flag = true
                argsyms = $1.split(",").map() {|s| s.strip().to_sym()}
                iterable = read_expression($2)
                suite = "    #{$3.lstrip()}\n"
            when /^else\s*?:(.*?)$/
                iterable.each() do |*args|
                    $continue = false
                    argsyms.zip(args) do |k, v|
                        where($address)[k] = v
                    end
                    read_suite(suite)
                end
                flag = false
                suite = "    #{$1.lstrip()}\n"
            else
                suite += line+"\n"
            end
        end
        if flag
            iterable.each() do |*args|
                $continue = false
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
            when /^def\s+([A-z_][\w_]*)\((.*)\)\s*:(.*)$/
                funcname = $1
                argstr = $2
                suite = "    #{$3.lstrip()}\n"
            else
                suite += line+"\n"
            end
        end
        where($address)[funcname.to_sym()] = Pyfunc.new(argstr, suite)
        a, $answer = $answer, nil
        return a
    else
        w = where($address)
        case stmt
        when /^(.+?)(\*\*=|\/\/=|>>=|<<=)(.+)$/ # 累算代入文(3字のもの)
            case $2
            when "**="
                w[read_expression($1)] **= read_expression($3)
            when "//="
                w[read_expression($1)] /= read_expression($3)
            when ">>="
                w[read_expression($1)] >>= read_expression($3)
            when "<<="
                w[read_expression($1)] <<= read_expression($3)
            end
        when /^(.+?)(\+=|\-=|\*=|\/=|%=|&=|\^=\|=)(.+)$/  # 累算代入文(2字のもの)
            case $2
            when "+="
                w[read_expression($1)] += read_expression($3)
            when "-="
                w[read_expression($1)] -= read_expression($3)
            when "*="
                w[read_expression($1)] *= read_expression($3)
            when "/="
                w[read_expression($1)] /= read_expression($3).to_f()
            when "%="
                w[read_expression($1)] %= read_expression($3)
            when "&="
                w[read_expression($1)] &= read_expression($3)
            when "^="
                w[read_expression($1)] ^= read_expression($3)
            when "|="
                w[read_expression($1)] |= read_expression($3)
            end
        when /^.+?(?:=.+?)+$/ # 代入文 # まだ多重代入文に対応していない
            serval = stmt.split("=").map(&:strip)
            val = read_expression(serval[-1])
            serval[0..-2].each() do |x|
                case x
                when /^([A-z_][\w_]*?)\[(.+)\]$/ # まだ arr[i][j] = v みたいなのに対応してない
                    where($address)[$1.to_sym()][read_expression($2)] = val
                else
                    where($address)[x.to_sym()] = val
                end
            end
        else #式文
            read_expression(stmt)
        end
    end
    nil
end

# '', "", (), [], {}を内側から先に評価し、dictに格納していく。
def rename_brackets(expr)
    return nil if expr == nil
    
    if /["']/ =~ expr
        # 文字列リテラルを先に評価し、dictに格納する。
        expr = expr.gsub(
            /(?=(?:(?:([\"\'`])(?:(?:(?!\1)[^\\\n])|(?:\\[^\n])|(?:\1\1))*?\1)(?:(?:(?!\1)[^\\\n])|(?:\\[^\n])|(?:\1\1))*?)+\n?$)(?:\1(?:(?:(?!\1)[^\\\n])|(?:\\[^\n])|(?:\1\1))*?(?:\1))/
        ) do |matched|
            key = "c"+SecureRandom.alphanumeric()
            where($address)[key.to_sym()] = read_atom(matched)
            key
        end
    end

    while /[\(\[\{]/ =~ expr
        # method_callを先に評価し、dictに格納する。# まだキーワード引数に対応していない # まだ*に対応していない
        while /([A-z_][\w\._]*)\.([A-z_][\w_]*?)\(([^\(\)\[\]\{\}]*?)\)/ =~ expr
            expr = expr.gsub(/([A-z_][\w\._]*)\.([A-z_][\w_]*?)\(([^\(\)\[\]\{\}]*?)\)/) do
                key = "m"+SecureRandom.alphanumeric()
                argstrs = $3.split(",").find_all() {|x| x!=""}
                args = argstrs.map() {|x| read_expression(x)}
                $name = $1.to_sym()
                m = $gd[read_expression($1).class()::name.to_sym()][$2.to_sym()]
                where($address)[key.to_sym()] = m.call(*args)
                key
            end
        end

        # function_callを先に評価し、dictに格納する。
        while /([A-z_][\w_]*)\(([^\(\)\[\]\{\}]*?)\)/ =~ expr
            expr = expr.gsub(/([A-z_][\w_]*)\(([^\(\)\[\]\{\}]*?)\)/) do
                key = "f"+SecureRandom.alphanumeric()
                argstrs = $2.split(",").find_all() {|x| x!=""}
                args = argstrs.map() {|x| read_expression(x)}
                where($address)[key.to_sym()] = read_atom($1).call(*args)
                key
            end
        end

        # ()内を先に評価し、dictに格納する。
        while /\(([^\(\)\[\]\{\}]+?)\)/ =~ expr
            expr = expr.gsub(/\(([^\(\)\[\]\{\}]+?)\)/) do
                key = "b"+SecureRandom.alphanumeric()
                where($address)[key.to_sym()] = read_expression($1)
                key
            end
        end

        # x[index]を先に評価し、dictに格納する。
        while /([A-z_][\w._]*)\[([^\(\)\[\]\{\}]+?)\]/ =~ expr
            expr = expr.gsub(/([A-z_][\w._]*)\[([^\(\)\[\]\{\}]+?)\]/) do
                key = "i"+SecureRandom.alphanumeric()
                dol1 = read_atom($1)
                where($address)[key.to_sym()] =
                    case $2
                    when /^(.*?)\:(.*?)\:(.*?)$/
                        dol2 = read_expression($1) || 0
                        dol3 = read_expression($2)-1 || -1
                        dol4 = read_expression($3) || 1
                        dol1[dol2..dol3].each_slice(dol4).map() {|x| x[0]}
                    when /^(.*?)\:(.*?)$/
                        dol2 = read_expression($1) || 0
                        dol3 = read_expression($2)-1 || -1
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
        while /\[([^\(\)\[\]\{\}]*?)\]/ =~ expr
            expr = expr.gsub(/\[([^\(\)\[\]\{\}]*?)\]/) do #まだ内包表記に対応してない。
                key = "a"+SecureRandom.alphanumeric()
                where($address)[key.to_sym()] = $1.split(",").map() {|x| read_expression(x)}
                key
            end
        end

        # {key: value...}(dict)を先に評価し、dictに格納する。
        while /\{([^\(\)\[\]\{\}]*?)\}/ =~ expr
            expr = expr.gsub(/\{([^\(\)\[\]\{\}]*?)\}/) do
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
    end
    expr
end

# 式を読み解く。
def read_expression(expr)
    return nil if expr == nil
    expr = rename_brackets(expr.strip())

    case expr
    when /^lambda (.+?):(.+)/ #lambda
        Pylamb.new($1, $2)
    when /^(.+?) if (.+?) else (.+)$/ # if_else
        read_expression($2) ? read_expression($1) : read_expression($3)
    when /^(.+?) or (.+)$/ # or
        read_expression($1) || read_expression($2)
    when /^(.+?) and (.+?)$/ # and
        read_expression($1) && read_expression($2)
    when /^not (.+?)$/ # not
        !read_expression($1)
    when /^(.+?)(\sin\s|\snot\s+?in\s|\sis\s|\sis\s+?not\s|<=|<|>=|>|!=|==)(.+)$/
        dol1, dol3 = $1, $3
        case $2.strip()
        when "in"
            read_expression(dol3).include?(read_expression(dol1))
        when /not\s+?in/
            !read_expression(dol3).include?(read_expression(dol1))
        when "is"
            read_expression(dol1).equal?(read_expression(dol3))
        when /is\s+?not/
            !read_expression(dol1).equal?(read_expression(dol3))
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
    when /^(.+?)\|(.+)$/ # |
        read_expression($1) | read_expression($2)
    when /^(.+?)\^(.+)$/ # ^
        read_expression($1) ^ read_expression($2)
    when /^(.+?)&(.+)$/ # &
        read_expression($1) & read_expression($2)
    when /^(.+?)[(<<)(>>)](.+)$/ # <<, >>
        case $2
        when "<<"
            read_expression($1) << read_expression($3)
        when ">>"
            read_expression($1) >> read_expression($3)
        else
            raise expr
        end
    when /^([^\+\-]+?)(\+|\-)(.+)$/ # add, sub
        case $2
        when "+"
            read_expression($1) + read_expression($3)
        when "-"
            read_expression($1) - read_expression($3)
        else
            raise expr
        end
    when /^([^*\/%]+?)(\*|\/|\/\/|%)(.+)$/ # mul, div, mod
        case $2
        when "*"
            read_expression($1) * read_expression($3)
        when "/"
            read_expression($1) / read_expression($3).to_f()
        when "//"
            read_expression($1) / read_expression($3)
        when "/"
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
    when /^(.+)\*\*(.+?)$/ # exp
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

def where(address)
    d = $gd
    address.each() do |a|
        d = d[a]
    end
    d
end

def what(address, key)
    address.length().downto(0) do |i|
        v = where(address[0..i])[key]
        return v if v
    end
    where([])[key]
end

def what_with_address(address, key)
    address.length().downto(0) do |i|
        a = address[0...i]
        v = where(a)[key]
        return [v, a] if v
    end
    [nil, []]
end

def bracket(line)
    l = line.gsub(
        /(?=(?:(?:([\"\'`])(?:(?:(?!\1)[^\\\n])|(?:\\[^\n])|(?:\1\1))*?\1)(?:(?:(?!\1)[^\\\n])|(?:\\[^\n])|(?:\1\1))*?)+\n?$)(?:\1(?:(?:(?!\1)[^\\\n])|(?:\\[^\n])|(?:\1\1))*?(?:\1))/,
        "_"
    )
    l.count("([{")-l.count(")]}")
end


File.open(filename, "r") do |fin|
    read_file(fin)
end