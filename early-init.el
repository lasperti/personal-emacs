;;; early-init.el --- the small one -*- lexical-binding: t -*-

;; Author: lasperti

;;; Commentary:

;; Simple early-init.el to maximize speed and UI minimalism.

;;; Code:
(setq package-enable-at-startup nil)

(push '(menu-bar-lines . 0) default-frame-alist)
(push '(tool-bar-lines . 0) default-frame-alist)
(push '(vertical-scroll-bars . nil) default-frame-alist)

(setq frame-inhibit-implied-resize t)
(setq inhibit-x-resources t)

(setq ring-bell-function 'ignore)

(setq inhibit-startup-screen t
      inhibit-startup-echo-area-message user-login-name)

(push '(background-color . "#ffffff") default-frame-alist)
(push '(foreground-color . "#000000") default-frame-alist)

;;; early-init.el ends here
