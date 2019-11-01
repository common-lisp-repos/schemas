(declaim (sb-ext:muffle-conditions cl:warning))

(setf *random-state* (make-random-state t))

(load "norm-schema-util.lisp")
(load "norm-protoschemas.lisp")
(load "norm-stories.lisp")
(load "norm-unify.lisp")
(load "norm-match.lisp")
(load "real_util.lisp")
(load "norm-time.lisp")
(load "parsed-stories.lisp")

;(setf kite-gen-schema (match-story-to-schema *KITE-STORY* go_somewhere.v t))
;(print-schema (car kite-gen-schema))

(setf story *PARSED-MONKEY-STORY*)
; (setf story *MONKEY-STORY*)
;(setf story *PARSED-STORY-1*)

(format t "story:~%")
(loop for sent in story
	do (format t "	~s~%~%" sent))


(load-story-time-model story)

(defparameter *NUM-SHUFFLES* 40)
(defparameter *GENERALIZE* nil)
(defparameter *RUN-MATCHER* t)

; (defparameter *ALL-SCHEMAS-PLAYGROUND* *PROTOSCHEMAS*)
(defparameter *ALL-SCHEMAS-PLAYGROUND* (list 'do_action_to_enable_action.v 'take_object.v))


(setf matches (make-hash-table :test #'equal))

;(format t "scores:~%")
;(loop for sc in scores do (format t "	~s~%" (- (car sc) (second sc))))
(if *RUN-MATCHER*
;(loop for i from 1 to 10 do 
(loop for protoschema in *ALL-SCHEMAS-PLAYGROUND* do (block match-proto
	;(if (not (equal protoschema 'do_action_to_enable_action.v))
		; then
	;	(return-from match-proto)
	;)

	(setf best-match-res-pair (best-story-schema-match story (eval protoschema) *NUM-SHUFFLES* *GENERALIZE*))
	(setf best-match-res (car best-match-res-pair))
	(setf best-score (car best-match-res-pair))
	(setf best-match (second best-match-res-pair))
	(setf best-bindings (third best-match-res-pair))
	(format t "best match for protoschema ~s (score ~s):~%~%" protoschema best-score)
	; (print-schema best-match)
	; (format t "deduped:~%")
	(setf match (dedupe-sections best-match))
	(print-schema match)
	(format t "~%~%~%")

	(setf (gethash protoschema matches) match)

	; (format t "bindings: ~s~%" (ht-to-str best-bindings))

	;(loop for var being the hash-keys of best-bindings do (block binding-loop
	;	(format 
	;))
))
;)
)

; (ahow)
;(format t "~s~%" (eval-time-prop '(E1.SK BEFORE.PR E3.SK)))
;(format t "~s~%" (eval-time-prop '(E3.SK BEFORE.PR E2.SK)))


(setf enable-match (gethash 'do_action_to_enable_action.v matches))
(setf get-match (gethash 'take_object.v matches))


(format t "~%MERGING do_action_to_enable_action.v AND take_object.v~%")
(format t "(do_action_to_enable_action.v as external header~%~%")
; (print-schema (merge-schemas do_action_to_enable_action.v take_object.v))
(setf merged-schema (dedupe-sections (merge-schemas enable-match get-match)))
(print-schema merged-schema)
(format t "~%generalizing constants to variables:~%")
(setf gen-merge (generalize-schema-constants merged-schema))
(print-schema gen-merge)


;(setf ep-ids (extract-section-vars gen-merge ':Episode-relations))
; (print-ht time-graph)



(format t "~%cleaning up constraint IDs:~%")
(setf cleaned-schema (rename-constraints (sort-steps gen-merge)))
(print-schema cleaned-schema)

(setf cleaner-schema (clean-do-kas cleaned-schema))

(format t "~%even cleaner schema:~%")
(print-schema cleaner-schema)
