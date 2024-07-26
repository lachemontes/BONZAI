import os
import re
import glob

import pandas as pd
#======================================================
# Config files
#======================================================
configfile: "config.yaml"

#======================================================
# Global variables
#======================================================

RAW_DATA_DIR =config['input_dir']
RESULTS_DIR=config['results_dir'].rstrip("/")

if RESULTS_DIR == "" and not RAW_DATA_DIR == "":
	RESULTS_DIR=os.path.abspath(os.path.join(RAW_DATA_DIR, os.pardir))

PAIRED=True

if not RAW_DATA_DIR == "":
	RAW_DATA_DIR=RAW_DATA_DIR.rstrip("/")
	SAMPLES,=glob_wildcards(RAW_DATA_DIR + "/{sample}_" + str(config['reverse_tag']) + ".fastq.gz")
	SAMPLES.sort()
else:
	RAW_DATA_DIR=RESULTS_DIR+"/00_RAW_DATA"

dir_list = ["RULES_DIR","ENVS_DIR", "ADAPTERS_DIR", "RAW_NOTEBOOKS","RAW_DATA_DIR", "QC_DIR", "CLEAN_DATA_DIR", "ASSEMBLY_DIR", "MAPPING_DIR", "TRANSCRIPTOME_ASSEMBLY_DIR", "ANNOTATION", "ABUNDANCE", "BENCHMARKS", "NOTEBOOKS_DIR", "PLOTS_DIR"]
dir_names = ["rules", "../envs", "db/adapters", "../notebooks" ,RAW_DATA_DIR, RESULTS_DIR + "/01_QC", RESULTS_DIR + "/01_QC", RESULTS_DIR + "/02_ASSEMBLY", RESULTS_DIR + "/03_MAPPING" , RESULTS_DIR + "/04_TRANSCRIPTOME_ASSEMBLY", RESULTS_DIR + "/05_ANNOTATION", RESULTS_DIR + "/06_GENE_EXPRESSION", RESULTS_DIR + "/BENCHMARK", RESULTS_DIR + "/NOTEBOOKS" ,RESULTS_DIR + "/FIGURES_AND_TABLES"]
dirs_dict = dict(zip(dir_list, dir_names))


print("Input Directory")
print(RAW_DATA_DIR)

print("Results Directory")
print(RESULTS_DIR)

print("Sample Names = ")
print(*SAMPLES, sep = ", ")
print(len(SAMPLES))

def inputReadsCount(wildcards):
# Read counts
	inputs=[]
	inputs.extend(expand(dirs_dict["RAW_DATA_DIR"] + "/{sample}_" + str(config['forward_tag']) + "_read_count.txt", sample=SAMPLES))
	inputs.extend(expand(dirs_dict["RAW_DATA_DIR"] + "/{sample}_" + str(config['reverse_tag']) + "_read_count.txt", sample=SAMPLES))
	inputs.extend(expand(dirs_dict["CLEAN_DATA_DIR"] + "/{sample}_forward_paired_read_count.txt", sample=SAMPLES))
	inputs.extend(expand(dirs_dict["CLEAN_DATA_DIR"] + "/{sample}_reverse_paired_read_count.txt", sample=SAMPLES))
	inputs.extend(expand(dirs_dict["CLEAN_DATA_DIR"] + "/{sample}_merged_unpaired.tot_read_count.txt", sample=SAMPLES))
	inputs.extend(expand(dirs_dict["CLEAN_DATA_DIR"] + "/{sample}_forward_paired_noEuk.tot_read_count.txt", sample=SAMPLES))
	inputs.extend(expand(dirs_dict["CLEAN_DATA_DIR"] + "/{sample}_reverse_paired_noEuk.tot_read_count.txt", sample=SAMPLES))
	inputs.extend(expand(dirs_dict["CLEAN_DATA_DIR"] + "/{sample}_unpaired_noEuk.tot_read_count.txt", sample=SAMPLES))
	inputs.extend(expand(dirs_dict["CLEAN_DATA_DIR"] + "/{sample}_forward_paired_clean.tot_read_count.txt", sample=SAMPLES))
	inputs.extend(expand(dirs_dict["CLEAN_DATA_DIR"] + "/{sample}_reverse_paired_clean.tot_read_count.txt", sample=SAMPLES))
	inputs.extend(expand(dirs_dict["CLEAN_DATA_DIR"] + "/{sample}_unpaired_clean.tot_read_count.txt", sample=SAMPLES))


rule all:
	input:
		inputReadsCount,
		# inputQC,
		# inputAssembly,
		# inputMapping,
		# inputTranscriptomeAssembly,
		# inputAnnotation,
		# inputAbundance,


include: os.path.join(RULES_DIR, '00_download_tools.smk')
include: os.path.join(RULES_DIR, '01_quality_control.smk')
include: os.path.join(RULES_DIR, '02_assembly.smk')
include: os.path.join(RULES_DIR, '03_mapping.smk')
include: os.path.join(RULES_DIR, '04_transcriptome_assembly.smk')
include: os.path.join(RULES_DIR, '05_annotation.smk')
include: os.path.join(RULES_DIR, '06_gene_expression.smk')
