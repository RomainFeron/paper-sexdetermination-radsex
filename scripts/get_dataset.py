import logging
import os
import requests
import time
import xmltodict
from Bio import Entrez
from urllib.error import HTTPError
from utils import setup_logging, create_dir


def query_wrapper(tool, max_tries, sleep_between_tries, **args):
    '''
    Small wrapper function to query NCBI.
    Handles all Entrez tools, arguments are gotten from **args.
    If the query fails, will attempt again every <sleep_between_tries> seconds
    until <max_tries>.
    '''
    retry_count = 0
    while True:
        logging.info(f'Querying <{tool}>: attempt {retry_count + 1}/{max_tries}')
        try:
            handle = getattr(Entrez, tool)(**args)
            record = Entrez.read(handle)
            logging.info(f'Querying <{tool}> was successful on attempt {retry_count + 1}/{max_tries}')
            break
        except (HTTPError, RuntimeError) as error:
            logging.error(f'Querying <{tool}> failed on attempt {retry_count + 1}/{max_tries}: <{error}>')
            retry_count += 1
            if retry_count == max_tries:
                logging.error(f'Reached max attempts, cannot connect to NCBI.')
                exit(1)
        time.sleep(sleep_between_tries)
    return record


def get_dataset(bioproject, dataset, max_tries, sleep_between_tries):
    '''
    Query NCBI SRA database to retrieve information on a dataset (i.e. species)
    from a specific bioproject. Uses the esearch / efetch paradigm and parses
    the XML output of esearch to extract relevant data. The output is a list
    dictionaries, each containing the SRA accession number, name, and sex of a
    sample.
    '''

    # Format dataset string for NCBI query
    dataset = dataset.replace(' ', '+').replace('_', '+')

    # First query: esearch the SRA databse with the bioproject and the dataset
    record = query_wrapper('esearch', max_tries, sleep_between_tries,
                           db='sra',
                           term=f'{bioproject}[Bioproject]+{dataset}[Organism]',
                           usehistory='y')

    # Both query_key and web_env are variables needed to fetch data with efetch
    query_key = record['QueryKey']
    web_env = record['WebEnv']

    # Efetch output is not handled properly by BioPython's Entrez implementation,
    # so we need to construct the URL and query it manually.
    efetch_base_url = 'https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?'
    efetch_request = f'{efetch_base_url}db=sra&query_key={query_key}&WebEnv={web_env}&retmode=runinfo'

    retry_count = 0
    while True:
        logging.info(f'Querying efetch: attempt {retry_count + 1}/{max_tries}')
        response = requests.get(efetch_request)
        if response.status_code == 200:
            logging.info(f'Querying efetch was successful on attempt {retry_count + 1}/{max_tries}')
            break
        logging.error(f'Querying <efetch> failed on attempt {retry_count + 1}/{max_tries}: <{response.text}>')
        retry_count += 1
        if retry_count == max_tries:
            logging.error(f'Reached max attempts, cannot connect to NCBI.')
            exit(1)
        time.sleep(sleep_between_tries)

    # Parse the XML response
    parsed_response = xmltodict.parse(response.text)

    # The value of the field <'EXPERIMENT_PACKAGE_SET'><'EXPERIMENT_PACKAGE'> in
    # the XML output is a list of properties for each sample
    data = parsed_response['EXPERIMENT_PACKAGE_SET']['EXPERIMENT_PACKAGE']
    dataset_data = []
    for sample in data:
        # For our own data. alias contains the sample name with a RAD_ prefix
        # For medaka, alias contains the sample name
        # Most properties names have an @ prefix from the XML parsing somehow
        name = sample['EXPERIMENT']['@alias'].replace('RAD_', '')
        sex = None
        # The value of the field <SAMPLE><SAMPLE_ATTRIBUTES><SAMPLE_ATTRIBUTE>
        # in the XML output is a list of dictionaries with a weird format:
        # {TAG: <property name>, VALUE: <property value>}
        tmp = sample['SAMPLE']['SAMPLE_ATTRIBUTES']['SAMPLE_ATTRIBUTE']
        for t in tmp:
            if t['TAG'] == 'sex':  # Find sex property and store its value
                sex = t['VALUE']
        # Get SRA accession number
        accession = sample['RUN_SET']['RUN']['@accession']
        # Create dictionary for the sample
        dataset_data.append({'accession': accession,
                             'name': name,
                             'sex': sex})
    return(dataset_data)


# Main script execution
if __name__ == '__main__':

    setup_logging(snakemake)

    logging.info('Getting info from snakemake')
    # NCBI identification parameters. Using an API key raises
    # the allowed number of query per seconds from 3 to 10
    Entrez.api_key = snakemake.params.ncbi_api_key
    Entrez.email = snakemake.params.ncbi_email
    # NCBI query parameters
    max_tries = snakemake.params.max_tries
    sleep_between_tries = snakemake.params.sleep_between_tries

    # Get dataset and bioproject info
    dataset = snakemake.wildcards.dataset
    bioproject = snakemake.params.bioproject

    popmap_file_path = snakemake.output.popmap
    download_info_path = snakemake.output.download_info

    logging.info(f'Retrieving sample data for dataset <{dataset}> in bioproject <{bioproject}>')

    data = get_dataset(bioproject, dataset, max_tries, sleep_between_tries)

    logging.info(f'Found {len(data)} samples for dataset <{dataset}>')

    # Create two types of output files:
    #   - a popmap file with sample name and sex for each sample
    #   - a download info file containing the SRA accession number
    popmap_file = open(popmap_file_path, 'w')
    create_dir(download_info_path)
    for sample in data:
        popmap_file.write(f'{sample["name"]}\t{sample["sex"]}\n')
        with open(os.path.join(download_info_path, f'{sample["name"]}.accession'), 'w') as dl_file:
            dl_file.write(sample['accession'])
    logging.info(f'Successfully generated popmap file {popmap_file_path} and download files')
