;;; ---- init.el begin ----
;; ---- author Aminore ----

;;; --- custom configg for emacs ---
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("45631691477ddee3df12013e718689dafa607771e7fd37ebc6c6eb9529a8ede5"
     default))
 
 '(package-selected-packages
   '(ace-window agent-shell all-the-icons arduino-mode auctex cape
		cdlatex cmake-mode conda consult corfu csv-mode
		dashboard dirvish eglotx google-translate magit
		marginalia markdown-mode mwim nasm-mode nerd-icons
		ob-mermaid orderless org-journal python python-mode
		racket-mode rainbow-delimiters rust-mode
		smart-mode-line typescript-mode vertico vterm)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; --- faster load ---
(advice-add 'package-install :after
            (lambda (&rest _) (package-quickstart-refresh)))
(advice-add 'package-delete :after
            (lambda (&rest _) (package-quickstart-refresh)))

;; --- basic ---
(setq ring-bell-function 'ignore)
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))


;; --- package resource ---
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
	("melpa" . "https://melpa.org/packages/")
	("nongnu" . "https://elpa.nongnu.org/nongnu/")))


;; --- load theme ---
(load-theme 'modus-vivendi t)

;; --- font ---
(add-hook 'emacs-startup-hook
	  (lambda ()
	    
	    (set-face-attribute 'default nil :font "Hack 13")

	    (setq-default line-spacing 0.3)))


;; --- special config for built in packages ---
(with-eval-after-load 'org
  (defun org-set-fomular-size ()
    (interactive)
    (plist-put org-format-latex-options :scale 2)))

(setq flymake-no-changes-timeout 5)

(setq auto-save-default nil)

(add-hook 'prog-mode-hook
	  (lambda ()
	    (electric-pair-mode 1)
	    (setq-local electric-pair-inhibit-predicate
			(lambda (char)
			  (or (eq char ?\( )
			      (electric-pair-default-inhibit char)
			      )))))


;; --- line number ---
(global-visual-line-mode 1)


;; --- font-lock ---



(add-to-list 'load-path "~/.emacs.d/lisp/")

(require 'lang)
(require 'tool)
(require 'ease)
(require 'user-defun)
(require 'study-workflow)
(require 'dsh-agent-shell)

(defvar packages '(lang
		   tool
		   ease
		   user-defun
		   study-workflow
		   dsh-agent-shell))



(use-package smooth-reading
  :load-path "~/.emacs.d/lisp"
  :bind ("C-c r" . smooth-reading-mode))
