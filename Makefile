run:
	nextflow run ./nf_workflow.nf -resume -c nextflow.config

run_hpcc:
	nextflow run ./nf_workflow.nf -resume -c nextflow_hpcc.config -with-conda

run_hpcc_gpu:
	nextflow run ./nf_workflow.nf -resume -c nextflow_hpcc_gpu.config -with-conda

run_docker:
	nextflow run ./nf_workflow.nf -resume -with-docker <CONTAINER NAME>