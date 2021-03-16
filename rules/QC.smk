## A set of rules to perform raw read QC analysis on RNA-seq data
## This does not include subsequent QC post Alignment

rule fastqc:
    input: workDir + '/data/{sample}_{read}.fastq.gz'
    output: workDir + '/Results/fastQC/{stage}/{sample}_{read}_fastqc.zip'
    params: partition = getPartition, outDir = lambda wildcards: workDir + "/Results/fastQC/{}/".format(wildcards.stage)
    resources: cpus = 1, mem_mb = 3000, time = 120
    conda: workDir + '/envs/fastqc.yaml'
    version: "1.0"
    shell:
     """
     echo {params.partition}
     fastqc -o {params.outDir} {input}
     """
