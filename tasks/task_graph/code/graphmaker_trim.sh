#!/bin/bash
#Script to generate graph of tasks based on specified terminal nodes
#This script simply starts at the terminal nodes and takes one step upstream repeatedly until it encounters no upstream pre-requisites.
#It presumes there is an acyclic graph in ../output/graph.txt.

#if [ acyclic -n ../output/graph.txt ]
#then

grep -v '^#' ../output/graph.txt > temp_graph.txt #Remove comments from graph.

ENDPOINTS="->manuscriptcontents$"
#ENDPOINTS="->ACS_commuting_analysis$|->Amazon_counterfactual_visualize$|->Brazil_commuting_analysis$|->eventstudy_nyc_counterfactual_analyze$|->eventstudy_nyc_counterfactual_analyze_NTA$|->ex_post_regret$|->LODES_commuting_analysis$|->LODES_findemploymentspikes$|->LODES_gravity_analysis$|->LODES_gravity_dataprep$|->monte_carlo$|->paper_elements$"

while [ -n "$ENDPOINTS" ]
do
awk /${ENDPOINTS}/{print} temp_graph.txt >> temp.txt
ENDPOINTS=$(awk /${ENDPOINTS}/{print} temp_graph.txt | awk -F'->' '{print "->" $1 "$|"}' | sort | uniq | tr -d '\n' | sed s'/|$//')
done
cat <(echo -e 'digraph G {') <(sort temp.txt | uniq | grep -v 'setup_environment') <(echo '}') > ../output/graph_trim.txt
rm temp.txt temp_graph.txt

#fi
