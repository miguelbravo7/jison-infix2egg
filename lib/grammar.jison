%{
  const { Value, Word, Apply, topEnv } = require('@ull-esit-pl-1920/p7-t3-egg-2-miguel');

  const makeApply = (value, ...params) => {
    value = typeof value === 'string' ? new Word({value: value}) : value;
    let app = new Apply(value);
    app.args.push(...params);
    return app;
  }
%}

%lex
%%
\s+    {/* skip whitespace */}
#[^\n\r]*
[ \r\n\t]
"=="|"!="|">="|"<="|"<"|">"     return 'LOGICOP';
"*"|"/"                         return 'MULOP';
"-"|"+"                         return 'ADDOP';
"="                             return 'ASSIGN';
"^"                             return '^';

"("                             return 'LP';
")"                             return 'RP';
"{"                             return 'LC';
"}"                             return 'RC';
"["                             return 'LB';
"]"                             return 'RB';

","                             return 'COMMA';
"."                             return 'DOT';
";"                             return 'SEMICOLON';
":"                             return 'COLON';

<<EOF>>                         return 'EOF';

"if"                            return 'IF';
"else"                          return 'ELSE';
"do"                            return 'DO';
"while"                         return 'WHILE';
"function"                      return 'FUNC';
"for"                           return 'FOR';
"var"                           return 'VAR';


[a-zaA-Z_][a-zA-Z0-9_]*       return 'WORD';
\"[^"]*\"                     return 'STRING';
[0-9]+("."[0-9]+)?            return 'NUMBER';

/lex

%left 'COMMA'
%right 'ASSIGN'
%left 'LOGICOP'
%left 'ADDOP'
%left 'MULOP'

%nonassoc IF_WITHOUT_ELSE
%nonassoc ELSE

%start start
%%

%ebnf

start
   : program EOF {console.log($1.evaluate(topEnv))}
   ;

program
   : program statement  {$$ = makeApply('do', $1, $2)}
   | statement
   ;

block
   : LC RC
   | LC program RC {$$ = makeApply('do', $2)}
   ;

parameter_pairs
	: {$$ = []}
   | id COLON term                     {$$ = [new Value({value: $1.name}), $3]}
   | id COLON func                     {$$ = [new Value({value: $1.name}), $3]}
   | id COLON LC parameter_pairs RC    {$$ = [new Value({value: $1.name}), makeApply('object', ...$4)]}
   | value COLON term                    {$$ = [$1, $3]}
   | value COLON func                    {$$ = [$1, $3]}
   | value COLON LC parameter_pairs RC   {$$ = [$1, makeApply('object', ...$4)]}
	| parameter_pairs COMMA parameter_pairs {$$ = [...$1, ...$3]}
	;

statement
   : declaration
   | if_stmt
   | WHILE LP expr RP block {$$ = makeApply('while', $3, $5)}
   | DO block WHILE LP expr RP {$$ = makeApply('while', $5, $2)}
   | func 
   | block
   ;

if_stmt
   : IF LP expr RP block %prec IF_WITHOUT_ELSE {$$ = makeApply('if', $3, $5)}
	| IF LP expr RP block ELSE statement {$$ = makeApply('if', $3, $5, $7)}
   ;

func
   : FUNC LP parameter_list RP block {$$ = makeApply('fun', ...$3, $5);}
   | FUNC id LP parameter_list RP block {$$ = makeApply('def', $2, makeApply('fun', ...$4, $6));}
   ;

parameter_list
	: {$$ = []}
   | id                      {$$ = [$1]}
   | LC parameter_pairs RC {$$ = makeApply('object', ...$2)}
	| parameter_list COMMA parameter_list {$$ = [...$1, ...$3]}
	;

declaration
   : VAR id ASSIGN expr SEMICOLON {$$ = makeApply('def', $2, $4)}
   | VAR id ASSIGN LC parameter_pairs RC SEMICOLON {$$ = makeApply('def', $2, makeApply('object', ...$5))}
   | expr SEMICOLON {$$ = $1}
   ;

expr
   : id apply ASSIGN expr {$$ = makeApply(new Word({value: $3}), $1, ...$2, $4)}
   | id apply ASSIGN LC parameter_pairs RC {$$ = makeApply(new Word({value: $2}), $1, makeApply('object', ...$4))}
   | op 
   ;

op
   : op LOGICOP op {$$ = makeApply(new Word({value: $2}), $1, $3)}
   | op ADDOP op {$$ = makeApply(new Word({value: $2}), $1, $3)}
   | op MULOP op {$$ = makeApply(new Word({value: $2}), $1, $3)}
   | term
   ;

term
   : id apply {$2.forEach((e) => {
                  if(Array.isArray(e)) {$1 = makeApply($1, ...e)}
                  else {$1 = makeApply($1, e)}
               });
               $$ = $1}
   | value   
   ;

apply
   : {$$ = []}
   | apply DOT id {$$ = [...$1, new Value({value: $3.name})]}
   | apply LP expr_list RP {$$ = [...$1, $3]}
   | apply LB expr RB {$$ = [...$1, $3]}
   ;

expr_list
	: {$$ = []}
   | expr                      {$$ = [$1]}
	| expr_list COMMA expr_list {$$ = [...$1, ...$3]}
	;

id
   : WORD {$$ = new Word({value: yytext})}
   ;

value
   : NUMBER {$$ = new Value({value: Number(yytext)})}
   | STRING {$$ = new Value({value: yytext.substring(1, yytext.length-1)})}
   ;
