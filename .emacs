;; --- Custom File Location & Early Warning Suppression ---
(setq custom-file "~/.emacs.custom.el")
(setq warning-minimum-level :error) ; Suppress non-fatal startup warnings

;; --- Package Management ---
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; --- UI & Basic Settings ---
(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(global-display-line-numbers-mode 1)
(global-hl-line-mode 1)
(column-number-mode 1)
(delete-selection-mode 1)
(electric-pair-mode 1)
(save-place-mode 1)
(defalias 'yes-or-no-p 'y-or-n-p)

(setq backup-directory-alist `(("." . ,(concat user-emacs-directory "backups"))))
(setq auto-save-file-name-transforms `((".*" ,(concat user-emacs-directory "auto-save/") t)))
(setq inhibit-startup-message t)

(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; --- History ---
(use-package savehist
  :init
  (savehist-mode 1))

;; --- Keybindings Helper ---
(use-package which-key
  :ensure t
  :init
  (which-key-mode 1)
  :custom
  (which-key-idle-delay 0.5)
  (which-key-side-window-location 'bottom))

;; --- Completion (Vertico Stack & Consult) ---
(use-package vertico
  :ensure t
  :init
  (vertico-mode 1))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode 1))

(use-package consult
  :ensure t
  :bind (("C-x b"   . consult-buffer)
         ("M-g g"   . consult-goto-line)
         ("C-x p s" . consult-ripgrep)))

;; --- Navigation & Utilities ---
(use-package ace-window
  :ensure t
  :bind ("M-o" . ace-window))

(use-package undo-tree
  :ensure t
  :init
  (global-undo-tree-mode)
  :custom
  (undo-tree-history-directory-alist `(("." . ,(concat user-emacs-directory "undo")))))

;; --- In-buffer Completion (Corfu) ---
(use-package corfu
  :ensure t
  :custom
  (corfu-cycle t)
  (corfu-auto t)
  (corfu-auto-delay 0.1)
  (corfu-auto-prefix 2)
  :bind (:map corfu-map
              ("TAB" . corfu-insert)
              ("<tab>" . corfu-insert))
  :init
  (global-corfu-mode))

(use-package corfu-popupinfo
  :after corfu
  :hook (corfu-mode . corfu-popupinfo-mode)
  :custom
  (corfu-popupinfo-delay 0.2))

;; --- Code Intelligence (Eglot & Snippets) ---
(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :ensure t
  :after yasnippet)

(use-package eglot
  :hook ((python-mode
          python-ts-mode
          c-mode
          c++-mode
          js-mode
          typescript-ts-mode
          rust-mode) . eglot-ensure)
  :config
  (setq read-process-output-max (* 1024 1024)))

;; --- Rust Support & Tree-sitter Automatic Repair ---
(use-package rust-mode
  :ensure t
  :init
  (setq treesit-language-source-alist
        '((rust "https://github.com/tree-sitter/tree-sitter-rust")))

  ;; Check if tree-sitter rust grammar works. If not, automatically compile it.
  (unless (treesit-language-available-p 'rust)
    (ignore-errors
      (treesit-install-language-grammar 'rust)))

  (setq rust-mode-treesitter-derive t))

;; --- Git Integration (Magit) ---
(use-package magit
  :ensure t
  :bind ("C-x g" . magit-status))

;; --- Project.el Enhancements ---
(defun my-project-try-local (dir)
  (let ((root (locate-dominating-file dir ".project")))
    (when root
      (cons 'local root))))

(cl-defmethod project-root ((project (head local)))
  (cdr project))

(add-hook 'project-find-functions #'my-project-try-local)

;; --- Speed Navigation & Multi-Editing ---
(use-package avy
  :ensure t
  :bind (("M-j"   . avy-goto-char-timer)
         ("M-g w" . avy-goto-word-1)))

(use-package multiple-cursors
  :ensure t
  :bind (("C->"     . mc/mark-next-like-this)
         ("C-<"     . mc/mark-previous-like-this)
         ("C-c C-<" . mc/mark-all-like-this)))

(use-package expreg
  :ensure t
  :bind ("C-=" . expreg-expand))

;; --- Load Saved Custom Settings at Bottom ---
(when (file-exists-p custom-file)
  (load-file custom-file))
