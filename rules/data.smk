checkpoint get_dataset:
    '''
    Query NCBI to retrieve information on a dataset. Two outputs:
    - popmap: groups info file with sample name and its group (i.e. sex)
    - download_info: file with the SRA accession number used to download the
    reads with sra toolkit.
    Bioproject for a dataset is obtained from the parsing of the
    'data/info.tsv' file.
    '''
    output:
        popmap = 'results/radsex/{dataset}/popmap.tsv',
        download_info = directory('results/radsex/{dataset}/.download')
    benchmark:
        'benchmarks/{dataset}/get_dataset.tsv'
    log:
        'logs/{dataset}/get_dataset.txt'
    conda:
        '../envs/workflow.yaml'
    resources:
        mem_mb = config['resources']['default']['mem_mb'],
        runtime_s = config['resources']['default']['runtime_s']
    params:
        bioproject = lambda wildcards: config['info'][wildcards.dataset]['bioproject'],
        ncbi_api_key = config['ncbi']['api_key'],
        ncbi_email = config['ncbi']['email'],
        max_tries = config['ncbi']['max_tries'],
        sleep_between_tries = config['ncbi']['sleep_between_tries']
    script: '../scripts/get_dataset.py'


def download_dataset_input(wildcards):
    '''
    Generate a list of read files for all samples in a dataset.
    '''
    checkpoints.get_dataset.get(dataset=wildcards.dataset)
    reads_file = 'results/radsex/{dataset}/samples/{sample}.fq.gz'
    samples = glob_wildcards(f'results/{wildcards.dataset}/.download/{{sample}}.accession').sample
    all_samples = expand(reads_file, dataset=wildcards.dataset, sample=samples)
    return all_samples


rule download_dataset:
    '''
    Download reads from NCBI for all samples in a dataset.
    '''
    input:
        download_dataset_input
    output:
        touch('results/radsex/{dataset}/.dl.done')
    benchmark:
        'benchmarks/{dataset}/download_dataset.tsv'
    log:
        'logs/{dataset}/download_dataset.txt'
    resources:
        mem_mb = config['resources']['default']['mem_mb'],
        runtime_s = config['resources']['default']['runtime_s']


rule download_sample:
    '''
    Download reads from NCBI for a single sample.
    '''
    input:
        os.path.join(rules.get_dataset.output.download_info, '{sample}.accession')
    output:
        'results/radsex/{dataset}/samples/{sample}.fq.gz'
    benchmark:
        'benchmarks/{dataset}/download_sample/{sample}.tsv'
    log:
        'logs/{dataset}/download_sample/{sample}.txt'
    conda:
        '../envs/workflow.yaml'
    resources:
        mem_mb = config['resources']['default']['mem_mb'],
        runtime_s = config['resources']['default']['runtime_s']
    shell:
        'fastq-dump -Z --gzip $(cat {input}) > {output} 2> {log}'


rule download_genome:
    '''
    Download a genome file from the path give in 'data/info.tsv'.
    '''
    output:
        'results/radsex/{dataset}/genome/genome.fa'
    benchmark:
        'benchmarks/{dataset}/download_genome.tsv'
    log:
        'logs/{dataset}/download_genome.txt'
    conda:
        '../envs/workflow.yaml'
    resources:
        mem_mb = config['resources']['default']['mem_mb'],
        runtime_s = config['resources']['default']['runtime_s']
    params:
        url = lambda wildcards: config['info'][wildcards.dataset]['genome']
    shell:
        'wget -O- {params.url} > .tmp_genome 2> {log}; \\\n'
        'if $(file .tmp_genome | grep -q "gzip"); then \\\n'
        '   gzip -dc .tmp_genome > {output} 2>> {log}; rm -f .tmp_genome; \\\n'
        'else \\\n'
        '   mv .tmp_genome > {output} 2>> {log}; \\\n'
        'fi'
