%option noyywrap nounput case-insensitive
%{
#include <cstdlib>
#include <iostream>
#include <sstream>

#include "fig.h"
#include "scat.h"

int indent=0;
int padding=0;
int pos=0;
bool first_line;
bool in_module=false;
bool in_function=false;
bool block_end=false;
bool semicolon=false;

void pad(std::string setting, int min);
void new_lines();
bool check(std::string setting);
void write(std::string str);
void write(char c);
void write(int count, char c);

Config conf;
std::stringstream* ss;

%}

%s NORMAL
%s INLINE
%s SCADFILE
%s COMMENT
%s FUNCTION
%s MAYBENEWLINE
%x MLCOMMENT

%%

^[\t ]*\/\/			{ 	
					BEGIN(COMMENT);
					new_lines();
					write("//");
					padding=0;
				}
\/\/				{ 	
					BEGIN(COMMENT);
					if(check("tab before comment")) write('\t');
					else pad("pad before comment", 0);
					write(yytext);
					padding=0;
				}
<COMMENT>[^ \t][^\n]*		{
					BEGIN(0);
					pad("pad comment start",0);
					write(yytext);
					first_line=false;
					new_lines();
					padding=0;
				}
\/\*				{
					BEGIN(MLCOMMENT);
					new_lines();
					write(yytext);
				}
<MLCOMMENT>\*\/			{	
					BEGIN(0);
					write(yytext);
					new_lines();
				}
<MLCOMMENT>.|\n			{	
					write(yytext[0]);
				}
[ \t]				{}
\n				{	first_line=false;	}
";"				{ 	
					BEGIN(MAYBENEWLINE);
					write(yytext[0]); 
					semicolon=true;
					padding=0;
				}
"="				| 
"?"				| 
":"				| 
"+"				| 
"-"				| 
"*"				| 
"/"				| 
"%"				| 
"^"				| 
<INLINE>"<"			| 
<INLINE>">"			| 
"<="				| 
">="				| 
"=="				| 
"!="				| 
"&&"				| 
"||"				{	
					BEGIN(INLINE);
					pad("operator padding",0);
					write(yytext); 
					padding=0;
					pad("operator padding",0);
				}
"{"				{
					BEGIN(MAYBENEWLINE);
					pad("pad before brace",0);
					++indent;
					write(yytext[0]);
					padding=0;
				}
"}"				{
					BEGIN(MAYBENEWLINE);
					if(indent>0) --indent;
					new_lines();
					write(yytext[0]);
					if(indent==0)block_end=true;
					padding=0;
				}
"()"				{
					pad("pad before bracket",0);
					write(yytext);
					padding=0;
				}
"("				{
					BEGIN(INLINE);
					pad("pad before bracket",0);
					write(yytext[0]);
					padding=0;
					pad("pad inside bracket",0);
				}
")"				{
					BEGIN(NORMAL);
					pad("pad inside bracket",0);
					write(yytext[0]);
					padding=0;
				}
"["				{
					BEGIN(INLINE);
					write(yytext[0]);
					padding=0;
					pad("pad inside square",0);
				}
"]"				{
					BEGIN(NORMAL);
					pad("pad inside square",0);
					write(yytext[0]);
					padding=0;
				}
"<"				{
					BEGIN(SCADFILE);
					pad("pad before angular",0);
					write(yytext[0]);
					padding=0;
					pad("pad inside angular",0);
				}
">"				{
					BEGIN(0);
					pad("pad inside angular",0);
					write(yytext[0]);
					padding=0;
				}
","				{
					BEGIN(INLINE);
					write(yytext[0]);
					padding=0;
					pad("comma padding",0);
				}
\"[^\"]*\"			{	
					write(yytext);
					padding=0;
				}
<INLINE>\$?[_a-z0-9]+		{
					write(yytext);
					padding=0;
				}	
function			{
					BEGIN(FUNCTION);
					in_function=true;
					write(yytext);
					padding=0;
				}
module				{
					BEGIN(FUNCTION);
					in_module=true;
					write(yytext);
					padding=0;
				}
<FUNCTION>\$?[_a-z0-9]+		{
					pad("function padding",1);
					write(yytext);
					padding=0;
				}	
<NORMAL>\$?[_a-z0-9]+		{
					if (check("one function per line") || (check("no new identifiers after") && pos>conf.get_int("no new identifiers after"))) {
						first_line=false;
						new_lines();
						write('\t');
					} else pad("function padding",1);
					write(yytext);
					padding=0;
				}	
<SCADFILE>[^>]+			{
					write(yytext);
					padding=0;
				}
<MAYBENEWLINE>\$?[_a-z0-9]+	{
					BEGIN(NORMAL);
					new_lines();
					write(yytext);
					padding=0;
				}	
\$?[_a-z0-9]+			{
					BEGIN(NORMAL);
					write(yytext);
					padding=0;
				}	
<<EOF>>				{
					*ss<<std::endl;
					return 0;
				}
.				{
					write(yytext[0]);
					padding=0;
				}
%%

void pad(std::string setting, int min) {
	if(conf.has(setting)){
		double set=conf.get_int(setting);
		if(set>min) min=set;
	} 
	if(min>padding) min-=padding;
	else return;
	write(min, ' ');
	padding+=min;
}

bool check (std::string setting){
	if(conf.has(setting) && conf.get_bool(setting))
		return true;
	return false;
}

void write(std::string str) {
	*ss<<str;
	pos+=str.length();
}

void write(int count, char c){
	if(count==0) return;
	if (c!='\t') {
		write(std::string(count, c));
		return;
	}
	if (conf.has("indent type") && conf.get_string("indent type").compare("spaces")==0) {
		int spaces=0;
		if(conf.has("indent spaces")) spaces=conf.get_int("indent spaces");
		spaces*=count;
		*ss<<std::string(spaces,' ');
		pos+=spaces;
	} else {
		int spaces=4;
		if(conf.has("tab width")) spaces=conf.get_int("tab width");
		*ss<<std::string(count,'\t');
		pos+=spaces*count;
	}
}

void write(char c){
	write(1,c);
}

void new_lines(){
	if(first_line) {
		first_line=false;
		return;
	}
	*ss<<std::endl;
	pos=0;
	if(indent!=0) {
		write(indent,'\t');
		return;
	} else {
		if (in_module && block_end){
			int new_lines=(conf.has("lines after module")?conf.get_int("lines after module"):0);
			for(int i=0;i<new_lines;++i) *ss<<std::endl;
			in_module=false;
		}
		if (in_function && semicolon){
			int new_lines=(conf.has("lines after function")?conf.get_int("lines after function"):0);
			for(int i=0;i<new_lines;++i) *ss<<std::endl;
			in_function=false;
		}
	}
	semicolon=false;
	block_end=false;
}

void format (std::string filename, Config _conf, std::stringstream* _ss){
	first_line=true;
	ss=_ss;
	ss->str("");
	conf=_conf;
	yyin=fopen(filename.c_str(),"r");
	yylex();
}

