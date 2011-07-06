;;; pong.el v0.1 --- Emacs implementation of pong

;; Copyright (C) 1999 by Free Software Foundation, Inc.

;; Author: Benjamin Drieu
;; Keywords: games

;; This file is NOT part of GNU Emacs.

;; GNU Emacs and this file are free software; you can redistribute
;; them and/or modify them under the terms of the GNU General Public
;; License as published by the Free Software Foundation; either
;; version 2, or (at your option) any later version.

;; GNU Emacs and this file are distributed in the hope that they will
;; be useful, but WITHOUT ANY WARRANTY; without even the implied
;; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
;; See the GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; This is an implementation of the classical game pong.

;;; Code:

(require 'cl)
(require 'gamegrid)

(defvar pong-buffer-name "*Pong*")

(defvar pong-width 50)
(defvar pong-height 30)
(defvar pong-raquette-width 3)
(defvar pong-raoul-raquette (/ (- pong-height pong-raquette-width) 2))
(defvar pong-albert-raquette 10)
(defvar pong-xx -1)
(defvar pong-yy 1)
(defvar pong-x (/ pong-width 2))
(defvar pong-y (/ pong-height 2))

(defvar pong-mode-map
  (make-sparse-keymap 'pong-mode-map))

(defvar pong-null-map
  (make-sparse-keymap 'pong-null-map))

(define-key pong-mode-map [left]        'pong-move-left)
(define-key pong-mode-map [right]       'pong-move-right)
(define-key pong-mode-map [up]          'pong-move-up)
(define-key pong-mode-map [down]        'pong-move-down)
(define-key pong-mode-map "q"         'pong-quit)
(define-key pong-mode-map "p"         'pong-pause)

(defvar pong-blank-options
  '(((glyph colorize)
     (t ?\040))
    ((color-x color-x)
     (mono-x grid-x)
     (color-tty color-tty))
    (((glyph color-x) [0 0 0])
     (color-tty "black"))))

(defvar pong-brick-options
  '(((glyph colorize)
     (emacs-tty ?O)
     (t ?\040))
    ((color-x color-x)
     (mono-x mono-x)
     (color-tty color-tty)
     (mono-tty mono-tty))
    (((glyph color-x) [1 1 0])
     (color-tty "yellow"))))

(defvar pong-dot-options
  '(((glyph colorize)
     (t ?\*))
    ((color-x color-x)
     (mono-x grid-x)
     (color-tty color-tty))
    (((glyph color-x) [1 0 0])
     (color-tty "red"))))

(defvar pong-border-options
  '(((glyph colorize)
     (t ?\+))
    ((color-x color-x)
     (mono-x grid-x))
    (((glyph color-x) [0.5 0.5 0.5])
     (color-tty "white"))))

(defvar pong-space-options
  '(((t ?\040))
    nil
    nil))

(defconst pong-blank    0)
(defconst pong-brick    1)
(defconst pong-dot      2)
(defconst pong-border   3)
(defconst pong-space    4)

(defun pong-display-options ()
  (let ((options (make-vector 256 nil)))
    (loop for c from 0 to 255 do
      (aset options c
            (cond ((= c pong-blank)
                   pong-blank-options)
                  ((= c pong-brick)
                   pong-brick-options)
                  ((= c pong-dot)
                   pong-dot-options)
                  ((= c pong-border)
                   pong-border-options)
                  ((= c pong-space)
                   pong-space-options)
                  (t
                   '(nil nil nil)))))
    options))

(defun pong-init-buffer ()
  (interactive)
  (get-buffer-create pong-buffer-name)
  (switch-to-buffer pong-buffer-name)
  (use-local-map pong-mode-map)

  (setq gamegrid-use-glyphs t)
  (setq gamegrid-use-color t)
  (gamegrid-init (pong-display-options))

  (gamegrid-init-buffer pong-width
                        (+ 2 pong-height)
                        1)

  (let ((buffer-read-only nil))
    (loop for y from 0 to (1- pong-height) do
          (loop for x from 0 to (1- pong-width) do
                (gamegrid-set-cell x y pong-border)))
    (loop for y from 1 to (- pong-height 2) do
          (loop for x from 1 to (- pong-width 2) do
                (gamegrid-set-cell x y pong-blank))))

  (loop for y from pong-raoul-raquette to (1- (+ pong-raoul-raquette pong-raquette-width)) do
        (gamegrid-set-cell 2 y pong-brick))
  (loop for y from pong-albert-raquette to (1- (+ pong-albert-raquette pong-raquette-width)) do
        (gamegrid-set-cell (- pong-width 3) y pong-brick)
))

(defun pong-move-left ()
  ""
  (interactive)
  (if (> pong-raoul-raquette 1)
      (and
       (setq pong-raoul-raquette (1- pong-raoul-raquette))
       (pong-update-raquette pong-raoul-raquette 2 pong-raoul-raquette))))

(defun pong-move-right ()
  ""
  (interactive)
  (if (< (+ pong-raoul-raquette pong-raquette-width) (1- pong-height))
      (and
       (setq pong-raoul-raquette (1+ pong-raoul-raquette))
       (pong-update-raquette pong-raoul-raquette 2 pong-raoul-raquette))))

(defun pong-move-up ()
  ""
  (interactive)
  (if (> pong-albert-raquette 1)
      (and
       (setq pong-albert-raquette (1- pong-albert-raquette))
       (pong-update-raquette pong-albert-raquette (- pong-width 3) pong-albert-raquette))))

(defun pong-move-down ()
  ""
  (interactive)
  (if (< (+ pong-albert-raquette pong-raquette-width) (1- pong-height))
      (and
       (setq pong-albert-raquette (1+ pong-albert-raquette))
       (pong-update-raquette pong-albert-raquette (- pong-width 3) pong-albert-raquette))))

(defun pong-update-raquette (pong-raquette x y)
  (gamegrid-set-cell x y pong-brick)
  (gamegrid-set-cell x (1- (+ y pong-raquette-width)) pong-brick)
  (if (> y 1)
      (gamegrid-set-cell x (1- y) pong-blank))
  (if (< (+ pong-raquette pong-raquette-width) (1- pong-height))
      (gamegrid-set-cell x (+ y pong-raquette-width) pong-blank)))

(defun pong ()
  ""
  (interactive)
  (setq pong-raoul-score 0)
  (setq pong-albert-score 0)
  (pong-init-game))

(defun pong-init-game ()
  (cancel-function-timers 'pong-update-game)
  (setq pong-raquette-width 3)
  (setq pong-raoul-raquette (/ (- pong-height pong-raquette-width) 2))
  (setq pong-albert-raquette pong-raoul-raquette)
  (setq pong-xx -1)
  (setq pong-yy 0)
  (setq pong-x (/ pong-width 2))
  (setq pong-y (/ pong-height 2))
  (pong-init-buffer)
  (gamegrid-start-timer 0.1 'pong-update-game)
  (pong-update-score))

(defun pong-update-game (pong-buffer)
  ""
  (let ((old-x pong-x)
        (old-y pong-y))

    (setq pong-x (+ pong-x pong-xx))
    (setq pong-y (+ pong-y pong-yy))

    (if (and (> old-y 0)
             (< old-y (- pong-height 1)))
        (gamegrid-set-cell old-x old-y pong-blank))

    (if (and (> pong-y 0)
             (< pong-y (- pong-height 1)))
        (gamegrid-set-cell pong-x pong-y pong-dot))

    (cond
     ((or (= pong-x 3) (= pong-x 2))
      (if (and (>= pong-y pong-raoul-raquette)
               (< pong-y (+ pong-raoul-raquette pong-raquette-width)))
          (and
           (setq pong-yy (+ pong-yy
                            (cond
                             ((= pong-y pong-raoul-raquette) -1)
                             ((= pong-y (1+ pong-raoul-raquette)) 0)
                             (t 1))))
           (setq pong-xx (- pong-xx)))))

     ((or (= pong-x (- pong-width 4)) (= pong-x (- pong-width 3)))
      (if (and (>= pong-y pong-albert-raquette)
               (< pong-y (+ pong-albert-raquette pong-raquette-width)))
          (and
           (setq pong-yy (+ pong-yy
                            (cond
                             ((= pong-y pong-albert-raquette) -1)
                             ((= pong-y (1+ pong-albert-raquette)) 0)
                             (t 1))))
           (setq pong-xx (- pong-xx)))))

     ((<= pong-y 1)
      (setq pong-yy (- pong-yy)))

     ((>= pong-y (- pong-height 2))
      (setq pong-yy (- pong-yy)))

     ((< pong-x 1)
      (setq pong-albert-score (1+ pong-albert-score))
      (pong-init-game))

     ((>= pong-x (- pong-width 1))
      (setq pong-raoul-score (1+ pong-raoul-score))
      (pong-init-game)))))

(defun pong-update-score ()
  (let* ((string (format "Score:  %d / %d" pong-raoul-score pong-albert-score))
         (len (length string)))
    (loop for x from 0 to (1- len) do
      (gamegrid-set-cell x
                         pong-height
                         (aref string x)))))

(defun pong-pause ()
  (interactive)
  (define-key pong-mode-map "p" 'pong-resume)
  (cancel-function-timers (quote pong-update-game)))

(defun pong-resume ()
  (interactive)
  (define-key pong-mode-map "p" 'pong-pause)
  (gamegrid-start-timer 0.1 'pong-update-game))

(defun pong-quit ()
  (interactive)
  (cancel-function-timers (quote pong-update-game))
  (kill-buffer pong-buffer-name))

;;; pong.el ends here 
