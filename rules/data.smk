checkpoint get_dataset:
    '''
    '''
    output:
        popmap = 'results/{dataset}/popmap.tsv',
        download_info = directory('results/{dataset}/.download')
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
    '''
    checkpoints.get_dataset.get(dataset=wildcards.dataset)
    reads_file = 'results/{dataset}/samples/{sample}.fq.gz'
    samples = glob_wildcards(f'results/{wildcards.dataset}/.download/{{sample}}.accession').sample
    all_samples = expand(reads_file, dataset=wildcards.dataset, sample=samples)
    return all_samples


rule download_dataset:
    ''''
    '''
    input:
        download_dataset_input
    output:
        touch('results/{dataset}/.dl.done')
    benchmark:
        'benchmarks/{dataset}/download_dataset.tsv'
    log:
        'logs/{dataset}/download_dataset.txt'
    resources:
        mem_mb = config['resources']['default']['mem_mb'],
        runtime_s = config['resources']['default']['runtime_s']


rule download_sample:
    ''''
    '''
    input:
        os.path.join(rules.get_dataset.output.download_info, '{sample}.accession'),
    output:
        'results/{dataset}/samples/{sample}.fq.gz'
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
