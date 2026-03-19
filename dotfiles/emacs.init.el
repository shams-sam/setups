;; .emacs.d/init.el

;; ===================================
;; Package Setup (use-package)
;; ===================================
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")))
(setq package-check-signature nil)
(unless package--initialized (package-initialize))

;; Bootstrap use-package
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

;; ===================================
;; Basic Customization
;; ===================================
(setq inhibit-startup-message t)
(setq make-backup-files nil)
(global-display-line-numbers-mode t)
(menu-bar-mode -1)

;; Enable 24-bit color in terminal
(when (not (display-graphic-p))
  (setq xterm-color-count 16777216))

;; ===================================
;; Theme — doom-one (matches agnoster dark)
;; ===================================
(use-package doom-themes
  :config
  (load-theme 'doom-dark+ t)
  (doom-themes-visual-bell-config))

;; Dark modeline to match theme
(use-package doom-modeline
  :hook (after-init . doom-modeline-mode)
  :config
  (setq doom-modeline-height 25))

;; ===================================
;; Packages (deferred — load on demand)
;; ===================================

(use-package ace-window
  :bind ("M-o" . ace-window)
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)
        aw-char-position 'top-left
        aw-dispatch-always t
        aw-leading-char-style 'char
        aw-scope 'frame))

(use-package magit
  :defer t)

(use-package vlf
  :defer t)

(use-package highlight-indent-guides
  :hook ((prog-mode . highlight-indent-guides-mode)
         (yaml-mode . highlight-indent-guides-mode)))

;; ===================================
;; Python Development (lazy — loads on .py files)
;; ===================================
(use-package elpy
  :defer t
  :hook (python-mode . elpy-enable)
  :config
  (setq elpy-rpc-python-command "python3")
  (setq elpy-rpc-virtualenv-path 'current)
  (setq python-shell-interpreter "python3"))

(use-package blacken
  :defer t)

(setq python-indent-guess-indent-offset t)
(setq python-indent-guess-indent-offset-verbose nil)

;; ===================================
;; Clipboard over SSH (reverse port forward to localhost:2225)
;; ===================================
(unless (display-graphic-p)
  (defun my/copy-to-clipboard (text &rest _)
    (let ((process-connection-type nil))
      (if (or (not (getenv "SSH_CONNECTION"))
              (string= (getenv "SSH_CONNECTION") ""))
          ;; Local macOS — pbcopy
          (let ((proc (start-process "pbcopy" nil "pbcopy")))
            (process-send-string proc text)
            (process-send-eof proc))
        ;; Remote — send via reverse-forwarded port
        (let ((proc (start-process "clipboard" nil "nc" "-N" "localhost" "2225")))
          (process-send-string proc text)
          (process-send-eof proc)))))

  (defun my/paste-from-clipboard ()
    (if (or (not (getenv "SSH_CONNECTION"))
            (string= (getenv "SSH_CONNECTION") ""))
        (shell-command-to-string "pbpaste")
      nil))

  (setq interprogram-cut-function #'my/copy-to-clipboard)
  (setq interprogram-paste-function #'my/paste-from-clipboard))

(custom-set-variables
 '(elpy-formatter 'black))
(custom-set-faces
 '(default ((t (:background "#000000"))))
 '(line-number ((t (:background "#000000"))))
 '(fringe ((t (:background "#000000")))))
