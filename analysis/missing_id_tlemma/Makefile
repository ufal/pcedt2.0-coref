SHELL=/bin/bash

LRC=0
ifeq ($(LRC), 1)
LRC_FLAG=-p --jobs=50 --workdir='../tmp/treex_runs/{NNN}-run.{XXXX}'
endif

#tmp/pcedt_treex_unaligned/done :
#	$(MAKE) -C .. $@

########### FIND OUT IF THERE ARE DIFFERENT IDS IN THE OLD AND THE NEW PCEDT ##################

#------- all ids --------------#
#old_new.en.ids.diff :
#	zcat /net/data/pcedt2.0/data/*/*.treex.gz | grep -P "id=.EnglishT" | grep -v "reffile" | sed 's/^.*"\(.*\)".*$$/\1/' | sort > old.en.ids.txt
#	zcat tmp/pcedt_structured/*/wsj_*.en.t.gz | grep -P "id=.EnglishT" | grep -v "reffile" | sed 's/^.*"\(.*\)".*$$/\1/' | sort > new.en.ids.txt
#	diff old.en.ids.txt new.en.ids.txt > $@

#--------- extract all t-ids (and tlemmas) from the old PCEDT ---------------#
old.en_cs.id_tlemma.all.txt : /net/data/pcedt2.0/data
	treex $(LRC_FLAG) \
		Read::Treex from='!$</*/*.treex.gz' \
		Util::Eval tnode='print $$tnode->id."\t".$$tnode->t_lemma."\n";' > old.en_cs.id_tlemma.all.unsorted.txt
	cat old.en_cs.id_tlemma.all.unsorted.txt | sort > $@

#--------- extract coref t-ids (and tlemmas) from the new PCEDT -------------#
new.en_cs.id_tlemma.coref.txt : ../tmp/pcedt_treex_unaligned/done
	treex $(LRC_FLAG) \
		Read::Treex from='!$(dir $<)/*/wsj_*.treex.gz' \
		Util::Eval doc='use Treex::Tool::Coreference::Utils; my @bundles = $$doc->get_bundles; my @en_ttrees = map {($$_->get_tree("en","t",""), $$_->get_tree("cs","t",""))} @bundles; my @en_chains = Treex::Tool::Coreference::Utils::get_coreference_entities(\@en_ttrees, {ordered => "topological"}); foreach my $$chain (@en_chains) { foreach my $$tnode (@$$chain) { print $$tnode->id."\t".$$tnode->t_lemma."\n"; } print "\n"; }' \
		> new.en_cs.id_tlemma.coref_chains.txt
	cat new.en_cs.id_tlemma.coref_chains.txt | grep -v -P "^\s*$$" | sort > $@

#---------- get coref id-tlemma pairs from the new PCEDT not present in the old PCEDT -------------#
old_new.en_cs.id_tlemma.coref.diff : new.en_cs.id_tlemma.coref.txt old.en_cs.id_tlemma.all.txt
	diff $^ | grep "^<" > $@

#---------- build a list of addresses to coref id-tlemma pairs missing in the old PCEDT ------------#
missing_id_tlemma.sample.list : old_new.en_cs.id_tlemma.coref.diff
	cat $< | cut -f 1 | cut -c1,2 --complement | \
		sed 's/^\(.*\(wsj_\(..\)..\)-s\([0-9]\+\).*\)$$/..\/tmp\/pcedt_treex_unaligned\/\3\/\2.treex.gz##\4.\1/' | \
		perl -ne '$$_ =~ s|^(T-wsj(..)(..).*s([0-9]+).*)$$|../tmp/pcedt_treex_unaligned/$$2/wsj_$$2$$3.treex.gz##XXX.$$1|; my $$s = $$4 + 1; $$_ =~ s/XXX/$$s/; print $$_;' | \
		shuffle -r 1986 | head -n 20  > $@

#---------- build a list of old PCEDT bundles to the new missing IDS ------------------#
old_trees.missing_id_tlemma.sample.list : missing_ids.sample.list
	cat $< | sed 's/##\(.*\)\..*$$/##\1/' | sed 's|\.\./tmp/pcedt_treex_unaligned|/net/data/pcedt2.0/data|' > $@
