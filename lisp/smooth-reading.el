;;; smooth-reading.el --- A minor mode for smoother reading experience  -*- lexical-binding: t; -*-

;; Copyright (C) 2025  Yin Shoyu

;; Author: Yin Shuoyu Aminore_III@outlook.com
;; Version: 0.1
;; Keywords: convenience, reading
;; URL: https://github.com/AminoreIII/smooth-reading
;; Package-Requires: ((emacs "27"))

;;; Commentary:

;; This package provides a minor mode `smooth-reading-mode' that
;; rebinds common navigation keys for comfortable reading, and adds
;; temporary anchor markers for quick jumping within a buffer.


(defgroup smooth-reading nil
  "Customization options for the Smooth Reading minor mode."
  :group 'tools)

(defcustom s-r-scroll-line 4
  "Number of lines to scroll when using `n' and `p' keys."
  :type 'integer
  :group 'smooth-reading)

(defcustom s-r-special-cursor 'hbar
  "Cursor type used when the minor mode is active."
  :type 'symbol
  :group 'smooth-reading)




;; An implement of a index
(defun s-r-show-list (opt-list)
  "Display a menu in the minibuffer and execute the selected function.

OPT-LIST is an alist of the form ((?KEY DESCRIPTION FUNCTION) ...).
The user presses a single character KEY, and the corresponding FUNCTION
is called with no arguments. If KEY is not in the list, a message is shown."
  (let* ((prompt (mapconcat
                  (lambda (opt) (format "[%c] %s" (car opt) (cadr opt)))
                  opt-list "\n"))
         (choice (read-char (concat prompt "\n\nplease make a choice: ")))
	 (selected (assq choice opt-list)))
      (if selected
          (funcall (caddr selected))
        (message "invalid choice"))))


(defun s-r-minibuffer-completing (ori-dict)
  "Prompt user to select a key from ORI-DICT with completion.

ORI-DICT is an alist where each element is (KEY . DESCRIPTION).
The KEY is shown as the completion candidate, and DESCRIPTION is
displayed as a suffix annotation. The function returns the selected
KEY as a string."
  (minibuffer-with-setup-hook
      (lambda ()
	(setq-local completion-extra-properties
		   `(:affixation-function
		     ,(lambda (candids)
			(mapcar (lambda (ca)
				  (list ca "" (concat "\t" (cdr(assoc ca ori-dict)))))
				candids)))))
    (completing-read "please make a choice: " (mapcar #'car ori-dict) nil t)))




;; --- About anchors --- 


(defcustom s-r-anchor-number 8
  "The maximum of number of anchors"
  :type 'integer
  :group 'smooth-reading)



(defvar-local s-r-anchor nil
  "stack of anchors for smooth-reading-mode")

(defvar-local s-r-anchor-sort nil
  "sorted anchors")


 
;; this is bind to "]"
(defun s-r-next-anchor ()
  (interactive)
  (let* ((posit (point))
	 (where (cl-find-if (lambda (x) (> x posit)) s-r-anchor-sort :from-end t)))
    (if where
	(goto-char where)
      (if s-r-anchor
	  (message "It's the last anchor.")
	(message "There is no anchor")))))

;; this is bind to "["
(defun s-r-previous-anchor ()
  (interactive)
  (let* ((posit (point))
	 (where (cl-find-if (lambda (x) (< x posit)) s-r-anchor-sort)))
    (if where
	(goto-char where)
      (if s-r-anchor
	  (message "It's the last anchor.")
	(message "There is no anchor")))))


;; make a anchor 
(defun s-r-set-anchor ()
  (interactive)
  (when (>= (length s-r-anchor) s-r-anchor-number)
      (nbutlast s-r-anchor))
  (setq s-r-anchor (cons (point) s-r-anchor))
  (setq s-r-anchor-sort (copy-sequence s-r-anchor))
  (sort s-r-anchor-sort '>))

;; this is bind to 
(defun s-r-delete-latest-anchor ()
  (interactive)
  (if s-r-anchor
      (progn (setq s-r-anchor (cdr s-r-anchor))
	     (setq s-r-anchor-sort (copy-sequence s-r-anchor))
	     (sort s-r-anchor-sort '>))
    (message "There is no anchor remain")))


(defun s-r-anchor-vertical ()
  (mapcar (lambda (pos)
		(cons (number-to-string pos) (string-replace "\n" "" (buffer-substring-no-properties
			   (max (point-min) (- pos 20))
			   (min (point-max) (+ pos 20))))))
	      s-r-anchor-sort))





(defun s-r-delete-select-anchor ()
  (while t
    (let* ((dic (s-r-anchor-vertical))
	   (st-out (s-r-minibuffer-completing dic))
	   (choice (string-to-number st-out)))
      (setq s-r-anchor-sort (delete choice s-r-anchor-sort))
      (setq s-r-anchor (delete choice s-r-anchor)))))


(defun s-r-anchor-bookmark-convert ()
  (while t
    (let* ((dic (s-r-anchor-vertical))
	   (st-out (s-r-minibuffer-completing dic))
	   (choice (string-to-number st-out)))
      (save-excursion
	(goto-char choice)
	(bookmark-set (read-string "please give it a name: "))))))

(defun s-r-anchor-empty ()
  (when (y-or-n-p "want to delete all the anchors?")
    (setq s-r-anchor nil)
    (setq s-r-anchor-sort nil)))




(defvar s-r-index-list
  '((?d "Delete selected anchor" s-r-delete-select-anchor)
    (?s "Save anchor as bookmark" s-r-anchor-bookmark-convert)
    (?e "Delete all anchors" s-r-anchor-empty)
    (?g "Quit menu" ignore))
  "Menu definitions for `s-r-anchor-index'.")

;; a hebrid buffer
(defun s-r-anchor-index ()
  "Display an index buffer and wait for a single key press"
  (interactive)
  (s-r-show-list s-r-index-list))









;;--- outline part --- 
;;a impliment of an outline

(defconst s-r-md-head-regexp
  "^\\(#+\\)[ \t]+\\(.*?\\)[ \t]*$"
  "regexp the heads of a markdown file")

(defconst s-r-org-head-regexp
  "^\\(\\*+\\)[ \t]+\\(.*?\\)[ \t]*$"
  "regexp the heads of a org file")

(defvar-local s-r-outline-cache nil)

(defun s-r-md-head-matcher ()
  (save-excursion
    (goto-char (point-min))
    (let ((result nil)
	  )
      (while (re-search-forward s-r-md-head-regexp nil t)
	(let ((pos (match-beginning 0))
	      (title (match-string 2))
	      (depth (length (match-string 1))))
	  (push (list (line-number-at-pos pos) title depth) result)))
      (setq s-r-outline-cache (nreverse result))
      )))


(defvar-local s-r-modif -1)

(defun s-r-modified-p ()
  (let ((track (< s-r-modif (buffer-modified-tick))))
    (setq s-r-modif (buffer-modified-tick))
    track))












(defun s-r-outline ()
  (interactive)
  ())
  



;;; --- translate part --- 
;; coorperate with google translate
(use-package google-translate
  :ensure t)


(defun translate-choose ()
  (if (use-region-p)
      (replace-regexp-in-string "\n" " " (buffer-substring-no-properties (region-beginning) (region-end)))
    (let ((temp-r (bounds-of-thing-at-point 'word)))
      (if temp-r
	  (buffer-substring-no-properties (car temp-r) (cdr temp-r))
	(progn (message "The region is empty")
	       (signal 'quit nil))))))


(defun translate-period ()
  (interactive)
  (let* ((text (translate-choose))
	(json (google-translate-request "en" "zh-CN" text))
	(translation (google-translate-json-translation json)))
    (message translation)))



;;; --- help part --- 
;; the document
(defvar s-r-doc
  '(("n" "scroll down asigned lines")
    ("p" "scroll up asigned lines")
    ("q" "quit the minor-mode")
    ("f" "next word")
    ("b" "previous word")
    ("SPC" "set-mark-command")
    ("v" "next page")
    ("u" "index")
    ("t" "translate period or word")
    ("/" "delete the latest anchor")
    ("?" "help")
    ("o" "outline")
    ("[" "previous anchor")
    ("]" "next anchor")))



;; The document of this package
(defun s-r-help ()
  (interactive)
  (let* ((doc (mapconcat (lambda (sec) (format "[%s] %s" (car sec) (cadr sec))) s-r-doc "\n")))
    (read-char (concat doc "\n\npress any key to quit:"))))






;; define the minor-mode
;;;###autoload
(define-minor-mode smooth-reading-mode 
  "This mode is for easier reading"
  :lighter "smooth-reading"
  :keymap (let ((map (make-sparse-keymap)))
	    (define-key map (kbd "n") (lambda () (interactive) (scroll-up s-r-scroll-line)))
	    (define-key map (kbd "p") (lambda () (interactive) (scroll-down s-r-scroll-line)))
	    (define-key map (kbd "f") (lambda () (interactive) (forward-word 1)))
	    (define-key map (kbd "b") (lambda () (interactive) (backward-word 1)))
	    (define-key map (kbd "[") 's-r-previous-anchor)
	    (define-key map (kbd "]") 's-r-next-anchor)
	    (define-key map (kbd "v") 'scroll-up)
	    (define-key map (kbd "SPC") 'set-mark-command)
	    (define-key map (kbd "u") 's-r-anchor-index)
	    (define-key map (kbd "m") 's-r-set-anchor)
	    (define-key map (kbd "/") 's-r-delete-latest-anchor)
	    (define-key map (kbd "o") 's-r-outline)
	    (define-key map (kbd "?") 's-r-help)
	    (define-key map (kbd "t") 'translate-period)
	    (define-key map (kbd "q") 'smooth-reading-mode)
	    map)
  (if smooth-reading-mode
      (progn (message "block enabled")
	     (setq-local cursor-type s-r-special-cursor)
	     (setq-local s-r-read-only-save buffer-read-only)
	     (setq buffer-read-only t))
    (progn (message "block disabled")
	   (setq buffer-read-only s-r-read-only-save)
	   (kill-local-variable 'cursor-type)
	   (kill-local-variable 's-r-read-only-save)
	   )))



(provide 'smooth-reading)
