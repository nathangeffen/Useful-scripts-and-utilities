# Useful scripts and utilities

This is a collection of useful scripts and utilities that programmers and sys admins might find useful.

## Bash scripts

### prepend.sh
  
This script prepends a file to a list of files. Usage: 
  
    $ prepend.sh FILE [FILE]
  
The following example prepends a file called copyrightnotice to all the C source files in a directory.
  
    $ prepend.sh copyrightnotice *.c *.h

## Python scripts

### textstats.py

This script counts the characters, words, words in sentences, sentences and paragraphs in standard input. Usage:

    $ textstats.py < FILE
    
#### Known bugs

The sentence counting algorithm is very simple and will miscalculate certain cases. For example, a decimal number or inside a sentence will result in one sentence being counted as two. An abbreviation with fullstops will also generate additional sentences. 

E.g. this sentence is counted as three sentences because of the periods between the "E" and the "g" and the following will be counted as two sentences.

     The value of PI is 3.14, which is approximately 22/7.

Maybe one day I'll make the algorithm more sophisticated.

## Emacs scripts 

### textstats.el

This script counts the characters, words, words in sentences, sentences, paragraphs and mean words per sentence in the selected Emacs region. To execute it, highlight the region of interest, press M-x and run text-statistics.

This is actually a more correct version than the Python textstats.py. It is also quite fast. It takes fewer than 10 seconds to process a file with just under 150,000 words on an i3. A typical book only has 60,000 to 100,000 words. The Python version is significantly faster though, processing the same file in 1.5 seconds and giving nearly identical results, despite its bugs.

# Copying and modifying

The following programmes and code snippets are in the [public domain](http://en.wikipedia.org/wiki/Public_Domain "Wikipedia public domain entry"):

- prepend.sh
- textstats.py

The following programmes and code snippets are copyright Nathan Geffen under the [GNU General Public License version 2](http://emacswiki.org/GPL "GPL ver 2"):

- textstats.el
