SHELL=/bin/bash

TREEX=PERL5LIB=${PWD}/lib:${PERL5LIB} treex
LRC=0
ifeq ($(LRC), 1)
LRC_FLAG=-p --jobs=200 --workdir='tmp/treex_runs/{NNN}-run.{XXXX}' --qsub "-v PERL5LIB=${PWD}/lib"
TREEX=treex $(LRC_FLAG)
endif

##################################################################################################################################
############################## RETRIEVE THE SCHEMA FILES FOR PDT-LIKE PARTS OF THE NEW PCEDT #####################################
##################################################################################################################################
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

##################################################################################################################################
##################### CREATE THE PCEDT-LIKE DIRECTORY STRUCTURE AND CHANGE REFERENCES AND SOME MARKUP ############################
##################################################################################################################################
tmp/pcedt_structured/done : orig_data
	bin/structure_pcedt_parts.sh $< $(dir $@)
	touch $@

##################################################################################################################################
########## TRANSFORM PDT-LIKE LANGUAGE PARTS TO A SINGLE-FILE TREEX REPRESENTATION - LANGUAGES ARE SENTENCE-ALIGNED ##############
##################################################################################################################################
tmp/pcedt_treex_unaligned/done : tmp/pcedt_structured/done | orig_data/schema
	mkdir -p $(dir $@)
	mkdir -p tmp/treex_runs
	treex $(LRC_FLAG) \
		Read::PCEDT from='!$(dir $<)*/wsj_*.en.t.gz' schema_dir=$| skip_finished='{$(dir $<)(..)/wsj_(....).*}{$(dir $@)$$1/wsj_$$2.treex.gz}' \
		Write::Treex substitute='{$(dir $<)(..)/wsj_(....).*}{$(dir $@)$$1/wsj_$$2.treex.gz}'
	touch $@

# there are bugs in the original PDT-like documents, which cause problems in the Treex representation
# they were fixed manually, see BUGS

##################################################################################################################################
################################ EXTRACT THE COREF LINKS FROM THE NEW PCEDT IN TREEX FORMAT ######################################
##################################################################################################################################
tmp/coref_links.list : tmp/pcedt_treex_unaligned/done
	$(TREEX) \
		Read::Treex from='!$(dir $<)*/wsj_*.treex.gz' \
		PCEDT20Coref::CorefLinksPrinter language=en \
		PCEDT20Coref::CorefLinksPrinter language=cs \
	> $@

tmp/old_pcedt_new_coref/done : tmp/coref_links.list | /net/data/pcedt2.0/data
	mkdir -p $(dir $@)
	$(TREEX) \
		Read::Treex from='!$|/*/wsj_*.treex.gz' \
		PCEDT20Coref::CorefLinksLoader links_file=$< \
		Write::Treex substitute='{$|/(..)/(.*)$$}{$(dir $@)/$$1/$$2}'
	touch $@
