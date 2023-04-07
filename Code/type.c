#include"type.h"

Node *new_node(int is_terminal, int type, int type_val)
{
    //printf("%d %d %d\n",is_terminal, type, type_val);
    Node *p = (Node *)malloc(sizeof(Node));
    p->is_terminal = is_terminal;
    p->type = type;
    p->type_val.int_val = type_val;
    p->branches_num = 0;
    //printf("%d %d %d\n",is_terminal, type, type_val);
}

Node *new_node_f(int is_terminal, int type, float type_val)
{
    Node *p = (Node *)malloc(sizeof(Node));
    p->is_terminal = is_terminal;
    p->type = type;
    p->type_val.float_val = type_val;
    p->branches_num = 0;
}
void add_node(Node *par, Node *son)
{
    if (son != NULL)
        par->nodelist[(par->branches_num)++] = son;
}

void print(Node *root, int depth, symbol_node *symbol_list)
{
    //printf("%d %d\n",root->is_terminal,root->type);
    for (int i = 0; i < depth; i++)
    {
        printf("  ");
    }
    if (root->is_terminal)
    {
        switch (root->type)
        {
        // INT_,
        // FLOAT_,
        // OP_,
        // ID_,
        // SYM_,
        // TYPE_INT,
        // TYPE_FLOAT,
        // BRAC_,
        // KEY_
        case INT_:
            /* code */
            printf("INT: %d\n", root->type_val.int_val);
            break;
        case FLOAT_:
            printf("FLOAT: %f\n", root->type_val.float_val);
            break;
        case ID_:
            printf("ID: %s\n", symbol_list[root->type_val.int_val].name);
            break;
        case OP_:
        {
            switch (root->type_val.int_val)
            {
            case ADD_:
                printf("PLUS\n");
                break;
            case SUB_:
                printf("MINUS\n");
                break;
            case MUL_:
                printf("STAR\n");
                break;
            case DIV_:
                printf("DIV\n");
                break;
            case DOT_:
                printf("DOT\n");
                break;
            case NOT_:
                printf("NOT\n");
                break;
            case AND_:
                printf("AND\n");
                break;
            case OR_:
                printf("OR\n");
                break;
            case ASSIGNOP_:
                printf("ASSIGNOP\n");
                break;
            case RELOP_L:
            case RELOP_G:
            case RELOP_GE:
            case RELOP_LE:
            case RELOP_E:
            case RELOP_NE:
                printf("RELOP\n");
                break;
            default:
                break;
            }
        }
        break;
        case SYM_:
        {
            //printf("%d\n",root->type_val.int_val);
            switch (root->type_val.int_val)
            {
            case SEMI_:
                printf("SEMI\n");
                break;
            case COMMA_:
                printf("COMMA\n");
                break;
            default:
                break;
            }
        }
        break;
        case TYPE_INT:
            printf("TYPE: int\n");
            break;
        case TYPE_FLOAT:
            printf("TYPE: float\n");
            break;
        case BRAC_:
        {
            switch (root->type_val.int_val)
            {
            case LC_:
                printf("LC\n");
                break;
            case RC_:
                printf("RC\n");
                break;
            case LB_:
                printf("LB\n");
                break;
            case RB_:
                printf("RB\n");
                break;
            case LP_:
                printf("LP\n");
                break;
            case RP_:
                printf("RP\n");
                break;
            default:
                break;
            }
        }
        break;
        case KEY_:
        {
            switch (root->type_val.int_val)
            {
            case STRUCT_:
                printf("STRUCT\n");
                break;
            case RETURN_:
                printf("RETURN\n");
                break;
            case IF_:
                printf("IF\n");
                break;
            case ELSE_:
                printf("ELSE\n");
                break;
            case WHILE_:
                printf("WHILE\n");
                break;

            default:
                break;
            }
        }
        break;
        default:
            break;
        }
    }
    else
    {
        switch (root->type)
        {
        case PROGRAM_:
            printf("Program");
            break;
        case EXTDEFLIST_:
            printf("ExtDefList");
            break;
        case EXTDEF_:
            printf("ExtDef");
            break;
        case EXTDECLIST_:
            printf("ExtDecList");
            break;
        case SPECIFIER_:
            printf("Specifier");
            break;
        case STRUCTSPECIFIER_:
            printf("StructSpecifier");
            break;
        case OPT_TAG_:
            printf("OptTag");
            break;
        case TAG_:
            printf("Tag");
            break;
        case VARDEC_:
            printf("VarDec");
            break;
        case FUNDEC_:
            printf("FunDec");
            break;
        case VARLIST_:
            printf("VarList");
            break;
        case PARAMDEC_:
            printf("ParamDec");
            break;
        case COMPST_:
            printf("CompSt");
            break;
        case STMTLIST_:
            printf("StmtList");
            break;
        case STMT_:
            printf("Stmt");
            break;
        case DEFLIST_:
            printf("DefList");
            break;
        case DEF_:
            printf("Def");
            break;
        case DECLIST_:
            printf("DecList");
            break;
        case DEC_:
            printf("Dec");
            break;
        case EXP_:
            printf("Exp");
            break;
        case ARGS_:
            printf("Args");
            break;
        default:
            break;
        }
        printf(" (%d)\n", root->line);
        for (int i = 0; i < root->branches_num; i++)
        {
            print(root->nodelist[i], depth + 1, symbol_list);
        }
    }
}
