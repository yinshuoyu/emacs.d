;;; ---- ease.el begin ----
;; This file is for the packages that make emacs more usable


;; A better frame for minibuffer completion
(use-package vertico
  :init
  (vertico-mode))

;; better minibuffer, including more comment
(use-package marginalia
  :init
  (marginalia-mode))

;; modernized completion front-end
(use-package corfu
  :init
  (global-corfu-mode)
  :custom
  (corfu-auto t)
  (corfu-cycle t)
  (corfu-quit-no-match t)
  :config
  (setq completion-in-region-function #'corfu--completion-in-region))

;; enrich the source for completion
;;(use-package cape 
  ;:init
  ;(add-hook 'completion-at-point-functions #'cape-file 90)
  ;(add-hook 'completion-at-point-functions #'cape-dabbrev 80))

;; A better C-a and C-e
(use-package mwim
  :bind
  ("C-a" . mwim-beginning-of-code-or-line)
  ("C-e" . mwim-end-of-code-or-line))

;; make parameters colorful
(use-package rainbow-delimiters
  :hook (prog-mode .rainbow-delimiters-mode))

(use-package dirvish
  :init
  (dirvish-override-dired-mode)
  :config
  (setq dirvish-reuse-session 1)
  (setq dirvish-attributes '(nerd-icons file-size git-msg subtree-state))
  (setq dirvish-peek-mode t))

(use-package consult
  :ensure t
  :bind
  (("C-x b" . consult-buffer)
   ("C-s" . consult-line)
   ("C-c f" . consult-find)
   ("C-c g" . consult-ripgrep)
   ("C-c i" . consult-imenu)))

;; file-manage -- orderless
(use-package orderless
  :init
  (setq completion-ignore-case t)   
  (setq orderless-matching-styles '(orderless-prefixes))   
  (setq orderless-split-function 'orderless-split-without-word) 
  (setq completion-styles '(orderless basic)))

(message "ease loaded")
(provide 'ease)
