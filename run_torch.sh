#!/bin/bash
#SBATCH --job-name=gpu_job
#SBATCH --partition=gpu
#SBATCH --gres=gpu:1
#SBATCH --cpus-per-task=8
#SBATCH --mem=8G

conda activate hello_world
python ./test_torch.py