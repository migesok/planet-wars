(in-package :planet-wars)

(defun parse-planet (line)
  (let ((tokens (split-sequence:split-sequence #\space line)))
    (assert (string= "P" (elt tokens 0)))
    (make-planet :x (parse-number:parse-number (elt tokens 1))
                 :y (parse-number:parse-number (elt tokens 2))
                 :owner (parse-number:parse-number (elt tokens 3))
                 :n-ships (parse-number:parse-number (elt tokens 4))
                 :growth (parse-number:parse-number (elt tokens 5)))))

(defun read-planet (stream)
  (parse-planet (read-line stream)))

(defun write-planet (planet stream)
  (format stream "P ~F ~F ~D ~D ~D~%" (x planet) (y planet)
          (owner planet) (n-ships planet) (growth planet)))

(defun parse-fleet (line)
  (let ((tokens (split-sequence:split-sequence #\space line)))
    (assert (string= "F" (elt tokens 0)))
    (make-fleet :owner (parse-number:parse-number (elt tokens 1))
                :n-ships (parse-number:parse-number (elt tokens 2))
                :source (parse-number:parse-number (elt tokens 3))
                :destination (parse-number:parse-number (elt tokens 4))
                :n-total-turns (parse-number:parse-number (elt tokens 5))
                :n-remaining-turns (parse-number:parse-number (elt tokens 6)))))

(defun read-fleet (stream)
  (parse-fleet (read-line stream)))

(defun write-fleet (fleet stream)
  (format stream "F ~D ~D ~D ~D ~D ~D~%" (owner fleet) (n-ships fleet)
          (source fleet) (destination fleet) (n-total-turns fleet)
          (n-remaining-turns fleet)))

(defun read-game (stream)
  (let ((planets ())
        (fleets ())
        (next-planet-id 0))
    (loop for line = (read-line stream nil nil)
          while (and line (not (string= "go" line)))
          do
          (when (plusp (length line))
            (cond ((char= #\P (aref line 0))
                   (let ((planet (parse-planet line)))
                     (setf (id planet) next-planet-id)
                     (incf next-planet-id)
                     (push planet planets)))
                  ((char= #\F (aref line 0))
                   (push (parse-fleet line) fleets)))))
    (make-game :planets (coerce (nreverse planets) 'vector)
               :fleets (coerce (nreverse fleets) 'vector))))

(defun write-game (game stream)
  (map nil (lambda (planet)
             (write-planet planet stream))
       (planets game))
  (map nil (lambda (fleet)
             (write-fleet fleet stream))
       (fleets game)))

(defun write-order (order stream)
  (format stream "~D ~D ~D~%" (planet-id (order-source order))
          (planet-id (order-destination order))
          (order-n-ships order)))

(defun write-orders (orders stream)
  (map nil (lambda (order)
             (write-order order stream))
       orders))
