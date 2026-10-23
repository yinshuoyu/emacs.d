;;; ---- lang.el begin ----
;; This file is for packages about programing languages

;; --- lsp contractor ---
(add-to-list 'exec-path (expand-file-name "~/.local/bin"))
(add-to-list 'exec-path (expand-file-name "~/.cargo/bin"))

(use-package eglot
  :ensure nil
  :commands (eglot eglot-ensure)
  :custom
  (eglot-sync-connect 1)
  (eglot-autoshutdown t)
  :config
  (setq eglot-server-programs
	'((python-mode . ("/home/yin/.local/miniconda3/envs/ml/bin/basedpyright-langserver" "--stdio"))
	  (rust-mode . ("rust-analyzer"))
	  (c-mode . ("clangd"))
	  (c++-mode . ("clangd"))
	  (racket-mode . ("racket" "-l" "racket-langserver"))
	  (arduino-mode . ("arduino-language-server" "--fqbn" "arduino:avr:uno"))
	  (nasm-mode . ("~/.cargo/bin/asm-lsp"))
	  (typescript-mode . ("tsc" "--lsp" "--stdio"))
	  (js-mode . ("tsc" "--lsp" "--stdio")))))

(add-hook 'python-mode-hook
          (lambda ()
            (setq-local completion-at-point-functions
                        '(eglot-completion-at-point))))


(add-hook 'python-mode-hook 'eglot-ensure)
(add-hook 'rust-mode-hook 'eglot-ensure)
(add-hook 'c-mode-hook 'eglot-ensure)
(add-hook 'c++-mode-hook 'eglot-ensure)
(add-hook 'racket-mode-hook 'eglot-ensure)
(add-hook 'arduino-mode-hook 'eglot-ensure)
(add-hook 'nasm-mode-hook 'eglot-ensure)
(add-hook 'typescript-mode-hook 'eglot-ensure)
(add-hook 'js-mode-hook 'eglot-ensure)

(add-to-list 'auto-mode-alist '("\\.py\\'" . python-mode))
(add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-mode))
(add-to-list 'auto-mode-alist '("\\.c\\'" . c-mode))
(add-to-list 'auto-mode-alist '("\\.cpp\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.h\\'" . c-mode))
(add-to-list 'auto-mode-alist '("\\.rkt\\'" . racket-mode))
(add-to-list 'auto-mode-alist '("\\.ino\\'" . arduino-mode))
(add-to-list 'auto-mode-alist '("\\.asm\\'" . nasm-mode))




;; --- Compile language ---

;; --- environment management ---

(use-package conda
  :commands conda-env-activate
  :ensure t
  :init
  (setq conda-anaconda-home (expand-file-name "~/.local/miniconda3"))
  :config
  (defun conda-env-reset ()
    (interactive)
    (setq-local conda-env-current-name nil)
    (eglot-shutdown (eglot-current-server))
    (eglot-ensure)))

(defun get-conda-env ()
  (unless (and (boundp 'conda-env-current-name)
	       conda-env-current-name)
    (call-interactively 'conda-env-activate)
  (concat "VIRTUAL_ENV=" conda-anaconda-home "/envs/" conda-env-current-name)))



(provide 'lang)
