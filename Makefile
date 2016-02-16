SHELL=/bin/bash

tmp/pcedt_structured/done : orig_data
	bin/structure_pcedt_parts.sh $< $(dir $@)
	touch $@

tmp/pcedt_treex_unaligned/done : tmp/pcedt_structured/done
	mkdir -p $(dir $@)

########### FIND OUT IF THERE ARE DIFFERENT IDS IN THE OLD AND THE NEW PCEDT ##################

old_new.en.ids.diff :
	zcat /net/data/pcedt2.0/data/*/*.treex.gz | grep -P "id=.EnglishT" | grep -v "reffile" | sed 's/^.*"\(.*\)".*$$/\1/' | sort > old.en.ids.txt
	zcat tmp/pcedt_structured/*/wsj_*.en.t.gz | grep -P "id=.EnglishT" | grep -v "reffile" | sed 's/^.*"\(.*\)".*$$/\1/' | sort > new.en.ids.txt
	diff old.en.ids.txt new.en.ids.txt > $@
