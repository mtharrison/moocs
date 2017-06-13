/*
 *  The scanner definition for COOL.
 */

/*
 *  Stuff enclosed in %{ %} in the first section is copied verbatim to the
 *  output, so headers and global definitions are placed here to be visible
 * to the code in the file.  Don't remove anything that was here initially
 */
%{

/*
Tokens:

CLASS - done
ELSE
FI
IF
IN
INHERITS - done
LET
LOOP
POOL
THEN
WHILE
CASE
ESAC
OF
DARROW - done
NEW - done
ISVOID - done
STR_CONST - done
INT_CONST - done
BOOL_CONST
TYPEID - done
OBJECTID
ASSIGN
NOT
LE
ERROR
LET_STMT
*/

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
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

%}

/* *** DECLARATIONS *** */

/* Keywords */

CLASS           ?i:class
INHERITS        ?i:inherits
ISVOID          ?i:isvoid
NEW             ?i:new

/* Operators */

DARROW          =>

/* Names */

OBJECTID  {LCASE}({UCASE}|{LCASE}|[_])+
TYPEID    {UCASE}({UCASE}|{LCASE}|[_])+

/* Values */

INT_CONST       [0-9]+
STR_CONST       \".*\"

/* Other */

LCASE           [a-z]
UCASE           [A-Z]
WHITESPACE      [\f\r\v\t\n ]+
LCB             \{
RCB             \}
LPRN            \(
RPRN            \)
COLN            \:
CMMA            \,
SEMI            \;
PERD            \.

%%

 /* *** RULES *** */

 /* Keywords */

{CLASS}     { return CLASS; }
{INHERITS}  { return INHERITS; }
{ISVOID}    { return ISVOID; }
{NEW}       { return NEW; }

 /* Operators */

{DARROW} { return DARROW; }

 /* Names */

{OBJECTID} { cool_yylval.symbol = idtable.add_string(yytext); return OBJECTID; }
{TYPEID}   { cool_yylval.symbol = idtable.add_string(yytext); return TYPEID; }

 /* Values */

{INT_CONST} { cool_yylval.symbol = inttable.add_string(yytext); return INT_CONST; }
{STR_CONST} { cool_yylval.symbol = stringtable.add_string(yytext); return STR_CONST; }

 /* Other */

{WHITESPACE} { }
{LCB}        { return int('{'); }
{RCB}        { return int('}'); }
{LPRN}       { return int('('); }
{RPRN}       { return int(')'); }
{COLN}       { return int(':'); }
{CMMA}       { return int(','); }
{SEMI}       { return int(';'); }
{PERD}       { return int('.'); }

 /* String constants (C syntax) */

%%
