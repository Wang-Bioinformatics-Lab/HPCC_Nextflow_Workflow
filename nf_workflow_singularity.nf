#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.tag = "from-nextflow-on-hpcc"

process processHello {
    publishDir "./nf_output_singularity", mode: 'copy'

    input:
    val tag

    output:
    path 'hello.txt'

    """
    /usr/local/bin/hello "${tag}" | tee hello.txt
    """
}

workflow {
    processHello(params.tag)
}
