SHELL=/bin/bash

TREEX=PERL5LIB=${PWD}/lib:${PERL5LIB} treex
LRC=0
ifeq ($(LRC), 1)
LRC_FLAG=-p --jobs=50 --workdir='tmp/treex_runs/{NNN}-run.{XXXX}' --qsub "-v PERL5LIB=${PWD}/lib"
TREEX:=$(TREEX) $(LRC_FLAG)
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

##################################################################################################################################
################################# LOAD THE COREF LINKS FROM THE NEW PCEDT TO THE OLD PCEDT #######################################
##################################################################################################################################
tmp/old_pcedt_new_coref/done : tmp/coref_links.list | /net/data/pcedt2.0/data
	mkdir -p $(dir $@)
	$(TREEX) \
		Read::Treex from='!$|/*/wsj_*.treex.gz' \
		Coref::RemoveLinks type=all \
		PCEDT20Coref::CorefLinksLoader links_file=$< \
		Write::Treex substitute='{$|/(..)/(.*)$$}{$(dir $@)/$$1/$$2}'
	touch $@

##################################################################################################################################
########################### EXTRACT THE GOLD ALIGNMENT LINKS FOR COREFERENTIAL EXPRESSIONS  ######################################
##################################################################################################################################
ALIGN_COREF_DIR=/home/mnovak/projects/align_coref

tmp/gold_align_coref_links.list : $(ALIGN_COREF_DIR)/data/gold_aligned.mgiza_on_czeng/full.list
	$(TREEX) -Sref \
		Read::Treex from=@$< \
		PCEDT20Coref::AlignLinksPrinter align_langs=en,cs > $@

##################################################################################################################################
#################### REPLACE THE ORIGINAL ALIGNMENT WITH THE GOLD AND SUPERVISED ONE ON ANAPHORIC EXPRESSIONS ####################
##################################################################################################################################
tmp/old_pcedt_sup_ali/done : tmp/old_pcedt_new_coref/done tmp/gold_align_coref_links.list
	mkdir -p $(dir $@)
	$(TREEX) \
		Read::Treex from='!$(dir $(word 1,$^))/*/wsj_*.treex.gz' \
		PCEDT20Coref::AlignLinksLoader align_dir=en_cs align_name=coref_gold links_file=$(word 2,$^) \
		Align::T::Supervised::Resolver language=en,cs align_trg_lang=cs align_name=coref_supervised delete_orig_align=1 skip_annotated=1 \
			model_path=data/models/align/supervised/en_cs.all_anaph.train.ref.model,data/models/align/supervised/cs_en.all_anaph.train.ref.model \
		Write::Treex substitute='{$(dir $(word 1,$^))/(..)/(.*)$$}{$(dir $@)/$$1/$$2}'
	touch $@

##################################################################################################################################
######################################### FINALIZE THE DATA (remove wild attributes) #############################################
##################################################################################################################################
final_data/done : tmp/old_pcedt_sup_ali/done
	mkdir -p $(dir $@)
	$(TREEX) \
		Read::Treex from='!$(dir $<)/*/wsj_*.treex.gz' \
		Util::Eval tnode='$$tnode->set_wild();' \
		Write::Treex substitute='{$(dir $<)/(..)/(.*)$$}{$(dir $@)/$$1/$$2}'
	touch $@
