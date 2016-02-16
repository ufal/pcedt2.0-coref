SHELL=/bin/bash

tmp/pcedt_structured/done : orig_data
	mkdir -p $(dir $@)
	for i in `seq 0 24`; do \
		i_str=`printf "%02d\n" $$i`; \
		trg_dir=$(dir $@)/$$i_str; \
		mkdir $$trg_dir; \
		for j in $</en/$$i_str*/*; do \
			src_file=`basename $$j`; \
			trg_file=`echo $$src_file | sed 's/\.\(.\)\.gz$$/.en.\1.gz/'`; \
			cp -v $$j $$trg_dir/$$trg_file; \
		done; \
		for j in $</cs/wsj$$i_str*; do \
			src_file=`basename $$j`; \
			trg_file=`echo $$src_file | sed 's/^wsj/wsj_/' | sed 's/cz/cs/'`; \
			cp -v $$j $$trg_dir/$$trg_file; \
			if [[ "$$trg_file" != *.gz ]]; then \
				gzip $$trg_dir/$$trg_file; \
			fi; \
		done; \
	done
	touch $@
