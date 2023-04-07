#include"type.h"
#include"sdt.h"
extern struct Node *root;
extern symbol_node symbol_list[MAX_SYMBOL_LIST_LEN];
extern int symbol_list_num;

//we use the completed parsing-tree and symbol_list (which was constructed in .l) *root to analyze
//and symbol_list only stores the IDs' name-string,
//so we build a new symbol table which has more inf through traversing the parsing tree



int test11()  //test for link ,  no use
{
    //sjy hao sao
    return symbol_list_num+root->type;
}

symbol_entry symbol_table[MAX_SYMBOL_TABLE_LEN]; //the real symbol table
int symbol_entry_num;

void dfs_parsing_tree(Node* r)
{
    for(int i=0;i<r->branches_num;i++) //terminal symbol will pass this
    {
        dfs_parsing_tree(r->nodelist[i]);
    }

    // TODO: process the node now
    if(r->is_terminal==1)  //terminal symbol, INT, ID, FLOAT
    {
        if(r->type==ID_)
        {
            //maybe do nothing
        }
        else if(r->type==INT_)
        {

        }
        else if(r->type==FLOAT_)
        {

        }
    }
    else
    {
        if(r->pro_no==4)//int a,b,c;
        {
            if(r->nodelist[0]->pro_no==)
            {
                
            }
        }
        
    }
}

void symantic_analize()
{
    dfs_parsing_tree(root);
    return;
}

