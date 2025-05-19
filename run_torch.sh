#!/bin/bash -l

#SBATCH --job-name=gpu_job
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G

export $PATH = '$CONDA_DEFAULT_ENV/bin:$PATH'
source activate hello_world
python ./bin/test_torch.py