SHELL=bash

all: $(addprefix ../output/,task_flow.png task_flow_branchdiff.png)
trim: $(addprefix ../output/,task_flow.png task_flow_branchdiff.png task_flow_branchdiff_trim.png)

../output/graph.txt: graphmaker.sh $(shell find ../../ -name "Makefile") | ../output
	bash graphmaker.sh
../output/task_flow.png: ../output/graph.txt
	dot -Grankdir=LR -Tpng $< -o $@
../output/graph_trim.txt: graphmaker_trim.sh ../output/graph.txt
	bash graphmaker_trim.sh
../output/task_flow_trim.png: ../output/graph_trim.txt
	dot -Grankdir=LR -Tpng $< -o $@
../output/graph_branchdiff.txt: ../output/graph.txt
	cat <(grep -v '}' ../output/graph.txt) <(git diff --name-status master HEAD | grep '^[AM]' | grep -o 'tasks/[A-z0-9_]*' | sed 's/tasks\///' | sort | uniq | sed 's/$$/ [shape=box]/') <(echo }) > $@
../output/task_flow_branchdiff.png: ../output/graph_branchdiff.txt
	dot -Grankdir=LR -Tpng <(grep -v 'setup_environment' $<) -o $@
../output/graph_branchdiff_trim.txt: branchdiff_trim.sh ../output/graph_branchdiff.txt
	bash $<
../output/task_flow_branchdiff_trim.png: ../output/graph_branchdiff_trim.txt
	dot -Grankdir=LR -Tpng $< -o $@

../output/graph_bidirectional_edges.txt: ../output/graph.txt
	grep -v '{\|}' ../output/graph.txt | awk -F'->' '{if ($$2 < $$1) {print $$2 "," $$1} else {print $$1 "," $$2} }' | sort | uniq -d  > $@

include ../../generic.make
