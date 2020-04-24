import yaml
from collections import defaultdict

COMMANDS = ['depth', 'distrib', 'freq', 'map', 'process', 'signif', 'subset']


def get_dataset_info():
    '''
    '''
    info_file = open(config['info_file'])
    header = info_file.readline().rstrip('\n').split('\t')
    config['info'] = {}
    for line in info_file:
        if len(line) > 1:
            fields = dict(zip(header, line.rstrip('\n').split('\t')))
            config['info'][fields['dataset']] = {'bioproject': fields['bioproject'],
                                                 'genome': fields['genome']}


def populate_command_config(command):
    '''
    '''
    with open(config['default_settings_file']) as settings_file:
        defaults = yaml.safe_load(settings_file)
    if defaults[command]:
        for setting, value in defaults[command].items():
            if command in config['params'] and setting in config['params'][command]:  # Second: check the command-specific section of the config file
                value = config['params'][command][setting]
            elif setting in config['params']['general']:  # Last: check the general section of the config file
                value = config['params']['general'][setting]
            config['commands'][command][setting] = value


def get_options(command, wildcards):
    '''
    '''
    options = []
    for option, value in config['commands'][command].items():
        if isinstance(value, bool):
            if value:
                options.append(f'--{option}')
        elif isinstance(value, list):
            value = ",".join(value)
            options.append(f'--{option} {value}')
        elif isinstance(value, dict):
            value = ",".join(value.values())
            options.append(f'--{option} {value}')
        else:
            options.append(f'--{option} {value}')
    return ' '.join(options)


def init_workflow():
    '''
    '''
    get_dataset_info()
    config['commands'] = defaultdict(dict)
    for command in COMMANDS:
        populate_command_config(command)
