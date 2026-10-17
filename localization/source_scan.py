import re,json
from pathlib import Path
# Lex literals with nested interpolations intact, skipping comments.
def literals(s,lang):
 i=0
 def string_end(i):
  j=i+1
  while j<len(s):
   if s[j]=='\\':
    if lang=='swift' and s[j:j+2]=='\\(':
     j=balanced(j+1,'(',')');continue
    j+=2;continue
   if lang=='kt' and s[j:j+2]=='${':j=balanced(j+1,'{','}');continue
   if s[j]=='"':return j+1
   j+=1
  return len(s)
 def balanced(i,a,b):
  depth=1;j=i+1
  while j<len(s) and depth:
   if s[j]=='"':j=string_end(j);continue
   if s[j]==a:depth+=1
   if s[j]==b:depth-=1
   j+=1
  return j
 while i<len(s):
  if s[i:i+2]=='//':i=s.find('\n',i) if '\n' in s[i:] else len(s);continue
  if s[i:i+2]=='/*':
   e=s.find('*/',i+2);i=e+2 if e>=0 else len(s);continue
  if s[i]=='"':
   end=string_end(i);start=i-1 if lang=='m' and i>0 and s[i-1]=='@' else i
   yield start,end,s[i+1:end-1];i=end
  else:i+=1
