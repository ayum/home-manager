(setq delete-old-versions t)
(setq inhibit-startup-screen t)
(setq ring-bell-function 'ignore)
(setq coding-system-for-read 'utf-8)
(setq coding-system-for-write 'utf-8)
(setq sentence-end-double-space nil)
(setq default-fill-column 80)
(setq initial-scratch-message "")
(setq initial-major-mode 'org-mode)
(setq auto-save-list-file-prefix (expand-file-name "~/.local/state/emacs-auto-save-list/"))

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

(add-to-list 'default-frame-alist '(font . "SourceCodePro" ))
(set-face-attribute 'default t :font "SourceCodePro" )

;;(use-package key-chord
;;  :ensure t
;;  :config
;;  (key-chord-mode 1)
;;  (key-chord-define evil-insert-state-map "kj" 'evil-normal-state))
(use-package general
  :ensure t
  :demand t
  :config
  (general-evil-setup t)
  (general-define-key
   "M-x" 'counsel-M-x)
  (general-define-key
   :states '(normal visual emacs)
   "/" 'swiper)
  (general-create-definer leader-key
   :states '(normal visual insert motion emacs)
   :keymaps 'override
   :prefix "SPC"
   :non-normal-prefix "C-SPC")
  (leader-key
   "'"   'multi-vterm
   "/"   'counsel-ag
   ":"   'execute-extended-command
   "TAB" 'toggle-buffers
   "SPC" 'counsel-M-x

   "b" '(:ignore t :which-key "buffers")
   "bb"  'ivy-switch-buffer

   "w" '(:ignore t :which-key "window")
   "w <right>" 'windmove-right
   "w <left>"  'windmove-left
   "w <up>"    'windmove-up
   "w <down>"  'windmove-down
   "w/"        'split-window-right
   "w-"        'split-window-below
   "wx"        'delete-window

   "a" '(:ignore t :which-key "applications")
   "ar" 'ranger
   "ad" 'deer

   "s" '(:ignore t :which-key "search")
   "sc" 'evil-ex-nohighlight
   "sl" 'ivy-resume

   "t" '(:ignore t :which-key "toggles")
   "tn" 'display-line-numbers-mode
   "tl" 'toggle-truncate-lines
   "tm" 'hide-mode-line-mode
   "tt" 'treemacs
   
   "x" '(:ignore t :which-key "text")
   "xl" '(:ignore t :which-key "lines")
   "xls" 'sort-lines
   
   "g" '(:ignore t :which-key "code")
   "gc" 'evilnc-comment-or-uncomment-lines

   "q" '(:ignore t :which-key "quit")
   "qq" 'save-buffers-kill-terminal
   "qr" 'restart-emacs))

(use-package exec-path-from-shell
  :ensure t
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

(use-package evil
  :ensure t
  :init
  (setq evil-disable-insert-state-bindings t
        evil-want-keybinding nil
        evil-want-C-u-scroll t
        evil-want-C-i-jump t
        evil-want-C-d-scroll t
        evil-want-C-w-delete t
        evil-want-Y-yank-to-eol t
        evil-split-window-below t
        evil-vsplit-window-right t
        evil-respect-visual-line-mode t)
  :config
  (evil-set-initial-state 'vterm-mode 'insert)
  (evil-mode 1)
  (setq-default evil-escape-delay 0.01))

(use-package hide-mode-line
  :ensure t
  :commands hide-mode-line-mode)
(global-hide-mode-line-mode t)

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
  :defer 2
  :general
  (:keymaps 'treemacs-mode-map
   :states 'treemacs
   "f f" 'treemacs-find-file)
  :config
  (progn
    (setq treemacs-persist-file (expand-file-name "~/.local/state/emacs-treemacs"))
    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)))
(use-package treemacs-evil
  :ensure t
  :after (treemacs evil)
  :defer 1)

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

(setq lsp-clients-clangd-executable "clangd")
(use-package lsp-mode
  :ensure t
  :demand t
  :init
  (setq lsp-keymap-prefix "SPC l")
  :config
  (fset 'lsp-command-map lsp-command-map)
  (lsp-enable-which-key-integration t)
  :hook ((c-mode . lsp))
  :commands (lsp lsp-deferred)
  :general
  (leader-key
    "l" 'lsp-command-map))
(add-hook 'lsp-mode-hook #'lsp-enable-which-key-integration)
(use-package lsp-ui :after lsp :commands lsp-ui-mode)
(use-package lsp-ivy :after lsp :commands lsp-ivy-workspace-symbol)
(use-package lsp-treemacs :after lsp :commands lsp-treemacs-errors-list)
