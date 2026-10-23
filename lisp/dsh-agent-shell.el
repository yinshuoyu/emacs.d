;;; dsh-agent-shell.el --- DSH (DeepSeek Harness) as an agent-shell agent -*- lexical-binding: t; -*-

;;; Commentary:

;; Registers DSH as an `agent-shell' agent.  DSH ships a standard ACP v1 stdio
;; server (`dsh --profile acp'); agent-shell is the Emacs ACP client that
;; speaks to it.  No other package is involved, and DSH needs no changes.
;;
;; Setup:
;;   1. dsh --profile acp --help                  ; once, in a real terminal
;;   2. M-x package-install RET agent-shell RET   ; pulls acp + shell-maker
;;   3. (require 'dsh-agent-shell)                ; in init.el
;;
;; This file binds no key and defines no command of its own.  Use agent-shell's
;; own entry points.  These four are autoloaded, so binding them works before
;; agent-shell is loaded:
;;
;;   M-x agent-shell                 DWIM: reuse this project's shell, toggle if
;;                                   already in one, carry region/context over
;;   M-x agent-shell-new-shell       always a new shell, always pick an agent
;;   M-x agent-shell-resume-session  resume by session id
;;   M-x agent-shell-toggle          show/hide the shell buffer
;;
;; `agent-shell-switch-buffer' and `agent-shell-select-config' are NOT
;; autoloaded; binding those would need agent-shell loaded first.
;;
;; Loading this file does not load agent-shell; it loads on first use.
;;
;; Whether starting a shell prompts for an agent is controlled by agent-shell's
;; own `agent-shell-preferred-agent-config' (see its docstring, or the notes at
;; the end of this file).

;;; Code:

;; Compile-time only, all three.  They exist purely because the byte-compiler
;; cannot see agent-shell's non-autoloaded symbols, and they emit no runtime
;; code (`(defvar foo)' with no value leaves foo unbound -- verified).  They say
;; nothing about when anything exists at runtime: the registration below is
;; deferred, so `agent-shell-agent-configs' is guaranteed bound by the time
;; that form runs.
(declare-function agent-shell-make-environment-variables "agent-shell")
(declare-function agent-shell--make-acp-client "agent-shell")
(defvar agent-shell-agent-configs)

(defgroup udsh nil
  "Drive DSH (DeepSeek Harness) from Emacs via agent-shell."
  :group 'agent-shell)

(defcustom udsh-acp-command '("dsh" "--profile" "acp")
  "Command and arguments that start the DSH ACP server.

The first element is the executable; the rest are its arguments.
Use an absolute path if `dsh' is not on the PATH your Emacs sees: a
GUI-launched Emacs often inherits a shorter PATH than a login shell."
  :type '(repeat string)
  :group 'udsh)

(defcustom udsh-environment-variables nil
  "Extra environment variables for the DSH process.

A flat list of \"NAME\" \"value\" pairs, for example
\\='(\"DSH_PERMISSION_MODE\" \"danger-full-access\") to change the
sandbox policy, or \\='(\"DSH_HOME\" \"/somewhere/else\") to point at
a different DSH home."
  :type '(repeat string)
  :group 'udsh)

(defun udsh--environment ()
  "Build the environment for the DSH process.

`:inherit-env t' is required, not defensive: without it
`agent-shell-make-environment-variables' returns nil, and agent-shell
spawns the agent with an empty environment.  `dsh' would then fail to
resolve its own binary, its profile under $DSH_HOME, and its stored
credentials."
  (apply #'agent-shell-make-environment-variables
         :inherit-env t
         udsh-environment-variables))

(defun udsh--make-agent-config ()
  "Return the agent-shell configuration alist for DSH.

agent-shell calls this each time it needs the configuration, so edits
here take effect without restarting Emacs."
  (agent-shell-make-agent-config
   :identifier 'dsh
   :mode-line-name "DSH"
   :buffer-name "DSH"
   :shell-prompt "DSH> "
   :shell-prompt-regexp "DSH> "
   ;; agent-shell shows an authentication UI only when this is non-nil.  DSH
   ;; answers `authenticate' with immediate success and needs no credentials
   ;; over the wire, so it stays nil (the default).
   :client-maker (lambda (buffer)
                   (agent-shell--make-acp-client
                    :command (car udsh-acp-command)
                    :command-params (cdr udsh-acp-command)
                    :environment-variables (udsh--environment)
                    :context-buffer buffer))
   :install-instructions
   "Install DSH:  npm install -g @deepseek-ai/dsh
Then initialize the ACP profile once:  dsh --profile acp --help"))

;; Registration must wait for agent-shell: `agent-shell-agent-configs' is a
;; plain defcustom with no autoload, so touching it earlier would signal
;; void-variable.  Waiting also lets agent-shell install its own default agent
;; list first, which `add-to-list' then extends rather than replaces.
(with-eval-after-load 'agent-shell
  (add-to-list 'agent-shell-agent-configs #'udsh--make-agent-config))

(provide 'dsh-agent-shell)

;;; dsh-agent-shell.el ends here
