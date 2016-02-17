SHELL=/bin/bash

orig_data/schema : 
	mkdir $@
	cat orig_data/cs/schema/tanot_schema.xml | \
        sed 's/target-node\.rf/target_node.rf/g' | \
    	sed 's/informal-type/type/g' > $@/tanot_schema.xml
	cp ${TMT_ROOT}/treex/lib/Treex/Block/Read/PDT_schema/tdata_schema.xml $@
	cp ${TMT_ROOT}/treex/lib/Treex/Block/Read/PDT_schema/adata_schema.xml $@
	cp ${TMT_ROOT}/treex/lib/Treex/Block/Read/PDT_schema/pdata_eng_schema.xml $@
	cat orig_data/en/schema/tdata_eng_schema.xml | \
        sed 's/target-node\.rf/target_node.rf/g' | \
    	sed 's/informal-type/type/g' > $@/tdata_eng_schema.xml
	cp orig_data/en/schema/adata_eng_schema.xml $@

tmp/pcedt_structured/done : orig_data
	bin/structure_pcedt_parts.sh $< $(dir $@)
	touch $@

tmp/pcedt_treex_unaligned/done : tmp/pcedt_structured/done | orig_data/schema
	mkdir -p $(dir $@)
	treex -p --jobs=200 --workdir='tmp/treex_runs/{NNN}-run.{XXXX}' \
		Read::PCEDT from='!$(dir $<)*/wsj_*.en.t.gz' schema_dir=$| \
		Write::Treex substitute='{$(dir $<)(..)/wsj_(....).*}{$(dir $@)$$1/wsj_$$2.treex.gz}'
	touch $@

########### FIND OUT IF THERE ARE DIFFERENT IDS IN THE OLD AND THE NEW PCEDT ##################

old_new.en.ids.diff :
	zcat /net/data/pcedt2.0/data/*/*.treex.gz | grep -P "id=.EnglishT" | grep -v "reffile" | sed 's/^.*"\(.*\)".*$$/\1/' | sort > old.en.ids.txt
	zcat tmp/pcedt_structured/*/wsj_*.en.t.gz | grep -P "id=.EnglishT" | grep -v "reffile" | sed 's/^.*"\(.*\)".*$$/\1/' | sort > new.en.ids.txt
	diff old.en.ids.txt new.en.ids.txt > $@
