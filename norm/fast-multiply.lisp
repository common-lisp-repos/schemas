;	Copyright AT&T 1991

;;; Fast multipication of binary temporal constraints
;;; encode as integers.

;;; DEPENDS ON:
;;; bitcode  (compile, load, eval)

;;; Note: the following code can be made faster by using Van Kelly's suggestion of
;;; replacing the arrays with simple vectors.

(eval-when (eval compile load)
  (proclaim '(type (simple-array fixnum (13 13)) allen-13x13))
  (proclaim `(type (simple-array fixnum ,(list (ash 1 6) (ash 1 6))) allen-LL))
  (proclaim `(type (simple-array fixnum ,(list (ash 1 6) (ash 1 7))) allen-LH))
  (proclaim `(type (simple-array fixnum ,(list (ash 1 7) (ash 1 6))) allen-HL))
  (proclaim `(type (simple-array fixnum ,(list (ash 1 7) (ash 1 7))) allen-HH))
  )

(defparameter allen-13x13 (make-array '(13 13) :element-type 'fixnum))

(defparameter allen-LL (make-array (list (ash 1 6) (ash 1 6)) :element-type 'fixnum))
(defparameter allen-LH (make-array (list (ash 1 6) (ash 1 7)) :element-type 'fixnum))
(defparameter allen-HL (make-array (list (ash 1 7) (ash 1 6)) :element-type 'fixnum))
(defparameter allen-HH (make-array (list (ash 1 7) (ash 1 7)) :element-type 'fixnum))

(defconstant bits0-6 #B111111)
(defconstant bits0-7 #B1111111)

(defconstant allen-13x13-list
    `(
      (,(&& e) 
       (,(&& e)  . ,(&& e))
       (,(&& d)  . ,(&& d))
       (,(&& c)  . ,(&& c))
       (,(&& s)  . ,(&& s))
       (,(&& si) . ,(&& si))
       (,(&& f)  . ,(&& f))
       (,(&& fi) . ,(&& fi))
       (,(&& b)  . ,(&& b))
       (,(&& a)  . ,(&& a))
       (,(&& m)  . ,(&& m))
       (,(&& mi) . ,(&& mi))
       (,(&& o)  . ,(&& o))
       (,(&& oi) . ,(&& oi))
       )
      (,(&& d) 
       (,(&& e)  . ,(&& d))
       (,(&& d)  . ,(&& d))

       (,(&& di)  . ,(&& any))
       (,(&& s)  . ,(&& d))
       (,(&& si) . ,(&& > oi mi d f))
       (,(&& f)  . ,(&& d))
       (,(&& fi) . ,(&&  < d m o s))
       (,(&& b)  . ,(&& b))
       (,(&& a)  . ,(&& a))
       (,(&& m)  . ,(&& b))
       (,(&& mi) . ,(&& a))
       (,(&& o)  . ,(&& d s b m o))
       (,(&& oi) . ,(&& > oi mi d f))
       )
      (,(&& c) 
       (,(&& e)  . ,(&& c))
       (,(&& d)  . ,(&& e d di s si f fi o oi))
       (,(&& c)  . ,(&& c))
       (,(&& s)  . ,(&& c fi o))
       (,(&& si) . ,(&& c))
       (,(&& f)  . ,(&& c si oi))
       (,(&& fi) . ,(&& c))
       (,(&& b)  . ,(&& c fi b m o))
       (,(&& a)  . ,(&& c si a mi oi))
       (,(&& m)  . ,(&& c fi o))
       (,(&& mi) . ,(&& c oi si))
       (,(&& o)  . ,(&& c fi o))
       (,(&& oi) . ,(&& c si oi))
       )
      (,(&& s) 
       (,(&& e)  . ,(&& s))
       (,(&& d)  . ,(&& d))
       (,(&& c)  . ,(&& c fi b m o))
       (,(&& s)  . ,(&& s))
       (,(&& si) . ,(&& e s si ))
       (,(&& f)  . ,(&& d))
       (,(&& fi) . ,(&& b m o))
       (,(&& b)  . ,(&& b))
       (,(&& a)  . ,(&& a))
       (,(&& m)  . ,(&& b))
       (,(&& mi) . ,(&& mi))
       (,(&& o)  . ,(&& b m o))
       (,(&& oi) . ,(&& d f oi))
       )
      (,(&& si) 
       (,(&& e)  . ,(&& si))
       (,(&& d)  . ,(&& d f oi))
       (,(&& c)  . ,(&& c))
       (,(&& s)  . ,(&& e s si))
       (,(&& si) . ,(&& si))
       (,(&& f)  . ,(&& oi))
       (,(&& fi) . ,(&& c))
       (,(&& b) .  ,(&& < o m di fi))
       (,(&& a)  . ,(&& a))
       (,(&& m)  . ,(&& c fi o))
       (,(&& mi) . ,(&& mi))
       (,(&& o)  . ,(&& c fi o))
       (,(&& oi) . ,(&& oi))
       )
      (,(&& f)  
       (,(&& e)  . ,(&& f))
       (,(&& d)  . ,(&& d))
       (,(&& c)  . ,(&& c si a mi oi))
       (,(&& s)  . ,(&& d))
       (,(&& si) . ,(&& a mi oi))
       (,(&& f)  . ,(&& f))
       (,(&& fi) . ,(&& e f fi))
       (,(&& b)  . ,(&& b))
       (,(&& a)  . ,(&& a))
       (,(&& m)  . ,(&& m))
       (,(&& mi) . ,(&& a))
       (,(&& o)  . ,(&& d s o))
       (,(&& oi) . ,(&& a mi oi))
       )
      (,(&& fi) 
       (,(&& e)  . ,(&& fi))
       (,(&& d)  . ,(&& d s  o))
       (,(&& c)  . ,(&& c))
       (,(&& s)  . ,(&& o))
       (,(&& si) . ,(&& c))
       (,(&& f)  . ,(&& e f fi))
       (,(&& fi) . ,(&& fi))
       (,(&& b)  . ,(&& b))
       (,(&& a)  . ,(&& c si a mi oi))
       (,(&& m)  . ,(&& m))
       (,(&& mi) . ,(&& c si oi))
       (,(&& o)  . ,(&& o))
       (,(&& oi) . ,(&& c si oi))
       )
      (,(&& b)  
       (,(&& e)  . ,(&& b))
       (,(&& d)  . ,(&& d s b m o))
       (,(&& c)  . ,(&& b))
       (,(&& s)  . ,(&& b))
       (,(&& si) . ,(&& b))
       (,(&& f)  . ,(&& d s b m o))
       (,(&& fi) . ,(&& b))
       (,(&& b)  . ,(&& b))
       (,(&& a)  . ,(&& any))
       (,(&& m)  . ,(&& b))
       (,(&& mi) . ,(&& d s b m o))
       (,(&& o)  . ,(&& b))
       (,(&& oi) . ,(&& d s b m o))
       )
      (,(&& a)  
       (,(&& e)  . ,(&& a))
       (,(&& d)  . ,(&& d f a mi oi))
       (,(&& c)  . ,(&& a))
       (,(&& s)  . ,(&& d f a mi oi))
       (,(&& si) . ,(&& a))
       (,(&& f)  . ,(&& a))
       (,(&& fi)  . ,(&& a))
       (,(&& b)  . ,(&& any))
       (,(&& a)  . ,(&& a))
       (,(&& m)  . ,(&& d f a mi oi))
       (,(&& mi) . ,(&& a))
       (,(&& o)  . ,(&& d f a mi oi))
       (,(&& oi) . ,(&& a))
       )
      (,(&& m)  
       (,(&& e)  . ,(&& m))
       (,(&& d)  . ,(&& d s o))
       (,(&& c)  . ,(&& b))
       (,(&& s)  . ,(&& m))
       (,(&& si) . ,(&& m))
       (,(&& f)  . ,(&& d s o))
       (,(&& fi) . ,(&& b))
       (,(&& b)  . ,(&& b))
       (,(&& a)  . ,(&& c si a mi oi))
       (,(&& m)  . ,(&& b))
       (,(&& mi) . ,(&& e f fi))
       (,(&& o)  . ,(&& b))
       (,(&& oi) . ,(&& d s o))
       )
      (,(&& mi) 
       (,(&& e)  . ,(&& mi))
       (,(&& d)  . ,(&& d f oi))
       (,(&& c)  . ,(&& a))
       (,(&& s)  . ,(&& d f oi))
       (,(&& si) . ,(&& a))
       (,(&& f)  . ,(&& mi))
       (,(&& fi) . ,(&& mi))
       (,(&& b)  . ,(&& c fi b m o))
       (,(&& a)  . ,(&& a))
       (,(&& m)  . ,(&& e s si))
       (,(&& mi) . ,(&& a))
       (,(&& o)  . ,(&& d f oi))
       (,(&& oi) . ,(&& a))
       )
      (,(&& o)  
       (,(&& e)  . ,(&& o))
       (,(&& d)  . ,(&& d s o))
       (,(&& c)  . ,(&& c fi b m o))
       (,(&& s)  . ,(&& o))
       (,(&& si) . ,(&& c fi o))
       (,(&& f)  . ,(&& d o s))
       (,(&& fi) . ,(&& b m o))
       (,(&& b)  . ,(&& b))
       (,(&& a)  . ,(&& c si a mi oi))
       (,(&& m)  . ,(&& b))
       (,(&& mi) . ,(&& c si oi))
       (,(&& o)  . ,(&& b m o))
       (,(&& oi) . ,(&& e d c o s si f fi oi))
       )
      (,(&& oi) 
       (,(&& e)  . ,(&& oi))
       (,(&& d)  . ,(&& d f oi))
       (,(&& c)  . ,(&& c si a mi oi))
       (,(&& s)  . ,(&& d f oi))
       (,(&& si) . ,(&& a mi oi))
       (,(&& f)  . ,(&& oi))
       (,(&& fi) . ,(&& c si oi))
       (,(&& b)  . ,(&& c fi b m o))
       (,(&& a)  . ,(&& a))
       (,(&& m)  . ,(&& di fi o))
       (,(&& mi) . ,(&& a))
       (,(&& o)  . ,(&& e d c s si f fi o oi))
       (,(&& oi) . ,(&& a mi oi))
       )
      ))

(defun allen-multiply (x y)
  (declare (optimize (safety 0) (speed 3)))
  (declare (type fixnum x y))
  "Multiply Allen constraints X and Y, which are represented as fixnums,
using 4 tables of size 2**7 x 2**7"
  (let ((xL (logand x bits0-6))
	(yL (logand y bits0-6))
	(xH (ash x -6))
	(yH (ash y -6)))
    (declare (type fixnum xL yL xH yH))
;    (declare (:explain :calls :types))  ;; Prints info about optimization
    (logior (aref allen-LL xL yL)
	    (aref allen-LH xL yH)
	    (aref allen-HL xH yL)
	    (aref allen-HH xH yH))))

(defun initialize-13x13-allen-array ()
  "Initialize allen-13x13"
  (do ((r 0 (1+ r))) ((> r 12))
    (do ((c 0 (1+ c))) ((> c 12))
      (setf (aref allen-13x13 r c) 
	(multiply-primitives (bitdecode (ash 1 r))
			     (bitdecode (ash 1 c))))
      ))
  ;(format t "Initialized allen-13x13~%")
	)


(defun initialize-big-allen-arrays ()
  "Initialize allen-LL, allen-LH, allen-HL, allen-HH"
  ;; Initialize allen-LL
  (do ((r 0 (1+ r))) ((> r bits0-6))
    (do ((c 0 (1+ c))) ((> c bits0-6))
      (setf (aref allen-LL r c) (slow-allen-multiply r c))))
  ; (format t "Initialized allen-LL~%")
  ;; Initialize allen-LH
  (do ((r 0 (1+ r))) ((> r bits0-6))
    (do ((c 0 (1+ c))) ((> c bits0-7))
      (setf (aref allen-LH r c) (slow-allen-multiply r (ash c 6)))))
  ; (format t "Initialized allen-LH~%")
  ;; Initialize allen-HL
  (do ((r 0 (1+ r))) ((> r bits0-7))
    (do ((c 0 (1+ c))) ((> c bits0-6))
      (setf (aref allen-HL r c) (slow-allen-multiply (ash r 6) c))))
  ; (format t "Initialized allen-HL~%")
  ;; Initialize allen-HH
  (do ((r 0 (1+ r))) ((> r bits0-7))
    (do ((c 0 (1+ c))) ((> c bits0-7))
      (setf (aref allen-HH r c) (slow-allen-multiply (ash r 6) (ash c 6)))))
  ; (format t "Initialized allen-HH~%")
  )


(defun initialize-allen-arrays ()
  "Initialize all the arrays used for constraint multiplication"
  (initialize-13x13-allen-array)
  (initialize-big-allen-arrays))

(defun slow-allen-multiply (x y)
  "Multiply Allen constraints X and Y, which are represented as fixnums,
using a 13 x 13 table"
  (declare (optimize (safety 0) (speed 3)))
;  (declare (:explain :calls :types))
  (declare (type fixnum x y))
  (let ((answer 0))
    (declare (type fixnum answer))
    (if (or (= x any) (= y any))
	(return-from slow-allen-multiply any))
    (do ((r 0 (1+ r))) ((> r 12))
      (declare (type fixnum r))
      (if (logbitp r x)
	  (do ((c 0 (1+ c))) ((> c 12))
	    (declare (type fixnum c))
	    (if (logbitp c y)
		(progn 
		  (setq answer (logior answer 
				       (aref allen-13x13 r c)))
		  (if (= answer any)
		      (return-from slow-allen-multiply any)))))))
    answer))

(defun multiply-primitives (sym1 sym2)
  "Multiply primitive Allen constaints SYM1 and SYM2, which are
represented as symbols"
  (cdr (assoc (bitcode sym2)
	      (cdr (assoc (bitcode sym1) 
			  allen-13x13-list)))))


  
