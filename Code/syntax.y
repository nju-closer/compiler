%{
    #define YYDEBUG 1
#include <stdio.h>
#include "lex.yy.c"
struct Node *root=NULL;
int flag = 0;
int errline;
void print_error(char *err);
%}

%union{
    int type_op;
    int type_int;
    int type_id;
    int type_sym;
    int type_type;
    int type_brac;
    int type_key;
    float type_float;
    struct Node *root;
}

/* declared tokens */
%token <type_int> INT
%token <type_float> FLOAT
%token <type_op> ADD SUB MUL DIV DOT NOT AND OR
%token <type_id> ID
%token <type_sym> SEMI COMMA ASSIGNOP RELOP 
%token <type_type> TYPE
%token <type_brac> LC RC LB RB LP RP
%token <type_key> STRUCT RETURN IF ELSE WHILE

%type <root> Program ExtDefList ExtDef ExtDecList
%type <root> OptTag Tag VarDec FunDec VarList ParamDec
%type <root> CompSt StmtList Stmt
%type <root> DefList Def DecList Dec
%type <root> Exp Args
%type <root> Specifier StructSpecifier


%right ASSIGNOP
%left OR
%left AND
%left RELOP
%left ADD SUB
%left MUL DIV
%right NOT
%nonassoc MINUS

%left DOT LP RP LB RB

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%


//High-level Definitions
Program : 
ExtDefList 
{   
    Node *p = new_node(0, PROGRAM_, 0);
    add_node(p, $1);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    p->pro_no=1;
    $$ = p;
    root = $$;
    
}
;

ExtDefList : ExtDef ExtDefList {
    Node *p = new_node(0, EXTDEFLIST_, 0);
    // p->line = (@$).first_line;
    p->line = ($1) -> line;
    p->pro_no=2;
    add_node(p, $1);
    add_node(p, $2);
    $$ = p;
}
| /* empty */{
    Node *p = new_node(0, EXTDEFLIST_, 0);
    //p->line = (@$).first_line + 1;
    p->line = yylineno;
    p->pro_no=3;
    $$ = NULL;
    }
;

