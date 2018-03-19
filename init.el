;; Melpa ;;
(require 'package)
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(when (< emacs-major-version 24)
  ;; For important compatibility libraries like cl-lib
  (add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/")))
(package-initialize)

;; Other
(require 'expand-region)
(global-set-key (kbd "C-;") 'er/expand-region)

;; fill-column indicator replacing column-marker
(require 'fill-column-indicator)
(setq fci-rule-width 1)
(setq fci-rule-color "darkblue")
(setq fci-rule-column 80)
(add-hook 'rust-mode-hook (lambda () (interactive) (fci-mode 1)))
(add-hook 'c-mode-hook (lambda () (interactive) (fci-mode 1)))
(add-hook 'c++-mode-hook (lambda () (interactive) (fci-mode 1)))

;; (require 'column-marker)
;; (add-hook 'c++-mode-hook (lambda () (interactive) (column-marker-1 80)))
;; (add-hook 'java-mode-hook (lambda () (interactive) (column-marker-1 80)))
;; (add-hook 'latex-mode-hook (lambda () (interactive) (column-marker-1 80)))

(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))

(add-hook 'before-save-hook 'whitespace-cleanup)

(setq-default indent-tabs-mode nil)

(defconst my-cc-style
  '("bsd"
  (c-offsets-alist . ((innamespace .[0])))))
(c-add-style "my-cc-style" my-cc-style)

;; helm-projectile
(projectile-global-mode)
(setq projectile-completion-system 'helm)
(helm-projectile-on)

(setq-default) tab-width 4

;; Backup Directory
(defvar --backup-directory (concat user-emacs-directory "backups"))
(if (not (file-exists-p --backup-directory))
        (make-directory --backup-directory t))
(setq backup-directory-alist `(("." . ,--backup-directory)))
(setq make-backup-files t              ; backup of a file the first time it is saved.
      backup-by-copying t               ; don't clobber symlinks
      version-control t                 ; version numbers for backup files
      delete-old-versions t             ; delete excess backup files silently
      delete-by-moving-to-trash t
      kept-old-versions 6               ; oldest versions to keep when a new numbered backup is made (default: 2)
      kept-new-versions 9               ; newest versions to keep when a new numbered backup is made (default: 2)
      auto-save-default t               ; auto-save every buffer that visits a file
      auto-save-timeout 20              ; number of seconds idle time before auto-save (default: 30)
      auto-save-interval 200            ; number of keystrokes between auto-saves (default: 300)
      )
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(c-basic-offset 4)
 '(c-default-style
   (quote
    ((c-mode . "my-cc-style")
     (c++-mode . "my-cc-style")
     (java-mode . "java")
     (awk-mode . "awk")
     (other . "gnu"))))
 '(inhibit-startup-screen t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; Irony Mode
(add-hook 'c++-mode-hook 'irony-mode)

;; replace the `completion-at-point' and `complete-symbol' bindings in
;; irony-mode's buffers by irony-mode's asynchronous function
(defun my-irony-mode-hook ()
  (define-key irony-mode-map [remap completion-at-point]
    'irony-completion-at-point-async)
  (define-key irony-mode-map [remap complete-symbol]
    'irony-completion-at-point-async))
(add-hook 'irony-mode-hook 'my-irony-mode-hook)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)

;; company-irony
(add-hook 'c++-mode-hook 'company-mode)

(add-hook 'after-init-hook 'global-company-mode)
(setq company-idle-delay 1)
(eval-after-load 'company
  '(add-to-list 'company-backends 'company-irony))
(add-hook 'irony-mode-hook 'company-irony-setup-begin-commands)
(require 'company-irony-c-headers)
;; Load with `irony-mode` as a grouped backend
(eval-after-load 'company
  '(add-to-list
    'company-backends '(company-irony-c-headers company-irony)))

;; flycheck-irony
(add-hook 'c++-mode-hook 'flycheck-mode)

(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-irony-setup))

;; multiple-cursors
(require 'multiple-cursors)
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)
;;(global-set-key (kbd "C-'") 'mc/mark-all-words-like-this)

;; eldoc-mode
(add-hook 'irony-mode-hook 'irony-eldoc)

(global-set-key (kbd "TAB") #'company-indent-or-complete-common)
(setq company-tooltip-align-annotations t)

(setq
 helm-gtags-ignore-case t
 helm-gtags-auto-update t
 helm-gtags-use-input-at-cursor t
 helm-gtags-pulse-at-cursor t
 helm-gtags-prefix-key "\C-cg"
 helm-gtags-suggested-key-mapping t
 )
(require 'helm-gtags)
;; Enable helm-gtags-mode
(add-hook 'dired-mode-hook 'helm-gtags-mode)
(add-hook 'eshell-mode-hook 'helm-gtags-mode)
(add-hook 'c-mode-hook 'helm-gtags-mode)
(add-hook 'c++-mode-hook 'helm-gtags-mode)
(add-hook 'asm-mode-hook 'helm-gtags-mode)

(define-key helm-gtags-mode-map (kbd "C-c g a") 'helm-gtags-tags-in-this-function)
(define-key helm-gtags-mode-map (kbd "C-j") 'helm-gtags-select)
(define-key helm-gtags-mode-map (kbd "M-.") 'helm-gtags-dwim)
(define-key helm-gtags-mode-map (kbd "M-,") 'helm-gtags-pop-stack)
(define-key helm-gtags-mode-map (kbd "C-c <") 'helm-gtags-previous-history)
(define-key helm-gtags-mode-map (kbd "C-c >") 'helm-gtags-next-history)

(defun my-run-latex ()
  (interactive)
  (TeX-save-document (TeX-master-file))
  (TeX-command "LaTeX" 'TeX-master-file -1))

(defun my-LaTeX-hook ()
 (local-set-key (kbd "C-c C-a") 'my-run-latex))

(add-hook 'LaTeX-mode-hook 'my-LaTeX-hook)

(add-hook 'after-init-hook #'global-flycheck-mode)
