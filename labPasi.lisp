(defun contanumeri (x)
  (cond
   ((null X) 0)
   ((numberp (first x)) (+ 1 (contanumeri (rest x))))
   ((list (first x)) (+ (contanumeri (first x)) (contanumeri (rest x))))
   (t (contanumeri (rest x)))))
      
(defun cancellanumeri (x)
  (cond
   ((null x) nil)
   ((atom (car x)) (if (numberp (car x)) (cancellanumeri (cdr x))
                     (cons (car x) (cancellanumeri (cdr x)))))
   (t (append (cancellanumeri (first x)) (cancellanumeri (rest x))))))
        
(defun sommanumeri (x)
  (cond
   ((null x) 0)
   ((numberp (first x)) (+ (first x) (sommanumeri (rest x))))
   ((list (first x)) (+ (sommanumeri (first x)) (sommanumeri (rest x))))
   (t (sommanumeri (rest x)))))

(defun aggiungi_numero (l n)
  (cond
   ((null l) (cons l n))
   ((> (car l) n) (cons n l))
   (t (cons (car l) (aggiungi_numero (cdr l) n)))))
