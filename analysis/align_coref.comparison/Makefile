SHELL=/bin/bash

BASE_DIR=../..
include $(BASE_DIR)/makefile.common

##################################################################################################################################
#################### ADD THE ORIGINAL ALIGNMENT WITH THE GOLD AND SUPERVISED ONE ON ANAPHORIC EXPRESSIONS ####################
##################################################################################################################################
$(BASE_DIR)/tmp/analysis/old_pcedt_sup_ali_added/done : $(BASE_DIR)/tmp/old_pcedt_new_coref/done $(BASE_DIR)/tmp/gold_align_coref_links.list
	mkdir -p $(dir $@)
	$(TREEX) \
		Read::Treex from='!$(dir $(word 1,$^))/*/wsj_*.treex.gz' \
		PCEDT20Coref::AlignLinksLoader align_dir=en_cs align_name=coref_gold links_file=$(word 2,$^) delete_orig_align=0 \
		Align::T::Supervised::Resolver language=en,cs align_trg_lang=cs align_name=coref_supervised delete_orig_align=0 skip_annotated=0 \
			model_path=data/models/align/supervised/en_cs.all_anaph.train.ref.model,data/models/align/supervised/cs_en.all_anaph.train.ref.model \
		Write::Treex substitute='{$(dir $(word 1,$^))/(..)/(.*)$$}{$(dir $@)/$$1/$$2}'
	touch $@

pcedt20_coref.stats : $(BASE_DIR)/tmp/analysis/old_pcedt_sup_ali_added/done
	$(TREEX) \
		Read::Treex from='!$(dir $<)/*/wsj_*.treex.gz' \
		PCEDT20Coref::AlignCorefStats > \
	$@

.SECONDARY : full.en.aligncoref.stats full.cs.aligncoref.stats all.en.aligncoref.stats all.cs.aligncoref.stats full.en.allcoref.stats full.cs.allcoref.stats all.en.allcoref.stats all.cs.allcoref.stats

aligncoref.stats : pcedt20_coref.stats
	cat $< | grep "IS_ALIGN_COREF=1" > $@
allcoref.stats : pcedt20_coref.stats
	cp $< $@

en.% : %
	cat $< | grep "^English" > $@
cs.% : %
	cat $< | grep -v "^English" > $@

all.% : %
	cp $< $@
eval.% : %
	cat $< | grep "wsj_\?194[56789]" > $@
full.% : %
	cat $< | grep "wsj_\?19[01234]" > $@

DATA_SET=eval
#DATA_SET=all
LANGUAGE=en
#LANGUAGE=cs
ALIGN_COREF=1
COREF_TYPES_NAME=aligncoref
ifeq ($(ALIGN_COREF),0)
COREF_TYPES_NAME=allcoref
endif

count : $(DATA_SET).$(LANGUAGE).$(COREF_TYPES_NAME).stats
	cat $< | wc -l

coref_nodes_distr : $(DATA_SET).$(LANGUAGE).$(COREF_TYPES_NAME).stats
	cat $< | ./merge_node_categories.pl | cut -f2 | distr

entity_count : $(DATA_SET).$(LANGUAGE).$(COREF_TYPES_NAME).stats
	cat $< | cut -f1,4 | \
	perl -ne 'my @cols = split /\s+/, $$_; if ($$cols[1] !~ /TNODE_ENTITY=0/) {$$cols[0] =~ s/^.*wsj_?(....).*$$/$$1/;} else {$$cols[0] =~ s/^.*wsj_?//;} print $$cols[0]." ".$$cols[1]."\n";' | \
	sort | uniq -c | wc -l
entity_no_singletons_count : $(DATA_SET).$(LANGUAGE).$(COREF_TYPES_NAME).stats
	cat $< | cut -f1,4 | \
	perl -ne 'my @cols = split /\s+/, $$_; if ($$cols[1] !~ /TNODE_ENTITY=0/) {$$cols[0] =~ s/^.*wsj_?(....).*$$/$$1/;} else {$$cols[0] =~ s/^.*wsj_?//;} print $$cols[0]." ".$$cols[1]."\n";' | \
	sort | uniq -c | grep -v -P "^\s*1\s+" | wc -l

sup_aligned_anaph_count : PATTERN=coref_supervised
unsup_aligned_anaph_count : PATTERN=(int|gdfa|rule)
gold_aligned_anaph_count : PATTERN=coref_gold
sup_aligned_anaph_count unsup_aligned_anaph_count gold_aligned_anaph_count : $(DATA_SET).$(LANGUAGE).aligncoref.stats
	a=`cat $< | grep -P "COREF\S*$(PATTERN)" | wc -l`; \
	b=`cat $< | wc -l`; \
	perl -e 'printf "%.1f\n", $$ARGV[0] / $$ARGV[1] * 100' $$a $$b

%_entity_align_rate : $(DATA_SET).$(LANGUAGE).allcoref.stats
	cat $< | $(BASE_DIR)/bin/entity_alignment_rate.pl $*
