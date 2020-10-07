import logging
import os
from utils import setup_logging


def get_resources(benchmark_file):
    '''
    Parses a benchmark file from snakemake and returns two values: runtime (s)
    and memory usage (Mb).
    '''
    header = benchmark_file.readline()[:-1].split('\t')
    runtime_index = header.index('s')
    mem_index = header.index('max_pss')
    data = benchmark_file.readline()[:-1].split('\t')
    return data[runtime_index], data[mem_index]


# Main script execution
if __name__ == '__main__':

    setup_logging(snakemake)

    logging.info('Getting info from snakemake')
    # Get data from snakemake
    benchmarks_base_dir = snakemake.params.benchmarks_dir
    radsex_base_dir = snakemake.params.radsex_dir
    min_depth = snakemake.params.min_depth
    datasets = snakemake.params.datasets
    output_file_path = snakemake.output[0]

    logging.info('Creating output file')

    output_file = open(output_file_path, 'w')
    output_file.write('dataset\treads\tprocess_runtime\tdistrib_runtime\tsignif_runtime\tprocess_mem\tdistrib_mem\tsignif_mem\n')

    logging.info('Getting data from benchmark files')

    for dataset in datasets:
        logging.info(f'Getting data for {dataset}')
        process_file = open(os.path.join(benchmarks_base_dir, dataset, 'process.tsv'))
        distrib_file = open(os.path.join(benchmarks_base_dir, dataset, f'distrib_{min_depth}.tsv'))
        signif_file = open(os.path.join(benchmarks_base_dir, dataset, f'signif_{min_depth}.tsv'))
        depth_file = open(os.path.join(radsex_base_dir, dataset, f'depth.tsv'))
        depth_file.readline()
        reads = sum((int(line.split('\t')[2]) for line in depth_file))
        fields = [0] * 8
        fields[0] = dataset
        fields[1] = str(reads)
        fields[2], fields[5] = get_resources(process_file)
        fields[3], fields[6] = get_resources(distrib_file)
        fields[4], fields[7] = get_resources(signif_file)
        output_file.write('\t'.join(fields) + '\n')
