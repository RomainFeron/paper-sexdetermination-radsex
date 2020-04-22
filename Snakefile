configfile: 'config.yaml'

include: 'rules/config.smk'
init_workflow()

include: 'rules/data.smk'
include: 'rules/radsex.smk'

rule all:
    input:
        default = expand(rules.default_workflow.output, dataset=config['info'].keys())
