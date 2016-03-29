.SECONDARY :

publish: ../release/index.html ../release/data.html ../release/documentation.html ../release/licence.html ../release/credits.html ../release/acknowledgment.html

../release/%.html : release_html/%.html release_html/%.content.html release_html/%.title.html
	cat $(word 1,$^) | ./fill_texts_to_patterns.pl $(word 2,$^) $(word 3,$^) > $@

release_html/%.content.html : markdown/%.md
	cat $< | pandoc -f markdown -t html | sed '1s/^/CONTENT\n/' > $@

markdown/documentation.md : ../README.md
	cp $< $@
