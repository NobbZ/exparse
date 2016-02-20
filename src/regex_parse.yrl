Nonterminals regex union simple_re concat basic_re star plus qmark elem_re group any eos set pos_set neg_set set_items set_item range char_.

Terminals '|' '*' '+' '(' ')' '.' '$' '\\' '[' '[^' ']' '-' '?' char.

Rootsymbol regex.

regex -> union : '$1'.
regex -> simple_re : '$1'.

union -> regex '|' simple_re : [{union, '$1', '$3'}].

simple_re -> concat : [lists:flatten(['$1'])].
simple_re -> basic_re : '$1'.

concat -> simple_re basic_re : ['$1'|'$2'].

basic_re -> star : '$1'.
basic_re -> plus : '$1'.
basic_re -> qmark : '$1'.
basic_re -> elem_re : '$1'.

star -> elem_re '*' : {zero_more, '$1'}.

plus -> elem_re '+' : {one_more, '$1'}.

qmark -> elem_re '?' : {zero_one, '$1'}.

elem_re -> group : ['$1'].
elem_re -> any : ['$1'].
elem_re -> eos : ['$1'].
elem_re -> char_ : ['$1'].
elem_re -> set : ['$1'].

group -> '(' regex ')' : {group, '$2'}.

any -> '.' : any.

eos -> '$' : eos.

set -> pos_set : '$1'.
set -> neg_set : '$1'.

pos_set -> '[' set_items ']' : {set, lists:sort(lists:flatten('$2'))}.

neg_set -> '[^' set_items ']' : {neg_set, lists:sort(lists:flatten('$2'))}.

set_items -> set_item           : lists:flatten(['$1']).
set_items -> set_item set_items : ['$1'|'$2'].

set_item -> range : '$1'.
set_item -> char_ : '$1'.

range -> char_ '-' char_ : lists:seq('$1', '$3').

char_ -> char : extract('$1').
char_ -> '\\' '|' : $|.
char_ -> '\\' '*' : $*.
char_ -> '\\' '+' : $+.
char_ -> '\\' '(' : $(.
char_ -> '\\' ')' : $).
char_ -> '\\' '.' : $..
char_ -> '\\' '$' : $$.
char_ -> '\\' '\\' : $\\.
char_ -> '\\' '[' : $[.
char_ -> '\\' ']' : $].
char_ -> '\\' '-' : $-.
char_ -> '\\' '?' : $?.

Erlang code.

-export([parse_string/1]).

extract({_, _, X}) -> X.

parse_string(Str) ->
    {ok, Tokens, _} = regex_scan:string(Str),
    parse(Tokens).

%dangle([]) -> [];
%dangle([H|T]) when is_list(H) -> dangle(H) ++ 
    
