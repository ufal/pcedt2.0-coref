SHELL=/bin/bash

BASE_DIR=../..
include $(BASE_DIR)/makefile.common

pcedt20_coref.stats : $(BASE_DIR)/release/data/done
	$(TREEX) \
		Read::Treex from='!$(dir $<)/*/wsj_*.treex.gz' \
		PCEDT20Coref::AlignCorefStats > \
	$@

correspondence_table : pcedt20_coref.stats
	cat $< | ../align_coref.comparison/merge_node_categories.pl | ./create_correspondence_table.pl
