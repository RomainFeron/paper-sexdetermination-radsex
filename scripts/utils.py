import logging
import os
import sys


class LoggerWriter:
    '''
    Redirect output / error streams to a logger.
    '''

    def __init__(self, logger, level):
        self.logger = logger
        self.level = level
        self._msg = ''

    def write(self, message):
        '''
        Write method to generate clean output
        '''
        self._msg = self._msg + message
        while '\n' in self._msg:
            pos = self._msg.find('\n')
            self.logger.log(self.level, f'(PYTHON: {__name__}.py)  ' + self._msg[:-1])
            self._msg = self._msg[pos + 1:]

    def flush(self):
        '''
        Dummy flush method
        '''
        pass


def setup_logging(snakemake):
    '''
    Setup logging in a script called by Snakemake:
      - setup a basic logger to stderr
      - get log info from snakemake object
      - setup logging to the log file obtained from snakemake obejct
      - setup logging formatting
    '''

    # Setup logging
    logging.basicConfig(level=logging.INFO,
                        format='[%(asctime)s]::%(levelname)s  %(message)s',
                        datefmt='%Y.%m.%d - %H:%M:%S')

    # Check if script was called by snakemake, exit with exception otherwise
    try:
        snakemake
    except NameError:
        logging.error('This script is meant to be called by snakemake.')
        raise

    # Reset logging handler
    for handler in logging.root.handlers[:]:
        logging.root.removeHandler(handler)

    # Setup logging again with output file
    logging.basicConfig(filename=snakemake.log[0],
                        level=logging.INFO,
                        format='[%(asctime)s]::%(levelname)s  %(message)s',
                        datefmt='%Y.%m.%d - %H:%M:%S')

    # Redirect stdout and stderr to logger object to have all output in log file
    logger = logging.getLogger('logger')
    sys.stdout = LoggerWriter(logger, logging.INFO)
    sys.stderr = LoggerWriter(logger, logging.ERROR)


def create_dir(dir_path):
    '''
    Check if a directory exists and creates it if it does not.
    '''
    if not os.path.isdir(dir_path):
        os.mkdir(dir_path)


def remove_file_if_exists(file_path):
    '''
    Check if a file exists and deletes it if it exists.
    '''
    if os.path.exists(file_path):
        os.remove(file_path)
