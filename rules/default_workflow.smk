rule process:
    '''
    '''
    input:
        rules.download_dataset.output
    output:
        'results/{dataset}/markers_table.tsv'
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
        min_depth = config['params']['process']['min-depth'],
        samples_dir = lambda wildcards: f'results/{wildcards.dataset}/samples'
    shell:
        'radsex process '
        '--threads {threads} '
        '--input-dir {input} '
        '--output-file {output} '
        '--min-depth {params.min_depth} '
        '2> {log}'


rule depth:
    '''
    '''
    input:
        markers_table = rules.process.output,
        popmap = 'results/{dataset}/popmap.tsv'
    output:
        'results/{dataset}/depth.tsv'
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
    '''
    input:
        rules.depth.output
    output:
        by_individual = 'results/{dataset}/depth_by_individual.png',
        by_sex = 'results/{dataset}/depth_by_sex.png'
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
    '''
    input:
        markers_table = rules.process.output,
        popmap = 'results/{dataset}/popmap.tsv'
    output:
        'results/{dataset}/distrib_{min_depth}.tsv'
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
    '''
    input:
        rules.distrib.output
    output:
        'results/{dataset}/distrib_{min_depth}.png',
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
    '''
    input:
        markers_table = rules.process.output
    output:
        'results/{dataset}/freq_{min_depth}.tsv'
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
    '''
    input:
        rules.freq.output
    output:
        'results/{dataset}/freq_{min_depth}.png',
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
    '''
    input:
        markers_table = rules.process.output,
        popmap = 'results/{dataset}/popmap.tsv'
    output:
        'results/{dataset}/signif_{min_depth}.tsv'
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
    '''
    all_input_files = rules.distrib.output + rules.freq.output + rules.signif.output + rules.depth.output
    all_input_files += rules.depth_plot.output + rules.distrib_plot.output + rules.freq_plot.output
    output = expand(all_input_files,
                    dataset=wildcards.dataset,
                    min_depth=config['params']['general']['min_depth']),
    return output[0]


rule default_workflow:
    '''
    '''
    input:
        default_workflow_input
    output:
        'results/{dataset}/.done'
    benchmark:
        'benchmarks/{dataset}/default_workflow.tsv'
    log:
        'logs/{dataset}/default_workflow.txt'
    resources:
        mem_mb = config['resources']['default']['mem_mb'],
        runtime_s = config['resources']['default']['runtime_s']
