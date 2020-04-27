# Constrain value of min_depth to a number
wildcard_constraints:
    min_depth = '\d+'


rule process:
    '''
    Compute a table of individual marker depths.
    '''
    input:
        rules.download_dataset.output
    output:
        'results/radsex/{dataset}/markers_table.tsv'
    benchmark:
        'benchmarks/{dataset}/process.tsv'
    log:
        'logs/{dataset}/process.txt'
    conda:
        '../envs/workflow.yaml'
    threads:
        config['resources']['process']['threads']
    resources:
        mem_mb = config['resources']['process']['mem_mb'],
        runtime_s = config['resources']['process']['runtime_s']
    params:
        samples_dir = lambda wildcards: f'results/radsex/{wildcards.dataset}/samples'
    shell:
        'radsex process '
        '--threads {threads} '
        '--input-dir {params.samples_dir} '
        '--output-file {output} '
        '--min-depth 1 '
        '2> {log}'


rule depth:
    '''
    Compute the number of reads, number of markers, and min, max, median, and
    average marker depth in each individual.
    '''
    input:
        markers_table = rules.process.output,
        popmap = 'results/radsex/{dataset}/popmap.tsv'
    output:
        'results/radsex/{dataset}/depth.tsv'
    benchmark:
        'benchmarks/{dataset}/depth.tsv'
    log:
        'logs/{dataset}/depth.txt'
    conda:
        '../envs/workflow.yaml'
    resources:
        mem_mb = config['resources']['default']['mem_mb'],
        runtime_s = config['resources']['default']['runtime_s']
    shell:
        'radsex depth '
        '--markers-table {input.markers_table} '
        '--popmap {input.popmap} '
        '--output-file {output} '
        '2> {log}'


rule depth_plot:
    '''
    Plot the results of radsex depth; two outputs:
    - Boxplot of distribution of number of reads in each group
    - Barplot with number of reads per individual
    '''
    input:
        rules.depth.output
    output:
        by_individual = 'results/radsex/{dataset}/depth_by_individual.png',
        by_sex = 'results/radsex/{dataset}/depth_by_sex.png'
    benchmark:
        'benchmarks/{dataset}/depth_plot.tsv'
    log:
        'logs/{dataset}/depth_plot.txt'
    conda:
        '../envs/workflow.yaml'
    resources:
        mem_mb = config['resources']['default']['mem_mb'],
        runtime_s = config['resources']['default']['runtime_s']
    script:
        '../scripts/depth_plot.R'


rule distrib:
    '''
    Compute the distribution of markers between two groups.
    '''
    input:
        markers_table = rules.process.output,
        popmap = 'results/radsex/{dataset}/popmap.tsv'
    output:
        'results/radsex/{dataset}/distrib_{min_depth}.tsv'
    benchmark:
        'benchmarks/{dataset}/distrib_{min_depth}.tsv'
    log:
        'logs/{dataset}/distrib_{min_depth}.txt'
    conda:
        '../envs/workflow.yaml'
    resources:
        mem_mb = config['resources']['default']['mem_mb'],
        runtime_s = config['resources']['default']['runtime_s']
    params:
        options = lambda wildcards: get_options('distrib', wildcards)
    shell:
        'radsex distrib '
        '--markers-table {input.markers_table} '
        '--popmap {input.popmap} '
        '--output-file {output} '
        '{params.options} '
        '2> {log}'


rule distrib_plot:
    '''
    Plot the results of radsex distrib in a tile plot.
    '''
    input:
        rules.distrib.output
    output:
        'results/radsex/{dataset}/distrib_{min_depth}.png',
    benchmark:
        'benchmarks/{dataset}/distrib_{min_depth}_plot.tsv'
    log:
        'logs/{dataset}/distrib_{min_depth}_plot.txt'
    conda:
        '../envs/workflow.yaml'
    resources:
        mem_mb = config['resources']['default']['mem_mb'],
        runtime_s = config['resources']['default']['runtime_s']
    script:
        '../scripts/distrib_plot.R'


rule freq:
    '''
    Compute the distribution of markers in the entire population.
    '''
    input:
        markers_table = rules.process.output
    output:
        'results/radsex/{dataset}/freq_{min_depth}.tsv'
    benchmark:
        'benchmarks/{dataset}/freq_{min_depth}.tsv'
    log:
        'logs/{dataset}/freq_{min_depth}.txt'
    conda:
        '../envs/workflow.yaml'
    resources:
        mem_mb = config['resources']['default']['mem_mb'],
        runtime_s = config['resources']['default']['runtime_s']
    params:
        options = lambda wildcards: get_options('freq', wildcards)
    shell:
        'radsex freq '
        '--markers-table {input.markers_table} '
        '--output-file {output} '
        '{params.options} '
        '2> {log}'


rule freq_plot:
    '''
    Plot the results of radsex freq in a distribution plot.
    '''
    input:
        rules.freq.output
    output:
        'results/radsex/{dataset}/freq_{min_depth}.png',
    benchmark:
        'benchmarks/{dataset}/freq_{min_depth}_plot.tsv'
    log:
        'logs/{dataset}/freq_{min_depth}_plot.txt'
    conda:
        '../envs/workflow.yaml'
    resources:
        mem_mb = config['resources']['default']['mem_mb'],
        runtime_s = config['resources']['default']['runtime_s']
    script:
        '../scripts/freq_plot.R'


rule signif:
    '''
    Extract markers significantly associated with groups in a fasta file.
    '''
    input:
        markers_table = rules.process.output,
        popmap = 'results/radsex/{dataset}/popmap.tsv'
    output:
        'results/radsex/{dataset}/signif_{min_depth}.fa'
    benchmark:
        'benchmarks/{dataset}/signif_{min_depth}.tsv'
    log:
        'logs/{dataset}/signif_{min_depth}.txt'
    conda:
        '../envs/workflow.yaml'
    resources:
        mem_mb = config['resources']['default']['mem_mb'],
        runtime_s = config['resources']['default']['runtime_s']
    params:
        options = lambda wildcards: get_options('signif', wildcards)
    shell:
        'radsex signif '
        '--markers-table {input.markers_table} '
        '--popmap {input.popmap} '
        '--output-file {output} '
        '{params.options} '
        '2> {log}'


def default_workflow_input(wildcards):
    '''
    Generate a list of all default workflow output for a single dataset.
    '''
    all_input_files = rules.distrib.output + rules.freq.output + rules.signif.output + rules.depth.output
    all_input_files += rules.depth_plot.output + rules.freq_plot.output + rules.distrib_plot.output
    output = expand(all_input_files,
                    dataset=wildcards.dataset,
                    min_depth=config['params']['general']['min_depth']),
    return output[0]


rule default_workflow:
    '''
    Aggregator rule to run the default workflow on a single dataset.
    '''
    input:
        default_workflow_input
    output:
        touch('results/radsex/{dataset}/.done')
    benchmark:
        'benchmarks/{dataset}/default_workflow.tsv'
    log:
        'logs/{dataset}/default_workflow.txt'
    resources:
        mem_mb = config['resources']['default']['mem_mb'],
        runtime_s = config['resources']['default']['runtime_s']
