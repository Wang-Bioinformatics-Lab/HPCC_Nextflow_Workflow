run:
	nextflow run ./nf_workflow.nf -resume -c nextflow.config

run_hpcc:
	nextflow run ./nf_workflow.nf -resume -c nextflow_hpcc.config -with-conda

run_hpcc_gpu:
	nextflow run ./nf_workflow.nf -resume -c nextflow_hpcc_gpu.config -with-conda

# Run the helloworld Singularity container through Nextflow on HPCC.
# Run this *on* the HPCC login node (with the `nextflow` conda env active).
# The .sif must already be on HPCC — `make hello_all_hpcc` from a laptop
# builds and ships it.
run_hpcc_singularity:
	nextflow run ./nf_workflow_singularity.nf -resume -c nextflow_hpcc_singularity.config

run_docker:
	nextflow run ./nf_workflow.nf -resume -with-docker <CONTAINER NAME>

# ----------------------------------------------------------------------------
# Hello-world container: Docker -> Singularity -> HPCC
# ----------------------------------------------------------------------------
# End-to-end demo of building a Docker image locally, converting it to a
# Singularity .sif locally with apptainer, shipping the .sif to UCR HPCC,
# and running it through SLURM. Each target below is a distinct step so
# you can re-run any stage independently; `hello_all_hpcc` chains them.
#
# Why build the .sif locally? Avoids paying SLURM scheduling overhead for
# every container change, no Docker Hub credentials on HPCC needed, and the
# .sif is reproducible from your local Dockerfile. Apptainer 1.4.x on the
# local box is file-format compatible with `singularity-ce/4.3.2` on HPCC.
#
# Why srun the run? Per the hpcc-ucr skill etiquette, anything more than a
# couple seconds of CPU goes through the scheduler — never the login node.
#
# HPCC layout (override on the make command line if needed):
HPCC_HOST   ?= hpcc
HPCC_GROUP  ?= mxwanglab
HPCC_NETID  ?= mingxunw
HPCC_WORK   ?= /bigdata/$(HPCC_GROUP)/$(HPCC_NETID)/helloworld_container

HELLO_IMG   ?= helloworld:latest
HELLO_DIR   := containers/helloworld
HELLO_SIF   := $(HELLO_DIR)/build/helloworld.sif

# 1. Build the Docker image locally from containers/helloworld/Dockerfile.
hello_docker_build:
	docker build -t $(HELLO_IMG) $(HELLO_DIR)

# 2. Build the Singularity .sif locally via apptainer, reading directly
#    from the local Docker daemon (no intermediate tar). Requires apptainer
#    on PATH (sudo apt install -y apptainer after adding ppa:apptainer/ppa).
hello_singularity_build: hello_docker_build
	mkdir -p $(HELLO_DIR)/build
	apptainer build --force $(HELLO_SIF) docker-daemon://$(HELLO_IMG)
	@ls -lh $(HELLO_SIF)

# 3. Ship the .sif to /bigdata on HPCC. rsync is resumable; re-running this
#    only re-transfers if the .sif changed.
hello_ship_hpcc: hello_singularity_build
	ssh $(HPCC_HOST) 'mkdir -p $(HPCC_WORK)/logs'
	rsync -avh --partial --progress $(HELLO_SIF) \
	  $(HPCC_HOST):$(HPCC_WORK)/helloworld.sif

# 4. Run the .sif on a compute node and tail the stdout log.
hello_run_hpcc:
	ssh $(HPCC_HOST) "bash -lc '\
	  srun --partition=short --time=00:05:00 --cpus-per-task=1 --mem=1G \
	       --job-name=helloworld_run \
	       --output=$(HPCC_WORK)/logs/run-%j.out \
	       --error=$(HPCC_WORK)/logs/run-%j.err \
	       bash -lc \"\
	         module load singularity/4.3.2 && \
	         cd $(HPCC_WORK) && \
	         singularity run helloworld.sif from-make-target\" && \
	  ls -t $(HPCC_WORK)/logs/run-*.out | head -1 | xargs cat'"

# Convenience: full pipeline (build local -> ship .sif -> run on HPCC).
hello_all_hpcc: hello_ship_hpcc hello_run_hpcc
