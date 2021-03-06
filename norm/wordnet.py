WORD_LST = [
    "FIELD.N",
    "WAGON.N",
    "FLOWER.N",
    "SET.N",
]

import sys
from nltk.corpus import wordnet

WORD_LST = sys.argv[1:]

def lemma_to_el(lemma):
    spl = str(lemma)[7:][:-2].split('.')[:3]
    num = int(spl[2])
    # return ("%s_%d.%s" % (spl[0], num, spl[1])).upper()
    return ("%s.%s" % (spl[0], spl[1])).upper()

def el_to_lemma(el):
    spl = el.split('.')
    wspl = spl[0].split('_')

    # sense = int(wspl[-1])
    sense = 1
    word = '_'.join(wspl).lower()
    pos = spl[1].lower()

    return '%s.%s.%02d' % (word, pos, sense)
    

def hypernyms(word_sym):
    syns = wordnet.synset(el_to_lemma(word_sym))
    hypernyms = [syns]
    while True:
        hypernym = hypernyms[-1].hypernyms()
        if hypernym == []:
            break
        hypernyms.append(hypernym[0])

    lemmas = []
    for hyp in hypernyms:
        lemma = hyp.lemmas()[0]
        lemmas.append(lemma_to_el(lemma))

    return lemmas[1:]

def lisp_list(lst):
    return '(' + ' '.join([str(x) for x in lst]) + ')'

def wn_hypernyms(el):
    try:
        return lisp_list([el] + hypernyms(el))
    except:
        return ""

first = True
for x in WORD_LST:
    if first:
        first = False
    else:
        print ''

    print wn_hypernyms(x)
