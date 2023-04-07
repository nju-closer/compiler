#define MAX_SYMBOL_TABLE_LEN 1000


typedef struct array   //to describe array
{
    union 
    {
        int base_type;  // the last dim of the array,int or float
        struct array* next_type;
    } type;
    int size;
} array;


typedef struct type_des //to describe type
{
    int type;   //int ,float, or array, or struct
    array* ary;
    //TODO: the description of struct type
} type_des;


typedef struct func_des  //to describe the func(dont need name-list which is in symol table)
{
    type_des return_type;  //the type of return value
    int num_para;          //the num of parameter;
    // because the the parameters' action scope is global,so use the pointers of symbols 
    struct symbol_entry* para_list[10];

}func_des;

typedef struct symbol_entry
{
    char *name;
    int def_position;
    //TODO: more information, refering menual P60
    int func_or_var;   //   0 func   ; 1 var
    union{
        type_des* var_type;
        func_des* func_type;

    }type;
} symbol_entry;
