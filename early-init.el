;; early-init.el

;; --- lazier gc ---
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)
(add-hook 'emacs-startup-hook
	  (lambda ()
	    (setq gc-cons-threshold (* 128 1024 1024)
		  gc-cons-percentage 0.2)))

;; --- Inhibit Ui ---
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-startup-screen t)

(setq package-quickstart t)
(setq package-enable-at-startup t)
