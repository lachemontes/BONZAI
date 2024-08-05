rule transcriptome_assembly_bam:
	input:
		sorted_bam=dirs_dict["MAPPING_DIR"] + "/{sample}_{reference_genome}_sorted.bam",
	output:
		gtf_file=dirs_dict["TRANSCRIPTOME_ASSEMBLY_DIR"] + "/{sample}_{reference_genome}.gtf",
		  gene_abundance=dirs_dict["TRANSCRIPTOME_ASSEMBLY_DIR"] +"/{sample}_{reference_genome}_gene_abundances.txt"
	message:
		"Transcriptome assembly"
	conda:
		dirs_dict["ENVS_DIR"] + "/env2.yaml"
	threads: 8
	shell:
		"""
		  stringtie {input.sorted_bam} -p {threads} -o {output.gtf_file} -A {output.gene_abundance}
		"""

rule convert_to_gff3:
	input:
		gtf_files=expand(dirs_dict["TRANSCRIPTOME_ASSEMBLY_DIR"] + "/{sample}_{{reference_genome}}.gtf", sample=SAMPLES),
		reference_fasta=dirs_dict["GENOMES_DIR"] +"/{reference_genome}.fasta",
	output:
		gtf_merged=dirs_dict["TRANSCRIPTOME_ASSEMBLY_DIR"] + "/merged_{reference_genome}.gtf",
		gff3_file=dirs_dict["TRANSCRIPTOME_ASSEMBLY_DIR"] + "/merged_{reference_genome}.gff3",
		transcript_file=dirs_dict["TRANSCRIPTOME_ASSEMBLY_DIR"] +"/merged_{reference_genome}_transcript.fasta"
	message:
		"merging "
	conda:
		dirs_dict["ENVS_DIR"] + "/env2.yaml"
	threads: 8
	shell:
		"""
		  stringtie --merge {input.gtf_files} -o {output.gtf_merged}	
		  gffread {output.gtf_merged} -o {output.gff3_file} 
		  gffread {output.gff3_file} -g {input.reference_fasta} -w {output.transcript_file}
		"""