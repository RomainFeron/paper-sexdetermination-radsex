

rule figure_3:
    '''
    '''
    input:
        distrib = 'results/oryzias_latipes/distrib_10.tsv',
        subset = rules.medaka_subset.output,
        map = rules.medaka_map.output,
        popmap = 'results/oryzias_latipes/popmap.tsv'
    output:
        png = 'results/figures/figure_3.png',
        svg = 'results/figures/figure_3.svg'
    benchmark:
        'benchmarks/figures/figure_3.tsv'
    log:
        'logs/figures/figure_3.txt'
    conda:
        '../envs/workflow.yaml'
    script:
        '../scripts/figures/figure_3.R'
