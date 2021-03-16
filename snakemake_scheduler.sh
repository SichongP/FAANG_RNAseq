#! /bin/bash -login
#SBATCH -J FAANG_RNA
#SBATCH -t 10-00:00:00
#SBATCH -N 1
#SBATCH -n 1
#SBATCH -c 1
#SBATCH -p high2
#SBATCH --mem=3gb
#SBATCH --mail-type=ALL
#SBATCH --mail-user=scpeng@ucdavis.edu


# -J job name
# -t time (minutes)
# -N number of nodes requested
# -n number of tasks to be run
# -c number of spus per task
# --mem minimum memory requested

# activate conda in general
conda activate base
cd /home/pengsc/projects/FAANG_mRNAseq

# Do something
mkdir -p logs_slurm
snakemake --profile slurm -s /home/pengsc/projects/FAANG_mRNAseq/Snakefile -p -k --rerun-incomplete --cluster-status ~/.config/snakemake/slurm_status.py
