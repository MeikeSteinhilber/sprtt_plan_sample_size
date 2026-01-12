#!/bin/bash
 
#SBATCH -J m_rerun_failed     # job name
#SBATCH -p parallel              # partition: parallel, smp
#SBATCH -C skylake               # CPU type: broadwell (40 Kerne), skylake (64 Kerne)
#SBATCH -A m2_jgu-sprt-sim       # project name
#SBATCH -n 1                     # Total number of tasks
#SBATCH -c 1                     # Total number of cores for the single task
#SBATCH -t 0:02:00               # Run time (hh:mm:ss)
#SBATCH -o output/stdout_rerun_failed.txt
#-------------------------------------------------------------------------------

EXCLUDE_NODES="x0638,x0378,x0533,x0044,x0355" # these nodes are potentially broken
if [ -n "$EXCLUDE_NODES" ]; then
    EXCLUDE_OPTION="--exclude=$EXCLUDE_NODES"
    echo "Excluding nodes: $EXCLUDE_NODES"
else
    EXCLUDE_OPTION=""
fi

# Constants from original script
declare -r hyper_n_rep_raw_data=10000
declare -ar hyper_f_expected=($(seq 0.10 0.05 0.40))
declare -r hyper_strategy="single"
declare -r hyper_select_raw_data="detailed"
declare -r hyper_distribution="normal"
declare -r hyper_n_raw_data=1500
declare -r account="m2_jgu-sprt-sim"

# Define the 4 specific cases to rerun
# Format: batch|f_simulated|sd|r
cases=(
  "3|0.10|11|11"
  "1|0.20|11|11"
  "2|0.10|111|111"
  "2|0.20|11|11"
)

echo "Rerunning ${#cases[@]} failed jobs..."
echo "========================================"

njobs=0
for case in "${cases[@]}"; do
    IFS='|' read -r hyper_batch hyper_f_simulated hyper_sd_raw_data hyper_r_raw_data <<< "$case"
    
    echo "------------"
    echo "Submitting job:"
    echo "  batch: $hyper_batch"
    echo "  f_simulated: $hyper_f_simulated"
    echo "  sd_raw_data: $hyper_sd_raw_data"
    echo "  r_raw_data: $hyper_r_raw_data"
    
    jobname="d_apply_sprt_batch_${hyper_batch}.${hyper_strategy}.${hyper_f_simulated}.${hyper_distribution}.${hyper_sd_raw_data}.${hyper_r_raw_data}.${hyper_n_raw_data}"
    slurmout="output/sprt_tool/apply_sprt_batch_${hyper_batch}.${hyper_strategy}.${hyper_f_simulated}.${hyper_distribution}.${hyper_sd_raw_data}.${hyper_r_raw_data}.${hyper_n_raw_data}.out"
    
    echo "  jobname: $jobname"
    echo "  output: $slurmout"
    
    sbatch $EXCLUDE_OPTION -A "$account" -J "$jobname" -o "$slurmout" cluster/tool_sprt_sample/apply_sprt_daughter_jobscript.sh \
        "$hyper_f_simulated" \
        "$hyper_batch" \
        "$hyper_strategy" \
        "$hyper_select_raw_data" \
        "${hyper_f_expected[*]}" \
        "$hyper_distribution" \
        "$hyper_sd_raw_data" \
        "$hyper_r_raw_data" \
        "$hyper_n_raw_data" \
        "$hyper_n_rep_raw_data"
    
    njobs=$((njobs + 1))
done

echo "========================================"
echo "Total jobs submitted: $njobs"