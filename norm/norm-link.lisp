(load "norm-schema-util.lisp")
(load "norm-unify.lisp")

; norm-link.lisp contains functions to link schemas together by their
; pre- and post-conditions.

(defun link-schemas-onedir (schema-post schema-pre story)
(block outer
	(setf schema-pre-uniq nil)
	(setf schema-post-uniq nil)
	(setf bindings nil)
	(let ((uniq-pair (uniquify-shared-vars schema-pre schema-post)))
		(progn
			(setf schema-pre-uniq (car uniq-pair))
			(setf schema-post-uniq (second uniq-pair))
		)
	)

	(setf story-time-props
		(loop for phi in (linearize-story story)
			if (time-prop? phi) collect phi))

	(setf all-ep-rels
		(loop for schema in (list schema-post schema-pre)
			append (mapcar #'second (section-formulas (get-section schema ':Episode-relations)))
		)
	)

	; (format t "time model: ~s~%" (append story-time-props all-ep-rels))
	(handler-case (load-time-model (append story-time-props all-ep-rels))
		(error () (progn (format t "error loading time model~%") (return-from outer nil)))
	)


	; (format t "trying to link ~s and ~s~%" (second schema-post) (second schema-pre))
	(setf schema-post-ep (third (second schema-post)))
	(setf schema-pre-ep (third (second schema-pre)))
	(loop for post-pair in (section-formulas (get-section schema-post ':Postconds))
		do (loop for pre-pair in (section-formulas (get-section schema-pre ':Preconds))
			do (block match-conds
				; (format t "checking post-pair ~s and pre-pair ~s (post-ep ~s and pre-ep ~s))~%" post-pair pre-pair schema-post-ep schema-pre-ep)
				(if
					; NOTE: this "precond-of" only means Allen time rel (p m),
					; and doesn't do any causation testing.
					; (not (eval-time-prop (list schema-post-ep 'after schema-pre-ep)))
					(eval-time-prop (list schema-post-ep 'precond-of schema-pre-ep))
					; then
					(block check-pre-post

						; (allen-how schema-post-ep schema-pre-ep)

						(setf post (second post-pair))
						(setf pre (second pre-pair))
						; (format t "matching pre ~s and post ~s~%" pre post)
						(setf post-bindings (unify post pre nil schema-post nil))
						(setf pre-bindings (unify pre post nil schema-pre nil))
						;(format t "post-bindings are ~s~%" (ht-to-str post-bindings))
						;(format t "pre-bindings are ~s~%" (ht-to-str pre-bindings))

						(if (or (or (not (null post-bindings)) (not (null pre-bindings))) (equal pre post))
							; then
							(progn
							; (format t "matched pre ~s and post ~s~%" pre post)
							(return-from outer (list post-bindings pre-bindings post pre))
							)
						)
					)
				)
			)
		)
	)

	(return-from outer nil)
)
)
