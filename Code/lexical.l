%{
/* 此处省略#include部分 */
    #include"syntax.tab.h"
    #include"type.h"
    #include<string.h>
    #include<stdio.h>
    symbol_node symbol_list[MAX_SYMBOL_LIST_LEN];
    int symbol_list_num = 0;
    int yycolumn = 1;
    int is_error = 0;
    #define YY_USER_ACTION \
    yylloc.first_line = yylloc.last_line = yylineno; \
    yylloc.first_column = yycolumn; \
    yylloc.last_column = yycolumn + yyleng - 1; \
    yycolumn += yyleng;


%}
delim " "|\t
SEMI ";"
COMMA ","
ASSIGNOP "="
RELOP >|<|>=|<=|==|!=
PLUS "+"
MINUS "-"
STAR "*"
DIV "/"
AND "&&"
OR "||"
DOT "."
NOT "!"
TYPE "int"|"float"
LP "("
RP ")"
LB "["
RB "]"
LC "{"
RC "}"
STRUCT "struct"
RETURN "return"
IF "if"
ELSE "else"
WHILE "while"
int8 "0"{1}[0-7]+
int16 "0x"{1}([0-9]|[a-fA-F])+
float ("0"|[1-9]+[0-9]*\.?[0-9]*)([eE][+-]?[0-9]+)?
int "0"|([1-9]+[0-9]*)
ID ([a-zA-Z]|_)+([a-zA-Z]|[0-9]|_)*

%%
{delim}+ {}
\n { yycolumn = 1; yylineno++;}
{SEMI} {yylval.type_sym = SEMI_;return SEMI;}
{COMMA} {yylval.type_sym = COMMA_;return COMMA;} 
{ASSIGNOP} {yylval.type_op = ASSIGNOP_;return ASSIGNOP;}
{RELOP} {yylval.type_op = get_relop(yytext);return RELOP;}
{PLUS} {yylval.type_op = ADD_;return ADD;}
{MINUS} {yylval.type_op = SUB_;return SUB;}
{STAR} {yylval.type_op = MUL_;return MUL;}
{DIV} {yylval.type_op = DIV_;return DIV;}
{AND} {yylval.type_op = AND_;return AND;}
{OR} {yylval.type_op = OR_;return OR;}
{DOT} {yylval.type_op = DOT_;return DOT;}
{NOT} {yylval.type_op = NOT_;return NOT;}
{TYPE} {yylval.type_type = get_type(yytext);return TYPE;}
{LP} {yylval.type_brac = LP_;return LP;}
{RP} {yylval.type_brac = RP_;return RP;}
{LB} {yylval.type_brac = LB_;return LB;}
{RB} {yylval.type_brac = RB_;return RB;}
{LC} {yylval.type_brac = LC_;return LC;}
{RC} {yylval.type_brac = RC_;return RC;}
{STRUCT} {yylval.type_key = STRUCT_;return STRUCT;}
{RETURN} {yylval.type_key = RETURN_;return RETURN;}
{IF} {yylval.type_key = IF_;return IF;}
{ELSE} {yylval.type_key = ELSE_;return ELSE;}
{WHILE} {yylval.type_key = WHILE_;return WHILE;}
{int8} {yylval.type_int= x_to_ten(yytext, 1);return INT;}
{int16} {yylval.type_int= x_to_ten(yytext, 2);return INT;}
{int} {yylval.type_int= atoi(yytext);return INT;}
{float} {yylval.type_float = atof(yytext);return FLOAT;}
{ID} {symbol_list[symbol_list_num].name = (char *)malloc(sizeof(char) * 1000);strcpy(symbol_list[symbol_list_num].name, yytext);yylval.type_id = symbol_list_num++;return ID;}
. {is_error = 1;printf("Error type A at Line %d: Mysterious characters \'%s\'\n",yylineno, yytext);}
%%

int x_to_ten(char *src,int base)
{
    int ans = 0;
    int len = strlen(src);
    for(int i = base;i < len;i++)
    {
        if(base == 1)
            ans = ans * 8 + src[i] - '0';
        else if(base == 2)
        {
            if(src[i] >= '0' && src[i] <= '9')
                ans = ans * 16 + src[i] - '0';
            else if(src[i] >= 'a' && src[i] <= 'f')
                ans = ans * 16 + src[i] - 'a' + 10;
            else if(src[i] >= 'A' && src[i] <= 'F')
                ans = ans * 16 + src[i] - 'A' + 10;

        }
    }
    return ans;
}

int get_relop(char *src)
{
    if(strcmp(src,"==") == 0)
        return RELOP_E;
    else if(strcmp(src,"!=") == 0)
        return RELOP_NE;
    else if(strcmp(src,">") == 0)
        return RELOP_G;
    else if(strcmp(src,"<") == 0)
        return RELOP_L;
    else if(strcmp(src,">=") == 0)
        return RELOP_GE;
    else if(strcmp(src,"<=") == 0)
        return RELOP_LE;
    else
        return -1;
}

int get_type(char *src)
{
    if(strcmp(src,"float") == 0)
        return TYPE_FLOAT;
    else if(strcmp(src,"int") == 0)
        return TYPE_INT;
    else
        return -1;
}


