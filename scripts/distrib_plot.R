# Get log file path from snakemake and redirect output to log
log_file_path <- snakemake@log[[1]]
log_file <- file(log_file_path)
sink(log_file, append=TRUE)
sink(log_file, append=TRUE, type="message")

# Get other info from snakemake
input_file_path <- snakemake@input[[1]]
output_file_path <- snakemake@output[[1]]

# Prevent R from automatically creating the file "Rplots.pdf"
pdf(NULL)

# Distribution of markers between males and females
distrib_plot <- sgtr::radsex_distrib(input_file_path,
                                     groups = c("male", "female"),
                                     group_labels = c("Males", "Females"),
                                     output_file = output_file_path)
