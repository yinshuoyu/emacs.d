;; This is the file to restore the functions the user himself defined
;; The file begin



;; -- switch to the new window ---
(defun auto-switch (&rest _)
  (other-window 1))

(advice-add 'split-window-below :after #'auto-switch)
(advice-add 'split-window-right :after #'auto-switch)
(advice-add 'list-buffers :after #'auto-switch)
(advice-add 'describe-mode :after #'auto-switch)


;; --- make faster to switch on path

(defun path-switch ()
  (interactive)
  (let ((default-directory (file-name-directory (completing-read "Find file under path: " recentf-list nil t))))
    (call-interactively 'find-file)))

(global-set-key (kbd "C-c p") 'path-switch)

;; -- make faster jumping to target lines
(defun line-blank-p ()
  (save-excursion
    (beginning-of-line)
    (looking-at-p "[ \t]*$")))

(defun jump-to-next-same-indent ()
  (interactive)
  (let ((start-indent (current-indentation)))
    (while (and (not (eobp))
		(zerop (forward-line 1))
		(or (line-blank-p)
		    (>= (current-indentation) start-indent)))
      )
    (forward-line -1)
    (back-to-indentation)))

(global-set-key (kbd "M-n") 'jump-to-next-same-indent)

(defun gptel-current ()
  (interactive)
  (gptel (current-buffer)))

(defvar sjtu-hpc "clschf@pilogin.hpc.sjtu.edu.cn:")

(defvar mount-point "~/remote")

(defun sshfs-mount ()
  (interactive)
  (let ((target (read-directory-name "Please asign the mount point"  "~/remote")))
    (message target)
    (shell-command (concat "sshfs " sjtu-hpc " " target))
    (setq mount-point target)))



(defun sshfs-unmount ()
  (interactive)
  (shell-command (concat "fusermount -u " mount-point)))
  

(global-set-key (kbd "M-s-a") (lambda () (interactive) (insert "(")))
(global-set-key (kbd "M-s-s") (lambda () (interactive) (insert ")")))
(global-set-key (kbd "M-s-d") (lambda () (interactive) (insert "[")))
(global-set-key (kbd "M-s-f") (lambda () (interactive) (insert "]")))
(global-set-key (kbd "M-s-g") (lambda () (interactive) (insert "-")))
(global-set-key (kbd "M-s-h") (lambda () (interactive) (insert "_")))

(with-eval-after-load 'flymake
  (define-key flymake-mode-map (kbd "M-N") #'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "M-P") #'flymake-goto-prev-error))
  


;; --- provide ---
(provide 'user-defun)
