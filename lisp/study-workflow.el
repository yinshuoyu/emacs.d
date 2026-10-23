;;; ---- study-workflow ----
;; This file is about the packages used for academic acitvity, including article writing, RSS, article notes.

;; (use-package elfeed
;;   :ensure t
;;   :bind
;;   ("C-c w" . elfeed)
;;   :custom
;;   (elfeed-use-curl t)
;;   :config
;;   (setq elfeed-search-filter "ture")
;;   (setq elfeed-feeds
;; 	  '(("https://rss.arxiv.org/rss/cs.ai" :title "cs.ai")
;; 	    ("https://rss.arxiv.org/rss/q-bio.NC" :title "q-bio.NC"))))

(use-package org-journal
  :ensure t
  :bind
  ("C-c j" . org-journal-new-entry)
  :config
  (setq org-journal-dir "~/notes/journal/")
  (setq org-journal-file-format "%Y-%m-%d.org"))


;; Something about org
(with-eval-after-load 'org
  (setq org-agenda-files '("~/notes/schedule.org"))
  (setq org-agenda-span 'week)
  (setq org-agenda-start-on-weekday 1)

  (setq org-agenda-custom-commands
	'(("w" "Week" agenda ""
	   ((org-agenda-span 'week)
	    (org-agenda-start-on-weekday 1)
	    (org-agenda-skip-scheduled-if-done t)))
	  ("d" "Today" agenda ""
	   ((org-agenda-span 'day)
	    (org-agenda-skip-scheduled-if-done t)))
	  ("p" "Personal" tags "+personal"
	  ((org-agenda-skip-scheduled-if-done t)))))

  (setq org-capture-templates
      '(("t" "Task" entry (file+headline "~/notes/schedule.org" "Waiting")
         "* TODO %?\n  SCHEDULED: %t")
        ("e" "Event" entry (file+headline "~/notes/schedule.org" "Schedule")
         "* %?\n  %^T")))

  (setq org-file-apps
	'(("\\.pdf\\'" . "xdg-open %s")
	  (auto-mode . emacs)
	  (directory . emacs)
	  ("\\.mm\\'" . default)
	  ("\\.x?html?\\'" . default))))







(provide 'study-workflow)
