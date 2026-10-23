;;; ---- tool.el begin ----
;; This file is for the packages that give emacs more complete new features and functions

;; A more useful start page
(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-banner-logo-title "Remember to start Stretchly"))

;; A beautiful mode-line
(use-package smart-mode-line
  :init (sml/setup))

;; A better way to move the cursor
(use-package avy
  :bind (("C-;" . avy-goto-char-timer)
	 ("C-," . avy-goto-line)
	 ("C-'" . avy-goto-word-0)))


;; A better way to switch among the windows
(use-package ace-window 
  :bind
  ("M-o" . ace-window)
  :config
  (setq aw-dispatch-always t))

;; Give emacs ai support
(use-package agent-shell
  :defer t
  :commands (agent-shell))


(use-package vterm
  :defer t)
  



(provide 'tool)
