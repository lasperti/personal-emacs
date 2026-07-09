;;; init.el --- the big one -*- lexical-binding: t -*-

;; Author: lasperti

;;; Commentary:

;; This is my personal Emacs configuration.
;; I do everything inside Emacs. It is my favourite piece of software.
;; Reading this code ends up being reading a part of my brain too.

;;; Code:

;;;; Package Manager (Elpaca)
(defvar elpaca-installer-version 0.12)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca-activate)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-sources-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;;;; Elpaca <-> Use-Package Translation Layer
(elpaca elpaca-use-package
  (elpaca-use-package-mode)
  (setq use-package-always-ensure t))

;;;; Visual Interface
(load-theme 'modus-operandi t)

(set-face-attribute 'default nil :font "Iosevka" :height 130)

;;;; Core Dependencies
(use-package transient)

;;;; org-mode
(use-package org
  :ensure nil 
  :custom
  (org-directory (file-truename "~/org"))
  (org-startup-indented t)
  (org-return-follows-link t)
  (org-catch-invisible-edits 'smart)
  
  (org-todo-keywords
   '((sequence "TODO(t)" "ACTIVE(a)" "WAITING(w)" "|" "RESOLVED(r)" "KILLED(k)")))
  (org-log-done 'time)
  (org-enforce-todo-dependencies t)
  
  :hook
  (org-mode . visual-line-mode))

;;;; org-roam
(use-package org-roam
  :custom
  (org-roam-directory (file-truename "~/org"))
  (org-roam-dailies-directory "journal/")
  (org-roam-completion-everywhere t)

  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)     
         ("C-c n i" . org-roam-node-insert)   
         ("C-c n c" . org-roam-capture)
         ("C-c n j" . org-roam-dailies-capture-today)
         :map org-mode-map
         ("C-M-i" . completion-at-point))

  :config
  (setq org-roam-capture-templates
   '(("1" "Treaty" plain "%?"
      :if-new (file+head "treaty/%<%Y%m%d%H%M%S>-${slug}.org" 
                         "#+TITLE: ${title}\n#+DATE: [%<%Y-%m-%d>]\n#+EPOCH: \n\n* Preamble\n\n* Directives\n")
      :unnarrowed t)
     ("2" "Source" plain "%?"
      :if-new (file+head "source/%<%Y%m%d%H%M%S>-${slug}.org" 
                         "#+TITLE: ${title}\n#+DATE: [%<%Y-%m-%d>]\n\n* Metadata\n\n* Provenance\n\n* Archival\n")
      :unnarrowed t)
     ("3" "Fact" plain "%?"
      :if-new (file+head "fact/%<%Y%m%d%H%M%S>-${slug}.org" 
                         "#+TITLE: ${title}\n#+DATE: [%<%Y-%m-%d>]\n\n* Ontology\n\n* Mechanics\n\n* Provenance\n")
      :unnarrowed t)
     ("4" "Picture" plain "%?"
      :if-new (file+head "picture/%<%Y%m%d%H%M%S>-${slug}.org" 
                         "#+TITLE: ${title}\n#+DATE: [%<%Y-%m-%d>]\n\n* Handout\n\n* Friction\n\n* Exploit\n")
      :unnarrowed t)
     ("5" "Proposition" plain "%?"
      :if-new (file+head "proposition/%<%Y%m%d%H%M%S>-${slug}.org" 
                         "#+TITLE: ${title}\n#+DATE: [%<%Y-%m-%d>]\n#+STATE: ACTIVE\n\n* Initial state\n\n* Active state\n- [ ] \n\n* Target state\n")
      :unnarrowed t)
     ("6" "Space" plain "%?"
      :if-new (file+head "space/%<%Y%m%d%H%M%S>-${slug}.org" 
                         "#+TITLE: ${title}\n#+DATE: [%<%Y-%m-%d>]\n\n* Metadata\n\n* Architecture\n")
      :unnarrowed t)
     ("7" "Name (Entity/Organization)" plain "%?"
      :if-new (file+head "name/%<%Y%m%d%H%M%S>-${slug}.org" 
                         "#+TITLE: ${title}\n#+DATE: [%<%Y-%m-%d>]\n\n* Metadata\n\n* Architecture\n")
      :unnarrowed t)
     ("9" "Thought" plain "%?"
      :if-new (file+head "thought/%<%Y%m%d%H%M%S>-${slug}.org" 
                         "#+TITLE: ${title}\n#+DATE: [%<%Y-%m-%d>]\n\n* Hypothesis\n")
      :unnarrowed t)))

  (defvar my/journal-header 
    "#+TITLE: Journal - %<%Y-%m-%d>\n#+DATE: [%<%Y-%m-%d>]\n\n* Thesis\n\n* Antithesis\n\n* Synthesis\n")

(setq org-roam-dailies-capture-templates
        '(("s" "Synthesis" entry
           "* [%<%H:%M>]\n%?"
           :target (file+head+olp "%<%Y-%m-%d>-journal.org" my/journal-header ("Synthesis")))
          ("a" "Antithesis" entry
           "* [%<%H:%M>]\n%?"
           :target (file+head+olp "%<%Y-%m-%d>-journal.org" my/journal-header ("Antithesis")))
          ("t" "Thesis" plain
           "** [%<%H:%M>]\n%?"
           :target (file+head+olp "%<%Y-%m-%d>-journal.org" my/journal-header ("Thesis")))))
  (org-roam-db-autosync-mode))

;;;; org-roam-ui
(use-package org-roam-ui
  :after org-roam
  :config
  (setq org-roam-ui-sync-theme t
        org-roam-ui-follow t
        org-roam-ui-update-on-save t
        org-roam-ui-open-on-start nil))

;;;; Magit
(use-package magit)

;;; init.el ends here
