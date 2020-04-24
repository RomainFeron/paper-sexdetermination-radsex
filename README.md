# RADSex paper analyses workflow

Complete workflow to perform analyses and generate figures from the RADSex paper (https://www.biorxiv.org/content/10.1101/2020.04.22.054866v1).

The workflow is still under development and not functional yet.

## Installing the workflow

The workflow requires Snakemake (>= 5.8) and makes use of Conda to handle software dependencies. If you do not have Snakemake and Conda setup, you can follow my quick setup guide available [here](https://gist.github.com/RomainFeron/da9df092656dd799885b612fedc9eccd).

Once Conda and Snakemake are setup, you can simply clone the workflow repository:

```bash
# You can use ssh to clone the repository if you set it up
git clone https://github.com/RomainFeron/paper-sexdetermination-radsex.git
```

## Running the workflow

To run the workflow, first navigate to the workflow's directory:

```bash
cd paper-sexdetermination-radsex
```

If you're using a Conda environment to run Snakemake (which is preferred), make sure it's activated:

```bash
conda activate snakemake
```

Then, simply run snakemake in the directory (you can adjust the number of cores allocated to Snakemake with `-j`):

```bash
# Run Snakemake with 8 cores and using Conda to handle dependencies
snakemake -j8 --use-conda
```

## Quick workflow description

This workflow implements all the analyses presented in the RADSex paper and generates figures for each analyses as well as most figures included in the paper. Data is defined in `data/info.tsv`; reads are downloaded from the NCBI SRA repository and genomes are downloaded from provided links. All parameters are defined in `config.yaml`.

Briefly, this workflow performs the following steps:

- Get reads and sex information from NCBI, generate a group info file for each dataset.
- Generate a table of marker depths for each dataset.
- Run `distrib`, `signif`, `freq`, and `depth` on each dataset with a minimum depth (`--min-depth`) of 1, 2, 5, and 10.
- Generate standard plots from the results of these analyses.
- Run `map` and `subset` for datasets where it's possible / required.
- Generate all figures and tables that can be automatically generated.
