# Get log file path from snakemake and redirect output to log
log_file_path <- snakemake@log[[1]]
log_file <- file(log_file_path)
sink(log_file, append=TRUE)
sink(log_file, append=TRUE, type="message")

# Get other info from snakemake
input_file_path <- snakemake@input[[1]]
sex_output_file <- snakemake@output$by_sex[[1]]
individual_output_file <- snakemake@output$by_individual[[1]]

# Prevent R from automatically creating the file "Rplots.pdf"
pdf(NULL)

# Boxplot for the distribution of number of reads per sex
reads_plot <- sgtr::radsex_depth(input_file_path,
                                 groups = c("male", "female", "missing"),
                                 group_labels = c("Males", "Females", "Unknown"),
                                 group_colors = c("dodgerblue3", "red2", "grey70"),
                                 metric = "Reads",
                                 ylab = "Number of reads",
                                 output_file = sex_output_file)

# Barplot for number of reads per individual
depth_plot <- sgtr::radsex_depth(input_file_path,
                                 groups = c("male", "female", "missing"),
                                 type = "barplot",
                                 group_colors = c("dodgerblue3", "red2", "grey70"),
                                 metric = "Reads",
                                 ylab = "Number of reads",
                                 width = 16,
                                 height =10,
                                 output_file = individual_output_file)
