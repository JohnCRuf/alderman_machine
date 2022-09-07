#!/bin/sh

#SBATCH --output=slurmlogs/%x_%j.out
#SBATCH --error=slurmlogs/%x_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --mem-per-cpu=5g
#SBATCH --mail-type=FAIL
#SBATCH --partition=covert-dingel

$command1
$command2
