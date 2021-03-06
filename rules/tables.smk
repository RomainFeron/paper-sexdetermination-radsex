
rule supp_table_4:
    '''
    Generate supplementary table 4 from the radsex paper, i.e. runtime and
    peak memory usage on each dataset for radsex and stacks.
    '''
    output:
        'results/tables/supp_table_4.tsv'
    benchmark:
        'benchmarks/tables/supp_table_4.tsv'
    log:
        'logs/tables/supp_table_4.txt'
    conda:
        '../envs/workflow.yaml'
    script:
        '../scripts/tables/supp_table_4.py'


rule supp_table_6:
    '''
    Generate supplementary table 6 from the radsex paper, i.e. an excel file
    containing all markers significantly associated with sex for all datasets.
    '''
    input:
        cyprinus_carpio = 'results/radsex/cyprinus_carpio/signif_10.fa',
        gadus_morhua = 'results/radsex/gadus_morhua/signif_10.fa',
        gymnotus_carapo = 'results/radsex/gymnotus_carapo/signif_10.fa',
        plecoglossus_altivelis = 'results/radsex/plecoglossus_altivelis/signif_10.fa',
        poecilia_sphenops = 'results/radsex/poecilia_sphenops/signif_10.fa',
        tinca_tinca = 'results/radsex/tinca_tinca/signif_10.fa'
    output:
        'results/tables/supp_table_6.xlsx'
    benchmark:
        'benchmarks/tables/supp_table_6.tsv'
    log:
        'logs/tables/supp_table_6.txt'
    conda:
        '../envs/workflow.yaml'
    script:
        '../scripts/tables/supp_table_6.py'
