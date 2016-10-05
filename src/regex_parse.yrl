Nonterminals regex union simple_re concat basic_re star plus qmark elem_re group any bos eos set slash_set pos_set neg_set set_items set_item range char_.

Terminals '|' '*' '+' '(' ')' '.' '$' '\\' '[' '[^' ']' '-' '?' '^' char.

Rootsymbol regex.

Unary 500 '\\'.
Unary 400 '(' ')' '[' ']'.
Unary 300 '*' '+' '?'.
Unary 200 '^' '$'.
Left 100 '|'.

regex -> union : '$1'.
regex -> simple_re : flatten('$1').

union -> regex '|' simple_re : {union, flatten('$1'), flatten('$3')}.

simple_re -> '$empty' : epsilon.
simple_re -> concat : '$1'.
simple_re -> basic_re : '$1'.

concat -> simple_re basic_re : ['$1'|'$2'].

basic_re -> star : '$1'.
basic_re -> plus : '$1'.
basic_re -> qmark : '$1'.
basic_re -> elem_re : '$1'.

star -> elem_re '*' : {zero_more, '$1'}.

plus -> elem_re '+' : {one_more, '$1'}.

qmark -> elem_re '?' : {zero_one, '$1'}.

elem_re -> group : '$1'.
elem_re -> any : '$1'.
elem_re -> bos : '$1'.
elem_re -> eos : '$1'.
elem_re -> char_ : '$1'.
elem_re -> set : '$1'.

group -> '(' regex ')' : {group, '$2'}.

any -> '.' : any.

bos -> '^' : bos.

eos -> '$' : eos.

set -> slash_set : '$1'.
set -> pos_set   : '$1'.
set -> neg_set   : '$1'.

slash_set -> '\\' char : slash_set('$2').

pos_set -> '[' set_items ']' : {set, lists:sort(lists:flatten('$2'))}.

neg_set -> '[^' set_items ']' : {neg_set, lists:sort(lists:flatten('$2'))}.

set_items -> set_item           : lists:flatten(['$1']).
set_items -> set_item set_items : ['$1'|'$2'].

set_item -> range : '$1'.
set_item -> char_ : '$1'.

range -> char_ '-' char_ : lists:seq(hd('$1'), hd('$3')).

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

-export([parse_string/1, flatten/1]).

-dialyzer({nowarn_function, parse/1}).
-dialyzer({nowarn_function, parse_and_scan/1}).
-dialyzer({nowarn_function, format_error/1}).

-spec(parse_string(maybe_improper_list()) -> {ok, 'Elixir.ExParse.RegexParse':ast()} | {error, any()}).
parse_string(Str) when is_list(Str) ->
    {ok, Tokens, _} = regex_scan:string(Str),
    parse(Tokens).

extract({_, _, X}) -> X.

flatten(List) when is_list(List) -> flatten(List, []);
flatten(Thing) -> Thing.

flatten([H|T], Acc) when is_list(H) -> flatten(H, flatten(T, Acc));
flatten([H|T], Acc)                 -> [H|flatten(T, Acc)];
flatten([],    Acc)                 -> Acc;
flatten(Thing, Acc)                 -> [Thing|flatten(Acc)].

slash_set({char, _, C}) -> slash_set(hd(C));
slash_set($d) -> digit;
slash_set($s) -> whitespace;
slash_set($w) -> word_character;
slash_set($D) -> no_digit;
slash_set($S) -> no_whitespace;
slash_set($W) -> no_word_character.
