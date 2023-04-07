#include <stdio.h>
int yyparse();
int yyrestart(FILE *f);
void print_tree();     //defined in syntax.y to print parsing tree

void symantic_analize();

int yydebug;
extern int flag;       //will be setted in syntax.y
extern int is_error;   //will be setted in lexical.l
extern struct Node *root;

int test11();
int main(int argc, char **argv)
{
    if (argc <= 1)
        return 1;
    FILE *f = fopen(argv[1], "r");
    if (!f)
    {
        perror(argv[1]);
        return 1;
    }
    // yylex();
    yyrestart(f);
    //yydebug = 1;
    yyparse();
    if(!is_error && !flag)
    {
        print_tree();
        // printf("%8d%8d%8d\n", lines, words, chars);
        symantic_analize();
    }
    printf("%d\n",test11());
    return 0;
}
