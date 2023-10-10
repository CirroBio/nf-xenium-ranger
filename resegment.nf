#!/usr/bin/env nextflow

// Using DSL-2
nextflow.enable.dsl=2

process resegment {
    input:
    path "xenium_bundle"

    output:
    path "outs/"

    """#!/bin/bash
set -e

xeniumranger \
    resegment \
    --id=${params.id} \
    --xenium-bundle=\$PWD/xenium_bundle \
    --expansion-distance ${params.expansion_distance} \
    --dapi-filter ${params.dapi_filter} \
    --resegment-nuclei ${params.resegment_nuclei}

"""

}

workflow {
    Channel
        .fromPath(
            params.input.split(',').toList(),
            type: 'dir',
            checkIfExists: true
        )
        | resegment
}