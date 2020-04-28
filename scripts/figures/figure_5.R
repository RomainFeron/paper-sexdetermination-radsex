library(sgtr)
library(ggplot2)
library(cowplot)

# Get log file path from snakemake and redirect output to log
log_file_path <- snakemake@log[[1]]
log_file <- file(log_file_path)
sink(log_file, append=TRUE)
sink(log_file, append=TRUE, type="message")

# Get other info from snakemake
cyprinus_carpio_file <- snakemake@input$cyprinus_carpio[[1]]
gadus_morhua_file <- snakemake@input$gadus_morhua[[1]]
gymnotus_carapo_file <- snakemake@input$gymnotus_carapo[[1]]
plecoglossus_altivelis_file <- snakemake@input$plecoglossus_altivelis[[1]]
poecilia_sphenops_file <- snakemake@input$poecilia_sphenops[[1]]
tinca_tinca_file <- snakemake@input$tinca_tinca[[1]]
png_output_file <- snakemake@output$png[[1]]
svg_output_file <- snakemake@output$svg[[1]]

# Prevent R from automatically creating the file "Rplots.pdf"
pdf(NULL)

# Generate distrib plot for each dataset
cyprinus_carpio_plot <- radsex_distrib(cyprinus_carpio_file,
                                       groups = c("male", "female"),
                                       group_labels = c("Males", "Females"),
                                       title = expression(bolditalic("C. carpio")))
gadus_morhua_plot <- radsex_distrib(gadus_morhua_file,
                                       groups = c("male", "female"),
                                       group_labels = c("Males", "Females"),
                                       title = expression(bolditalic("G. morhua")))
gymnotus_carapo_plot <- radsex_distrib(gymnotus_carapo_file,
                                       groups = c("male", "female"),
                                       group_labels = c("Males", "Females"),
                                       title = expression(bolditalic("G. carapo")))
plecoglossus_altivelis_plot <- radsex_distrib(plecoglossus_altivelis_file,
                                       groups = c("male", "female"),
                                       group_labels = c("Males", "Females"),
                                       title = expression(bolditalic("P. altivelis")))
poecilia_sphenops_plot <- radsex_distrib(poecilia_sphenops_file,
                                       groups = c("male", "female"),
                                       group_labels = c("Males", "Females"),
                                       title = expression(bolditalic("P. sphenops")))
tinca_tinca_plot <- radsex_distrib(tinca_tinca_file,
                                       groups = c("male", "female"),
                                       group_labels = c("Males", "Females"),
                                       title = expression(bolditalic("T. tinca")))

# Grab legend from one of the plot
legend <- get_legend(cyprinus_carpio_plot)

# Combine plots, remove some axis titles and legend
combined <- plot_grid(cyprinus_carpio_plot + theme(legend.position = "none", 
                                                   axis.title.x = element_blank()),
                      gadus_morhua_plot + theme(legend.position = "none", 
                                                axis.title.x = element_blank(),
                                                axis.title.y = element_blank()), 
                      gymnotus_carapo_plot + theme(legend.position = "none",
                                                   axis.title.x = element_blank(),
                                                   axis.title.y = element_blank()), 
                      plecoglossus_altivelis_plot + theme(legend.position = "none"), 
                      poecilia_sphenops_plot + theme(legend.position = "none",
                                                     axis.title.y = element_blank()),
                      tinca_tinca_plot + theme(legend.position = "none", 
                                               axis.title.y = element_blank()),
                      labels = c("A", "B", "C", "D", "E", "F"), 
                      label_size = 24,
                      rel_heights = c(0.9, 0.9),
                      rel_widths = c(0.9, 0.9, 0.9),
                      ncol = 3,
                      align ="hv")

# Combine figure with legend
full_figure <- plot_grid(combined, legend, ncol=2, rel_widths = c(1, 0.15))

# Save figure to png and svg
ggsave(png_output_file, full_figure, width=16, height=10)
ggsave(svg_output_file, full_figure, width=16, height=10)
