# Coreference extension to Prague Czech-English Dependency Treebank 2.0

Prague Czech-English Dependency Treebank 2.0 (PCEDT) is a parallel treebank of Czech and English comprising 
over 1.2 million running words in almost 50,000 sentences for each part. The treebank contains texts
from the entire Penn Treebank - Wall Street Jurnal section and its Czech translations. On top of it,
it includes three levels of rich linguistic annotation: morphological layer (part-of-speech tags, lemmas),
analytical layer (labeled dependency tree of shallow syntax), and tectogrammatical layer (labeled dependency
tree of deep syntax). The tectogrammatical tree consists only of the content words, however, new nodes
unexpressed in a surface representation may be introduced, e.g., dropped pronouns in Czech.

Tectogrammatical layer is also the place where coreference relations are annotated, as it allows
for annotating zero anaphora. Annotation of anaphoric relations and related phenomena in PCEDT
has been so far developed in two steps:

1. PCEDT 2.0 original release
  1. grammatical coreference
  2. pronominal textual coreference
2. PCEDT 2.0 Coref release
  1. nominal textual coreference
  2. coreference with split antecedents (i.e. bridging anaphora of the set-subset type)
  3. improved alignment of expressions bound in grammatical and pronomina textual coreference

## PCEDT 2.0 original release

The original release of PCEDT 2.0 (Hajič et al., 2012) captures annotation of so-called grammatical and pronominal textual coreference
for both Czech and English. While most of the English textual coreference links were imported from the BBN Pronoun Coreference and Entity Type Corpus, the Czech coreference of the same type was annotated completely from scratch. Both English and Czech grammatical coreference was annotated from scratch, as well.

Grammatical coreference comprises several subtypes of relations, which mainly differ in the nature of referring
expressions (e.g. relative pronoun, reflexive pronoun). The common property is that they appear as a consequence
of language-dependent grammatical rules.

On the other hand, the arguments of textual coreference are not realized by grammatical means alone, but also via
context. The pronominal textual coreference includes those coreference links that use a personal, possessive, or
demonstrative pronoun as referring expression. It also includes pronouns dropped from the surface, especially
in Czech (zero anaphora).

## PCEDT 2.0 Coref release

The release of PCEDT 2.0 Coref (Nedoluzhko et al., 2016) builds upon the original release of PCEDT 2.0 and extends
it with further types of coreference relations and related phenomena.

The set of coreferential relations with a specific referent is completed here by introducing annotation of nominal
textual coreference, i.e. coreference links with a nominal group as referring expression.

Bridging relations are not included in PCEDT 2.0, except for a special case of split antecedents. This is the case
when the expression is coreferential with the union of antecedents A+B, both present in tectogrammatical structure
of the corresponding text.

The abovementioned new annotation has been in fact conducted hand in hand with another annotation work.
All the new annotation, including the annotation work in progress, is planned to be soon 
released in PCEDT 3.0. As in PCEDT 2.0 Coref we aimed to release only the coreferential extensions,
we decided to extract all the coreferential relations from the newly annotated data and import it back
to the original version of PCEDT 2.0. Technically, since every node is specified by its ID, it should be easy
to import the links by remembering the IDs of the two nodes forming a link. However, due to changes in the other
annotation in PCEDT, some of the nodes in the new version of PCEDT might not exist in the old version.
Therefore, we had to adopt a heuristics based on the node's ancestors in the tree and its semantic role
to find a finest replacement for the missing node. Still, the structural changes might be too extensive.
In that case, our heuristics fails and the coreferential link remains unimported. The following table
reveals that it concerns only 0.07% of cases. In PCEDT 3.0, all the unimported links will be present.


|                    | Count   |
|:-------------------|--------:|
| Links to be import | 268,707 |
| Covered nodes      | 372,038 |
| Missing ID         |     623 |
| Heuristics failed  |     284 |

TODO: write about the difference in tlemma
