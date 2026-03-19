;; early-init.el — loaded before init.el (Emacs 27+)

;; Prevent package.el from loading packages before init.el runs
(setq package-enable-at-startup nil)

;; Suppress GC during startup — restore after init
(setq gc-cons-threshold most-positive-fixnum)

;; Disable file-name-handler-alist during init (regex matching on every load)
(defvar my/file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

;; Restore after init
(add-hook 'emacs-startup-hook
  (lambda ()
    (setq gc-cons-threshold (* 16 1024 1024)) ;; 16MB — generous but not infinite
    (setq file-name-handler-alist my/file-name-handler-alist)))
