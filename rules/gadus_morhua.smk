rule gadus_morhua_subset:
    '''
    '''
    input:
        markers_table = 'results/radsex/gadus_morhua/markers_table.tsv',
        popmap = 'results/radsex/gadus_morhua/popmap.tsv'
    output:
        'results/radsex/gadus_morhua/subset_male_markers.tsv'
    benchmark:
        'benchmarks/gadus_morhua/gadus_morhua_subset.tsv'
    log:
        'logs/gadus_morhua/gadus_morhua_subset.txt'
    conda:
        '../envs/workflow.yaml'
    params:
        min_depth = 10,
        groups = 'male,female',
        min_group1 = 20,
        max_group2 = 2
    shell:
        'radsex subset '
        '--markers-table {input.markers_table} '
        '--popmap {input.popmap} '
        '--output-file {output} '
        '--min-depth {params.min_depth} '
        '--groups {params.groups} '
        '--min-group1 {params.min_group1} '
        '--max-group2 {params.max_group2} '
        '2> {log}'


rule gadus_morhua_subset_plot:
    '''
    '''
    input:
        subset = rules.gadus_morhua_subset.output,
        popmap = 'results/radsex/gadus_morhua/popmap.tsv'
    output:
        'results/radsex/gadus_morhua/markers_clustering.png'
    benchmark:
        'benchmarks/gadus_morhua/gadus_morhua_subset_plot.tsv'
    log:
        'logs/gadus_morhua/gadus_morhua_subset_plot.txt'
    conda:
        '../envs/workflow.yaml'
    script:
        '../scripts/gadus_morhua/subset_plot.R'


rule gadus_morhua_map:
    '''
    '''
    input:
        markers_table = 'results/radsex/gadus_morhua/markers_table.tsv',
        popmap = 'results/radsex/gadus_morhua/popmap.tsv',
        genome = 'results/radsex/gadus_morhua/genome/genome.fa'
    output:
        'results/radsex/gadus_morhua/map.tsv'
    benchmark:
        'benchmarks/gadus_morhua/gadus_morhua_map.tsv'
    log:
        'logs/gadus_morhua/gadus_morhua_map.txt'
    conda:
        '../envs/workflow.yaml'
    params:
        min_depth = 10,
        groups = 'male,female'
    shell:
        'radsex map '
        '--markers-file {input.markers_table} '
        '--popmap {input.popmap} '
        '--genome-file {input.genome} '
        '--output-file {output} '
        '--min-depth {params.min_depth} '
        '--groups {params.groups} '
        '2> {log}'


rule gadus_morhua_map_plot:
    '''
    '''
    input:
        rules.gadus_morhua_map.output
    output:
        circos = 'results/radsex/gadus_morhua/map_circos.png',
        manhattan = 'results/radsex/gadus_morhua/map_manhattan.png'
    benchmark:
        'benchmarks/gadus_morhua/gadus_morhua_map_plot.tsv'
    log:
        'logs/gadus_morhua/gadus_morhua_map_plot.txt'
    conda:
        '../envs/workflow.yaml'
    script:
        '../scripts/gadus_morhua/map_plot.R'
