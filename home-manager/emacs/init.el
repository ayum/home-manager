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
(setq initial-major-mode 'org-mode)
(setq read-file-name-completion-ignore-case t)
(setopt use-short-answers t)

(put 'delete-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)

(when (timerp undo-auto-current-boundary-timer)
  (cancel-timer undo-auto-current-boundary-timer))
(fset 'undo-auto--undoable-change
      (lambda () (add-to-list 'undo-auto--undoably-changed-buffers (current-buffer))))
;; Undo charachter by character
;;(fset 'undo-auto-amalgamate 'ignore)

;;(advice-add #'undefined :override #'keyboard-quit)

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

(scroll-bar-mode -1)
(tool-bar-mode   -1)
(tooltip-mode    -1)
(menu-bar-mode   -1)
(global-auto-revert-mode t)
(electric-pair-mode)
(desktop-save-mode 1)
(add-hook 'server-after-make-frame-hook
  (lambda () (desktop-read)))

(defun display-startup-echo-area-message ()
  (message ""))

(add-to-list 'default-frame-alist '(font . "SourceCodePro" ))
(set-face-attribute 'default t :font "SourceCodePro" )

(use-package which-key
  :ensure t
  :demand t
  :init
  (setq which-key-separator " ")
  (setq which-key-prefix-prefix "+")
  (setq which-key-idle-delay 0.01)
  :config
  (which-key-mode))

(add-hook
     'c-mode-hook
      (lambda ()
      (define-key c-mode-base-map (kbd "/") #'swiper)))

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
(define-key mode-specific-map (kbd "tn")        'display-line-numbers-mode)
(define-key mode-specific-map (kbd "tm")        'hide-mode-line-mode)
(define-key mode-specific-map (kbd "tt")        'treemacs)
(define-key mode-specific-map (kbd "tr")        'display-fill-column-indicator-mode)
(define-key mode-specific-map (kbd "tw")        'whitespace-mode)
(define-key mode-specific-map (kbd "ts")        'smartparens-strict-mode)
(define-key mode-specific-map (kbd "f")         'select-frame-by-name)

(defun meow-setup ()
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty
        meow-use-clipboard t
        meow-use-cursor-position-hack t
        meow-keypad-describe-delay 1.0)
;; Suppose to disable keypad translation in inner keymap (ctl-x-map), but seems not working
;;  (setq meow-use-keypad-when-execute-kbd nil)

  (setq meow-paren-state-keymap (make-keymap))
  (meow-define-state paren
    "meow state for interacting with smartparens"
    :lighter " [P]"
    :keymap meow-paren-state-keymap)

  ;; meow-define-state creates the variable
  (setq meow-cursor-type-paren 'hollow)

  (meow-define-keys 'paren
    '("<escape>" . meow-normal-mode)
    '("S" . meow-normal-mode)
    '("l" . sp-forward-sexp)
    '("h" . sp-backward-sexp)
    '("j" . sp-down-sexp)
    '("k" . sp-up-sexp)
    '("n" . sp-forward-slurp-sexp)
    '("b" . sp-forward-barf-sexp)
    '("v" . sp-backward-barf-sexp)
    '("c" . sp-backward-slurp-sexp)
    '("u" . meow-undo))
  
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
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)
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
   '("n" . meow-search)
   '("o" . meow-block)
   '("O" . meow-to-block)
   '("p" . meow-yank)
   '("q" . meow-quit)
   '("Q" . meow-goto-line)
   '("r" . meow-replace)
   '("R" . meow-swap-grab)
;   '("s" . meow-kill)
   '("s" . delete-region)
   '("S" . meow-paren-mode) ;
   '("t" . meow-till)
   '("u" . meow-undo)
   '("U" . meow-undo-in-selection)
   '("v" . meow-visit)
   '("w" . meow-mark-word)
   '("W" . meow-mark-symbol)
   '("x" . meow-line)
   '("X" . meow-goto-line)
   '("y" . meow-save)
   '("Y" . meow-sync-grab)
   '("z" . meow-pop-selection)
   '("'" . repeat)
   '("<escape>" . ignore)))

(use-package meow
  :ensure t
  :demand t
  :config
  (meow-setup)
  (meow-global-mode 1))

(use-package key-chord
  :ensure t
  :config
  (key-chord-mode 1)
  (key-chord-define meow-insert-state-keymap "jk" #'meow-insert-exit)
  (key-chord-define meow-paren-state-keymap "jk" #'meow-normal-mode))

(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

(use-package hide-mode-line
  :ensure t
  :commands hide-mode-line-mode)
;;Uncomment to hide by default
;;(global-hide-mode-line-mode t)

(use-package spacemacs-theme
  :ensure t
  :config
  (load-theme 'spacemacs-dark t))

(use-package nerd-icons
  :ensure t
  :custom
  (nerd-icons-font-family "Symbols Nerd Font Mono"))
(use-package treemacs-nerd-icons
  :ensure t
  :after nerd-icons
  :config
  (treemacs-load-theme "nerd-icons"))
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
;  (setq eglot-ignored-server-capabilites
;        '(:documentHighlightProvider ;;no highlight on hover
;          :inlayHintProvider ;; no argument signatures
;          ))
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

(use-package smartparens
  :ensure t
;  :hook (prog-mode text-mode markdown-mode c-mode c++-mode)
  :config
  (require 'smartparens-config)
  (smartparens-global-strict-mode))
