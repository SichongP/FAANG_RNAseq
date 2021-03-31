configfile: "config.yaml"

## Process data files
## Format: {rep}_{tissue}_{read}.fastq.gz
### rep: AH1 - AH4
### tissue: [\w\d]+
### read: R1 or R2

## each rep doesn't necessarily have same tissues
## So we use rep_tissue together as an identifier, termed SAMPLE
## But we also make two dicts: {rep: [tissues]} and {tissue: [reps]} 
## in order to do pair-wise analysis 

import glob, os

# Get current directory, we will prepend this path to ensure correct pathing in all rules
workDir = str(os.getcwd())

READS = ['R1', 'R2']
SAMPLES = []
REPS = {} # [tissue: [reps]]
TISSUES = {} # {rep: [tissues]}


for file in glob.glob("data/RNAseq/*R1*gz"):
    rep, tissue, read = file.replace('.fastq.gz', '').replace('data/','').split('_')
    SAMPLES.append('_'.join([rep, tissue]))
    if rep not in TISSUES:
        TISSUES[rep] = [tissue]
    else:
        TISSUES[rep].append(tissue)
    if tissue not in REPS:
        REPS[tissue] = [rep]
    else:
        REPS[tissue].append(rep)

def getPartition(wildcards, resources):
    # Determine partition for each rule based on resources requested
    for key in resources.keys():
        if 'bmm' in key and int(resources['cpus_bmm']) > 0:
            return 'bmm'
        elif 'med' in key and int(resources['cpus_med']) > 0:
            return 'med2'
    if int(resources['mem_mb']) / int(resources['cpus']) > 4000:
        return 'bml'
    else:
        return 'low2'

rule all:
    input: 
        workDir + '/Results/fastQC/trimming/multiqc_report.html',
        workDir + '/Results/fastQC/raw/multiqc_report.html',
        expand("Results/mapping/{sample}.markDup.bam", sample = SAMPLES),
        expand("Results/mapping/{sample}.markDup.bam.bai", sample = SAMPLES),
        "Results/Reports/MappingReport.pdf"

include: "rules/QC.smk"
include: "rules/Mapping.smk"
