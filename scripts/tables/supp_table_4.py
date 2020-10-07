import logging
import os
from utils import setup_logging


def get_resources(benchmark_file):
    '''
    Parses a benchmark file from snakemake and returns two values: runtime (s)
    and memory usage (Mb).
    '''
    header = benchmark_file.readline()[:-1].split('\t')
    runtime_index = header.find('s')
    mem_index = header.find('max_pss')
    data = benchmark_file.readline()[:-1].split('\t')
    return data[runtime_index], data[mem_index]


# Main script execution
if __name__ == '__main__':

    setup_logging(snakemake)

    logging.info('Getting info from snakemake')
    # Get data from snakemake
    benchmarks_base_dir = snakemake.params.benchmarks_dir
    min_depth = snakemake.params.min_depth
    datasets = snakemake.params.datasets
    output_file_path = snakemake.output

    output_file = open(output_file_path, 'w')
    output_file.write('dataset\tprocess_runtime\tdistrib_runtime\tsignif_runtime\tprocess_mem\tdistrib_mem\tsignif_mem\n')

    for dataset in datasets:
        process_file_path = os.path.join(benchmarks_base_dir, dataset, 'process.tsv')
        distrib_file_path = os.path.join(benchmarks_base_dir, dataset, f'distrib_{min_depth}.tsv')
        signif_file_path = os.path.join(benchmarks_base_dir, dataset, f'signif_{min_depth}.tsv')
        fields = [0] * 7
        fields[0] = dataset
        fields[1], fields[4] = get_resources(process_file_path)
        fields[2], fields[5] = get_resources(distrib_file_path)
        fields[3], fields[6] = get_resources(signif_file_path)
        output_file.write('\t'.join(fields) + '\n')
