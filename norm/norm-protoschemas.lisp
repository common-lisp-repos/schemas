(defparameter do_action_for_pleasure.v
	'(epi-schema ((?x do_action_for_pleasure.v ?a) ** ?e)
		(:Roles
			(!r1 (?x agent1.n))
			(!r2 (?a action1.n))
			(!r3 (?p pleasure.n))
		)

		(:Goals
			(?g1 (?x (want.v (ka (experience.v ?p)))))
		)

		(:Steps
			(?e1 (?x (do.v ?a)))
		)

		(:Postconds
			(!p1 (?x (experience.v ?p)))
		)

		(:Episode-relations
			(!w1 (?g1 cause.v ?e1))
			(!w2 (?e1 cause.v ?p1))
		)
	)
)

(defparameter avoid_action_to_avoid_displeasure.v
	'(epi-schema ((?x avoid_action_to_avoid_displeasure.v ?a) ** ?e)
		(:Roles
			(!r1 (?x agent1.n))
			(!r2 (?a action1.n))
			(!r3 (?d displeasure.n))
		)

		(:Goals
			(?g1 (?x (want.v (that (not (?x (experience.v ?d)))))))
		)

		(:Preconds
			(!i1 (if (?x (do.v ?a))
						(?x (experience.v ?d))))
		)

		(:Steps
			(?e1 (not (?x (do.v ?a))))
		)

		(:Episode-relations
			(!w1 (?g1 cause.v ?e1))
		)
	)
)

(defparameter do_action_to_enable_action.v
	'(epi-schema ((?x do_action_to_enable_action.v ?a1 ?a2) ** ?e)
		(:Roles
			(!r1 (?x agent1.n))
			(!r2 (?a1 action1.n))
			(!r3 (?a2 action1.n))
		)

		(:Goals
			(?g1 (?x (want.v (ka (do.v ?a2)))))
		)

		(:Preconds
			(!i1 (not (?x (can.md (ka (do.v ?a2))))))
		)

		(:Steps
			(?e1 (?x ((adv-a (for.p (ka (do.v ?a2)))) do.v) ?a1))
			(?e2 (?x (can.md (ka (do.v ?a2)))))
		)

		(:Episode-relations
			(!w1 (?e1 cause.v ?e2))
			(!w2 (?g1 cause.v ?e1))
		)
	)
)

(defparameter give_object.v
	'(epi-schema ((?x give_object.v ?o (to.p-arg ?y)) ** ?e)
		(:Roles
			(!r1 (?x agent1.n))
			(!r2 (?o object1.n))
			(!r3 (?y agent1.n))
		)

		(:Goals
			(?g1 (?x (want.v (that (?y (have.v ?o))))))
		)

		(:Preconds
			(!i1 (?x have.v ?o))
			(!i2 (not (?y have.v ?o)))
		)

		(:Steps
			(?e1 (?x (give.v ?o (to.p-arg ?y))))
		)

		(:Postconds
			(!p1 (not (?x have.v ?o)))
			(!p2 (?y have.v ?o))
		)
	)
)

(defparameter use_tool.v
	'(epi-schema ((?x use_tool.v ?t (for.p-arg ?a)) ** ?e)
		(:Roles
			(!r1 (?x agent1.n))
			(!r2 (?t implement1.n))
			(!r3 (?a action1.n))
		)

		(:Goals
			(?g1 (?x (want.v (ka (do.v ?a)))))
		)

		(:Preconds
			(!i1 (?x (have.v ?t)))
			(!i2 (?t (suitable_for.p ?a))) ; the "telic" preposition suitable_for.a
											; will appear in prior object knowledge
		)

		(:Steps
			; Lots of ways to paraphrase this...
			(?e1 (?x ((adv-a (with.p ?t)) (do.v ?a))))
			(?e2 (?x ((adv-a (using.p ?t)) (do.v ?a))))
			(?e3 (?x (use.v ?t (for.p-arg ?a))))
		)

		(:Episode-relations
			(!w1 (?e1 same-time.a ?e2))
			(!w2 (?e1 same-time.a ?e3))
		)
	)
)