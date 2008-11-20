;;; show-tabs-mode.el --- Simple mode to highlight tabs

;; Copied/modified from show-whitespace-mode.el by:
;; Nick Hurley <hurley@todesschaf.org>

;; show-whitespace-mode:
;; Copyright (C) 2002 by Aurélien Tisné
;; Author: Aurélien Tisné <address@bogus.example.com>
;; Keywords: convenience, editing
;; Created: 7 Aug 2002

;; This file is not part of GNU Emacs.

;; COPYRIGHT NOTICE
;;
;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; Introduction:
;;
;; Tabs are not visible by default. This package,
;; when it is activated, highlights tabs. It may be useful to see
;; leading tabs where you shouldn't have them (python code, for example)
;;
;; You can choose between two modes of highlighting:
;;  - color: show tabs with faces
;;  - mark: show tabs with specific characters
;; Use 'cutomize-group RET show-tabs' to see the description.

;; Usage:
;;
;; Go to the appropriate buffer and press:
;;   M-x show-tabs-mode RET

;; The function `turn-on-show-tabs-mode' could be added to any major
;; mode hook to activate show-tabs Mode for all buffers in that
;; mode.  For example, the following line will activate show-tabs
;; Mode in all SGML mode buffers:
;;
;; (add-hook 'sgml-mode-hook 'turn-on-show-tabs-mode)

;; Support:
;;
;;  Any comments, suggestions, bug reports or upgrade requests are welcome.

;; Compatibility:
;;
;;  This version of show-whitespace has been developed with NTEmacs 21.2.1
;;  under MS Windows XP (nt5.1). It has been tested on linux both in X
;;  and console.
;;  Please, let me know if it works with other OS and versions of Emacs.

;; Thanks:
;;
;; I would like to thank Pieter Pareit for the suggestion of the mark style;
;; and for his precious tips.
 
;; Bug:
;;
;; - Using the mark mode, some special characters (like french accents)
;;   are displayed in decimal notation. (I don't understand why!)

;;; History:
;;
;; 1.0  14 Nov 2002  21.2.1
;;  - First release
;;
;; 2.0  22 Nov 2002  21.2.1
;;  - Add the style concept including the mark style (suggested by Pieter Pareit).
;;  - Add show-whitespace keywords at the end to be compliant with the
;;    outline mode.
;;
;; 2.1  04 Jan 2003  21.2.1
;;  - Show RET in mark style with ¶.
;;  - Show unbreakable spaces (suggested by Benjamin Drieu).

;;; Code:

(defgroup show-tab nil
  "Minor mode to show tabs."
  :prefix "show-tab-"
  :group 'editing
)

;; Variables:

(defcustom show-tab-style 'color
  "*Define the style tabs will be shown.

Supported values are 'color' and 'mark':
  If color, tabs are highilted with faces.
  If mark, tabs are substituated by visible characters."
  :type '(choice (const color) (const mark))
  :group 'show-tab
)

(defvar show-tab-active-style nil
  "Internal use.
Used to ensure to disable the mode in the same style it has been enabled.")

(defcustom show-tab-visible-tab 62      ; >
  "*Used to show a tab.  It is followed by a tab.

Used when `show-tab-style' is mark.
It's not a good idea to choose a character that may appear in the buffer."
  :type 'character
  :group 'show-tab)

(defvar show-tab-initial-font-lock-keywords nil
  "Used to save initial `font-lock-keywords' value to be able to restore\
it when the mode is switched off.")

(defvar show-tab-initial-display-table nil
  "Used to save initial `buffer-display-table' to be able to restore\
it when the mode is switched off.")

;; Faces:

(defface show-tab-spaces
  `((((type tty) (class color))
     (:background "LemonChiffon1"))
    (((type tty) (class mono))
     (:inverse-video t))
    (((class color))
     (:background "LemonChiffon1"))
    (t (:background "LemonChiffon1")))
  "Face for highlighting spaces."
  :group 'show-tab)

(defface show-tab-unbr-spaces
  `((((type tty) (class color))
     (:background "LemonChiffon3"))
    (((type tty) (class mono))
     (:inverse-video t))
    (((class color))
     (:background "LemonChiffon3"))
    (t (:background "LemonChiffon3")))
  "Face for highlighting unbreakable spaces."
  :group 'show-tab)

(defface show-tab-tabs
  `((((type tty) (class color))
     (:background "LemonChiffon2"))
    (((type tty) (class mono))
     (:inverse-video t))
    (((class color))
     (:background "LemonChiffon2"))
    (t (:background "LemonChiffon2")))
  "Face for highlighting tabs."
  :group 'show-tab)


;; Functions:

;;;###autoload
(define-minor-mode show-tabs-mode
  "Toggle whitespace highlighting in current buffer.

With arg, turn show-tabs mode on if and only if arg is positive.
This is a minor mode that affects only the current buffer."
  ;; the initial value
  nil
  ;; the indicator for the mode line
  " show-tab"
  ;; the keymap
  nil
  ;; the body
  (if show-tabs-mode
      ;; Show whitespaces distinguishing spaces and tabs
      (progn
        (setq show-tab-active-style show-tab-style)
        (if (eq show-tab-style 'mark)
            (progn                      ; mark
              (if buffer-display-table
                  (progn                ; backup the initial table
                    (make-local-variable 'show-tab-initial-display-table)
                    (setq show-tab-initial-display-table
                          (copy-sequence buffer-display-table)))
                (setq buffer-display-table (make-display-table)))
              (aset buffer-display-table ?\t (vector show-tab-visible-tab
                                                     show-tab-visible-tab
                                                     show-tab-visible-tab
                                                     show-tab-visible-tab))
              )

          (progn                        ; color
            (make-local-variable 'show-tab-initial-font-lock-keywords)
            (setq show-tab-initial-font-lock-keywords font-lock-keywords)
            (font-lock-add-keywords nil
                                    '(
                                      ;; show tabs
                                      ("[\t]+" (0 'show-tab-tabs t))
                                      ) t)
            (font-lock-fontify-buffer))))


    ;; revert to initial display
    (if (eq show-tab-active-style 'mark)
        ;; mark
        (setq buffer-display-table show-tab-initial-display-table)

      (progn                            ; color
        (setq font-lock-keywords show-tab-initial-font-lock-keywords)
        (font-lock-fontify-buffer)))))


;;;###autoload
(defun turn-on-show-tabs-mode ()
  "Turn on Show-Whitespace Mode.

This function is designed to be added to hooks, for example:
  (add-hook 'sgml-mode-hook 'turn-on-show-tabs-mode)"
  (show-tabs-mode 1))


;;  Allow this feature to be used.
(provide 'show-tabs-mode)

;;; show-tabs-mode.el ends here
