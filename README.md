# Useful scripts and utilities

This is a collection of useful scripts and utilities that programmers and sys admins might find useful.

## Bash scripts

### prepend.sh
  
This script prepends a file to a list of files. Usage: 
  
    $ prepend.sh FILE [FILE]
  
The following example prepends a file called copyrightnotice to all the C source files in a directory.
  
    $ prepend.sh copyrightnotice *.c *.h

### textstats.py

This python script counts the characters, words, words in sentences, sentences and paragraphs in standard input. Usage:

    $ textstats.py < FILE
    
#### Known bugs

The sentence counting algorithm is very simple and will miscalculate certain cases. For example, a decimal number or inside a sentence will result in one sentence being counted as two. An abbreviation with fullstops will also generate additional sentences. 

E.g. this sentence is counted as three sentences because of the periods between the "E" and the "g" and the following will be counted as two sentences.

     The value of PI is 3.14, which is approximately 22/7.

Maybe one day I'll make the algorithm more sophisticated.

# Copying and modifying

These utilities are in the [public domain](http://en.wikipedia.org/wiki/Public_Domain "Wikipedia public domain entry"). 
