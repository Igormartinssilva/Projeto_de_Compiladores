#ifndef VALLEX_H
#define VALLEX_H

#define TT_ID 0
#define TT_LIT_INT 1
#define TT_LIT_FLOAT 2

struct valLex{
      int line_number;
      int token_type;
      char* token_value;
};


struct valLex create(int line_number, int token_type, char* token_value);


#endif // VALLEX_H
