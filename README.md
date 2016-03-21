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

The original release of PCEDT 2.0 (Hajič et al., 2011; Hajič et al., 2012) captures annotation of so-called grammatical and pronominal textual coreference
for both Czech and English. While most of the English textual coreference links were imported from the BBN Pronoun Coreference and Entity Type Corpus, the Czech coreference of the same type was annotated completely from scratch. Both English and Czech grammatical coreference was annotated from scratch, as well.

Grammatical coreference comprises several subtypes of relations, which mainly differ in the nature of referring
expressions (e.g. relative pronoun, reflexive pronoun). The common property is that they appear as a consequence
of language-dependent grammatical rules.

On the other hand, the arguments of textual coreference are not realized by grammatical means alone, but also via
context. The pronominal textual coreference includes those coreference links that use a personal, possessive, or
demonstrative pronoun as referring expression. It also includes pronouns dropped from the surface, especially
in Czech (zero anaphora).

## PCEDT 2.0 Coref release

The release of PCEDT 2.0 Coref (Nedoluzhko et al., 2016a, Nedoluzhko et al., 2016b) builds upon the original release of PCEDT 2.0 and extends
it with further types of coreference relations and related phenomena.

### Coreference

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

Coreference annotation is represented by the following attributes of tectogrammatical nodes:
* `coref_gram.rf`: grammatical coreference, contains an ID of the antecedent
* `coref_text.rf`: textual coreference, contains an ID of the antecedent
* `coref_special` : reference to a text segment (value `segm`) or exophora (value `exoph`)
* `bridging`: bridging relations (here represented only by reference to split antecedents)
  * `target_node.rf`: ID of the antecedent
  * `type`: the type of bridging; only `SET_SUBSET` representing reference to split antecedent in PCEDT 2.0 Coref

More information on coreference annotation can be found in the [technical report](http://ufal.mff.cuni.cz/techrep/tr57.pdf).

## Alignment of coreferential expressions

Alignment of tectogrammatical nodes in the original release of PCEDT 2.0 was obtained by running
the GIZA++ word aligner on the surface representation of sentences, the produced links were projected
up to the tectogrammatical layer and some heuristics was applied for zeros, i.e. tectogrammatical nodes
unexpressed on the surface (e.g. dropped subject pronouns).
In PCEDT 2.0 Coref, improved annotation of alignment of coreferential expressions is introduced, replacing
the original alignment for the nodes under consideration. The new links come either from manual annotation
or are produced by a supervised aligner trained on this manual annotation.

The coreferential expressions targeted by improved alignment approach include central pronouns
(embracing personal, possessive, and reflexive pronouns), relative pronouns, and anaphoric zeros.
In fact, the set of targeted coreferential nodes was selected using solely the morpho-syntactic attributes,
without the coreference information itself. Each such node is indicated by the `align_coref` attribute.
More details on the classes of targeted coreferential expressions can be found in (Novák and Nedoluzhko, 2015).

The manual annotation has been conducted for coreferential nodes in sections `wsj_1900`-`49` by two annotators.
These alignment links are labeled by the `coref_gold` type. However, for a coreferential node that has no
aligned counterpart in the other language, one could not determine if the absence of alignment  is a result 
of a human decision, or a decision by one of the automatic alignment methods. 
The `align_coref` attribute is annotated for this purpose.
Therefore, if a tectogrammatical node belongs to one of the sections `wsj_1900`-`49` and
it has the `align_coref` attribute defined and true, it is clear that this node was treated by hand.
On the other hand, all the other nodes were aligned using the original alignment, combining GIZA++ and 
the heuristics.
Manual annotation of alignment is elborated in a greater detail in (Novák and Nedoluzhko, 2015).

Supervised aligner has been applied on all the coreferential nodes in PCEDT 2.0 Coref, except for those
belonging to the sections `wsj_1900`-`49`. The links produced by this aligner are of the `coref_supervised`
type. Analogous to the manual annotation, the `align_coref` attribute serves to indicate all the nodes
treated by supervised approach, even those eventually with no counterpart.
The supervised method was trained on the manually annotated data from the sections `wsj_1900`-`49`,
using the features capturing the original GIZA++ alignment and the topology of tectogrammatical trees
from both language sides, grammatical features, and combination of previous.
The supervised alignment approach is described in a greater detail in (Novák and Žabokrtský, 2014) and
(Nedoluzhko et al., 2016).

The annotation of alignment for tectogrammatical coreferential nodes is represented by the following attributes:
* `align_coref`: defined and true for the nodes whose alignment was treated either manually or using a supervised approach
* `alignment`: node alignment
  * `counterpart.rf`: the ID of the aligned counterpart
  * `type`: type of the alignment; in PCEDT 2.0 Coref the `coref_gold` and `coref_supervised` types are introduced for the
        counterparts found by hand and by the supervised method, respectively

# References
* Hajič Jan, Hajičová Eva, Panevová Jarmila, Sgall Petr, Cinková Silvie, Fučíková Eva, Mikulová Marie, Pajas Petr, Popelka Jan, Semecký Jiří, Šindlerová Jana, Štěpánek Jan, Toman Josef, Urešová Zdeňka, Žabokrtský Zdeněk: Prague Czech-English Dependency Treebank 2.0. Data/software, Institute of Formal and Applied Linguistics, Prague, Czech republic, http://ufal.mff.cuni.cz/pcedt2.0/, 2011
* Hajič Jan, Hajičová Eva, Panevová Jarmila, Sgall Petr, Bojar Ondřej, Cinková Silvie, Fučíková Eva, Mikulová Marie, Pajas Petr, Popelka Jan, Semecký Jiří, Šindlerová Jana, Štěpánek Jan, Toman Josef, Urešová Zdeňka, Žabokrtský Zdeněk: Announcing Prague Czech-English Dependency Treebank 2.0. In: Proceedings of the 8th International Conference on Language Resources and Evaluation (LREC 2012), Copyright © European Language Resources Association, İstanbul, Turkey, ISBN 978-2-9517408-7-7, pp. 3153-3160, 2012
* Nedoluzhko Anna, Novák Michal, Cinková Silvie, Mikulová Marie, Mírovský Jiří: Prague Czech-English Dependency Treebank 2.0 Coref. Data/software, Institute of Formal and Applied Linguistics, Prague, Czech republic, http://ufal.mff.cuni.cz/pcedt2.0-coref/, 2016
* Nedoluzhko Anna, Novák Michal, Cinková Silvie, Mikulová Marie, Mírovský Jiří: Coreference in Prague Czech-English Dependency Treebank. In: Proceedings of the 10th International Conference on Language Resources and Evaluation (LREC 2016), Copyright © European Language Resources Association, Portorož, Slovenia, ISBN ???, pp. ???-???, 2016
* Novák Michal, Nedoluzhko Anna: Correspondences between Czech and English Coreferential Expressions. In: Discours: Revue de linguistique, psycholinguistique et informatique., Vol. 16, Copyright © Presses universitaires de Caen, Caen, France, ISSN 1963-1723, pp. 1-41, Sep 2015
* Novák Michal, Žabokrtský Zdeněk: Cross-lingual Coreference Resolution of Pronouns. In: Proceedings of COLING 2014, the 25th International Conference on Computational Linguistics: Technical Papers, Copyright © Dublin City University and Association for Computational Linguistics, Dublin, Ireland, ISBN 978-1-941643-26-6, pp. 14-24, 2014