ExtDef : Specifier ExtDecList SEMI {
    Node *p = new_node(0, EXTDEF_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    add_node(p, $2);
    Node *q = new_node(1, SYM_, SEMI_);
    add_node(p, q);
    p->pro_no=4;
    $$ = p; 

    }//类型 + 声明列表 + ; int a,b;
| Specifier SEMI {
    Node *p = new_node(0, EXTDEF_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    Node *q = new_node(1, SYM_, SEMI_);
    add_node(p, q);
    p->pro_no=5;
    $$ = p;
} //int;
| Specifier FunDec CompSt {
    Node *p = new_node(0, EXTDEF_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    add_node(p, $2);
    add_node(p, $3);
    p->pro_no=6;
    $$ = p;
}//int f() {}
|Specifier error SEMI{Node *p = new_node(0, 0, 0);$$ = p;yyerrok;flag = 1;}
|error SEMI{Node *p = new_node(0, 0, 0);$$ = p;yyerrok;flag = 1;}
;

ExtDecList : VarDec {
    Node *p = new_node(0, EXTDECLIST_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    $$ = p;

}//int a中的a/int a[10]中的a[10]
|VarDec COMMA ExtDecList {
    Node *p = new_node(0, EXTDECLIST_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    Node* q = new_node(1, SYM_, $2);
    add_node(p, q);
    add_node(p, $3);
    $$ = p;
}//int a,b,c中的a,b,c
;

//Specifiers
Specifier : TYPE {
    Node *p = new_node(0, SPECIFIER_, 0);
    p->line = (@$).first_line;
    Node* q;
    q = new_node(1, $1, 0);
    add_node(p, q);
    $$ = p;
}//int | float
|StructSpecifier {
    Node *p = new_node(0, SPECIFIER_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    $$ = p;
}//struct
;

StructSpecifier : STRUCT OptTag LC DefList RC {
    Node *p = new_node(0, STRUCTSPECIFIER_, 0);
    p->line = (@$).first_line;
    Node *q = new_node(1, KEY_, STRUCT_);
    add_node(p, q);
    add_node(p, $2);
    q = new_node(1, BRAC_, LC_);
    add_node(p, q);
    add_node(p, $4);
    q = new_node(1, BRAC_, RC_);
    add_node(p, q);
    $$ = p;
} //struct node {int a;}
|STRUCT Tag {
    Node *p = new_node(0, STRUCTSPECIFIER_, 0);
    p->line = (@$).first_line;
    Node *q = new_node(1, KEY_, STRUCT_);
    add_node(p, q);
    add_node(p, $2);
    $$ = p;
} //struct Complex a, b;中的struct Complex (Tag)

;

OptTag : ID {
    Node* p=new_node(0,OPT_TAG_,0);
    p->line = (@$).first_line;
    Node* q=new_node(1,ID_,$1);
    add_node(p,q);
    $$=p;
} //struct Complex{}中的Complex
|/*empty*/{
    Node* p=new_node(0,OPT_TAG_,0);
    //p->line = (@$).first_line + 1;
    p->line = yylineno;
    $$ = NULL;
    }
;

Tag : ID {
    Node* p = new_node(0, TAG_, 0);
    p->line = (@$).first_line;
    Node* q = new_node(1, ID_, $1);
    add_node(p, q);
    $$ = p;
} //struct Complex{} 中的Complex
;

//Declarators
VarDec : ID {
    Node* p = new_node(0, VARDEC_, 0);
    p->line = (@$).first_line;
    Node* q = new_node(1, ID_, $1);
    add_node(p, q);
    $$ = p;
} //int a;中的a
|VarDec LB INT RB {
    Node* p =new_node(0, VARDEC_, 0);
    p->line = (@$).first_line;
    add_node(p, $1);
    Node* q = new_node(1, BRAC_, $2);
    add_node(p, q);
    q = new_node(1, INT_, $3);
    add_node(p, q);
    q = new_node(1, BRAC_, RB_);
    add_node(p, q);
    $$ = p;
}//int a[10][2]中的a[10][2]

;

FunDec : ID LP VarList RP {
    Node *p = new_node(0, FUNDEC_, 0);
    p->line = (@$).first_line;
    Node *q = new_node(1, ID_, $1);
    add_node(p, q);
    q = new_node(1, BRAC_, $2);
    add_node(p, q);
    add_node(p, $3);
    q = new_node(1, BRAC_, $4);
    add_node(p, q);
    $$ = p;

}//函数头int f(int a,int b)
|ID LP RP {
    Node *p = new_node(0, FUNDEC_, 0);
    p->line = (@$).first_line;
    Node *q = new_node(1, ID_, $1);
    add_node(p, q);
    q = new_node(1, BRAC_, $2);
    add_node(p, q);
    q = new_node(1, BRAC_, $3);
    add_node(p, q);
    $$ = p;
}//f()
|error RP{Node *p = new_node(0, 0, 0);$$ = p;yyerrok; flag = 1;}
;

VarList : ParamDec COMMA VarList {
    Node *p = new_node(0, VARLIST_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    Node *q = new_node(1, SYM_, $2);
    add_node(p, q);
    add_node(p, $3);
    $$ = p;
}//形参列表f(int a,int b)中的int a,int b
|ParamDec {
    Node *p = new_node(0, VARLIST_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    $$ = p;
}//只有一个形参

;

ParamDec : Specifier VarDec {
    Node *p = new_node(0, PARAMDEC_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    add_node(p, $2);
    $$ = p;
}//类型+ID/类型+数组，int a /int a[10][2]
;

//Statements

CompSt : LC DefList StmtList RC {
    Node *p = new_node(0, COMPST_, 0);
    p->line = (@$).first_line;
    Node *q = new_node(1, BRAC_, $1);
    add_node(p, q);
    add_node(p, $2);
    add_node(p, $3);
    q = new_node(1, BRAC_, $4);
    add_node(p, q);
    $$ = p;
}//{局部声明+语句列表}
|error RC{Node *p = new_node(0, 0, 0);$$ = p;yyerrok;flag = 1;}
;

StmtList : Stmt StmtList {
    Node *p = new_node(0, STMTLIST_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    add_node(p, $2);
    $$ = p;

}//语句+语句列表
| /*empty*/{
    Node *p = new_node(0, STMTLIST_, 0);
    //p->line = (@$).first_line + 1;
    p->line = yylineno;
    $$ = NULL;
    }
;

Stmt : Exp SEMI {
    Node *p = new_node(0, STMT_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    Node *q = new_node(1, SYM_, $2);
    add_node(p, q);
    $$ = p;
}//表达式;
| CompSt {
    Node *p = new_node(0, STMT_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    $$ = p;
}//复合语句{...}
| RETURN Exp SEMI {
    Node *p = new_node(0, STMT_, 0);
    p->line = (@$).first_line;
    Node *q = new_node(1, KEY_, $1);
    add_node(p, q);
    add_node(p, $2);
    q = new_node(1, SYM_, $3);
    add_node(p, q);
    $$ = p;
}//return x;
| IF LP Exp RP Stmt %prec LOWER_THAN_ELSE{
    Node *p = new_node(0, STMT_, 0);
    p->line = (@1).first_line;
    Node *q = new_node(1, KEY_, $1);
    add_node(p, q);
    q = new_node(1, BRAC_, $2);
    add_node(p, q);
    add_node(p, $3);
    q = new_node(1, BRAC_, $4);
    add_node(p, q);
    add_node(p, $5);
    $$ = p;
}//if (表达式) 语句
| IF LP Exp RP Stmt ELSE Stmt {
    Node *p = new_node(0, STMT_, 0);
    p->line = (@1).first_line;
    Node *q = new_node(1, KEY_, $1);
    add_node(p, q);
    q = new_node(1, BRAC_, $2);
    add_node(p, q);
    add_node(p, $3);
    q = new_node(1, BRAC_, $4);
    add_node(p, q);
    add_node(p, $5);
    q = new_node(1, KEY_, $6);
    add_node(p, q);
    add_node(p, $7);
    $$ = p;
}//if (表达式) 语句 else 语句
| WHILE LP Exp RP Stmt {
    Node *p = new_node(0, STMT_, 0);
    p->line = (@$).first_line;
    Node *q = new_node(1, KEY_, $1);
    add_node(p, q);
    q = new_node(1, BRAC_, $2);
    add_node(p, q);
    add_node(p, $3);
    q = new_node(1, BRAC_, $4);
    add_node(p, q);
    add_node(p, $5);
    $$ = p;
}//while (表达式) 语句
|IF LP error RP Stmt ELSE Stmt{Node *p = new_node(0, 0, 0);$$ = p;yyerrok;flag=1;}
|IF LP error RP Stmt %prec LOWER_THAN_ELSE{Node *p = new_node(0, 0, 0);$$ = p;yyerrok;flag=1;}
|WHILE LP error RP Stmt{Node *p = new_node(0, 0, 0);$$ = p;yyerrok;flag=1;}
|RETURN error SEMI{Node *p = new_node(0, 0, 0);$$ = p;yyerrok;flag=1;}
|error Stmt{Node *p = new_node(0, 0, 0);$$ = p;yyerrok;flag=1;}
;

//Local Definitions

DefList : Def DefList {
    Node *p = new_node(0, DEFLIST_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    add_node(p, $2);
    $$ = p;
} //局部声明+局部声明列表
| /*empty*/{
    Node *p = new_node(0, DEFLIST_, 0);
    //p->line = (@$).first_line + 1;
    p->line = yylineno;
    $$ = NULL;
    }
;

Def : Specifier DecList SEMI {
    Node *p = new_node(0, DEF_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    add_node(p, $2);
    Node *q = new_node(1, SYM_, $3);
    add_node(p, q);
    $$ = p;
    
}//int a,b,c;
|Specifier DecList error SEMI{Node *p = new_node(0, 0, 0);$$ = p;yyerrok;flag = 1;}
|Specifier error SEMI{Node *p = new_node(0, 0, 0);$$ = p;yyerrok;flag =1;}
;

DecList : Dec {
    Node *p = new_node(0, DECLIST_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    $$ = p;
} //int a;中的a
| Dec COMMA DecList {
    Node *p = new_node(0, DECLIST_  , 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    Node *q = new_node(1, SYM_, $2);
    add_node(p, q);
    add_node(p, $3);
    $$ = p;
}//int a,b,c;中的a,b,c
;

Dec : VarDec {
    Node *p = new_node(0, DEC_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    $$ = p;
}//int a;中的a
| VarDec ASSIGNOP Exp {
    Node *p = new_node(0, DEC_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    Node *q = new_node(1, OP_, $2);
    add_node(p, q);
    add_node(p, $3);
    $$ = p;
}//用表达式初始化定义，int a = 5;中的a = 5
;

//Expressions

Exp : Exp ASSIGNOP Exp
{
    Node *p = new_node(0, EXP_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    Node *q = new_node(1, OP_, $2);
    add_node(p, q);
    add_node(p, $3);
    $$ = p;
} // 赋值表达式
| Exp AND Exp
{
    Node *p = new_node(0, EXP_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    Node *q = new_node(1, OP_, $2);
    add_node(p, q);
    add_node(p, $3);
    $$ = p;
} //&&操作
| Exp OR Exp
{
    Node *p = new_node(0, EXP_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    Node *q = new_node(1, OP_, $2);
    add_node(p, q);
    add_node(p, $3);
    $$ = p;
}
| Exp RELOP Exp
{
    Node *p = new_node(0, EXP_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    Node *q = new_node(1, OP_, $2);
    add_node(p, q);
    add_node(p, $3);
    $$ = p;
} // 比较
| Exp ADD Exp
{
    Node *p = new_node(0, EXP_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    Node *q = new_node(1, OP_, $2);
    add_node(p, q);
    add_node(p, $3);
    $$ = p;
}
| Exp SUB Exp
{
    Node *p = new_node(0, EXP_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    Node *q = new_node(1, OP_, $2);
    add_node(p, q);
    add_node(p, $3);
    $$ = p;
}
| Exp MUL Exp
{
    Node *p = new_node(0, EXP_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    Node *q = new_node(1, OP_, $2);
    add_node(p, q);
    add_node(p, $3);
    $$ = p;
}
| Exp DIV Exp
{
    Node *p = new_node(0, EXP_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    Node *q = new_node(1, OP_, $2);
    add_node(p, q);
    add_node(p, $3);
    $$ = p;
}
| LP Exp RP
{
    Node *p = new_node(0, EXP_, 0);
    p->line = (@1).first_line;
    Node *q = new_node(1, BRAC_, $1);
    add_node(p, q);
    add_node(p, $2);
    q = new_node(1, BRAC_, $3);
    add_node(p, q);
    $$ = p;
} // 括号表达式
| SUB Exp %prec MINUS{
    Node *p = new_node(0, EXP_, 0);
    p->line = (@1).first_line;
    Node *q = new_node(1, OP_, $1);
    add_node(p, q);
    add_node(p, $2);
    $$ = p;
} // 单目运算符-a
| NOT Exp{
    Node *p = new_node(0, EXP_, 0);
    p->line = (@1).first_line;
    Node *q = new_node(1, OP_, $1);
    add_node(p, q);
    add_node(p, $2);
    $$ = p;
} // 单目运算符!a
| ID LP Args RP{
    Node *p = new_node(0, EXP_, 0);
    p->line = (@1).first_line;
    Node *q = new_node(1, ID_, $1);
    add_node(p, q);
    q = new_node(1, BRAC_, $2);
    add_node(p, q);
    add_node(p, $3);
    q = new_node(1, BRAC_, $4);
    add_node(p, q);
    $$ = p;
} // 函数调用f(1,2)
| ID LP RP{
    Node *p = new_node(0, EXP_, 0);
    p->line = (@1).first_line;
    Node *q = new_node(1, ID_, $1);
    add_node(p, q);
    q = new_node(1, BRAC_, $2);
    add_node(p, q);
    q = new_node(1, BRAC_, $3);
    add_node(p, q);
    $$ = p;
} // 函数调用f()
| Exp LB Exp RB{
    Node *p = new_node(0, EXP_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    Node * q = new_node(1, BRAC_, $2);
    add_node(p, q);
    add_node(p, $3);
    q = new_node(1, BRAC_, $4);
    add_node(p, q);
    $$ = p;
} // 数组访问a[10][10]
| Exp DOT ID{
    Node *p = new_node(0, EXP_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    Node * q = new_node(1, OP_, $2);
    add_node(p, q);
    q = new_node(1, ID_, $3);
    add_node(p, q);
    $$ = p;

} // 成员访问a.x
| ID{
    Node *p = new_node(0, EXP_, 0);
    p->line = (@1).first_line;
    Node * q = new_node(1, ID_, $1);
    add_node(p, q);
    $$ = p;
} 
| INT{
    Node *p = new_node(0, EXP_, 0);
    p->line = (@1).first_line;
    Node * q = new_node(1, INT_, $1);
    add_node(p, q);
    $$ = p;
} 
| FLOAT{
    Node *p = new_node(0, EXP_, 0);
    p->line = (@1).first_line;
    Node * q = new_node_f(1, FLOAT_, $1);
    add_node(p, q);
    $$ = p;
}
|LP error RP {Node *p = new_node(0, 0, 0);$$ = p;$$ = p;yyerrok;flag=1;}
|Exp LB error RB {Node *p = new_node(0, 0, 0);$$ = p;yyerrok;flag=1;}

;

Args : Exp COMMA Args {
    Node *p = new_node(0, ARGS_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    Node *q = new_node(1, SYM_, $2);
    add_node(p, q);
    add_node(p, $3);
    $$ = p;
}//实参列表1,2,3+2
| Exp {
    Node *p = new_node(0, ARGS_, 0);
    // p->line = (@$).first_line;
    p->line = ($1)->line;
    add_node(p, $1);
    $$ = p;
}//一个实参
;


%%
yyerror(char* msg)
{
    // printf("%d\n",yylval.type_brac);
    flag = 1;
    fflush(stdout);
    printf("Error type B at Line %d: %s.\n", yylineno, msg);
}

void print_error(char *err)
{
    //printf("Error type B at Line %d: %s.\n", yylineno, err);
}

void print_tree()
{
    print(root, 0, symbol_list);
}

