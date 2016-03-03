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

all.align_coref.stats : pcedt20_coref.stats
	cat $< | grep "IS_ALIGN_COREF=1" > $@
eval.align_coref.stats : all.align_coref.stats
	cat $< | grep "wsj_\?194[56789]" > $@
full.align_coref.stats : all.align_coref.stats
	cat $< | grep "wsj_\?19[01234]" > $@

en.% : %
	cat $< | grep "^English" > $@
cs.% : %
	cat $< | grep -v "^English" > $@

DATA_SET=eval
#DATA_SET=all
LANGUAGE=en
#LANGUAGE=cs

$(LANGUAGE)_$(DATA_SET)_all_count : $(LANGUAGE).$(DATA_SET).align_coref.stats
	cat $< | wc -l 

$(LANGUAGE)_$(DATA_SET)_sup_aligned_anaph_count : PATTERN=coref_supervised
$(LANGUAGE)_$(DATA_SET)_unsup_aligned_anaph_count : PATTERN=(int|gdfa|rule)
$(LANGUAGE)_$(DATA_SET)_gold_aligned_anaph_count : PATTERN=coref_gold
$(LANGUAGE)_$(DATA_SET)_sup_aligned_anaph_count $(LANGUAGE)_$(DATA_SET)_unsup_aligned_anaph_count $(LANGUAGE)_$(DATA_SET)_gold_aligned_anaph_count : $(LANGUAGE).$(DATA_SET).align_coref.stats
	cat $< | grep -P "COREF\S*$(PATTERN)" | wc -l
