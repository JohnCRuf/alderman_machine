wipeclean: #This deletes all output, input, and logs content
	$(WIPECLEAN) $(CURDIR)

run.sbatch: ../../setup_environment/code/run.sbatch | slurmlogs
	ln -s $< $@
../input/Project.toml: ../../setup_environment/output/Project.toml | ../input/Manifest.toml ../input
	ln -s $< $@
../input/Manifest.toml: ../../setup_environment/output/Manifest.toml | ../input
	ln -s $< $@
slurmlogs ../input ../output ../temp ../report:
	mkdir $@

../report/%.csv.log: ../output/%.csv | ../report
	cat <(md5 $<) <(echo -n 'Lines:') <(cat $< | wc -l ) <(head -3 $<) <(echo '...') <(tail -2 $<)  > $@

.PRECIOUS: ../../%
../../%: #Generic recipe to produce outputs from upstream tasks
	$(MAKE) -C $(subst output/,code/,$(dir $@)) ../output/$(notdir $@)
