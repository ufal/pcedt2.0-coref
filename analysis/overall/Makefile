link_count :
	wc -l ../../tmp/coref_links.list

covered_node_count :
	cat ../../tmp/coref_links.list | \
		cut -f 2,7 | \
		sed 's/	/\n/' | \
		sort | uniq | wc -l

# the following statistics must be extracted from the treex-run directory created by calling 'make tmp/old_pcedt_new_coref/done LRC=1'
# the sum of the following statistics accounts for a number of coreferential ID-tlemma pairs missing in the old PCEDT
TREEX_RUN_DIR=../../tmp/treex_runs/056-run.DzIu/output

different_tlemma_node_count :
	find $(TREEX_RUN_DIR) -name '*.stderr' | \
		xargs cat | \
		grep "tlemma ( old_tlemma" | \
		sed 's/^.*Node \([^ ]*\) found.*$$/\1/' | \
		sort | uniq | wc -l
missing_imported_node_count :
	find $(TREEX_RUN_DIR) -name '*.stderr' | \
		xargs cat | \
		grep "instead of .* ( old_tlemma" | \
		sed 's/^.*Node \([^ ]*\) found.*$$/\1/' | \
		sort | uniq | wc -l
missing_nonimported_node_count :
	find $(TREEX_RUN_DIR) -name '*.stderr' | \
		xargs cat | \
		grep "WARN" | \
		perl -ne 'my @a = split /\s+/, $$_; my ($$id) = grep {$$_ =~ /wsj/} @a; $$id =~ s/[:.]$$//g; print $$id."\n";' | \
		sort | uniq | wc -l
