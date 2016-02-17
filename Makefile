SHELL=/bin/bash

LRC=0
ifeq ($(LRC), 1)
LRC_FLAG=-p --jobs=50 --workdir='tmp/treex_runs/{NNN}-run.{XXXX}'
endif

orig_data/schema : 
	mkdir $@
	cat orig_data/cs/schema/tanot_schema.xml | \
        sed 's/target-node\.rf/target_node.rf/g' | \
    	sed 's/informal-type/type/g' > $@/tanot_schema.xml
	cp orig_data/cs/schema/aanot_schema.xml $@
	cp ${TMT_ROOT}/treex/lib/Treex/Block/Read/PDT_schema/tdata_schema.xml $@
	cp ${TMT_ROOT}/treex/lib/Treex/Block/Read/PDT_schema/adata_schema.xml $@
	cp ${TMT_ROOT}/treex/lib/Treex/Block/Read/PDT_schema/mdata_schema.xml $@
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
	mkdir -p tmp/treex_runs
	treex $(LRC_FLAG) \
		Read::PCEDT from='!$(dir $<)*/wsj_*.en.t.gz' schema_dir=$| skip_finished='{$(dir $<)(..)/wsj_(....).*}{$(dir $@)$$1/wsj_$$2.treex.gz}' \
		Write::Treex substitute='{$(dir $<)(..)/wsj_(....).*}{$(dir $@)$$1/wsj_$$2.treex.gz}'
	touch $@

# there are bugs in the original PDT-like documents, which cause problems in the Treex representation
# they were fixed manually, see BUGS
