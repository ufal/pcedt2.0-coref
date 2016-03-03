SHELL=/bin/bash

BASE_DIR=../..

pcedt20_coref.stats : $(BASE_DIR)/release/data/done
	treex -p --jobs=100 \
		Read::Treex from='!$(dir $<)/*/wsj_*.treex.gz' \
		PCEDT20Coref::AlignCorefStats > \
	$@
