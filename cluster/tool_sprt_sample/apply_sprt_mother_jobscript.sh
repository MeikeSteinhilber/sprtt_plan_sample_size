#!/bin/bash
 
#SBATCH -J m_apply_tool_sprt     # job name
#SBATCH -p parallel              # partition: parallel, smp
#SBATCH -C skylake               # CPU type: broadwell (40 Kerne), skylake (64 Kerne)
#SBATCH -A m2_jgu-sprt-sim       # project name
#SBATCH -n 1                     # Total number of tasks
#SBATCH -c 1                     # Total number of cores for the single task
#SBATCH -t 0:02:00               # Run time (hh:mm:ss)
##SBATCH --mail-user=msteinhi@uni-mainz.de
##SBATCH --mail-type=ALL
#SBATCH -o output/stdout_apply_tool_mother.txt
#-------------------------------------------------------------------------------

#set -x  # for debugging

EXCLUDE_NODES="x0638,x0378,x0533,x0044,x0355" # these nodes are potentially broken
if [ -n "$EXCLUDE_NODES" ]; then
    EXCLUDE_OPTION="--exclude=$EXCLUDE_NODES"
    echo "Excluding nodes: $EXCLUDE_NODES"
else
    EXCLUDE_OPTION=""
fi

declare -r hyper_n_rep_raw_data=10000
declare -r hyper_n_batches=4        # amount of nodes!!!!!
declare -ar f_simulated=(0 $(seq 0.10 0.05 0.40) )
declare -ar hyper_f_expected=($(seq 0.10 0.05 0.40))
declare -ar sd_raw_data=("1111" "111" "11")
declare -ar r_raw_data=("1111" "111" "11")


# get the batches
source cluster/create_batches.sh
create_batches "$hyper_n_rep_raw_data" "$hyper_n_batches" "cluster/apply_sprt_rows_batches.txt"

declare -ar hyper_strategy=("single")
declare -ar hyper_select_raw_data=("detailed") # detailed or all
declare -ar hyper_distribution=("normal")
declare -r  hyper_n_raw_data=(1500)
# declare -ar hyper_file_type=("rds")
# declare -ar hyper_raw_data_folder=("")
# declare -ar hyper_data_folder=("")
# declare -ar hyper_meta_data=("")
# declare -ar hyper_seed=("")

#-------------------------------------------------------------------------------
njobs=0
account=m2_jgu-sprt-sim
for hyper_f_simulated in "${f_simulated[@]}"; do
for i in "${!sd_raw_data[@]}"; do
   hyper_sd_raw_data="${sd_raw_data[$i]}"
   hyper_r_raw_data="${r_raw_data[$i]}"
   echo "sd=$hyper_sd_raw_data, sample_ratio=$hyper_r_raw_data"
   
for (( hyper_batch=1; hyper_batch<=hyper_n_batches; hyper_batch++ )); do # iterates over the batches


          # ---- check the arguments -----#
          echo "------------"
          echo "$hyper_f_simulated"
          echo "$hyper_batch"
          echo "$hyper_strategy"
          echo "$hyper_select_raw_data"
          echo "$hyper_f_expected"
          echo "$hyper_distribution"
          echo "$hyper_sd_raw_data"
          echo "$hyper_r_raw_data"
          echo "$hyper_n_raw_data"
          echo "$hyper_n_rep_raw_data"
          
          
          jobname="d_apply_sprt_batch_${hyper_batch}.${hyper_strategy}.${hyper_f_simulated}.${hyper_distribution}.${hyper_sd_raw_data}.${hyper_r_raw_data}.${hyper_n_raw_data}"
          slurmout="output/sprt_tool/apply_sprt_batch_${hyper_batch}.${hyper_strategy}.${hyper_f_simulated}.${hyper_distribution}.${hyper_sd_raw_data}.${hyper_r_raw_data}.${hyper_n_raw_data}.out"
          echo $slurmout  
           echo $jobname
           
           #sbatch -A "$account" -J "$jobname" -o "$slurmout" cluster/tool_sprt_sample/apply_sprt_daughter_jobscript.sh \
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
             if [ $njobs -gt 100 ]; then
                exit
             fi
done
done
done