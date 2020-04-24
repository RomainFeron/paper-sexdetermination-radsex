
rule supp_table_4:
    '''
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
    '''
    input:
        cyprinus_carpio = 'results/cyprinus_carpio/cyprinus_carpio.fa'
        gadus_morhua = 'results/gadus_morhua/gadus_morhua.fa'
        gymnotus_carapo = 'results/gymnotus_carapo/gymnotus_carapo.fa'
        plecoglossus_altivelis = 'results/plecoglossus_altivelis/plecoglossus_altivelis.fa'
        poecilia_sphenops = 'results/poecilia_sphenops/poecilia_sphenops.fa'
        tinca_tinca = 'results/tinca_tinca/tinca_tinca.fa'
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
