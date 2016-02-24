SHELL=/bin/bash

########### TNODES FROM THE NEW VERSION OF PCEDT FROM WHICH MORE THAN 1 COREF LINK ORIGIN (IN TREEX FORMAT) #####################
multiple_coref_anaphor.list :
	treex -p --jobs=100 \
		Read::Treex from='!tmp/pcedt_treex_unaligned/*/wsj_*.treex.gz' \
		Util::Eval tnode='my @antes = $$tnode->get_coref_nodes; if (@antes > 1) {print $$tnode->get_address . "\n";}' \
	> $@

########### SAME TNODE ADDRESSES TRANSFORMED TO POINT TO THE ORIGINAL PML LANGUAGE PARTS #####################
multiple_coref_anaphor.en_orig.list : multiple_coref_anaphor.list
	cat $< | grep "English" | sed 's|^.*/wsj_\(...\)|orig_data/en/data/\1/wsj_\1|' | sed 's/treex/t/' > $@
multiple_coref_anaphor.cs_orig.list : multiple_coref_anaphor.list
	cat $< | grep -v "English" | sed 's|^.*/wsj_\(....\)|orig_data/cs/data/wsj\1|' | sed 's/treex\.gz/cz\.t/' > $@
