;;; analog-clock.el --- Analog clock for GNU/Emacs

;; Copyright (C) 2008, 2009 Yoni Rabkin
;;
;; Author: Yoni Rabkin <yonirabkin@member.fsf.org>
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3 of
;; the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public
;; License along with this program; if not, write to the Free
;; Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
;; MA 02111-1307, USA.

;;; Commentary:
;;
;; This package renders an analog clock inside the Emacs window.
;;
;; To use it, M-x analog-clock.

;;; Installation:
;;
;; Place it in your load path with:
;;
;;    (add-to-list 'load-path "/PATH/TO/analog-clock/")
;;
;; .. add to your .emacs:
;;
;;    (require 'analog-clock)
;;
;; Finally choose if you want a clock with hands, or a
;; seven-segment-display by setting `analog-clock-draw-function' to
;; `analog-clock-draw-analog' or `analog-clock-draw-ssd'. For
;; instance:
;;
;;    (setq analog-clock-draw-function #'analog-clock-draw-analog)

;;; History:
;;
;; In the beginning there was TECO...

;; Bob's (chipschap) changelog for 4/4/2008:
;;
;; 1. Added sweep second hand and adjusted run interval to suit.
;; 2. Adjusted length of hands to allow for the new second hand.
;; 3. Made the clock much rounder by adjusting horizontal parameter.
;; 4. Eliminated excessive picture-mode messages by toggling artist /
;;    picture mode compatibility switch.
;; 5. Fixed spelling error (wow!).
;;
;; UPDATE: 16/08/2009 21:52. Added seven segment display.

;;; Thanks:
;;
;; Thanks to chipschap AKA Bob Newell.

;;; Code:

(require 'artist)

(defgroup analog-clock nil
  "Display an analog clock."
  :group 'games
  :prefix "analog-clock-")

(defvar analog-clock-buffer-name "*Analog Clock*")

(defvar analog-clock-pm-compat "Picture mode compatibility")

(defvar analog-clock-update-timer nil
  "Interval timer object.")
(defvar analog-clock-run-interval 1
  "How often to update the clock.")

(defvar analog-clock-center-x nil)
(defvar analog-clock-center-y nil)
(defvar analog-clock-size nil)

(defvar analog-clock-hours-factor 0.35)
(defvar analog-clock-minutes-factor 0.5)
(defvar analog-clock-seconds-factor 0.8)

(defvar analog-clock-phase (/ (* pi 3) 2))
(defvar analog-clock-horizontal-factor 1.4)

(defvar analog-clock-numerals-factor 0.8)
(defvar analog-clock-numerals-type 'roman)
(defvar analog-clock-numerals-positions
  (list 0
	(/ pi 6)
	(/ pi 3)
	(/ pi 2)
	(/ (* pi 2) 3)
	(/ (* pi 5) 6)
	pi
	(/ (* pi 7) 6)
	(/ (* pi 4) 3)
	(/ (* pi 3) 2)
	(/ (* pi 5) 3)
	(/ (* pi 11) 6)
	))
(defvar analog-clock-numerals-western
  (list "3" "4" "5" "6" "7" "8" "9" "10" "11" "12" "1" "2"))
(defvar analog-clock-numerals-roman
  (list "III" "IV" "V" "VI" "VII" "VIII" "IX" "X" "XI" "XII" "I" "II"))

(defvar analog-clock-display-seconds nil
  "Display the seconds hand when t, otherwise only minites.")

(defvar analog-clock-draw-function nil
  "Function to call for rendering a clock.")

(defvar analog-clock-ssd-origin '(1 . 1)
  "Coordinates to start drawing SSD clock.")

(defvar analog-clock-ssd-scale 1
  "Scaling/zoom factor for SSD clock.")

;;; --------------------------------------------------------
;;; Analog Clock
;;; --------------------------------------------------------

(defun analog-clock-size-from-window ()
  "Set proportions according to the current window."
  (setq analog-clock-center-x (floor (/ (window-width) 2))
	analog-clock-center-y (floor (/ (window-height) 2))
	analog-clock-size (- (floor (/ (min (window-width) (window-height))
				       2))
			     5)))

(defun analog-clock-prepare-buffer ()
  "Set-up the buffer."
  (when (get-buffer analog-clock-buffer-name)
    (kill-buffer analog-clock-buffer-name))
  (get-buffer-create analog-clock-buffer-name)
  (with-current-buffer analog-clock-buffer-name
    (setq analog-clock-run-interval
	  (if analog-clock-display-seconds 1 60))
    (buffer-disable-undo)
    (setq cursor-type nil)
    (and analog-clock-update-timer (cancel-timer analog-clock-update-timer))
    (setq analog-clock-update-timer
	  (run-at-time t analog-clock-run-interval 'analog-clock-update-handler))))

(defun analog-clock-draw-numerals ()
  "Draw the numerals on the clock face."
  (let ((r (round (* analog-clock-size
		     analog-clock-numerals-factor)))
	(j analog-clock-center-x)
	(k analog-clock-center-y)
	(numerals-list (cond ((eq analog-clock-numerals-type
				  'western)
			      analog-clock-numerals-western)
			     ((eq analog-clock-numerals-type
				  'roman)
			      analog-clock-numerals-roman)))
	(numeral-index 0))
    (dolist (t0 analog-clock-numerals-positions)
      (let ((x (round (+ (* (* r analog-clock-horizontal-factor) (cos t0))
			 j)))
	    (y (round (+ (* r (sin t0))
			 k))))
	(artist-text-insert-overwrite x y (nth numeral-index numerals-list))
	(setq numeral-index
	      (1+ numeral-index))))))

(defun analog-clock-draw-seconds-hand ()
  "Draw the seconds hand on the clock face."
  (let* ((seconds (nth 0 (decode-time)))
	 (t0 (+ (* (* pi 2) (/ seconds 60.0))
		analog-clock-phase))
	 (r (round (* analog-clock-size
		      analog-clock-seconds-factor)))
	 (j analog-clock-center-x)
	 (k analog-clock-center-y))
    (artist-draw-line
     analog-clock-center-x
     analog-clock-center-y
     (round (+ (* (* r analog-clock-horizontal-factor) (cos t0))
	       j))
     (round (+ (* r (sin t0))
	       k)))))

(defun analog-clock-draw-minutes-hand ()
  "Draw the minutes hand on the clock face."
  (let* ((minutes (nth 1 (decode-time)))
	 (t0 (+ (* (* pi 2) (/ minutes 60.0))
		analog-clock-phase))
	 (r (round (* analog-clock-size
		      analog-clock-minutes-factor)))
	 (j analog-clock-center-x)
	 (k analog-clock-center-y))
    (artist-draw-line
     analog-clock-center-x
     analog-clock-center-y
     (round (+ (* (* r analog-clock-horizontal-factor) (cos t0))
	       j))
     (round (+ (* r (sin t0))
	       k)))))

(defun analog-clock-draw-hours-hand ()
  "Draw the hours hand on the clock face."
  (let* ((minutes (nth 1 (decode-time)))
	 (hours (nth 2 (decode-time)))
	 (t0 (+ (+ (nth (mod hours 12) analog-clock-numerals-positions)
		   (* (/ pi 6) (/ minutes 60.0)))
		analog-clock-phase))
	 (r (round (* analog-clock-size
		      analog-clock-hours-factor)))
	 (j analog-clock-center-x)
	 (k analog-clock-center-y))
    (artist-draw-line
     analog-clock-center-x
     analog-clock-center-y
     (round (+ (* (* r analog-clock-horizontal-factor) (cos t0))
	       j))
     (round (+ (* r (sin t0))
	       k)))))

(defun analog-clock-draw-body ()
  "Draw the body of the clock."
  (with-current-buffer analog-clock-buffer-name
    (artist-mode)
    (artist-draw-ellipse-general
     analog-clock-center-x
     analog-clock-center-y
     (round (* analog-clock-size analog-clock-horizontal-factor))
     analog-clock-size)))

(defun analog-clock-draw-analog ()
  "Primary function for drawing the analog clock."
  (analog-clock-draw-body)
  (analog-clock-draw-numerals)
  (when analog-clock-display-seconds (analog-clock-draw-seconds-hand))
  (analog-clock-draw-minutes-hand)
  (analog-clock-draw-hours-hand))

;;; --------------------------------------------------------
;;; Seven Segment Display
;;; --------------------------------------------------------

(defun analog-clock-prepare-ssd-buffer ()
  "Prepare and draw in the analog-clock buffer."
  (when (get-buffer analog-clock-buffer-name)
    (kill-buffer analog-clock-buffer-name))
  (get-buffer-create analog-clock-buffer-name)
  (with-current-buffer analog-clock-buffer-name
    (analog-clock-display-hh-mm))
  (switch-to-buffer analog-clock-buffer-name))

(defun analog-clock-defsegment (origin start end scale)
  "Render a segment.

ORIGIN starting coordinates.
START  segment upper left corner.
END    segment lower right corner.
SCALE  scaling/zoom factor."
  (artist-mode)
  (let ((vscale 1)) ; chars are taller than wide
    (let ((x0 (+ (car origin)
		 (round (* scale (car start)))))
	  (y0 (+ (cdr origin)
		 (round (* vscale (* scale (cdr start))))))
	  (x1 (+ (car origin)
		 (round (* scale (car end)))))
	  (y1 (+ (cdr origin)
		 (round (* vscale (* scale (cdr end)))))))
      (artist-draw-rect x0 y0
			x1 y1))))

;; `analog-clock-defdigit' enumerates the seven segments as follows:
;;
;;   a......
;;   .......
;; f.       b.
;; ..       ..
;; ..       ..
;; ..       ..
;; ..       ..
;;   g......
;;   .......
;; e.       c.
;; ..       ..
;; ..       ..
;; ..       ..
;; ..       ..
;;   d......
;;   .......

(defun analog-clock-defdigit (origin dlist scale)
  "Render a digit.

ORIGIN starting coordinates.
DLIST  list of 7 Booleans to control segments.
SCALE  scaling/zoom factor."
  (when (nth 0 dlist)
    (analog-clock-defsegment origin '(2 . 1)  '(10 . 2)  scale)) ; a
  (when (nth 1 dlist)
    (analog-clock-defsegment origin '(10 . 2) '(11 . 8)  scale)) ; b
  (when (nth 2 dlist)
    (analog-clock-defsegment origin '(10 . 9) '(11 . 15) scale)) ; c
  (when (nth 3 dlist)
    (analog-clock-defsegment origin '(2 . 15) '(10 . 16) scale)) ; d
  (when (nth 4 dlist)
    (analog-clock-defsegment origin '(1 . 9)  '(2 . 15)  scale)) ; e
  (when (nth 5 dlist)
    (analog-clock-defsegment origin '(1 . 2)  '(2 . 8)   scale)) ; f
  (when (nth 6 dlist)
    (analog-clock-defsegment origin '(2 . 8)  '(10 . 9)  scale))) ; g

(defun analog-clock-defdigit-n (n origin scale)
  "Render the digit N.

ORIGIN starting coordinates.
SCALE  scaling/zoom factor."
  (let ((dmap
	 '((t   t   t   t   t   t   nil) ; 0
	   (nil t   t   nil nil nil nil) ; 1
	   (t   t   nil t   t   nil t)   ; 2
	   (t   t   t   t   nil nil t)   ; 3
	   (nil t   t   nil nil t   t)   ; 4
	   (t   nil t   t   nil t   t)   ; 5
	   (t   nil t   t   t   t   t)   ; 6
	   (t   t   t   nil nil nil nil) ; 7
	   (t   t   t   t   t   t   t)   ; 8
	   (t   t   t   nil nil t   t)   ; 9
	   )))
    (analog-clock-defdigit origin (nth n dmap) scale)))

(defun analog-clock-defcolon (origin scale)
  "Render a colon.

ORIGIN starting coordinates.
SCALE  scaling/zoom factor."
  (analog-clock-defsegment origin '(1 . 5) '(3 . 7) scale)
  (analog-clock-defsegment origin '(1 . 10) '(3 . 12) scale))

(defun analog-clock-def-hh-mm (h0 h1 m0 m1 origin scale)
  "Render the time in HH:MM format.

H0, H1, M0, M1 the digits of the time.
ORIGIN starting coordinates.
SCALE  scaling/zoom factor."
  (let ((x (car origin))
	(y (cdr origin)))
    (analog-clock-defdigit-n h0 origin scale)
    (analog-clock-defdigit-n h1 `(,(+ (round (* scale 20)) x) . ,y) scale)

    (analog-clock-defcolon      `(,(+ (round (* scale 37)) x) . ,y) scale)

    (analog-clock-defdigit-n m0 `(,(+ (round (* scale 45)) x) . ,y) scale)
    (analog-clock-defdigit-n m1 `(,(+ (round (* scale 65)) x) . ,y) scale)))

(defun analog-clock-display-hh-mm (origin scale)
  "Render the current time in HH:MM format.

ORIGIN starting coordinates.
SCALE  scaling/zoom factor."
  (let ((minutes (nth 1 (decode-time)))
	(hours   (nth 2 (decode-time))))
    (analog-clock-def-hh-mm
     (if (< hours 10) 0 (/ hours 10))
     (mod hours 10)
     (if (< minutes 10) 0 (/ minutes 10))
     (mod minutes 10)
     origin scale)))

(defun analog-clock-draw-ssd ()
  "Primary function for drawing SSD clock."
  (analog-clock-display-hh-mm
   analog-clock-ssd-origin
   analog-clock-ssd-scale))

(defun analog-clock-ssd-upscale ()
  "Increase the display scale."
  (interactive)
  (setq analog-clock-ssd-scale
	(+ analog-clock-ssd-scale 0.1))
  (analog-clock-update-handler))
(defun analog-clock-ssd-downscale ()
  "Decrease the display scale."
  (interactive)
  (setq analog-clock-ssd-scale
	(- analog-clock-ssd-scale 0.1))
  (analog-clock-update-handler))

;;; --------------------------------------------------------
;;; Mode
;;; --------------------------------------------------------

(defun analog-clock-kill-buffer ()
  "Kill the analog clock window."
  (interactive)
  (and analog-clock-update-timer
       (cancel-timer analog-clock-update-timer))
  (kill-this-buffer))

(define-derived-mode analog-clock-mode artist-mode "Analog Clock"
  "Major mode for \\<artist-mode-map>\\[Analog Clock].

\\{analog-clock-mode-map}"
  :group 'analog-clock
  (setq buffer-read-only t)
  (setq truncate-lines nil))

(setq analog-clock-mode-map
      (let ((map (make-sparse-keymap)))
	(define-key map "q" 'analog-clock-kill-buffer)
	(define-key map "u" 'analog-clock-update-handler)
	(define-key map "+" 'analog-clock-ssd-upscale)
	(define-key map "-" 'analog-clock-ssd-downscale)
	map))

(defun analog-clock-draw ()
  "Draw the clock."
  (funcall analog-clock-draw-function))

(defun analog-clock-update-handler ()
  "Update the display."
  (interactive)
  (with-current-buffer analog-clock-buffer-name
    (setq analog-clock-pm-compat artist-picture-compatibility)
    (setq artist-picture-compatibility nil)
    (let ((inhibit-read-only t))
      (let ((artist-line-char-set t)
	    (artist-fill-char-set t)
	    (artist-line-char artist-erase-char)
	    (artist-fill-char artist-erase-char)
	    (x1 2)
	    (y1 2)
	    (x2 (- (window-width) 2))
	    (y2 (- (window-height) 2)))
	(artist-fill-rect (artist-draw-rect x1 y1 x2 y2) x1 y1 x2 y2))
      (analog-clock-draw))
    ;; For some reason, artist mode needs to be turned off manually
    ;; after use.
    (setq artist-picture-compatibility analog-clock-pm-compat)
    (artist-mode -1)))

(defun analog-clock ()
  "Display an analog clock."
  (interactive)
  (analog-clock-prepare-buffer)
  (switch-to-buffer analog-clock-buffer-name)
  (analog-clock-size-from-window)
  (analog-clock-draw)
  (analog-clock-mode))

(when (not analog-clock-draw-function)
  (setq analog-clock-draw-function
	#'analog-clock-draw-analog))

(provide 'analog-clock)

;;; analog-clock.el ends here
