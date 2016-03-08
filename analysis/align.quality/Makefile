prepare_all_nodes_annot : all_nodes.wsj_1903.clean.ali_annot all_nodes.wsj_1944.clean.ali_annot all_nodes.wsj_1946.clean.ali_annot

all_nodes.%.clean.ali_annot : /home/mnovak/projects/align_coref/data/gold_aligned.mgiza_on_czeng/%.final.streex
	treex -Sref -Len \
		Read::Treex from='$<' \
		Align::Annot::Print layers='t' align_langs='en,cs' node_types='' \
	> $@
