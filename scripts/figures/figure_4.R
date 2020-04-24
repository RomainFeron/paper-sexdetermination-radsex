library(sgtr)
library(gtable)
library(gridExtra)
library(cowplot)

# Get log file path from snakemake and redirect output to log
log_file_path <- snakemake@log[[1]]
log_file <- file(log_file_path)
sink(log_file, append=TRUE)
sink(log_file, append=TRUE, type="message")

# Get other info from snakemake
distrib_file_path <- snakemake@input$distrib[[1]]
subset_file_path <- snakemake@input$subset[[1]]
map_file_path <- snakemake@input$map[[1]]
popmap_file_path <- snakemake@input$popmap[[1]]
png_output_file <- snakemake@output$png[[1]]
svg_output_file <- snakemake@output$svg[[1]]

# Prevent R from automatically creating the file "Rplots.pdf"
pdf(NULL)

# Generate distrib plot
distrib <- sgtr::radsex_distrib(input_file_path,
                                groups = c("male", "female"),
                                group_labels = c("Males", "Females"))

# Generate clustering plot
clutering <- sgtr:: radsex_marker_depths(input_file,
                                         group_info_file = popmap_file_path,
                                         group_labels = c("Males", "Females"),
                                         label_colors = c("dodgerblue3", "red3"),
                                         clustering_method = 'ward.D2',
                                         distance_method = 'binary')

# Generate manhattan plot
manhattan <- sgtr:: radsex_map_manhattan(input_file)

# Generate alignment metrics plot for LG1
lg1 <- sgtr:: radsex_map_region(input_file,
                                region = "1")

# Combine legend from distrib and clustering plots
distrib_legend = get_legend(distrib + theme(legend.margin = margin(5, 0, 5, 0)))
clustering_legend = get_legend(clustering)
top_row_legends = plot_grid(distrib_legend, clustering_legend, ncol = 1) + theme(plot.margin = margin(5, 5, 40, 5))
clustering = gtable_remove_grobs(clustering, "guide-box")
clustering = gtable_squash_cols(clustering, c(9, 10, 11))

# Combine manhattan and lg1 plots for bottom row
bottom_row = plot_grid(manhattan,
                       lg1$association + theme(axis.title.x = element_text(face="bold"),
                                                    axis.text = element_text(face="bold")),
                       ncol=2, label_size = 24, hjust=0.5, label_x=c(0.025, 0.025),
                       labels = c("C", "D"))

# Combine distrib and clustering plots for top row
top_row = plot_grid(distrib + theme(legend.position = "none"), top_row_legends, clustering,
                    labels=c("A", "", "B"), ncol=3, rel_widths = c(1.05, 0.15, 0.95),
                    label_size = 24, hjust=0.5, label_x=c(0.025, 0, 0.025))

# Combine top and bottom rows in final figure
combined = plot_grid(top_row, bottom_row, ncol=1, rel_heights = c(1, 0.6))

# Save figure to png and svg
ggsave(filename=png_output_file, plot = combined, width=16, height=12)
ggsave(filename=svg_output_file, plot = combined, width=16, height=12, dpi=400)

