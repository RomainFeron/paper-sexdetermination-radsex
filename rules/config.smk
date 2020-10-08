import yaml
from collections import defaultdict

# List of radsex commands
COMMANDS = ['depth', 'distrib', 'freq', 'map', 'process', 'signif', 'subset']


def get_dataset_info():
    '''
    Parse the file given by the field 'info_file' in the config file to get
    bioproject and genome file URL for each dataset.
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
    Initialize settings for a radsex command in the config dictionary.
    First look for setting value in the field 'params:<command>', then in the field
    'params:<general>' from the config file, then in the default settings file
    defined in the field 'default_settings_file' from the config file.
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
    Get value for all settings for a radsex command. Setting values were
    initialized in the populate_command_config() function.
    '''
    options = []
    option_values = config['commands'][command]
    if hasattr(wildcards, 'min_depth'):
        option_values['min-depth'] = wildcards.min_depth
    for option, value in option_values.items():
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
    Run functions to get information on the datasets and initialize settings
    for radsex commands.
    '''
    get_dataset_info()
    config['commands'] = defaultdict(dict)
    for command in COMMANDS:
        populate_command_config(command)
