rule medaka_subset:
    '''
    Extract male-biased markers for clustering.
    '''
    input:
        markers_table = 'results/radsex/oryzias_latipes/markers_table.tsv',
        popmap = 'results/radsex/oryzias_latipes/popmap.tsv'
    output:
        'results/radsex/oryzias_latipes/subset_male_markers.tsv'
    benchmark:
        'benchmarks/oryzias_latipes/medaka_subset.tsv'
    log:
        'logs/oryzias_latipes/medaka_subset.txt'
    conda:
        '../envs/workflow.yaml'
    params:
        min_depth = 10,
        groups = 'male,female',
        min_group1 = 20,
        max_group2 = 0
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


rule medaka_subset_plot:
    '''
    Cluster male-biased markers and display the results in a heatmap of 
    individual marker depths.
    '''
    input:
        subset = rules.medaka_subset.output,
        popmap = 'results/radsex/oryzias_latipes/popmap.tsv'
    output:
        'results/radsex/oryzias_latipes/markers_clustering.png'
    benchmark:
        'benchmarks/oryzias_latipes/medaka_subset_plot.tsv'
    log:
        'logs/oryzias_latipes/medaka_subset_plot.txt'
    conda:
        '../envs/workflow.yaml'
    script:
        '../scripts/medaka/subset_plot.R'


rule medaka_update_popmap:
    '''
    Update the groups info file for the two individuals identified as
    sex-reversed females. The identifier for these two individuals is given
    in the config file field 'medaka_male_outliers'
    '''
    input:
        'results/radsex/oryzias_latipes/popmap.tsv'
    output:
        'results/radsex/oryzias_latipes/popmap_updated.tsv'
    benchmark:
        'benchmarks/oryzias_latipes/medaka_update_popmap.tsv'
    log:
        'logs/oryzias_latipes/medaka_update_popmap.txt'
    conda:
        '../envs/workflow.yaml'
    shell:
        'echo placeholder'


rule medaka_update_distrib:
    '''
    Re-run radsex distrib with the updated popmap.
    '''
    input:
        markers_table = 'results/radsex/oryzias_latipes/markers_table.tsv',
        popmap = rules.medaka_update_popmap.output
    output:
        'results/radsex/oryzias_latipes/distrib_10_updated.tsv'
    benchmark:
        'benchmarks/oryzias_latipes/medaka_update_distrib.tsv'
    log:
        'logs/oryzias_latipes/medaka_update_distrib.txt'
    conda:
        '../envs/workflow.yaml'
    params:
        min_depth = 10,
        groups = 'male,female'
    shell:
        'radsex distrib '
        '--markers-table {input.markers_table} '
        '--popmap {input.popmap} '
        '--output-file {output} '
        '--min-depth {params.min_depth} '
        '--groups {params.groups} '
        '2> {log}'


rule medaka_distrib_plot:
    '''
    Generate a tile plot of distribution of markers between males and females
    from the results of radsex distrib with the updated popmap.
    '''
    input:
        rules.medaka_update_distrib.output
    output:
        'results/radsex/oryzias_latipes/distrib_10_updated.png'
    benchmark:
        'benchmarks/oryzias_latipes/medaka_distrib_plot.tsv'
    log:
        'logs/oryzias_latipes/medaka_distrib_plot.txt'
    conda:
        '../envs/workflow.yaml'
    script:
        '../scripts/distrib_plot.R'


rule medaka_update_signif:
    '''
    Extract markers significantly associated with sex with the updated popmap.
    '''
    input:
        markers_table = 'results/radsex/oryzias_latipes/markers_table.tsv',
        popmap = rules.medaka_update_popmap.output
    output:
        'results/radsex/oryzias_latipes/signif_10_updated.tsv'
    benchmark:
        'benchmarks/oryzias_latipes/medaka_update_signif.tsv'
    log:
        'logs/oryzias_latipes/medaka_update_signif.txt'
    conda:
        '../envs/workflow.yaml'
    params:
        min_depth = 10,
        groups = 'male,female'
    shell:
        'radsex signif '
        '--markers-table {input.markers_table} '
        '--popmap {input.popmap} '
        '--output-file {output} '
        '--min-depth {params.min_depth} '
        '--groups {params.groups} '
        '--output-fasta '
        '2> {log}'


rule medaka_map:
    '''
    Align markers to the genome of Oryzias latipes using the updated popmap.
    '''
    input:
        markers_table = 'results/radsex/oryzias_latipes/markers_table.tsv',
        popmap = rules.medaka_update_popmap.output,
        genome = 'results/radsex/oryzias_latipes/genome/genome.fa'
    output:
        'results/radsex/oryzias_latipes/map.tsv'
    benchmark:
        'benchmarks/oryzias_latipes/medaka_map.tsv'
    log:
        'logs/oryzias_latipes/medaka_map.txt'
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


rule medaka_map_plot:
    '''
    Generate circos and manhattan plots from the results of radsex map for the
    Oryzias latipes dataset
    '''
    input:
        rules.medaka_map.output
    output:
        circos = 'results/radsex/oryzias_latipes/map_circos.png',
        manhattan = 'results/radsex/oryzias_latipes/map_manhattan.png'
    benchmark:
        'benchmarks/oryzias_latipes/medaka_map_plot.tsv'
    log:
        'logs/oryzias_latipes/medaka_map_plot.txt'
    conda:
        '../envs/workflow.yaml'
    script:
        '../scripts/medaka/map_plot.R'
