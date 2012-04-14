#!/usr/bin/python

'''Calculates text statistics for a file including number of characters, words,
words in sentences, sentences and paragraphs.

If run as a standalone program, calculates text statistics for standard input.

This script works in python 2.7 and python 3.
'''

from __future__ import print_function, division

class TokenType:
    '''Different types of tokens on input stream.
    '''
    NONE = 0
    WORD = 1
    PUNCTUATION = 2
    WHITE_SPACE = 3
    OTHER = 4
    EOF = 5

class TokenInfo:
    value = ""
    tokenType = TokenType.NONE
    counter = 0
    nextValue = ""
    nextTokenType = TokenType.NONE

def getTokens(fileHandle):
    '''Generator for the tokens in a file.

    Tokens can be a word, white space, punctuation or other. The end of file 
    marker is not returned. 
    E.g. an empty file or stream would generate an empty list.
    '''

    def classify(c):
        ''' Determines the tokenType of a single character.
        '''
        if not c:
            return TokenType.EOF
        elif c.isalpha():
            return TokenType.WORD
        elif c in [" ", "\t", "\n"]:
            return TokenType.WHITE_SPACE
        elif c in [",", ";", ":", ".", "!", "?",]:
            return TokenType.PUNCTUATION
        else:
            return TokenType.OTHER         

    token = TokenInfo()
    token.nextValue = fileHandle.read(1)
    token.nextTokenType = classify(token.nextValue)

    while token.nextTokenType != TokenType.EOF:
        token.value = ""
        token.tokenType = token.nextTokenType
        token.counter = 0
        while token.tokenType == token.nextTokenType and token.nextValue:
            token.value += token.nextValue
            token.counter += 1
            token.nextValue = fileHandle.read(1)
            token.nextTokenType = classify(token.nextValue)
        yield token

def textStatistics(fileHandle):
    '''Counts the number of characters, words, paragraphs and sentences in a 
    file or stream and returns this as a dictionary.
    '''
    nChars = 0
    nWords = 0
    nSentences = 0
    nSentenceWords = 0
    nParas = 0

    currentSentenceWords = 0
    sentenceStarted = False
    sentenceEnded = False
    
    for token in getTokens(fileHandle):
        nChars += token.counter
        if token.tokenType == TokenType.WORD:
            nWords += 1
            currentSentenceWords += 1
            sentenceStarted = True
            sentenceEnded = False
        elif sentenceStarted and \
                token.tokenType == TokenType.PUNCTUATION and \
                token.value in ["!", ".", "?",]: # End of sentence found
            nSentences += 1
            nSentenceWords += currentSentenceWords
            currentSentenceWords = 0
            sentenceStarted = False
            sentenceEnded = True
            
        # End of paragraph found when a sentence has ended and there are two 
        # line breaks            
        elif sentenceEnded and \
                token.tokenType == TokenType.WHITE_SPACE and \
                token.value.count("\n") > 1: 
            nParas += 1
            sentenceEnded = False

        # If a paragraph break but not end of sentence, 
        # then this was probably a heading, so don't count words towards 
        # sentence.
        elif token.tokenType == TokenType.WHITE_SPACE and \
                token.value.count("\n") > 1: 
            currentSentenceWords = 0
        
        # If some other character, then can't be end of sentence.            
        elif token.tokenType != TokenType.WHITE_SPACE: 
            sentenceEnded = False

    # If EOF and sentence has ended, then this is also the end of a paragraph.
    if sentenceEnded: 
        nParas += 1

    return {"characters": nChars, 
            "words" : nWords, 
            "sentence-words" : nSentenceWords, 
            "sentences" : nSentences, 
            "paragraphs" : nParas}

if __name__ == '__main__':
    import sys

    def usageStatement():
        print("Usage:", sys.argv[0], "[FILE ...]")
        print("Calculates the characters, words, words in sentences, sentences"
              "and paragraphs in a given set of files.")
        print("If no files are specified, the program processes "
              "standard input")

    def output(fileHandle):
        d = textStatistics(fileHandle)
        for k,v in  d.items():
            print(k, v, end=" ")
        print("Mean sentence length %.2f" % \
              (d["sentence-words"] / d["sentences"]))

    if len(sys.argv) > 1:
        if sys.argv[1] == "--help":
            usageStatement()
        else:
            for fileName in sys.argv[1:]:
                try:
                    print("File:", fileName)
                    f = open(fileName)
                    output(f)
                except IOError:
                    print("Could not open file ", fileName)
    else:
        output(sys.stdin)

