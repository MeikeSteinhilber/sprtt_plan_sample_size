#!/bin/bash
create_batches() {
    local num_files=$1
    local num_batches=$2
    local output_file=$3

    local base_size=$((num_files / num_batches))
    local remainder=$((num_files % num_batches))

    local start_index=1
    #local output_file="cluster/rows_batches.txt"  # You can change the output file name as per your requirement

    # Empty the output_file if it already exists
    > "$output_file"

    for (( i=1; i<=num_batches; i++ )); do
        local end_index=$((start_index + base_size - 1))

        # Distribute the remainder among the batches
        if ((remainder > 0)); then
            end_index=$((end_index + 1))
            remainder=$((remainder - 1))
        fi

        # Initialize an empty string to hold the batch
        local batch_str=""
        for (( j=start_index; j<=end_index; j++ )); do
            # Append each number in the batch to batch_str, separated by a space
            batch_str+="$j "
        done
        
        # Write the batch string to the output_file
        echo "${batch_str% }" >> "$output_file"  # % trims the trailing space
        
        start_index=$((end_index + 1))
    done
}

# Example usage:
# create_batches 100 30

