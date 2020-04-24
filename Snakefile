configfile: 'config.yaml'

include: 'rules/config.smk'
init_workflow()
include: 'rules/data.smk'
include: 'rules/default_workflow.smk'
include: 'rules/medaka.smk'
include: 'rules/gadus_morhua.smk'
include: 'rules/figures.smk'
include: 'rules/tables.smk'


def all_input(wildcards):
    '''
    '''
    default_workflow = expand(rules.default_workflow.output,
                              dataset=config['info'].keys())
    figures = [*rules.figure_3.output, *rules.figure_4.output,
               *rules.figure_5.output, *rules.figure_6.output,
               *rules.supp_figure_2.output, *rules.supp_figure_3.output]
    tables = [*rules.supp_table_4.output, *rules.supp_table_6.output]
    all_input = default_workflow + figures + tables
    return all_input


rule all:
    input:
        all_input
