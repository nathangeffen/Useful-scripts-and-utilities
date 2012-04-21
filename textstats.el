;;; textstats.el --- determines textual statistics for region

;; Copyright (C) 2012 Nathan Geffen under the GNU General 
;; Public License Version 3.

;; Maintainer: Nathan Geffen

;;; Commentary:

;; This package contains the function text-statistics.  
;; It determines the number of characters, words, words in
;; sentences, sentences and paragraphs in a region of text.

;; In this programme a word is a set of alphanumeric characters.
;; The programme makes an attempt to recognise abbreviations and
;; decimal place numbers as single words.

;; The programme considers a sentence to be a set of words terminated by
;; a fullstop, exclamation mark or question mark.  However, if the next
;; sentence starts with a lower case letter, then it will consider it
;; part of the previous sentence and the fullstop to have been part of
;; an abbreviation. 

;; The programme will correctly recognise this as a single sentence with 
;; eight words.

;;   The rainbow has some bright colours, e.g. red.

;; But it will wrongly think this is two sentences, because Ronald
;; starts with an upper case R.

;;   Some of his friends supported him, e.g. Ronald.

;; Obviously trying to fix this kind of problem requires a much bigger
;; and more intelligent programme.

;; A paragraph contains at least one sentence.

;; A break between paragraphs consists of at least one
;; empty line or a line that contains only white space.

;; This is my first emacs lisp code. Both Emacs and Lisp
;; are still mysterious to me. Please forgive the
;; numerous newbie hacks and ugly code.

;; For most normal uses, this code works. It is very slow on large
;; files. 

;; To do: profile optimise the code.

;;; Code:

(defun get-tokens-region (beginning end)
  "Returns the tokens in a region"
  (interactive "r")
  (defun classify (char)
    (cond ((string-match "[a-zA-Z0-9]" char)
           'WORD)
          ((string-match "[\t\n ]" char)
           'WHITE-SPACE)
          ((string-match "[!?.;:,']" char)
           'PUNCTUATION)
          ('OTHER)))
  (save-excursion
    (let* ((token-list nil)
           (token-value "")
           (token-type 'NONE)
           (token-counter 0)
           (token-next-value (string (char-after beginning)))
           (token-next-type (classify token-next-value))
           (position beginning))
      (while (< position end)
        (setq token-value "")
        (setq token-type token-next-type)
        (setq token-counter 0)
        (while (and (eq token-type token-next-type) (< position end))
          (setq token-value (concat token-value token-next-value))
          (setq token-counter (1+ token-counter))
          (setq position (1+ position))
          (if (< position end)
              (setq token-next-value (string (char-after position)))
            (setq token-next-value ""))
          (setq token-next-type (classify token-next-value)))
        (setq  token-list (append (list 
                        (vector token-type token-value token-counter)) 
                       token-list)))
      (reverse token-list))))

(defun display-tokens (beginning end)
  "Displays the token information for a region"
  (interactive "r")
  (save-excursion
    (message (prin1-to-string (get-tokens-region beginning end)))))

(defun text-statistics (beginning end)
  "Counts chars, words, words in sentences, sentences and paragraphs in
  a region of text."
  (interactive "r")
  (message "Calculating statistics for region ...")
  (save-excursion
    (setq case-fold-search nil)
    (let* ((nChars 0)
          (nWords 0)
          (nSentences 0)
          (nSentenceWords 0)
          (nParas 0)
          (currentSentenceWords 0)
          (sentenceStarted nil)
          (sentenceEnded nil)
          (tokens (get-tokens-region beginning end))
          (nTokens (length tokens)))
      
      (while (not (eq nTokens 0))
        (setq token (car tokens))
        (setq tokens (cdr tokens))
        (setq nChars (+ nChars (aref token 2)))
        (setq tokenType (aref token 0))
        (setq tokenValue (aref token 1))
        (setq nTokens (1- nTokens))
        (cond ((eq (aref token 0) 'WORD) ; Token is a word
               (setq nWords (1+ nWords))
               (setq currentSentenceWords (1+ currentSentenceWords))
               (setq sentenceStarted t)
               (setq sentenceEnded nil))
              
              ;; Token is end of sentence marker
              ((and sentenceStarted      
                    (eq tokenType 'PUNCTUATION)
                    (string-match "[!?.]" tokenValue))
               
               ;; Before processing end of sentence check for
               ;; exceptional cases, including that the current token is
               ;; a decimal number or the current token is an
               ;; abbreviation. To do that we need to look ahead a
               ;; bit. This code is a bit messy and probably does not
               ;; cover some cases but the only alternative I can think
               ;; of is a full-on parser which seems excessive for the
               ;; purposes of this simple utility.
               (cond ((vectorp (car tokens))
                      (setq sym1 (aref (car tokens) 0)))
                     (t 
                      (setq sym1 nil)))
               (cond ((vectorp (car (cdr tokens)))
                      (setq char2 (aref (car (cdr tokens)) 1)))
                     (t 
                      (setq char2 "")))
               (cond ((eq sym1 'WORD) ;; This appears to be an abbreviation
                      (setq nWords (1- nWords)) ;; Undo previous word inc
                      (setq currentSentenceWords (1-
                                                  currentSentenceWords)))

                     ;; Check next word does not start with lower-case letter.
                     ;; If it does then current token is probably an
                     ;; abbreviation and not the end of a sentence.
                     ;; If it doesn't then this is an end of sentence.
                     ((not (and (eq sym1 'WHITE-SPACE) 
                                (string-match "^[a-z]" char2 )))
                      (setq nSentences (1+ nSentences))
                      (setq nSentenceWords 
                            (+ nSentenceWords currentSentenceWords))
                      (setq currentSentenceWords 0)
                      (setq sentenceStarted nil)
                      (setq sentenceEnded t))))
              
              ;; Paragraph break
              ((and sentenceEnded
                    (eq tokenType 'WHITE-SPACE)
                    (string-match "\n[\t ]*\n" tokenValue))
               (setq nParas (1+ nParas))
               (setq sentenceEnded nil))
              
              ;; Break in text with blank line(s) but not paragraph break
              ((and (eq tokenType 'WHITE-SPACE) 
                    (string-match "\n[\t ]*\n" tokenValue))
               (setq currentSentenceWords 0))
              
              ;; If some other character, then can't be end of sentence.
              ((not (eq tokenType 'WHITE-SPACE)) 
               (setq sentenceEnded nil)))
        )
      
      ;; End of tokens but no linebreak and sentence just ended? 
      ;; Then this is a paragraph.
      (if sentenceEnded 
          (setq nParas (1+ nParas)))

      (message "Characters: %d" nChars)
      (message "Words: %d" nWords)
      (message "Words in sentences: %d" nSentenceWords)
      (message "Sentences: %d" nSentences) 
      (message "Paragraphs: %d" nParas)
      (message "Mean words per sentence: %.2f" 
               (/ (float nSentenceWords) nSentences)))))
