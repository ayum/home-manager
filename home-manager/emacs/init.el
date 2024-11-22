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
(setq auto-save-list-file-prefix (expand-file-name "~/.local/state/emacs-auto-save-list/"))

(when (timerp undo-auto-current-boundary-timer)
  (cancel-timer undo-auto-current-boundary-timer))
(fset 'undo-auto--undoable-change
      (lambda () (add-to-list 'undo-auto--undoably-changed-buffers (current-buffer))))
;; Undo charachter by character
;;(fset 'undo-auto-amalgamate 'ignore)

(advice-add #'undefined :override #'keyboard-quit)

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

(defun display-startup-echo-area-message ()
  (message ""))

(defun toggle-buffers ()
  (interactive)
  (switch-to-buffer nil))

(defun evil-keyboard-quit ()
  (interactive)
  (and evil-mode (evil-force-normal-state))
  (keyboard-quit))

(add-to-list 'default-frame-alist '(font . "SourceCodePro" ))
(set-face-attribute 'default t :font "SourceCodePro" )

(use-package general
  :ensure t
  :demand t
  :config
  (general-auto-unbind-keys)
  (general-evil-setup t)
  (general-nmap "SPC" (general-simulate-key "C-SPC"))
;  (general-nmap "C-@" (general-simulate-key "C-SPC"))
;  (general-emap "C-@" (general-simulate-key "C-SPC"))
;  (general-mmap "C-@" (general-simulate-key "C-SPC"))
;  (general-omap "C-@" (general-simulate-key "C-SPC"))
;  (general-rmap "C-@" (general-simulate-key "C-SPC"))
;  (general-iemap "C-@" (general-simulate-key "C-SPC"))
;  (general-nvmap "C-@" (general-simulate-key "C-SPC"))
  (general-define-key "C-@" (general-simulate-key "C-SPC"))
  (general-define-key "C-SPC SPC" (general-simulate-key "C-SPC C-SPC" :which-key "most used"))
  (general-unbind 'treemacs treemacs-mode-map
   :with 'ignore
   "U")
  (general-emap
   :keymaps 'treemacs-mode-map
   "SPC" (general-simulate-key "C-SPC")
   "/" 'counsel-fzf
   "U" 'beginning-of-buffer)
  (general-define-key
   "M-x" 'counsel-M-x)
  (general-define-key
   :states '(visual insert motion)
   "C-g" 'evil-keyboard-quit)
  (general-define-key
   :states '(normal visual emacs)
   "/" 'swiper)
  (general-create-definer leader-key-spc
   :states '(normal visual insert motion emacs)
   :keymaps 'override
   :prefix "C-SPC C-SPC")
  (leader-key-spc
   "" '(:ignore t :which-key "most used")
   "b" 'ivy-switch-buffer
   "s" 'save-buffer
   "w" 'whitespace-mode
   "t" 'treemacs
   "m" 'hide-mode-line-mode
   "r" 'display-fill-column-indicator-mode
   "n" 'display-line-numbers-mode
   "l" 'toggle-truncate-lines
   "c" 'display-buffer-other-frame
   "f" 'select-frame-by-name)
  (general-create-definer leader-key
   :states '(normal visual insert motion emacs)
   :keymaps 'override
   :prefix "C-SPC")
  (leader-key
   "'"     'multi-vterm
   "/"     'swiper
   ":"     'counsel-M-x
   "TAB"   'toggle-buffers

   "<right>" 'windmove-right
   "<left>"  'windmove-left
   "<up>"    'windmove-up
   "<down>"  'windmove-down
   "l" 'windmove-right
   "h" 'windmove-left
   "k" 'windmove-up
   "j" 'windmove-down

   "b" '(:ignore t :which-key "buffers")
   "bb" 'ivy-switch-buffer
   "bx" 'kill-buffer

   "w" '(:ignore t :which-key "window")
   "w <right>" 'windmove-swap-states-right
   "w <left>"  'windmove-swap-states-left
   "w <up>"    'windmove-swap-states-up
   "w <down>"  'windmove-swap-states-down
   "wl"        'windmove-swap-states-right
   "wh"        'windmove-swap-states-left
   "wk"        'windmove-swap-states-up
   "wj"        'windmove-swap-states-down
   "w/"        'split-window-right
   "w-"        'split-window-below
   "wx"        'delete-window
   "wo"        'delete-other-windows
   "w="        'balance-windows

   "a" '(:ignore t :which-key "applications")
   "am" 'mail
   "ag" 'magit

   "t" '(:ignore t :which-key "toggles")
   "tn" 'display-line-numbers-mode
   "tl" 'toggle-truncate-lines
   "tm" 'hide-mode-line-mode
   "tt" 'treemacs
   "tr" 'display-fill-column-indicator-mode
   "tw" 'whitespace-mode
   
   "x" '(:ignore t :which-key "text")
   "xl" '(:ignore t :which-key "lines")
   "xls" 'sort-lines
   
   "g" '(:ignore t :which-key "code")
   "gc" 'evilnc-comment-or-uncomment-lines

   "q" '(:ignore t :which-key "quit")
   "qq" 'save-buffers-kill-terminal
   "qr" 'restart-emacs))

(use-package evil
  :ensure t
  :demand t
  :init
  (setq evil-disable-insert-state-bindings t
        evil-want-keybinding nil
        evil-want-fine-undo t
        evil-want-C-u-scroll t
        evil-want-C-i-jump t
        evil-want-C-d-scroll t
        evil-want-C-w-delete t
        evil-want-Y-yank-to-eol t
        evil-split-window-below t
        evil-vsplit-window-right t
        evil-respect-visual-line-mode t
        evil-move-beyond-eol t)
  :config
  (evil-set-initial-state 'vterm-mode 'insert)
  (evil-set-initial-state 'treemacs-mode 'emacs)
  (evil-set-undo-system 'undo-redo)
  (evil-mode 1)
  (setq-default evil-escape-delay 0.01))
(add-hook 'c-mode-common-hook
          (lambda () (modify-syntax-entry ?_ "w")))
(add-hook 'after-save-hook 'evil-force-normal-state)
(defun maybe-call-undo-boundary ()
  (let ((c last-command-event))
    (if (or (eq c '13) (eq c '32) (eq c 'escape) (eq c 'prior) (eq c 'next) (eq c 'left) (eq c 'right) (eq c 'up) (eq c 'down))
      (undo-boundary))))
(add-hook 'evil-insert-state-entry-hook
  (lambda ()
    (add-hook 'post-command-hook 'maybe-call-undo-boundary)))

(use-package key-chord
  :ensure t
  :config
  (key-chord-mode 1)
  (key-chord-define evil-insert-state-map "kj" 'evil-normal-state))

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
  :init
  (setq treemacs-user-mode-line-format
   (list
    '(:eva evil-mode-line-tag)
    " "
    '(:eval (treemacs-workspace->name (treemacs-current-workspace)))))
  :config
  (progn
    (setq treemacs-persist-file (expand-file-name "~/.local/state/emacs-treemacs"))
    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)))

(use-package which-key
  :ensure t
  :init
  (setq which-key-separator " ")
  (setq which-key-prefix-prefix "+")
  (setq which-key-idle-delay 0.01)
  :config
  (which-key-mode))

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
  :ensure t
  :init
  (setq smex-save-file (expand-file-name "~/.local/state/emacs-smex")))
(use-package counsel
  :ensure t
  :after smex)

(use-package evil-nerd-commenter :ensure t)

(use-package evil-surround
  :ensure t
  :config
  (global-evil-surround-mode 1))

(use-package company
  :ensure t
  :init
  (setq company-idle-delay 0.0
        company-minimum-prefix-length 1))
(add-hook 'after-init-hook 'global-company-mode)

(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

(setq lsp-clients-clangd-executable "clangd")
(use-package lsp-mode
  :ensure t
  :demand t
  :init
  (setq lsp-keymap-prefix "C-SPC ."
        lsp-idle-delay 0.1
        lsp-session-file (expand-file-name "~/.local/state/emacs-lsp-session"))
  :config
  (fset 'lsp-command-map lsp-command-map)
  (lsp-enable-which-key-integration t)
  :hook ((c-mode . lsp)
         (c++-mode . lsp))
  :commands (lsp lsp-deferred)
  :general
  (leader-key "." 'lsp-command-map))
(add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
(use-package lsp-ui :after lsp :commands lsp-ui-mode)
(use-package lsp-ivy :after lsp :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :after lsp :commands lsp-treemacs-errors-list)
