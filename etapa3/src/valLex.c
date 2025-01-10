#include "../include/valLex.h"


struct valLex create(int line_number, int token_type, char* token_value){
    struct valLex val;
    val.line_number = line_number;
    val.token_type = token_type;
    val.token_value = token_value;
    return val;
}