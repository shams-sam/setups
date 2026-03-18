;; .emacs.d/init.el 

;; ===================================
;; MELPA Package Support
;; ===================================
;; Enables basic packaging support
(require 'package)

;; Adds the Melpa and GNU ELPA archives to the list of available repositories
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("gnu" . "https://elpa.gnu.org/packages/")))

(setq package-check-signature nil)

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
    material-theme                  ;; Theme: material, material-light
    ace-window                      ;; Window navigation
    highlight-indent-guides         ;; Highlight indentations
    vlf                             ;; View Large Files in chunks
    )
  )

;; Scans the list in myPackages
;; If the package listed is not already installed, install it
(mapc #'(lambda (package)
          (unless (package-installed-p package)
            (package-install package)))
      myPackages)

(require 'vlf-setup) ;; to open large files

;; ===================================
;; Basic Customization
;; ===================================

(setq inhibit-startup-message t)    ;; Hide the startup message
(load-theme 'material t)            ;; Load material theme
(global-display-line-numbers-mode t) ;; Enable line numbers globally

;; ====================================
;; Development Setup
;; ====================================
;; Enable elpy
;; https://emacs.stackexchange.com/questions/16637/how-to-set-up-elpy-to-use-python3
;; https://emacs.stackexchange.com/questions/52652/elpy-doesnt-recognize-i-have-virtualenv-installed
;; in case of "peculiar error": try M-x elpy-config and install dependencies
(elpy-enable)
(setq elpy-rpc-python-command "python3")
(setq elpy-rpc-virtualenv-path 'current)
(setq python-shell-interpreter "python3")

;; Enable Flycheck
;; (when (require 'flycheck nil t)
;;   (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
;;   (add-hook 'elpy-mode-hook 'flycheck-mode))

;; Enable autopep8
;; (require 'py-autopep8)
;; (add-hook 'elpy-mode-hook 'py-autopep8-mode)

;; add hook for black instead of autopep8
;; reference: https://elpy.readthedocs.io/en/latest/customization_tips.html#auto-format-code-on-save
;; (add-hook 'elpy-mode-hook
;;    (lambda ()
;;      (add-hook 'before-save-hook
;;                'elpy-black-fix-code nil t)))

;; Disable emacs backup files
(setq make-backup-files nil)

;; Disable indentation warnings
;; https://stackoverflow.com/questions/18778894/emacs-24-3-python-cant-guess-python-indent-offset-using-defaults-4
(setq python-indent-guess-indent-offset t)
(setq python-indent-guess-indent-offset-verbose nil)

;; show lines over 80 characters
;; (require 'whitespace)
;; (setq whitespace-style '(face empty tabs trailing))
;; (global-whitespace-mode t)

;; ace-window
(require 'ace-window)
  :ensure t
(setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)
      aw-char-position 'top-left
      aw-dispatch-always 't
      ;; aw-ignore-current nil
      aw-leading-char-style 'char
      aw-scope 'frame)
(global-set-key (kbd "M-o") 'ace-window)
 ;; :bind (("M-o" . ace-window)
 ;;        ("M-O" . ace-swap-window)))


;; (defun custom-highlighter (level responsive display)
;;   (if (> 1 level)
;;       nil
;;     (highlight-indent-guides--highlighter-default level responsive character)
;;   )
;; )

;; (setq highlight-indent-guides-highlighter-function 'custom-highlighter)
(add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
(add-hook 'yaml-mode-hook 'highlight-indent-guides-mode)
;; (set-face-background 'highlight-indent-guides-odd-face "darkgray")
;; (set-face-background 'highlight-indent-guides-even-face "dimgray")
;; (set-face-foreground 'highlight-indent-guides-character-face "dimgray")

;; ====================================
;; Clipboard over SSH (reverse port forward to localhost:2225)
;; ====================================
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
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(elpy-formatter 'black)
 '(package-selected-packages
   '(csv-mode yapfify p4 log4j-mode logview dockerfile-mode yaml-mode yaml ace-window material-theme magit blacken py-autopep8 flycheck elpy better-defaults)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
