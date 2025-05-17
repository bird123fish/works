%option noyywrap
%{
#include <iostream>
#include <string>
#include <iomanip>

#include "SyntaxTree.hpp"
#include "parser.hpp"

// 统一 Token 编号（与测试用例一致）
#define INT          258
#define VOID         259
#define IDENT        263
#define INT_CONST    275
#define RETURN       262
#define LPAREN       269
#define RPAREN       270
#define LBRACE       273
#define RBRACE       274
#define ASSIGN       285
#define COMMA        286
#define SEMICOLON    287
#define ADD          264
#define SUB          265
#define MUL          266
#define DIV          267
#define GREATER      277
#define EQUAL        278
#define IF           260
#define ELSE         261
#define ERROR        0

int line_number = 0;        // 行号从0开始
int column_start_number = 1; // token 起始列号（列号从1开始计数）
int column_end_number = 1;   // token 结束列号

int current_token;

bool is_head_print;
void print_msg(std::ostream &out) {
    if (!is_head_print) {
        out << std::setw(10) << "Token"
            << std::setw(10) << "Text"
            << std::setw(10) << "line"
            << std::setw(10) << "(s,e)"
            << std::endl;
        is_head_print = true;
    }
    out << std::setw(10) << current_token
        << std::setw(10) << yytext
        << std::setw(10) << line_number
        << std::setw(10) << "(" << column_start_number << "," << column_end_number << ")" 
        << std::endl;
}

int handle_token(int token) {
    current_token = token;
    column_start_number = column_end_number; // 记录起始列
    yylval.symbol_size = strlen(yytext);
    yylval.current_symbol = new char[yylval.symbol_size + 1];
    strcpy(yylval.current_symbol, yytext);
    column_end_number += strlen(yytext); // 更新结束列
    print_msg(std::cout);
    return token;
}
%}

%%

// 注释处理
\/\*([^\*]|\*[^\/])*\*+\/  {
    for (unsigned i = 0; i < strlen(yytext); i++) {
        if (yytext[i] == '\n') {
            line_number++;
            column_end_number = 1; // 新行列号重置为1
        } else {
            column_end_number++;
        }
    }
}

\/\/.*  {
    column_end_number += strlen(yytext); // 单行注释，列号直接增加长度
}

// 关键字
int         { return handle_token(INT); }
void        { return handle_token(VOID); }
if          { return handle_token(IF); }
else        { return handle_token(ELSE); }
return      { return handle_token(RETURN); }

// 标识符
[a-zA-Z_][a-zA-Z_0-9]* { return handle_token(IDENT); }

// 整数常量
[0-9]+      { return handle_token(INT_CONST); }

// 运算符（注意优先级：先匹配双字符运算符）
"=="        { return handle_token(EQUAL); }
">="        { return handle_token(GREATER_EQUAL); } // 测试用例未涉及，可按需添加
"<="        { return handle_token(LESS_EQUAL); }    // 测试用例未涉及，可按需添加
"!="        { return handle_token(NOT_EQUAL); }     // 测试用例未涉及，可按需添加
"+"         { return handle_token(ADD); }
"-"         { return handle_token(SUB); }
"*"         { return handle_token(MUL); }
"/"         { return handle_token(DIV); }
">"         { return handle_token(GREATER); } // 测试用例007_if.txt中的">"

// 括号与标点
"("         { return handle_token(LPAREN); }
")"         { return handle_token(RPAREN); }
"{"         { return handle_token(LBRACE); }
"}"         { return handle_token(RBRACE); }
","         { return handle_token(COMMA); }
";"         { return handle_token(SEMICOLON); }
"="         { return handle_token(ASSIGN); } // 注意：放在双字符运算符之后

// 空白字符处理
\n          {
    line_number++;                // 换行后行号+1
    column_start_number = 1;      // 新行起始列号为1
    column_end_number = 1;        // 新行结束列号初始为1
}

[ \r]       { column_end_number += strlen(yytext); } // 空格和回车，列号直接增加长度
\t          { column_end_number += 1; }              // 制表符视为单个字符，列号+1

// 错误处理
.           { 
    std::cerr << "Error: Invalid character '" << yytext[0] << "' at line " 
              << line_number << ", column " << column_start_number << std::endl;
    return handle_token(ERROR); 
}

%%