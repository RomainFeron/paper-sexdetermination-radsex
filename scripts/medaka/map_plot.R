# Get log file path from snakemake and redirect output to log
log_file_path <- snakemake@log[[1]]
log_file <- file(log_file_path)
sink(log_file, append=TRUE)
sink(log_file, append=TRUE, type="message")

# Get other info from snakemake
input_file_path <- snakemake@input[[1]]
circos_file_path <- snakemake@output$circos[[1]]
manhattan_file_path <- snakemake@output$manhattan[[1]]

# Prevent R from automatically creating the file "Rplots.pdf"
pdf(NULL)

# Clustered heatmap of depth of each marker in each individual
p <- sgtr:: radsex_map_circos(input_file_path,
                              output_file = circos_file_path)

p <- sgtr:: radsex_map_manhattan(input_file_path,
                                 output_file = manhattan_file_path)
