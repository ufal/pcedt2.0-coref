%.html : release_html/%.html release_html/%.content.html release_html/%.title.html
	cat $(word 1,$^) | ./fill_texts_to_patterns.pl $(word 2,$^) $(word 3,$^) > $@

release_html/%.content.html : markdown/%.html
	cat $< | pandoc -f markdown -t html | sed '1s/^/CONTENT\n/' > $@
