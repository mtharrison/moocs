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

#define CHECK_SIZE()  \
    if ((strlen(string_buf) + 1) >= MAX_STR_CONST) { \
        BEGIN STRINGERROR; \
        cool_yylval.error_msg = "String contains escaped null character."; \
        return ERROR; \
    }

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

int comments = 0;

extern int curr_lineno;
extern int verbose_flag;

extern YYSTYPE cool_yylval;

/*
 *  Add Your own definitions here
 */

%}

/* *** DECLARATIONS *** */

/* Keywords */

CASE            ?i:case
CLASS           ?i:class
ELSE            ?i:else
ESAC            ?i:esac
FI              ?i:fi
IF              ?i:if
IN              ?i:in
INHERITS        ?i:inherits
ISVOID          ?i:isvoid
LET             ?i:let
LOOP            ?i:loop
NEW             ?i:new
POOL            ?i:pool
THEN            ?i:then
WHILE           ?i:while
NOT             ?i:not
OF              ?i:of

/* Operators */

DARROW          =>
ASSIGN          <-
LE              <=

/* Values */

INT_CONST       [0-9]+
BOOL_TRUE       t(?i:rue)
BOOL_FALSE      f(?i:alse)

/* Names */

OBJECTID  {LCASE}({UCASE}|{LCASE}|{DIGIT}|[_])*
TYPEID    {UCASE}({UCASE}|{LCASE}|{DIGIT}|[_])*

/* Comments */

SNGL_CMMT       --.*
SRT_CMMT        \(\*
END_CMNT        \*\)

/* Other */

LCASE           [a-z]
UCASE           [A-Z]
DIGIT           [0-9]
WHITESPACE      [\f\r\v\t ]+
NEWLINE         \n
LCB             \{
RCB             \}
LPRN            \(
RPRN            \)
COLN            \:
CMMA            \,
SEMI            \;
PERD            \.
EQAL            \=
PLUS            \+
MNUS            \-
TIMS            \*
DIVD            \/
LT              \<
TILDE           \~
AT              \@

ANY_CHAR		.

%x COMMENT STRING STRINGERROR

%%

 /* *** RULES *** */

 /* Keywords */

{CASE}      { return CASE; }
{CLASS}     { return CLASS; }
{ELSE}      { return ELSE; }
{ESAC}      { return ESAC; }
{FI}        { return FI; }
{IF}        { return IF; }
{IN}        { return IN; }
{INHERITS}  { return INHERITS; }
{ISVOID}    { return ISVOID; }
{LET}       { return LET; }
{LOOP}      { return LOOP; }
{NEW}       { return NEW; }
{POOL}      { return POOL; }
{THEN}      { return THEN; }
{WHILE}     { return WHILE; }
{NOT}       { return NOT; }
{OF}        { return OF; }

 /* Operators */

{ASSIGN} { return ASSIGN; }
{DARROW} { return DARROW; }
{LE}     { return LE; }

 /* Values */

{BOOL_TRUE}                 { cool_yylval.boolean = true; return BOOL_CONST; }
{BOOL_FALSE}                { cool_yylval.boolean = false; return BOOL_CONST; }
{INT_CONST}                 { cool_yylval.symbol = inttable.add_string(yytext); return INT_CONST; }


 /* Strings */

<INITIAL>\" {
    strcpy(string_buf, "");
    BEGIN STRING;
}

<STRING>\" {
    BEGIN INITIAL;
    cool_yylval.symbol = stringtable.add_string(string_buf);
    return STR_CONST;
}

<STRING>\\b                 { CHECK_SIZE(); strcat(string_buf, "\b"); }
<STRING>\\t                 { CHECK_SIZE(); strcat(string_buf, "\t"); }
<STRING>\\n                 { CHECK_SIZE(); strcat(string_buf, "\n"); }
<STRING>\\f                 { CHECK_SIZE(); strcat(string_buf, "\f"); }

<STRING>\\\0  {
    BEGIN STRINGERROR;
    cool_yylval.error_msg = "String contains escaped null character.";
    return ERROR;
}

<STRING>\0  {
    BEGIN STRINGERROR;
    cool_yylval.error_msg = "String contains null character.";
    return ERROR;
}

<STRING>\\.                 { CHECK_SIZE(); strcat(string_buf, yytext + 1); }
<STRING>\\\n                { CHECK_SIZE(); strcat(string_buf, "\n"); }

<STRING>\n {
    cool_yylval.error_msg = "Unterminated string constant";
    BEGIN INITIAL;
    return ERROR;
}

<STRING><<EOF>>             {
    cool_yylval.error_msg = "EOF in string constant";
    BEGIN INITIAL;
    return ERROR;
}

<STRINGERROR>[^\\]\n    { BEGIN(INITIAL); }
<STRINGERROR>\"         { BEGIN(INITIAL); }
<STRINGERROR>.          {}
<STRINGERROR>\n         {}

 /* Comments */

{SNGL_CMMT}                  { }
<INITIAL>\*\)				 { cool_yylval.error_msg = "Unmatched *)"; return ERROR; }
<INITIAL,COMMENT>{SRT_CMMT}  { comments++; BEGIN COMMENT; }
<COMMENT>{END_CMNT}          { comments--; if(comments == 0) BEGIN INITIAL; }
<COMMENT>{ANY_CHAR}          { }
<COMMENT>{NEWLINE}           { curr_lineno++; }
<COMMENT><<EOF>>             {
    cool_yylval.error_msg = "EOF in comment";
    BEGIN INITIAL;
    return ERROR;
}

 /* Names */

{OBJECTID} { cool_yylval.symbol = idtable.add_string(yytext); return OBJECTID; }
{TYPEID}   { cool_yylval.symbol = idtable.add_string(yytext); return TYPEID; }

 /* Other */

{WHITESPACE} { }
{NEWLINE}    { curr_lineno++; }
{LCB}        { return int('{'); }
{RCB}        { return int('}'); }
{LPRN}       { return int('('); }
{RPRN}       { return int(')'); }
{COLN}       { return int(':'); }
{CMMA}       { return int(','); }
{SEMI}       { return int(';'); }
{PERD}       { return int('.'); }
{EQAL}       { return int('='); }
{PLUS}       { return int('+'); }
{MNUS}       { return int('-'); }
{TIMS}       { return int('*'); }
{DIVD}       { return int('/'); }
{LT}         { return int('<'); }
{TILDE}      { return int('~'); }
{AT}         { return int('@'); }

 /* String constants (C syntax) */

 /* Errors */

{ANY_CHAR}  { cool_yylval.error_msg = yytext; return ERROR; }

<STRING>([^"\\\n\0])  { CHECK_SIZE(); strcat(string_buf, yytext); }

%%
