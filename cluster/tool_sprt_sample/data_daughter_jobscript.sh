#!/bin/bash
 
#SBATCH -J d_data_tool_sprt    # job name
#SBATCH -p parallel                   # partition: parallel, smp
##SBATCH -C broadwell                 # CPU type: broadwell (40 Kerne), skylake (64 Kerne)
#SBATCH -A m2_jgu-sprt-sim            # project name (ki_sprt oder m2_jgu-sprt-sim)
#SBATCH -N 1                          # e.g. one full node - do not do this, when your script is not using parallel code!
#SBATCH -n 1                          # Total number of tasks
##SBATCH -c 64                        # Total number of cores for the single task

#SBATCH -t 00:50:00                   # Run time (hh:mm:ss) 10.000
##SBATCH -t 00:20:00                   # Run time (hh:mm:ss)   2.000
##SBATCH -t 00:05:00                   # Run time (hh:mm:ss)      500
##SBATCH -t 00:15:00                   # Run time (hh:mm:ss)      200

#SBATCH --mail-user=msteinhi@uni-mainz.de
#SBATCH --mail-type=ALL
#SBATCH -o output/sprt_tool/stdout_data_daughter.txt

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
echo ${11}
echo ${12}
echo "------end of bash output------"
                       
srun Rscript cluster/tool_sprt_sample/run_tool_sprt_simulate_data.R \
  --hyper_n_rep $1 \
  --hyper_distribution $2 \
  --hyper_f_simulated "$3" \
  --hyper_sd $4 \
  --hyper_sample_ratio $5 \
  --hyper_max_n $6 \
  --hyper_raw_data_folder $7 \
  --hyper_file_type $8 \
  --hyper_cores_reduction $9 \
  --hyper_seed ${10} \
  --hyper_parallel ${11} \
  --hyper_sink  ${12}

echo "------job is finished------"
echo "Node: $NODE_NAME | Finished: $(date)"