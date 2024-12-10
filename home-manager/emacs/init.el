(setq delete-old-versions t)
(setq inhibit-startup-screen t)
(setq ring-bell-function 'ignore)
(setq coding-system-for-read 'utf-8)
(setq coding-system-for-write 'utf-8)
(setq sentence-end-double-space nil)
(setq-default fill-column 88)
(setq scroll-step 1)
(setq scroll-conservatively 10000)
(setq auto-window-vscroll nil)
(setq scroll-preserve-screen-position t)
(setq initial-scratch-message "")
(setq initial-major-mode 'text-mode)
(setq read-file-name-completion-ignore-case t)
(setopt use-short-answers t)

;; They are disabled by default
(put 'delete-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

(scroll-bar-mode -1)
(tool-bar-mode   -1)
(tooltip-mode    -1)
(menu-bar-mode   -1)
(global-auto-revert-mode t)
(electric-pair-mode 1)

;; Save windows and buffers on exit and restore them on start
(desktop-save-mode 1)
(add-hook 'server-after-make-frame-hook
  (lambda () (desktop-read)))

;; Use treesitter for c/c++ modes
(setq major-mode-remap-alist
 '((c-mode . c-ts-mode)
   (c++-mode . c++-ts-mode)))

;; Do not show help text on start
(defun display-startup-echo-area-message ()
  (message ""))

;; Dark mode, comment if using theme
(when (display-graphic-p)
  ;; Drop changes from early-init
  (setq default-frame-alist nil)
  ;; Just to invert
  (set-background-color "white")
  (invert-face 'default))
(set-variable 'frame-background-mode 'dark)

;; If you want it
;; (add-to-list 'default-frame-alist '(font . "SourceCodePro" ))
;; (set-face-attribute 'default t :font "SourceCodePro" )

;; Uncomment if using theme, but remember to comment dark mode settings before
;;(use-package spacemacs-theme
;;  :ensure t
;;  :demand t
;;  :config
;;  (load-theme 'spacemacs-dark t))

;;(use-package zenburn-theme
;;  :ensure t
;;  :config
;;  (load-theme 'zenburn t))

(defun ayum-delete-other-window ()
  (interactive)
  (other-window 1)
  (delete-window))

(add-hook 'c-mode-hook
  (lambda () (define-key c-mode-base-map (kbd "/") #'swiper)))

(global-set-key (kbd "C-o") 'pop-to-mark-command)

;; For simpler access in keypad meow mode
(global-unset-key (kbd "C-x C-0"))

(define-key mode-specific-map (kbd "'")         'multi-vterm)
(define-key mode-specific-map (kbd "<right>")   'windmove-right)
(define-key mode-specific-map (kbd "<left>")    'windmove-left)
(define-key mode-specific-map (kbd "<up>")      'windmove-up)
(define-key mode-specific-map (kbd "<down>")    'windmove-down)
(define-key mode-specific-map (kbd "l")         'windmove-right)
(define-key mode-specific-map (kbd "h")         'windmove-left)
(define-key mode-specific-map (kbd "k")         'windmove-up)
(define-key mode-specific-map (kbd "j")         'windmove-down)
(define-key mode-specific-map (kbd "b")         'counsel-switch-buffer)
(define-key mode-specific-map (kbd "w <right>") 'windmove-swap-states-right)
(define-key mode-specific-map (kbd "w <left>")  'windmove-swap-states-left)
(define-key mode-specific-map (kbd "w <up>")    'windmove-swap-states-up)
(define-key mode-specific-map (kbd "w <down>")  'windmove-swap-states-down)
(define-key mode-specific-map (kbd "wl")        'windmove-swap-states-right)
(define-key mode-specific-map (kbd "wh")        'windmove-swap-states-left)
(define-key mode-specific-map (kbd "wk")        'windmove-swap-states-up)
(define-key mode-specific-map (kbd "wj")        'windmove-swap-states-down)
(define-key mode-specific-map (kbd "wo")        'ayum-delete-other-window)
(define-key mode-specific-map (kbd "tn")        'display-line-numbers-mode)
(define-key mode-specific-map (kbd "th")        'hide-mode-line-mode)
(define-key mode-specific-map (kbd "tm")        'meow-normal-mode)
(define-key mode-specific-map (kbd "tt")        'treemacs)
(define-key mode-specific-map (kbd "tr")        'display-fill-column-indicator-mode)
(define-key mode-specific-map (kbd "tw")        'whitespace-mode)
(define-key mode-specific-map (kbd "ts")        'smartparens-strict-mode)
(define-key mode-specific-map (kbd "f")         'select-frame-by-name)

(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives '(("org"       . "http://orgmode.org/elpa/")
			 ("gnu"       . "http://elpa.gnu.org/packages/")
			 ("melpa"     . "https://melpa.org/packages/")))
(package-initialize)
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)

(use-package which-key
  :ensure t
  :demand t
  :init
  (setq which-key-separator " ")
  (setq which-key-prefix-prefix "+")
  (setq which-key-idle-delay 0.01)
  :config
  (which-key-mode))

;; Default except for settings and commented statments
(defun meow-setup ()
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty
        meow-use-clipboard t
        meow-use-cursor-position-hack t
;; Usefull but conflict with ayum-meow-keyboard-quit for quitting with selection
;;        meow-select-on-change t
;;        meow-select-on-append t
;;        meow-select-on-insert t
        meow-keypad-describe-delay 1.0)
;; Suppose to disable keypad translation in inner keymap (ctl-x-map), but seems not working
;;  (setq meow-use-keypad-when-execute-kbd nil)

  (defun ayum-meow-normal-self-insert ()
    (interactive)
    (meow--direction-backward)
    (meow--switch-state 'insert)
    (self-insert-command 1)
    (exchange-point-and-mark)
    (meow--switch-state 'normal)
    (setq deactivate-mark nil))

;; Do not unselect on keyboard-quit. Uncomment if want to do it throug insert hooks
  (defun ayum-keyboard-quit-advice (fn &rest args)
    (let ((region-was-active (region-active-p)))
      (unwind-protect
         (apply fn args)
      (when (and region-was-active (bound-and-true-p meow-normal-mode)) ;; comment it if uncommenting next line
;;      (when region-was-active
         (activate-mark t)))))
  (advice-add 'keyboard-quit :around #'ayum-keyboard-quit-advice)
;;  (add-hook 'meow-insert-mode-hook (lambda () (advice-add 'keyboard-quit :around #'ayum-keyboard-quit-advice)))
;;  (add-hook 'meow-insert-exit-hook (lambda () (advice-remove 'keyboard-quit #'ayum-keyboard-quit-advice)))
  (defun ayum-meow-keyboard-quit ()
    (interactive)
    (cond
     ((meow-keypad-mode-p)
      (meow--exit-keypad-state))
     ((and (meow-insert-mode-p)
           (eq meow--beacon-defining-kbd-macro 'quick))
      (setq meow--beacon-defining-kbd-macro nil)
      (when defining-kbd-macro
       (end-kbd-macro)
      (meow--switch-state 'beacon)))
     ((meow-insert-mode-p)
      (meow--switch-state 'normal)))
    (keyboard-quit)
    (setq deactivate-mark nil))
  (define-key meow-insert-state-keymap (kbd "C-g") 'ayum-meow-keyboard-quit)

  (meow-motion-overwrite-define-key
   '("j" . meow-next)
   '("k" . meow-prev)
   '("<escape>" . ignore))

  (meow-leader-define-key
   `("SPC" . ,ctl-x-map)
   ;; SPC j/k will run the original command in MOTION state.
   '("j" . "H-j")
   '("k" . "H-k")
   ;; Use SPC (0-9) for digit arguments.
   '("1" . meow-digit-argument)
   '("2" . meow-digit-argument)
   '("3" . meow-digit-argument)
   '("4" . meow-digit-argument)
   '("5" . meow-digit-argument)
   '("6" . meow-digit-argument)
   '("7" . meow-digit-argument)
   '("8" . meow-digit-argument)
   '("9" . meow-digit-argument)
   '("0" . meow-digit-argument)
   '("/" . swiper)
   '("?" . meow-cheatsheet))

  (meow-normal-define-key
   '("0" . meow-expand-0)
   '("9" . meow-expand-9)
   '("8" . meow-expand-8)
   '("7" . meow-expand-7)
   '("6" . meow-expand-6)
   '("5" . meow-expand-5)
   '("4" . meow-expand-4)
   '("3" . meow-expand-3)
   '("2" . meow-expand-2)
   '("1" . meow-expand-1)
   '("-" . negative-argument)
   '(";" . meow-reverse)
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
;;   '("[" . meow-beginning-of-thing)
;;   '("]" . meow-end-of-thing)
   '("<" . meow-beginning-of-thing) ;;
   '(">" . meow-end-of-thing) ;;
   '("{" . ayum-meow-noraml-self-insert) ;;
   '("(" . ayum-meow-normal-self-insert) ;;
   '("a" . meow-append)
   '("A" . meow-open-below)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change)
   '("d" . meow-delete)
   '("D" . meow-backward-delete)
   '("e" . meow-next-word)
   '("E" . meow-next-symbol)
   '("f" . meow-find)
   '("g" . meow-cancel-selection)
   '("G" . meow-grab)
   '("h" . meow-left)
   '("H" . meow-left-expand)
   '("i" . meow-insert)
   '("I" . meow-open-above)
   '("j" . meow-next)
   '("J" . meow-next-expand)
   '("k" . meow-prev)
   '("K" . meow-prev-expand)
   '("l" . meow-right)
   '("L" . meow-right-expand)
   '("m" . meow-join)
   '("M" . meow-pop-to-mark) ;; Not work as expected though
   '("n" . meow-search)
   '("o" . meow-block)
   '("O" . meow-to-block)
   '("p" . meow-yank)
   '("q" . meow-quit)
   '("Q" . meow-goto-line)
   '("r" . meow-replace)
   '("R" . meow-swap-grab)
;; Do not yank deleted region
;;   '("s" . meow-kill)
   '("s" . delete-region)
   '("t" . meow-till)
   '("u" . meow-undo)
   '("U" . meow-undo-in-selection)
   '("v" . meow-visit)
   '("w" . meow-mark-word)
   '("W" . meow-mark-symbol)
   '("x" . meow-line)
   '("y" . meow-save)
   '("Y" . meow-sync-grab)
   '("z" . meow-pop-selection)
   '("Z" . undo-redo) ;;
   '("'" . repeat)
   '("<escape>" . ignore)))

(use-package meow
  :ensure t
  :demand t
  :config
  (meow-setup)
  (meow-global-mode 1))

(use-package meow-tree-sitter
  :ensure t
  :config
  (meow-tree-sitter-register-defaults))

(use-package hide-mode-line
  :ensure t
  :commands hide-mode-line-mode)
;;Uncomment to hide by default
;;(global-hide-mode-line-mode t)

;; For pretty icons in treemacs
;;(use-package nerd-icons
;;  :ensure t
;;  :custom
;;  (nerd-icons-font-family "Symbols Nerd Font Mono"))
;;(use-package treemacs-nerd-icons
;;  :ensure t
;;  :after nerd-icons
;;  :config
;;  (treemacs-load-theme "nerd-icons"))
(use-package treemacs
  :ensure t
  :after treemacs-nerd-icons
  :config
  (progn
    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always))
  :bind
  (:map treemacs-mode-map
   ("/" . counsel-fzf)))

(use-package exec-path-from-shell
  :ensure t
  :config
  (exec-path-from-shell-initialize))
(use-package vterm
  :ensure t
  :init
  (setq vterm-kill-buffer-on-exit t))
(use-package multi-vterm
  :ensure t
  :config
  (setq multi-vterm-program "bash"))

(use-package ivy
  :ensure t)
(use-package smex
  :ensure t)
(use-package counsel
  :ensure t
  :after smex
  :bind (("M-x" . counsel-M-x)))

(use-package company
  :ensure t
  :init
  (setq company-idle-delay 0.01
        company-minimum-prefix-length 10
        company-global-modes nil)
  :bind (("M-/" . company-complete)))

(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

(use-package eglot
  :hook ((c++-mode c-mode)
         . eglot-ensure)
  :config
;; I see many do this, but i dont know if i need this
;;  (setq eglot-ignored-server-capabilites
;;        '(:documentHighlightProvider ;;no highlight on hover
;;          :inlayHintProvider ;; no argument signatures
;;          ))
  (with-eval-after-load 'eglot
    (add-to-list
      'eglot-server-programs
      '((c-mode c++-mode)
        . ("clangd"
           "-j=4"
           "-background-index"
           "--header-insertion=never"
           "--header-insertion-decorators=0"
           "-log=error"
           "--enable-config"
           "--all-scopes-completion"
           "--completion-style=detailed")))))
