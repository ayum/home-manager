(when (boundp 'native-comp-eln-load-path)
  (startup-redirect-eln-cache (expand-file-name "~/.cache/eln-cache/")))

(setq default-frame-alist '((background-color . "#000000") (ns-appearance . dark) (ns-transparent-titlebar . t) (ns-appearance . 'nil)))
