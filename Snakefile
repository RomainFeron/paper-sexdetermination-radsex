configfile: 'config.yaml'

include: 'rules/config.smk'

# Load the dataset info file and initialize radsex settings.
init_workflow()

include: 'rules/data.smk'
include: 'rules/default_workflow.smk'
include: 'rules/medaka.smk'
include: 'rules/gadus_morhua.smk'
include: 'rules/tables.smk'
include: 'rules/figures.smk'


def all_input(wildcards):
    '''
    Generate a list of all output files for the workflow.
    '''
    # Default workflow output files for each dataset.
    default_workflow = expand(rules.default_workflow.output,
                              dataset=config['info'].keys())
    # Oryzias latipes analyses output files
    medaka = [*rules.medaka_subset_plot.output, *rules.medaka_map_plot.output,
              *rules.medaka_distrib_plot.output, *rules.medaka_update_signif.output]
    medaka = [*rules.medaka_subset_plot.output, *rules.medaka_map_plot.output,
              *rules.medaka_distrib_plot.output, *rules.medaka_update_signif.output]
    # Gadus morhua analyses output files
    cod = [*rules.gadus_morhua_subset_plot.output, *rules.gadus_morhua_map_plot.output]
    # RADSex paper figures
    figures = [*rules.figure_3.output, *rules.figure_4.output,
               *rules.figure_5.output, *rules.figure_6.output,
               *rules.supp_figure_2.output, *rules.supp_figure_3.output]
    # RADSex paper tables
    tables = [*rules.supp_table_4.output, *rules.supp_table_6.output]
    # Gather everything
    all_input = default_workflow + figures + tables + medaka + cod
    return all_input


rule all:
    '''
    Aggregator rule to generate all output files for the workflow.
    '''
    input:
        all_input
