[![Work in Repl.it](https://classroom.github.com/assets/work-in-replit-14baed9a392b3a25080506f3b7b6d57f295ec2978f6f33ec97e36a161684cbe9.svg)](https://classroom.github.com/online_ide?assignment_repo_id=273227&assignment_repo_type=GroupAssignmentRepo)

Gramatica implementada:

```js
start
   : program EOF 
   ;

program
   : program statement 
   | statement
   ;

block
   : LC RC
   | LC program RC 
   ;

parameter_pairs
	:
    | id COLON term
    | id COLON func
    | id COLON LC parameter_pairs RC
    | value COLON term
    | value COLON func
    | value COLON LC parameter_pairs 
	| parameter_pairs COMMA parameter_pairs 
	;

statement
   : declaration
   | if_stmt
   | WHILE LP expr RP block 
   | DO block WHILE LP expr RP 
   | func 
   | block
   ;

if_stmt
   : IF LP expr RP block %prec IF_WITHOUT_ELSE 
   | IF LP expr RP block ELSE statement 
   ;

func
   : FUNC LP parameter_list RP block
   | FUNC id LP parameter_list RP block 
   ;

parameter_list
	:
    | id
    | LC parameter_pairs RC
	| parameter_list COMMA parameter_list
	;

declaration
   : VAR id ASSIGN expr SEMICOLON
   | VAR id ASSIGN LC parameter_pairs RC SEMICOLON
   | expr SEMICOLON
   ;

expr
   : id apply ASSIGN expr 
   | id apply ASSIGN LC parameter_pairs RC 
   | op 
   ;

op
   : op LOGICOP op 
   | op ADDOP op 
   | op MULOP op 
   | term
   ;

term
   : id apply 
   | value   
   ;

apply
   : 
   | apply DOT id 
   | apply LP expr_list RP 
   | apply LB expr RB 
   ;

expr_list
	: 
    | expr 
	| expr_list COMMA expr_list 
	;

id
   : WORD 
   ;

value
   : NUMBER 
   | STRING 
   ;
```