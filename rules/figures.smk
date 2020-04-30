
rule figure_3:
    '''
    Generate figure 3 from the radsex paper, i.e. performance comparison
    between stacks and radsex.
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
    Generate figure 4 from the radsex paper, i.e. results of the reanalysis
    of the Oryzias latipes dataset.
    '''
    input:
        distrib = 'results/radsex/oryzias_latipes/distrib_10.tsv',
        subset = rules.medaka_subset.output,
        map = rules.medaka_map.output,
        popmap = 'results/radsex/oryzias_latipes/popmap.tsv',
        chromosomes_file = rules.medaka_chromosomes_file.output
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
    Generate figure 5 from the radsex paper, i.e. radsex distrib tile plots
    for all datasets with markers significantly associated with sex.
    '''
    input:
        cyprinus_carpio = 'results/radsex/cyprinus_carpio/distrib_10.tsv',
        gadus_morhua = 'results/radsex/gadus_morhua/distrib_10.tsv',
        gymnotus_carapo = 'results/radsex/gymnotus_carapo/distrib_10.tsv',
        plecoglossus_altivelis = 'results/radsex/plecoglossus_altivelis/distrib_10.tsv',
        poecilia_sphenops = 'results/radsex/poecilia_sphenops/distrib_10.tsv',
        tinca_tinca = 'results/radsex/tinca_tinca/distrib_10.tsv'
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
    Generate figure 6 from the radsex paper, i.e. results of the analysis
    of the Gadus morhua dataset.
    '''
    input:
        subset = rules.gadus_morhua_subset.output,
        map = rules.gadus_morhua_map.output,
        popmap = 'results/radsex/gadus_morhua/popmap.tsv'
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
    Generate figure 5 from the radsex paper, i.e. median marker depth in an
    individual for each analyzed dataset.
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
    Generate figure 5 from the radsex paper, i.e. radsex distrib tile plots
    for all datasets without markers significantly associated with sex.
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
