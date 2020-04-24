import logging
import os
import xlwt
from utils import setup_logging, create_dir

# Main script execution
if __name__ == '__main__':

    setup_logging(snakemake)

    logging.info('Getting info from snakemake')
    # Get input file paths from snakemake
    cyprinus_carpio_file = snakemake.input.cyprinus_carpio
    gadus_morhua_file = snakemake.input.gadus_morhua
    gymnotus_carapo_file = snakemake.input.gymnotus_carapo
    plecoglossus_altivelis_file = snakemake.input.plecoglossus_altivelis
    poecilia_sphenops_file = snakemake.input.poecilia_sphenops
    tinca_tinca_file = snakemake.input.tinca_tinca
    # Get output file path from snakemale
    output_file_path = snakemake.output[0]

    # Group input files into a iterable
    files = (cyprinus_carpio_file,
             gadus_morhua_file,
             gymnotus_carapo_file,
             plecoglossus_altivelis_file,
             poecilia_sphenops_file,
             tinca_tinca_file)

    # Initialize the excel workbook
    output_file = xlwt.Workbook(encoding='utf-8')

    # Define header for each excel sheet
    HEADER = ('Marker ID', 'Number of males', 'Number of females',
              'P-value of association with sex', 'Min depth', 'Marker sequence')

    # Retrieve and format data from each file into a sheet in the workbook
    for file in files:
        # Get genus and species from file name
        genus, species = os.path.splitext(os.path.split(file)[-1])[0].split('_')
        # Format as "<Genus> <species>""
        species = genus[0].upper() + genus[1:] + ' ' + species
        # Create new sheet
        sheet = output_file.add_sheet(species)
        # Output header
        for i, field in enumerate(HEADER):
            sheet.write(0, i, field)
        # Copy marker names and sequence to excel sheet
        line_n = 1
        with open(os.path.join('data', file)) as f:
            for line in f:
                if line.startswith('>'):
                    # Retrieve marker ID from fasta header
                    fields = [x.split(':')[-1] for x in line[1:-1].split('_')]
                elif line[:-1]:
                    fields.append(line[:-1])
                    for i, field in enumerate(fields):
                        sheet.write(line_n, i, field)
                    line_n += 1

output_file.save(output_file_path)
