#include <stdlib.h>
#include <stdio.h>
#define MAX_BRANCHES_LEN 10
#define MAX_SYMBOL_LIST_LEN 1000
enum terminal_type
{
    INT_,
    FLOAT_,
    ID_,
    OP_,
    SYM_,
    TYPE_INT,
    TYPE_FLOAT,
    BRAC_,
    KEY_

};
enum no_terminal_type
{
    PROGRAM_,
    EXTDEFLIST_,
    EXTDEF_,
    EXTDECLIST_,
    SPECIFIER_,
    STRUCTSPECIFIER_,
    OPT_TAG_,
    TAG_,
    VARDEC_,
    FUNDEC_,
    VARLIST_,
    PARAMDEC_,
    COMPST_,
    STMTLIST_,
    STMT_,
    DEFLIST_,
    DEF_,
    DECLIST_,
    DEC_,
    EXP_,
    ARGS_
};
enum op_type
{
    ADD_,
    SUB_,
    MUL_,
    DIV_,
    DOT_,
    NOT_,
    AND_,
    OR_,
    ASSIGNOP_,
    RELOP_L,
    RELOP_G,
    RELOP_GE,
    RELOP_LE,
    RELOP_E,
    RELOP_NE
};
enum sym_type
{
    SEMI_,
    COMMA_
};
enum brac_type
{
    LC_,
    RC_,
    LB_,
    RB_,
    LP_,
    RP_
};

enum key_type
{
    STRUCT_,
    RETURN_,
    IF_,
    ELSE_,
    WHILE_
};
typedef struct symbol_node
{
    char *name;
    int type;
} symbol_node;

typedef struct Node
{
    /* data */
    int is_terminal;
    int type;
    union
    {
        /* data */
        int int_val;
        float float_val;
    } type_val;
    int branches_num;
    int line;
    int pro_no;
    struct Node *nodelist[MAX_BRANCHES_LEN];
} Node;

Node *new_node(int is_terminal, int type, int type_val);
Node *new_node_f(int is_terminal, int type, float type_val);
void add_node(Node *par, Node *son);
void print(Node *root, int depth, symbol_node *symbol_list);