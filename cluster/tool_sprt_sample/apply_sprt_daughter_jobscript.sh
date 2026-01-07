#!/bin/bash
 
#SBATCH -J d_apply_sprt # job name
#SBATCH -p parallel              # partition: parallel, smp
#SBATCH -C skylake               # CPU type: broadwell (40 Kerne), skylake (64 Kerne)
#SBATCH -A m2_jgu-sprt-sim       # project name
#SBATCH -N 1                     # e.g. one full node - do not do this, when your script is not using parallel code!
#SBATCH -n 1                     # Total number of tasks
#SBATCH -c 64                    # Total number of cores for the single task

#SBATCH -t 00:45:00             # Run time (hh:mm:ss) full run  10.000
##SBATCH -t 00:30:00              # Run time (hh:mm:ss) test run   2.000
##SBATCH -t 00:02:00              # Run time (hh:mm:ss) test run    200

#SBATCH --mail-user=msteinhi@uni-mainz.de
#SBATCH --mail-type=ALL
#SBATCH -o output/sprt_tool/stdout_apply_daughter.txt


module purge # ensures vanilla environment
module load lang/R # will load most current version of R

# do not forget to export OMP_NUM_THREADS, if the library you use, supports this
# not scale up to 64 threadsq
#export OMP_NUM_THREADS=64

NODE_NAME=$(hostname)
echo "========================================" 
echo "Job ID: $SLURM_JOB_ID"
echo "Node: $NODE_NAME"
echo "Started: $(date)"
echo "========================================" 

echo "------daughter bash arguments------"
echo $1
echo $2
echo $3
echo $4
echo $5
echo $6
echo $7
echo $8
echo $9
echo ${10}
# echo ${11}
# echo ${12}
# echo ${13}
# echo ${14}
echo "------end of bash output------"
                       
srun Rscript cluster/tool_sprt_sample/run_tool_sprt_apply.R \
  --hyper_f_simulated $1 \
  --hyper_batch $2 \
  --hyper_strategy $3 \
  --hyper_select_raw_data $4 \
  --hyper_f_expected "$5" \
  --hyper_distribution $6 \
  --hyper_sd_raw_data $7 \
  --hyper_r_raw_data $8 \
  --hyper_n_raw_data $9 \
  --hyper_n_rep_raw_data ${10}
  # --hyper_file_type ${11} \
  # --hyper_raw_data_folder ${12} \
  # --hyper_data_folder ${13} \
  # --hyper_meta_data ${14} \
  # --hyper_seed ${15}

echo "------job is finished------"
echo "Node: $NODE_NAME | Finished: $(date)"

