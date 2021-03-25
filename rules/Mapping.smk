rule RefGuidedAlignment:
    input:
        genomeDir = lambda wildcards: config['star_genome'],
        r1 = workDir + '/Results/trimming/{sample}_R1.fq.gz',
        r2 = workDir + '/Results/trimming/{sample}_R2.fq.gz'
    output:
        bam = "Results/mapping/{sample}.bam",
        stat = "Results/mapping/{sample}Log.final.out"
    params:
        partition = getPartition,
        RG = lambda wildcards: "ID:{name} SM:{name} PL:illumina LB:{name}".format(name = wildcards.sample),
        prefix = lambda wildcards: "Results/mapping/" + wildcards.sample,
        outType = "BAM SortedByCoordinate",
        unmapped = "Within",
        strandField = "intronMotif",
        attrIHStart = 0,
        readCommand = "zcat",
        interName = lambda wildcards: "Results/mapping/" + str(wildcards.sample) + "Aligned.sortedByCoord.out.bam"
    conda: "../envs/star.yaml"
    resources: mem_mb = 80000, mem_mb_bmm = 80000, time_min = 900, cpus = 10, cpus_bmm = 10
    shell:
     """
     MYTMPDIR=/scratch/pengsc/$SLURM_JOBID
     cleanup() {{ rm -rf $MYTMPDIR; }}
     trap cleanup EXIT
     mkdir -p /scratch/pengsc/
     STAR --outTmpDir $MYTMPDIR --outSAMattrRGline {params.RG} --outFileNamePrefix {params.prefix} --runThreadN {resources.cpus} --outSAMtype {params.outType} \
     --outBAMsortingThreadN {resources.cpus} --outSAMunmapped {params.unmapped} --outSAMstrandField {params.strandField} --outSAMattrIHstart {params.attrIHStart} \
     --readFilesCommand {params.readCommand} --genomeDir {input.genomeDir} --readFilesIn {input.r1} {input.r2}
     mv {params.interName} {output.bam}
     """

rule plotMappingRate:
    input: expand("Results/mapping/{sample}Log.final.out", sample = SAMPLES)
    output: 
        pdf = report("Results/Reports/MappingReport.pdf"),
        csv = report("Results/Reports/MappingReport.csv")
    conda: workDir + "/envs/python.yaml"
    resources: mem_mb = 8000, cpus = 1, time_min = 60, mem_mb_bmm = 8000, cpus_bmm = 1
    params: partition = getPartition
    script: workDir + "/scripts/mappingReport.py"
