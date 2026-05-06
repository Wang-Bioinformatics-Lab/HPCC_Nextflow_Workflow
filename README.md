# Nextflow Template

To run the workflow to test simply do

```
make run
```

To learn NextFlow checkout this documentation:

https://www.nextflow.io/docs/latest/index.html

## Installation

You will need to have conda, mamba, and nextflow installed. 

## Deployment to GNPS2

In order to deploy, we have a set of deployment tools that will enable deployment to the various gnps systems. To run the deployment, use the following commands from the deploy_gnps2 folder. 

```
make deploy-prod
```

You might need to checkout the module, do this by running

```
git submodule init
git submodule update
```

## Running on HPCC

Create a nextflow conda environment
```
conda create -n nextflow python=3.9
conda activate nextflow
conda install -c conda-forge mamba
mamba install -c bioconda nextflow
```

Run the workflow - this will run one process on cpu and another on gpu
```
make run_hpcc
```

This workflow will utilize a custom conda env that is created in the work folder and then used by the actual compute jobs

Running the workflow with GPU resources - this will run both on gpu
```
make run_hpcc_gpu
```

### Testing script on HPCC with gpu

This will get us an interactive session on HPCC with a GPU

```
srun -p gpu --gres=gpu:1 -c 8 --mem 8GB --pty bash -l
```

Here is how we do it with sbatch

```
sbatch ./run_torch.sh
```

## Hello-world container: Docker -> Singularity -> HPCC

End-to-end demo of building a Docker image locally, converting it to a
Singularity `.sif` locally, shipping the `.sif` to UCR HPCC, and running it
on a compute node. The image, scripts, and Makefile targets are all
stage-by-stage so each step can be re-run independently. See
`containers/helloworld/Dockerfile` and the `hello_*` targets in the
`Makefile`.

### Prerequisites

- **Docker** on your laptop (`docker --version`).
- **Apptainer** on your laptop (open-source fork of Singularity, format-
  compatible with `singularity-ce` on HPCC). Install on Ubuntu:

  ```
  sudo add-apt-repository -y ppa:apptainer/ppa
  sudo apt update
  sudo apt install -y apptainer
  apptainer --version    # tested with 1.4.5
  ```

- An `~/.ssh/config` entry aliasing `hpcc` to `cluster.hpcc.ucr.edu` (the
  Makefile uses the alias).

### The pipeline

1. **Build Docker image locally** — `docker build` from
   `containers/helloworld/Dockerfile` (Alpine + a tiny `hello.sh` that
   prints hostname/OS/user/args).
2. **Build `.sif` locally** — `apptainer build helloworld.sif
   docker-daemon://helloworld:latest` reads straight from your Docker daemon
   (no intermediate tar).
3. **Ship via rsync** — `.sif` goes to
   `/bigdata/<group>/<netid>/helloworld_container/helloworld.sif`. Resumable;
   re-running only re-transfers if the `.sif` changed.
4. **Run on a compute node** — `singularity run helloworld.sif` via `srun`
   on the `short` partition. Stdout lands under `logs/run-<jobid>.out`.

### Where the artifacts live

| Artifact | Location |
| --- | --- |
| Local Docker image | `helloworld:latest` (in your local Docker daemon) |
| **Local Singularity `.sif`** | **`containers/helloworld/build/helloworld.sif`** (gitignored) |
| **Singularity `.sif` on HPCC** | **`hpcc:/bigdata/<group>/<netid>/helloworld_container/helloworld.sif`** |
| Job logs on HPCC | `hpcc:/bigdata/<group>/<netid>/helloworld_container/logs/run-<jobid>.{out,err}` |

For this repo's defaults (`HPCC_GROUP=mxwanglab`, `HPCC_NETID=mingxunw`) the
`.sif` on HPCC is:

```
hpcc:/bigdata/mxwanglab/mingxunw/helloworld_container/helloworld.sif
```

You can `singularity run` it on a compute node, or point Nextflow's
`process.container` at that path.

### Run the pipeline

Run the whole thing:

```
make hello_all_hpcc
```

Or step by step:

```
make hello_docker_build         # local  -> docker image helloworld:latest
make hello_singularity_build    # local  -> containers/helloworld/build/helloworld.sif
make hello_ship_hpcc            # local  -> hpcc:.../helloworld_container/helloworld.sif
make hello_run_hpcc             # hpcc   -> singularity run, tail log
```

Override defaults if your NetID / group differ:

```
make hello_all_hpcc HPCC_NETID=alice HPCC_GROUP=somelab
```

### Inspecting / running the .sif manually on HPCC

```
ssh hpcc
module load singularity/4.3.2
cd /bigdata/<group>/<netid>/helloworld_container

# Metadata
singularity inspect helloworld.sif

# One-off run on a compute node (don't run on the login node)
srun --partition=short --time=00:05:00 --mem=1G \
  singularity run helloworld.sif "manual run"
```