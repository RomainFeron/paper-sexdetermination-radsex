# Get log file path from snakemake and redirect output to log
log_file_path <- snakemake@log[[1]]
log_file <- file(log_file_path)
sink(log_file, append = TRUE)
sink(log_file, append = TRUE, type = "message")

# Get other info from snakemake
distrib_file_path <- snakemake@input$distrib[[1]]
subset_file_path <- snakemake@input$subset[[1]]
map_file_path <- snakemake@input$map[[1]]
popmap_file_path <- snakemake@input$popmap[[1]]
chromosomes_file_path <- snakemake@input$chromosomes_file[[1]]
png_output_file <- snakemake@output$png[[1]]
svg_output_file <- snakemake@output$svg[[1]]

# Prevent R from automatically creating the file "Rplots.pdf"
pdf(NULL)

# Generate distrib plot
distrib <- sgtr::radsex_distrib(distrib_file_path,
                                groups = c("male", "female"),
                                group_labels = c("Males", "Females"))

# Generate clustering plot
clustering <- sgtr::radsex_marker_depths(subset_file_path,
                                         group_info_file = popmap_file_path,
                                         group_labels = c("Males", "Females"),
                                         label_colors = c("dodgerblue3", "red3"),
                                         clustering_method = 'ward.D2',
                                         distance_method = 'binary')

# Generate manhattan plot
manhattan <- sgtr::radsex_map_manhattan(map_file_path,
                                        chromosomes_file = chromosomes_file_path,
                                        chromosomes_as_numbers = TRUE)[[1]]

# Generate alignment metrics plot for LG1
lg1 <- sgtr::radsex_map_region(map_file_path,
                               chromosomes_file = chromosomes_file_path,
                               region = "Ola1")[[1]]

# Add rectangles to highlight genomic regions enriched in sex-biased markers
ymax <- ggplot2::ggplot_build(lg1)$layout$panel_scales_y[[1]]$range$range[2]

lg1 <- lg1 + ggplot2::geom_rect(data = data.frame(xmin = c(17000000), xmax = c(23000000), ymin = c(0), ymax = c(ymax)),
                                ggplot2::aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
                                color = "green4", fill = "green3",
                                alpha = 0.3)

lg1 <- lg1 + ggplot2::geom_rect(data = data.frame(xmin = c(14700000), xmax = c(17000000), ymin = c(0), ymax = c(ymax)),
                                ggplot2::aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
                                color = "purple4", fill = "purple4",
                                alpha = 0.3)

lg1 <- lg1 + ggplot2::geom_rect(data = data.frame(xmin = c(23000000), xmax = c(31900000), ymin = c(0), ymax = c(ymax)),
                                ggplot2::aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
                                color = "purple4", fill = "purple4",
                                alpha = 0.3)

# Combine legend from distrib and clustering plots
distrib_legend = cowplot::get_legend(distrib + ggplot2::theme(legend.margin = ggplot2::margin(5, 0, 5, 0)))
clustering_legend = cowplot::get_legend(clustering)
top_row_legends = cowplot::plot_grid(distrib_legend, clustering_legend, ncol =  1) + ggplot2::theme(plot.margin =  ggplot2::margin(5, 5, 40, 5))
clustering = cowplot::gtable_remove_grobs(clustering, "guide-box")
clustering = cowplot::gtable_squash_cols(clustering, c(9, 10, 11))

# Combine manhattan and lg1 plots for bottom row
bottom_row = cowplot::plot_grid(manhattan,
                                lg1 + ggplot2::theme(axis.title.x =  ggplot2::element_text(face =  "bold"),
                                                     axis.text = ggplot2::element_text(face = "bold")),
                                ncol = 2, label_size = 24, hjust = 0.5, label_x = c(0.025, 0.025),
                                labels = c("C", "D"))

# Combine distrib and clustering plots for top row
top_row = cowplot::plot_grid(distrib + ggplot2::theme(legend.position =  "none"), top_row_legends,
                             clustering,
                             labels = c("A", "", "B"), ncol = 3, rel_widths = c(1.05, 0.15, 0.95),
                             label_size = 24, hjust = 0.5, label_x = c(0.025, 0, 0.025))

# Combine top and bottom rows in final figure
combined = cowplot::plot_grid(top_row, bottom_row, ncol =  1, rel_heights =  c(1, 0.6))
# Save figure to png and svg
ggplot2::ggsave(filename = png_output_file, plot =  combined, width =  16, height =  12)
ggplot2::ggsave(filename = svg_output_file, plot = combined, width = 16, height = 12, dpi = 400)

