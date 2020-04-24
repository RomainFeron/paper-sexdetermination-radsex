
rule figure_3:
    '''
    '''
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


rule figure_4:
    '''
    '''
    input:
        distrib = 'results/oryzias_latipes/distrib_10.tsv',
        subset = rules.medaka_subset.output,
        map = rules.medaka_map.output,
        popmap = 'results/oryzias_latipes/popmap.tsv'
    output:
        png = 'results/figures/figure_4.png',
        svg = 'results/figures/figure_4.svg'
    benchmark:
        'benchmarks/figures/figure_4.tsv'
    log:
        'logs/figures/figure_4.txt'
    conda:
        '../envs/workflow.yaml'
    script:
        '../scripts/figures/figure_4.R'


rule figure_5:
    '''
    '''
    input:
        cyprinus_carpio = 'results/cyprinus_carpio/distrib_10.tsv',
        gadus_morhua = 'results/gadus_morhua/distrib_10.tsv',
        gymnotus_carapo = 'results/gymnotus_carapo/distrib_10.tsv',
        plecoglossus_altivelis = 'results/plecoglossus_altivelis/distrib_10.tsv',
        poecilia_sphenops = 'results/poecilia_sphenops/distrib_10.tsv',
        tinca_tinca = 'results/tinca_tinca/distrib_10.tsv'
    output:
        png = 'results/figures/figure_5.png',
        svg = 'results/figures/figure_5.svg'
    benchmark:
        'benchmarks/figures/figure_5.tsv'
    log:
        'logs/figures/figure_5.txt'
    conda:
        '../envs/workflow.yaml'
    script:
        '../scripts/figures/figure_5.R'


rule figure_6:
    '''
    '''
    input:
        subset = rules.gadus_morhua_subset.output,
        map = rules.gadus_morhua_map.output,
        popmap = 'results/gadus_morhua/popmap.tsv'
    output:
        png = 'results/figures/figure_6.png',
        svg = 'results/figures/figure_6.svg'
    benchmark:
        'benchmarks/figures/figure_6.tsv'
    log:
        'logs/figures/figure_6.txt'
    conda:
        '../envs/workflow.yaml'
    script:
        '../scripts/figures/figure_6.R'


rule supp_figure_2:
    '''
    '''
    output:
        png = 'results/figures/supp_figure_2.png',
        svg = 'results/figures/supp_figure_2.svg'
    benchmark:
        'benchmarks/figures/supp_figure_2.tsv'
    log:
        'logs/figures/supp_figure_2.txt'
    conda:
        '../envs/workflow.yaml'
    script:
        '../scripts/figures/supp_figure_2.R'


rule supp_figure_3:
    '''
    '''
    output:
        png = 'results/figures/supp_figure_3.png',
        svg = 'results/figures/supp_figure_3.svg'
    benchmark:
        'benchmarks/figures/supp_figure_3.tsv'
    log:
        'logs/figures/supp_figure_3.txt'
    conda:
        '../envs/workflow.yaml'
    script:
        '../scripts/figures/supp_figure_3.R'
