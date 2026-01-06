#!/bin/bash
 
#SBATCH -J m_data_tool_sprt # job name
#SBATCH -p parallel              # partition: parallel, smp
##SBATCH -C skylake              # CPU type: broadwell (40 Kerne), skylake (64 Kerne)
#SBATCH -A m2_jgu-sprt-sim       # project name
#SBATCH -n 1                     # Total number of tasks
#SBATCH -c 1                     # Total number of cores for the single task
#SBATCH -t 0:05:00               # Run time (hh:mm:ss)
##SBATCH --mail-user=msteinhi@uni-mainz.de
##SBATCH --mail-type=ALL
#SBATCH -o output/sprt_tool/stdout_data_mother.txt
#-------------------------------------------------------------------------------


declare -ar hyper_n_rep=(5000)

declare -ar distribution=("normal")
#declare -ar distribution=("normal" "mixture")

# this defines (indirectly) k_groups
declare -ar sd=("11" "1111" "111")
declare -ar sample_ratio=("11" "1111" "111")


declare -ar hyper_f_simulated=(0 $(seq 0.10 0.05 0.40) )
#declare -ar hyper_f_simulated=($(seq 0.10 0.01 0.25)) # from 0.10 in 0.01 steps up to 0.25 | 16 cases in total

declare -ar hyper_max_n=(1500)
declare -ar hyper_raw_data_folder=("raw_data")
declare -ar hyper_file_type=("rds")
declare -ar hyper_cores_reduction=(0)
declare -ar hyper_seed=(100000)
declare -ar hyper_parallel=("TRUE")
declare -ar hyper_sink=("TRUE")


#-------------------------------------------------------------------------------
njobs=0
account=m2_jgu-sprt-sim


for hyper_distribution in "${distribution[@]}"; do
for i in "${!sd[@]}"; do
   hyper_sd="${sd[$i]}"
   hyper_sample_ratio="${sample_ratio[$i]}"
   
   echo "sd=$hyper_sd, sample_ratio=$hyper_sample_ratio"

    jobname="sprt_tool_data_${hyper_n_rep}.${hyper_distribution}.${hyper_sd}.${hyper_sample_ratio}.${hyper_max_n}"
    slurmout="output/sprt_tool/data_${hyper_n_rep}.${hyper_distribution}.${hyper_sd}.${hyper_sample_ratio}.${hyper_max_n}.%j.out"
    echo $slurmout  
    echo $jobname
       sbatch -A "$account" -J "$jobname" -o "$slurmout" cluster/tool_sprt_sample/data_daughter_jobscript.sh \
            "$hyper_n_rep" \
            "$hyper_distribution" \
            "${hyper_f_simulated[*]}" \
            "$hyper_sd" \
            "$hyper_sample_ratio" \
            "$hyper_max_n" \
            "$hyper_raw_data_folder" \
            "$hyper_file_type" \
            "$hyper_cores_reduction" \
            "$hyper_seed" \
            "$hyper_parallel" \
            "$hyper_sink"
       njobs=$((njobs + 1))
       if [ $njobs -gt 100 ]; then
          exit
       fi
  done
done


