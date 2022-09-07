`##This file defines shell functions that
# 1. Improve Makefiles' readability by compartmentalizing all the "if" statement around SLURM vs local executables.
# 2. Cause Stata to report an error to Make when the Stata log file end at an error.`;

stata_with_flag() {
	stata_pc_and_slurm $@;
	if [ "$1" == "--no-job-name" ]; then
		shift;
	fi ;
	LOGFILE_NAME=$(basename ${1%.*}.log);
	if grep -q '^r([0-9]*);$' ${LOGFILE_NAME}; then 
		echo "STATA ERROR: There are errors in the running of ${1} file";
		echo "Exiting Status: $(grep '^r([0-9]*);$' ${LOGFILE_NAME} | head -1)";
		exit 1;
	fi
} ;

stata_pc_and_slurm() {
	if command -v sbatch > /dev/null ; then
		command1="module load stata/15";
		if [ "$1" == "--no-job-name" ]; then
			shift;
			command2="stata-se -e $@";
			print_info Stata $@;
        	sbatch -W --export=command1="$command1",command2="$command2" run.sbatch;
		else
			command2="stata-se -e $@";
			jobname1=$(echo "${1%.*}_" | sed 's/\.\.\/input\///');
        	jobname2=$(echo ${@:2} | sed -e "s/ /_/g");
			print_info Stata $@;
			sbatch -W --export=command1="$command1",command2="$command2" --job-name="$jobname1$jobname2" run.sbatch;
		fi;
	else
        if [ "$1" == "--no-job-name" ]; then
            shift;
        fi;
        print_info Stata $@;
        stata-se -e $@;
	fi 
} ; 

R_with_flag() {
	R_pc_and_slurm $@;
	if [ "$1" == "--no-job-name" ]; then
		shift;
	fi ;
	LOGFILE_NAME=$(basename ${1%.*}.log);
	if grep -q '^r([0-9]*);$' ${LOGFILE_NAME}; then 
		echo "R ERROR: There are errors in the running of ${1} file";
		echo "Exiting Status: $(grep '^r([0-9]*);$' ${LOGFILE_NAME} | head -1)";
		exit 1;
	fi
} ;

R_pc_and_slurm() {
	if command -v sbatch > /dev/null ; then
		command1="module load R/4.1.0";
		if [ "$1" == "--no-job-name" ]; then
			shift;
			command2="Rscript $@";
			print_info R $@;
        	sbatch -W --export=command1="$command1",command2="$command2" run.sbatch;
		else
			command2="Rscript $@";
			jobname1="${1%.*}_";
        	jobname2=$(echo ${@:2} | sed -e "s/ /_/g");
			print_info R $@;
			sbatch -W --export=command1="$command1",command2="$command2" --job-name="$jobname1$jobname2" run.sbatch;
		fi;
	else
        if [ "$1" == "--no-job-name" ]; then
            shift;
        fi;
        print_info R $@;
        Rscript $@;
	fi 
} ; 

julia_pc_and_slurm() {
	if command -v sbatch > /dev/null ; then 
		command1="module load julia/1.1.0";
		if [ "$1" == "--no-job-name" ]; then
			shift;
			command2="julia $@";
			print_info Julia $@;
			sbatch -W --export=command1="$command1",command2="$command2" run.sbatch;
		else
			command2="julia $@";
			jobname1="${1%.*}_";
			jobname2=$(echo ${@:2} | sed -e "s/ /_/g");
			print_info Julia $@;
			sbatch -W --export=command1="$command1",command2="$command2" --job-name="$jobname1$jobname2" run.sbatch;
		fi;
	else 
        if [ "$1" == "--no-job-name" ]; then
            shift;
        fi;
        print_info Julia $@;
        julia $@;
	fi 
} ;

clean_task() {
	find ${1} -type l -delete;
	PARENT_DIR=${1%/code};
	rm -f ${1}/*.log;
	rm -rf ${PARENT_DIR}/input ${PARENT_DIR}/output ${1}/slurmlogs; 
} ;

print_info() {
	software=$1;
	shift; 
	if [ $# == 1 ]; then
		echo "Running ${1} via ${software}, waiting...";
    else
        echo "Running ${1} via ${software} with args = ${@:2}, waiting...";
	fi
}
