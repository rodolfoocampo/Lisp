; Project: Automated Theorem Prover
; unify.lisp
; Description: unification module
;              unify and unify-var is W4701 instructional code
; Author: Mengqi Zong
; Email: mz2326@columbia.edu

(defun unify (x y &optional (theta nil))
  (cond ((eql theta 'fail) 'fail)
	((eql x y) theta)
	((var-p x) (unify-var x y theta))
	((var-p y) (unify-var y x theta))
	((and (compound-p x) (compound-p y))
	 (unify (args x) (args y) (unify (op x) (op y) theta)))
	((and (listp x) (listp y))
	 (unify (cdr x) (cdr y) (unify (car x) (car y) theta)))
	(t 'fail)))

(defun unify-var (var x theta)
  (let ((varbinding (assoc var theta))
	(xbinding (assoc x theta))
	(xsub (sub theta x)))
    (cond
      ; var already has a binding
      (varbinding (unify (cdr varbinding) x theta))
      ; x is a variable
      (xbinding (unify var (cdr xbinding) theta))
      ((occurs-p var xsub)
       'fail)
      (t (cons (cons var xsub) theta)))))

(defun sub (theta x)
  "Substitute whatever can be substituted in x."
  (cond
    ((null x) nil)
    ((compound-p x)
     (let ((xsub (copy-compound x)))
       (setf (args xsub) (sub theta (args xsub)))
       xsub))
    ((listp x)
     (cons
      (sub theta (car x))
      (sub theta (cdr x))))
    ((var-p x)
     (let ((xbinding (assoc x theta)))
       (cond
	 ((null xbinding) x)
	 (t (cdr xbinding)))))
    (t x)))

(defun occurs-p (var xsub)
  (cond
    ((null xsub) nil)
    ((compound-p xsub)
     (occurs-p var (args xsub)))
    ((listp xsub)
     (or
      (occurs-p var (car xsub))
      (occurs-p var (cdr xsub))))
    ;xsub is var or constant
    (t (eq var xsub))
    ))

(defun var-p (x)
  "all variables start with $"
  (cond
    ((compound-p x) nil)
    ((listp x) nil)
    ((eq (char (symbol-name x) 0) #\$) t)
    ; could only be a constant
    (t nil)
    ))

(defun negate (x)
  "negate x"
  (make-compound :op '! :args x))

(defstruct (compound (:conc-name nil)) op args)

(provide 'unify)
