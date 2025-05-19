#!/usr/bin/env nextflow
nextflow.enable.dsl=2

params.input = "README.md"

TOOL_FOLDER = "$baseDir/bin"

process processData {
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env.yml"

    input:
    file input 

    output:
    file 'output.tsv'

    """
    which python
    python $TOOL_FOLDER/script.py $input output.tsv
    """
}

process processGPU {
    publishDir "./nf_output", mode: 'copy'

    conda "$TOOL_FOLDER/conda_env_gpu.yml"

    clusterOptions "--gres=gpu:1"

    input:
    val input

    output:
    file 'gpu_summary.txt'

    """
    which python
    python $TOOL_FOLDER/test_torch.py > gpu_summary.txt
    """
}

workflow {
    data = Channel.fromPath(params.input)
    processData(data)

    val_ch = 0
    processGPU(val_ch)
}