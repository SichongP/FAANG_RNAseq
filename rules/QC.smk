## A set of rules to perform raw read QC analysis on RNA-seq data
## This does not include subsequent QC post Alignment

localrules: multiqc

rule fastqc:
    input: workDir + '/data/{sample}_{read}.fastq.gz'
    output: workDir + '/Results/fastQC/raw/{sample}_{read}_fastqc.zip'
    params: partition = getPartition, outDir = workDir + "/Results/fastQC/raw/"
    resources: cpus = 1, mem_mb = 3000, time = 120
    conda: workDir + '/envs/fastqc.yaml'
    version: "1.0"
    shell:
     """
     fastqc -o {params.outDir} {input}
     """

rule multiqc:
    input: expand(workDir + '/Results/fastQC/{{stage}}/{sample}_{read}_fastqc.zip', sample = SAMPLES, read = READS)
    output: report(workDir + '/Results/fastQC/{stage}/multiqc_report.html', category = 'QC', subcategory = 'FASTQ QC', caption = workDir + '/report/multiqc.rst', htmlindex = 'multiqc_report.html')
    params: outDir = lambda wildcards: workDir + "/Results/fastQC/{}/".format(wildcards.stage), inDir = lambda wildcards: workDir + "/Results/fastQC/{}/".format(wildcards.stage)
    conda: workDir + '/envs/multiqc.yaml'
    shell:
     """
     rm -r {params.outDir}multiqc_*
     multiqc -o {params.outDir} {params.inDir}
     """

rule trim:
    input: expand(workDir + '/data/{{sample}}_{read}.fastq.gz', read = READS)
    output: 
        r1 = temp(workDir + '/Results/trimming/{sample}_R1.fq.gz'),
        r2 = temp(workDir + '/Results/trimming/{sample}_R2.fq.gz'),
        qc1 = workDir + '/Results/fastQC/trimming/{sample}_R1_fastqc.zip',
        qc2 = workDir + '/Results/fastQC/trimming/{sample}_R2_fastqc.zip'
    conda: workDir + '/envs/trim_galore.yaml'
    resources: time_min=8000, mem_mb=8000, mem_mb_bmm=8000, cpus_bmm=1, cpus=1
    params: 
        partition = getPartition, 
        outDir = workDir + '/Results/trimming/', 
        basename = lambda wildcards: wildcards.sample,
        fastqc_args = '-o ' + workDir + '/Results/fastQC/trimming/',
        temp_r1 = lambda wildcards: workDir + '/Results/trimming/{}_val_1.fq.gz'.format(wildcards.sample),
        temp_r2 = lambda wildcards: workDir + '/Results/trimming/{}_val_2.fq.gz'.format(wildcards.sample),
        temp_qc1 = lambda wildcards: workDir + '/Results/fastQC/trimming/{}_val_1_fastqc.zip'.format(wildcards.sample),
        temp_qc2 = lambda wildcards: workDir + '/Results/fastQC/trimming/{}_val_2_fastqc.zip'.format(wildcards.sample)
    shell:
     """
     trim_galore --paired -o {params.outDir} --fastqc_args "{params.fastqc_args}" --basename {wildcards.sample} {input}
     mv {params.temp_r1} {output.r1}
     mv {params.temp_r2} {output.r2}
     mv {params.temp_qc1} {output.qc1}
     mv {params.temp_qc2} {output.qc2}
     """ 
