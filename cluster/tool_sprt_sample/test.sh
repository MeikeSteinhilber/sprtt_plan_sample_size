#!/bin/bash

declare -ar sd=("11111" "1111" "111" "11")
declare -ar sample_ratio=("11111" "1111" "111" "11")
declare -ar hyper_f_expected=(0 $(seq 0.10 0.05 0.40) )

#echo $hyper_f_simulated
echo "${hyper_f_expected[@]}"

for i in "${!sd[@]}"; do
   hyper_sd="${sd[$i]}"
   hyper_sample_ratio="${sample_ratio[$i]}"
   echo "sd=$hyper_sd, sample_ratio=$hyper_sample_ratio"
done
