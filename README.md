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

Run the workflow
```
make run_hpcc
```

This workflow will utilize a custom conda env that is created in the work folder and then used by the actual compute jobs

Running the workflow with GPU resources
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