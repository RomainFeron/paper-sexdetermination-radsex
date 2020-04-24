# Get log file path from snakemake and redirect output to log
log_file_path <- snakemake@log[[1]]
log_file <- file(log_file_path)
sink(log_file, append=TRUE)
sink(log_file, append=TRUE, type="message")

# Get other info from snakemake
subset_file_path <- snakemake@input$subset[[1]]
popmap_file_path <- snakemake@input$popmap[[1]]
output_file_path <- snakemake@output[[1]]

# Prevent R from automatically creating the file "Rplots.pdf"
pdf(NULL)

# Clustered heatmap of depth of each marker in each individual
p <- sgtr:: radsex_marker_depths(input_file,
                                 output_file = output_file_path,
                                 group_info_file = popmap_file_path,
                                 group_labels = c("Males", "Females"),
                                 label_colors = c("dodgerblue3", "red3"))
