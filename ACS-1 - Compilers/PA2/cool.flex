
/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{
#include <cool-parse.h>
#include <stringtab.h>
#include <utilities.h>

/* The compiler assumes these identifiers. */
#define yylval cool_yylval
#define yylex  cool_yylex

/* Max size of string constants */
#define MAX_STR_CONST 1025
#define YY_NO_UNPUT   /* keep g++ happy */

extern FILE *fin; /* we read from this file */

/* define YY_INPUT so we read from the FILE fin:
 * This change makes it possible to use this scanner in
 * the Cool compiler.
 */
#undef YY_INPUT
#define YY_INPUT(buf,result,max_size) \
  if ( (result = fread( (char*)buf, sizeof(char), max_size, fin)) < 0) \
    YY_FATAL_ERROR( "read() in flex scanner failed");

char string_buf[MAX_STR_CONST]; /* to assemble string constants */
char *string_buf_ptr;

extern int curr_lineno;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

 /* Error messages */
#define UNTERMINATED_STR_ERR "Unterminated string constant"
#define EOF_IN_STR_ERR "EOF in string constant"
#define NULL_IN_STR_ERR "String contains null character"
#define TOO_LONG_STR_ERR "String constant too long"
#define EOF_IN_COMMENT "EOF in comment"
#define UNMATCHED_COMMENT_ERR "Unmatched *)"

 /* Check whether a current string in the buffer is too long */
bool is_string_too_long(void);
 /* To support nested comments */
int open_comment_cnt;

%}

%option noyywrap

/*
 * Define names for regular expressions here.
 */
ID_CHAR [a-zA-Z0-9_]

/*
 * Start conditions.
 */
%x COMMENT STRING STRING_ERR
%%

 /*
  * Define regular expressions for the tokens of COOL here. Make sure, you
  * handle correctly special cases, like:
  *   - Nested comments
  *   - String constants: They use C like systax and can contain escape
  *     sequences. Escape sequence \c is accepted for all characters c. Except
  *     for \n \t \b \f, the result is c.
  *   - Keywords: They are case-insensitive except for the values true and
  *     false, which must begin with a lower-case letter.
  *   - Multiple-character operators (like <-): The scanner should produce a
  *     single token for every such operator.
  *   - Line counting: You should keep the global variable curr_lineno updated
  *     with the correct line number
  */

 /* Multi-line Comment */
<INITIAL,COMMENT>"(*" {
    BEGIN(COMMENT);
    ++open_comment_cnt;
}

<COMMENT><<EOF>> {
    BEGIN(INITIAL);
    yylval.error_msg = EOF_IN_COMMENT;
    return ERROR;
}

<COMMENT>"*)" {
    --open_comment_cnt;
    if (!open_comment_cnt)
        BEGIN(INITIAL);
}

<INITIAL>"*)" {
    yylval.error_msg = UNMATCHED_COMMENT_ERR;
    return ERROR;
}

<COMMENT>\n { ++curr_lineno; }

<COMMENT>. { /* Discard strings */ }

 /* Single-line Comment */
<INITIAL>--.* { /* Discard strings */ }

 /* Strings */
<INITIAL>\" {
    BEGIN(STRING);
    string_buf_ptr = string_buf;
}

<STRING>\" {
    BEGIN(INITIAL);
    *string_buf_ptr = '\0';
    yylval.symbol = stringtable.add_string(string_buf);
    return STR_CONST;
}

<STRING>\n {
    BEGIN(INITIAL);
    yylval.error_msg = UNTERMINATED_STR_ERR;
    ++curr_lineno;
    return ERROR;
}

<STRING><<EOF>> {
    BEGIN(INITIAL);
    yylval.error_msg = EOF_IN_STR_ERR;
    return ERROR;
}

<STRING>\0 {
    yylval.error_msg = NULL_IN_STR_ERR;
    return ERROR;
}

<STRING>\\\n {
    ++curr_lineno;
    *string_buf_ptr++ = '\n';
}

<STRING>\\. {
    if (is_string_too_long())
        return ERROR;

    char escaped = yytext[1];
    switch (escaped) {
    case 'n':
        *string_buf_ptr = '\n';
        break;
    case 't':
        *string_buf_ptr = '\t';
        break;
    case 'b':
        *string_buf_ptr = '\b';
        break;
    case 'f':
        *string_buf_ptr = '\f';
        break;
    default:
        *string_buf_ptr = escaped;
        break;
    }
    ++string_buf_ptr;
}

<STRING>. {
    if (is_string_too_long())
        return ERROR;
    *string_buf_ptr++ = yytext[0];
}

<STRING_ERR>\n {
    BEGIN(INITIAL);
    ++curr_lineno;
}

<STRING_ERR>\" { BEGIN(INITIAL); }

<STRING_ERR>. { /* Discard strings */ }

 /* Keywords */
(?i:class) { return CLASS; }
(?i:else) { return ELSE; }
(?i:fi) { return FI; }
(?i:if) { return IF; }
(?i:in) { return IN; }
(?i:inherits) { return INHERITS; }
(?i:isvoid) { return ISVOID; }
(?i:let) { return LET; }
(?i:loop) { return LOOP; }
(?i:pool) { return POOL; }
(?i:then) { return THEN; }
(?i:while) { return WHILE; }
(?i:case) { return CASE; }
(?i:esac) { return ESAC; }
(?i:new) { return NEW; }
(?i:of) { return OF; }
(?i:not) { return NOT; }
f(?i:alse) {
    yylval.boolean = 0;
    return BOOL_CONST;
}
t(?i:rue) {
    yylval.boolean = 1;
    return BOOL_CONST;
}

 /* Integers */
[0-9]+ {
    yylval.symbol = inttable.add_string(yytext);
    return INT_CONST;
}

 /* Type Identifiers */
[A-Z]{ID_CHAR}* {
    yylval.symbol = inttable.add_string(yytext);
    return TYPEID;
}

 /* Object Identifiers */
[a-z]{ID_CHAR}* {
    yylval.symbol = inttable.add_string(yytext);
    return OBJECTID;
}

 /* Special Notation */
"<-" { return ASSIGN; }
"<=" { return LE; }
"=>" { return DARROW; }
[{}()@,.+\-*/~<=:;] { return yytext[0]; }

 /* White Space */
\n { ++curr_lineno; }
[ \n\f\r\t\v] { /* Discard strings */ }

 /* An invalid character */
. {
    yylval.error_msg = yytext;
    return ERROR;
}

%%
bool is_string_too_long() {
    int str_len = string_buf_ptr - string_buf;
    if (str_len >= MAX_STR_CONST - 1) {
        BEGIN(STRING_ERR);
        yylval.error_msg = TOO_LONG_STR_ERR;
        return true;
    }

    return false;
}
