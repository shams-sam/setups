;; .emacs.d/init.el

;; ===================================
;; MELPA Package Support
;; ===================================
;; Enables basic packaging support
(require 'package)

;; Adds the Melpa archive to the list of available repositories
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)

;; Initializes the package infrastructure
(package-initialize)

;; If there are no archived package contents, refresh them
(when (not package-archive-contents)
  (package-refresh-contents))

;; Installs packages
;;
;; myPackages contains a list of package names
(defvar myPackages
  '(better-defaults                 ;; Set up some better Emacs defaults
    elpy                            ;; Emacs Lisp Python Environment
    flycheck                        ;; On the fly syntax checking
    py-autopep8                     ;; Run autopep8 on save
    blacken                         ;; Black formatting on save
    magit                           ;; Git integration
    material-theme                  ;; Theme
    ace-window                      ;; Window navigation
    )
  )

;; Scans the list in myPackages
;; If the package listed is not already installed, install it
(mapc #'(lambda (package)
          (unless (package-installed-p package)
            (package-install package)))
      myPackages)

;; ===================================
;; Basic Customization
;; ===================================

(setq inhibit-startup-message t)    ;; Hide the startup message
(load-theme 'material t)            ;; Load material theme
(global-linum-mode t)               ;; Enable line numbers globally

;; ====================================
;; Development Setup
;; ====================================
;; Enable elpy
;; https://emacs.stackexchange.com/questions/16637/how-to-set-up-elpy-to-use-python3
;; https://emacs.stackexchange.com/questions/52652/elpy-doesnt-recognize-i-have-virtualenv-installed
(elpy-enable)
(setq elpy-rpc-python-command "python3")
(setq elpy-rpc-virtualenv-path 'current)
(setq python-shell-interpreter "python3")

;; Enable Flycheck
(when (require 'flycheck nil t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode))

;; Enable autopep8
(require 'py-autopep8)
(add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save)

;; Disable emacs backup files
(setq make-backup-files nil)

;; show lines over 80 characters
;; (require 'whitespace)
;; (setq whitespace-style '(face empty tabs lines-tail trailing))
;; (global-whitespace-mode t)

;; ace-window
(require 'ace-window)
  :ensure t
(setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)
      aw-char-position 'top-left
      aw-ignore-current nil
      aw-leading-char-style 'char
      aw-scope 'frame)
(global-set-key (kbd "M-o") 'ace-window)
;;  :bind (("M-o" . ace-window)
;;         ("M-O" . ace-swap-window)))
