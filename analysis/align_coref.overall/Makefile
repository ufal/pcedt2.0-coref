SHELL=/bin/bash

BASE_DIR=../..
include $(BASE_DIR)/makefile.common

pcedt20_coref.stats : $(BASE_DIR)/release/data/done
	$(TREEX) \
		Read::Treex from='!$(dir $<)/*/wsj_*.treex.gz' \
		PCEDT20Coref::AlignCorefStats > \
	$@


all_coref_count : pcedt20_coref.stats
	cat $< | wc -l

en.pcedt20_coref.stats : pcedt20_coref.stats
	cat $< | grep "^English" > $@
cs.pcedt20_coref.stats : pcedt20_coref.stats
	cat $< | grep -v "^English" > $@


%_coref_count : %.pcedt20_coref.stats
	cat $< | wc -l
%_coref_types : %.pcedt20_coref.stats
	cat $< | cut -f2 | distr
