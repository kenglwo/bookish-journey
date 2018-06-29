(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory
              (expand-file-name(concat user-emacs-directory path))))
        (add-to-list 'load-path default-directory)
        (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
          (normal-top-level-add-subdirs-to-load-path))))))


(add-to-load-path "elisp" "conf" "public_repos")

(require 'init-loader)
(setq init-loader-show-log-after-init nil)
(init-loader-load "~/.emacs.d/conf")


(require 'package)
(add-to-list
 'package-archives
 '("marmalade" . "https://marmalade-repo.org/packages/"))
(add-to-list
 'package-archives
 '("melpa" . "https://melpa.org/packages/"))
(package-initialize)


;; setting for Mac
(when (eq system-type 'darwin)
  (require 'ucs-normalize)
  (setq file-name-coding-system 'utf-8-hfs)
  (setq locale-coding-system 'utf-8-hfs))

;; do not show startup message
(setq inhibit-startup-message 1)
;; do not show menu when started in terminal
(if (eq window-system 'x)
	(menu-bar-mode 1) (menu-bar-mode 0))
(menu-bar-mode nil)
;; delete message of scratch
(setq initial-scratch-message "")

;; 1 scroll moves 1 line
(setq mouse-wheel-scroll-amount '(1 ((shift) . 5)))
;; stop exceleration of scroll
(setq mouse-wheel-progressive-speed nil)

(golden-ratio-mode 1)
(add-to-list 'golden-ratio-exclude-buffer-names " *NeoTree*")


;; remove tool and scroll bar 
(when window-system
  (tool-bar-mode 0)
  (scroll-bar-mode 0))

;; C-m (newline-and-indent)
(define-key global-map (kbd "C-m") 'newline-and-indent)

(define-key global-map (kbd "C-c l") 'toggle-truncate-lines)

(define-key global-map (kbd "C-t") 'other-window)
(column-number-mode t)


;;(setq display-time-day-and-date t)
(setq display-time-24hr-format t)
(display-time-mode t)

(setq frame-title-format "%f")

(global-linum-mode t)

(setq-default tab-width 4)
(setq-default indent-tabs-mode t)

(set-face-background 'region "orange")

(set-face-attribute 'default nil
					:family "RictyDiminishedDiscord NF"
					:height 160)

(set-fontset-font
 nil 'japanese-jisx0208
 (font-spec :family "Noto Sans CJK JP"))

(global-hl-line-mode t)

(setq show-paren-delay 0)
(show-paren-mode t)
;;(setq show-paren-style 'expression nil)
;;(set-face-background 'show-paren-match-face nil)
;;(set-face-background 'show-paren-match-face "pink")
(transient-mark-mode 1)

;; (load-theme 'wombat t)
;; (load-theme 'atom-one-dark t)
;; (load-theme 'monokai t)
(load-theme 'madhat2r t)


(require 'undo-tree)					;

;;-------------------------------------------------------------------
(require 'helm-config)
(helm-mode 1)
(define-key helm-map (kbd "C-h") 'delete-backward-char)
(define-key helm-find-files-map (kbd "C-h") 'delete-backward-char)

;; TABとC-zを入れ替える
(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)   ; rebind tab to run persistent action
(define-key helm-map (kbd "C-i") 'helm-execute-persistent-action)       ; make TAB work in terminal
(define-key helm-map (kbd "C-z")  'helm-select-action)            ; list actions using C-z
;;(define-key helm-find-files-map (kbd "TAB") 'helm-execute-persistent-action)
;;(define-key helm-read-file-map (kbd "TAB") 'helm-execute-persistent-action)

;; キーバインド
(global-set-key (kbd "C-c h") 'helm-mini)
(global-set-key (kbd "<f10>") 'helm-mini)
(define-key global-map (kbd "C-x b")   'helm-buffers-list)
;;(define-key global-map (kbd "C-x b") 'helm-for-files)
(define-key global-map (kbd "C-x C-f") 'helm-find-files)
(define-key global-map (kbd "M-x")     'helm-M-x)
(define-key global-map (kbd "M-y")     'helm-show-kill-ring)

(global-set-key (kbd "C-M-o") 'helm-occur)
(define-key isearch-mode-map (kbd "C-o") 'helm-occur-from-isearch) ; isearchからhelm-occurを起動
(define-key helm-map (kbd "C-c C-a") 'all-from-helm-occur) ; helm-occurからall-extに受け渡し
;;------------------------------------------------------------------


(when (require 'auto-complete-config nil t)
  (define-key ac-mode-map (kbd "M-TAB") 'auto-complete)
 (ac-config-default)
 (setq ac-use-menu-map t)
 (setq ac-ignore-case nil))


(when (require 'color-moccur nil t)
 (define-key global-map (kbd "M-o") 'occur-by-moccur)
 (setq moccur-split-word t))

(require 'moccur-edit nil t)

(defadvice moccur-edit-change-file
  (after save-after-moccur-edit-buffer activate)
  (save-buffer))

(require 'wgrep nil t)

(when (require 'undohist nil t)
  (undohist-initialize))

(when (require 'undo-tree nil t)
  (define-key global-map (kbd "C-'") 'undo-tree-redo)
  (global-undo-tree-mode))


(when (require 'point-undo nil t)
  (define-key global-map (kbd "M-[") 'point-undo) ;; previous position
  (define-key global-map (kbd "M-]") 'point-redo)
)


(setq elscreen-prefix-key (kbd "C-z"))
(when (require 'elscreen nil t)
  (elscreen-start))
  ;; C-z C-z means defaul C-z (hide emacs)
  (if window-system
  	  (define-key elscreen-map (kbd "C-z") 'iconify-or-deiconify-frame)
  	(define-key elscreen-map (kbd "C-z") 'suspend-emacs))


(setq howm-directory (concat user-emacs-directory "howm"))
(setq howm-menu-lang 'ja)
(setq howm-file-name-format "%Y/%m/%Y-%m-%d.howm")
(when (require 'howm-mode nil t)
  (define-key global-map (kbd "C-c ,,") 'howm-menu))
(defun howm-save-buffer-and-kill ()
  (interactive)
  (when (and (buffer-file-name)
			 (howm-buffer-p))
	(save-buffer)
	(kill-buffer nil)))

(define-key howm-mode-map (kbd "C-c C-c") 'howm-save-buffer-and-kill)
  
(put 'narrow-to-region 'disabled nil)

;; quickrun was installed
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
	(web-mode quickrun zenburn-theme wgrep undohist undo-tree monokai-theme moccur-edit memory-usage madhat2r-theme labburn-theme howm helm-descbinds helm-c-moccur golden-ratio elscreen auto-complete atom-one-dark-theme))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(when (require 'web-mode nil t)
  (add-to-list 'auto-mode-alist '("//.html//'" . web-mode))
  (add-to-list 'auto-mode-alist '("//.css//'" . web-mode))
  (add-to-list 'auto-mode-alist '("//.js//'" . web-mode))
)

(ido-mode 1)
(ido-everywhere 1
(setq ido-enable-flex-matching t) ;; 中間/あいまい検索一致

(define-key global-map (kbd "C-h") 'delete-backward-char)

(if window-system 
    (progn
      (set-frame-parameter nil 'alpha 85)))
