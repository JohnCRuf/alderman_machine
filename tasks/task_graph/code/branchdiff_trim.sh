#!/bin/bash
#Script to generate graph of tasks based on specified terminal nodes
#This script simply starts at the terminal nodes and takes one step upstream repeatedly until it encounters no upstream pre-requisites.
#It presumes there is an acyclic graph in ../output/graph_branchdiff.txt.

#if [ acyclic -n ../output/graph_branchdiff.txt ]
#then

grep -v '^#' ../output/graph_branchdiff.txt | sed 's/^[[:space:]]*//' | sed 's/ \-> /\->/' > temp_graph.txt #Remove comments from graph.

#ENDPOINTS="->ACS_commuting_analysis$|->Amazon_counterfactual_visualize$|->Brazil_commuting_analysis$|->eventstudy_nyc_counterfactual_analyze$|->paper_elements$"
ENDPOINTS="$(grep '\[shape=box\]' temp_graph.txt | sed 's/ \[shape=box\]/$|/' | sed 's/^/\->/' | tr -d '\n' | sed 's/|$//')"
echo $ENDPOINTS

while [ -n "$ENDPOINTS" ]
do
awk /${ENDPOINTS}/{print} temp_graph.txt >> temp.txt
ENDPOINTS=$(awk /${ENDPOINTS}/{print} temp_graph.txt | awk -F'->' '{print "->" $1 "$|"}' | sort | uniq | tr -d '\n' | sed s'/|$//')
done
cat <(echo -e 'digraph G {') <(sort temp.txt | uniq | grep -v 'setup_environment') <(grep '\[shape=box\]' temp_graph.txt) <(echo '}') > ../output/graph_branchdiff_trim.txt
rm temp.txt temp_graph.txt

#fi
