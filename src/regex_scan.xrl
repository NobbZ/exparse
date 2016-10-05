Definitions.

Rules.

\|   : {token, {'|', TokenLine}}.
\*   : {token, {'*', TokenLine}}.
\+   : {token, {'+', TokenLine}}.
\(   : {token, {'(', TokenLine}}.
\)   : {token, {')', TokenLine}}.
\.   : {token, {'.', TokenLine}}.
\$   : {token, {'$', TokenLine}}.
\\   : {token, {'\\', TokenLine}}.
\[   : {token, {'[', TokenLine}}.
\[\^ : {token, {'[^', TokenLine}}.
\]   : {token, {']', TokenLine}}.
-    : {token, {'-', TokenLine}}.
\?   : {token, {'?', TokenLine}}.
\^   : {token, {'^', TokenLine}}.
.|\n : {token, {char, TokenLine, TokenChars}}.

Erlang code.

-dialyzer({nowarn_function, yyrev/2}).
