#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2

process resegment {
    publishDir params.output, mode: 'copy', overwrite: true
    input:
    path "input"

    output:
    path "*"

    """#!/bin/bash
set -e

# Log the contents of the input data
ls -lahtr
ls -lahtr input/

# Only include the command line flag if the value of the
# parameter is not the default
ARGS=()

ARGS+="--id"
ARGS+=" ${params.id}"

if [[ "${params.expansion_distance}" != "false" ]]; then
    ARGS+=" --expansion-distance"
    ARGS+=" ${params.expansion_distance}"
else
    echo "Ignoring --expansion-distance because parameter was not provided"
fi

if [[ "${params.dapi_filter}" != "false" ]]; then
    ARGS+=" --dapi-filter"
    ARGS+=" ${params.dapi_filter}"
else
    echo "Ignoring --dapi-filter because parameter was not provided"
fi

if [[ "${params.resegment_nuclei.toLowerCase()}" != "false" ]]; then
    ARGS+=" --resegment-nuclei"
    ARGS+=" ${params.resegment_nuclei.toLowerCase()}"
else
    echo "Ignoring --resegment-nuclei because parameter was not provided"
fi

echo "Running xeniumranger resegment with arguments: \${ARGS[@]}"

xeniumranger \
    resegment \
    --disable-ui true \
    --xenium-bundle=\$PWD/input \
    \${ARGS[@]} \
    | tee xeniumranger-resegment.log

# Move outputs to the top-level directory
mv xenium_analysis/* ./
"""

}

workflow {
    Channel
        .fromPath(
            params.input.split(',').toList(),
            type: 'dir',
            checkIfExists: true
        )
        .flatten()
        | resegment
}
