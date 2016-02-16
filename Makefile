SHELL=/bin/bash

tmp/pcedt_structured/done : orig_data
	mkdir -p $(dir $@)
	for i in `seq 0 24`; do \
		i_str=`printf "%02d\n" $$i`; \
		trg_dir=$(dir $@)/$$i_str; \
		mkdir $$trg_dir; \
		for j in $</en/$$i_str*/*; do \
			src_file=`basename $$j`; \
			src_base=`echo $$src_file | sed 's/\..*$$//'`; \
			trg_file=`echo $$src_file | sed 's/\.\(.\)\.gz$$/.en.\1.gz/'`; \
			trg_base=`echo $$trg_file | sed 's/\..*$$//'`; \
			echo $$j "--->" $$trg_dir/$$trg_file; \
			zcat $$j | sed "s/$$src_base\.\([apt]\)\.gz/$$trg_base.en.\1.gz/g" | gzip -c > $$trg_dir/$$trg_file; \
		done; \
		for j in $</cs/wsj$$i_str*; do \
			src_file=`basename $$j`; \
			src_base=`echo $$src_file | sed 's/\..*$$//'`; \
			trg_file=`echo $$src_file | sed 's/^wsj/wsj_/' | sed 's/cz/cs/'`; \
			trg_base=`echo $$trg_file | sed 's/\..*$$//'`; \
			echo $$j "--->" $$trg_dir/$$trg_file; \
			if [[ "$$trg_file" == *.gz ]]; then \
				zcat $$j | sed "s/$$src_base\.cz\.\([apt]\)\.gz/$$trg_base.cs.\1.gz/g" | gzip -c > $$trg_dir/$$trg_file; \
			else \
				cat $$j | sed "s/$$src_base\.cz\.\([apt]\)\.gz/$$trg_base.cs.\1.gz/g" | gzip -c > $$trg_dir/$$trg_file; \
			fi; \
		done; \
	done
	touch $@

tmp/pcedt_treex_unaligned/done : tmp/pcedt_structured/done
	mkdir -p $(dir $@)

########### FIND OUT IF THERE ARE DIFFERENT IDS IN THE OLD AND THE NEW PCEDT ##################

old_new.en.ids.diff :
	zcat /net/data/pcedt2.0/data/*/*.treex.gz | grep -P "id=.EnglishT" | grep -v "reffile" | sed 's/^.*"\(.*\)".*$$/\1/' | sort > old.en.ids.txt
	zcat tmp/pcedt_structured/*/wsj_*.en.t.gz | grep -P "id=.EnglishT" | grep -v "reffile" | sed 's/^.*"\(.*\)".*$$/\1/' | sort > new.en.ids.txt
	diff old.en.ids.txt new.en.ids.txt > $@
