# Get log file path from snakemake and redirect output to log
log_file_path <- snakemake@log[[1]]
log_file <- file(log_file_path)
sink(log_file, append = TRUE)
sink(log_file, append = TRUE, type = "message")

# Get other info from snakemake
input_file_path <- snakemake@input[[1]]
png_output_file <- snakemake@output$png[[1]]
svg_output_file <- snakemake@output$svg[[1]]

# Load data files
stats <- readr::read_delim(input_file_path, "\t", escape_double = FALSE, trim_ws = TRUE)

# Compute total run time and peak memory usage
stats$total_runtime = stats$process_runtime + stats$distrib_runtime + stats$signif_runtime
stats$total_memory = pmax(stats$process_mem, stats$distrib_mem, stats$signif_mem)

# Order factors by reads for performance plots
stats <- stats[order(stats$reads),]
stats$dataset <- factor(stats$dataset, levels = stats$dataset)

# Format species names nicely
stats$name <- paste0(toupper(substr(stats$dataset, 1, 1)), ". ", sapply(strsplit(as.character(stats$dataset), "_"), "[[", 2))

# Create a smooth x axis scale
x_axis_scale <- seq(min(stats$reads), max(stats$reads), (max(stats$reads) - min(stats$reads)) / 8)
names(x_axis_scale) <- round(seq(min(stats$reads), max(stats$reads), (max(stats$reads) - min(stats$reads)) / 8) / 10^6)

# Run time plot
runtime_data <- stats[, c("total_runtime", "dataset", "reads", "name")]
runtime_plot <- ggplot2::ggplot(runtime_data, ggplot2::aes(x = reads, y = total_runtime / 60)) +
    ggplot2::geom_point(size=3) +
    ggrepel::geom_text_repel(ggplot2::aes(label=name), force=6, box.padding = 0.4, fontface="italic") +
    ggplot2::scale_y_continuous(limits = c(0, 1.1 * max(runtime_data$total_runtime / 60)), expand = c(0, 0),
                                name = "RADSex total runtime (minutes)") +
    ggplot2::scale_x_continuous(name = "Millions of RAD-tags", limits = c(min(runtime_data$reads), max(runtime_data$reads)),
                                breaks = x_axis_scale, labels = names(x_axis_scale)) +
    cowplot::theme_cowplot() +
    ggplot2::theme(strip.text.x = ggplot2::element_blank(),
                   panel.grid.major.y = ggplot2::element_line(linetype=3, color="grey60"),
                   axis.text.y = ggplot2::element_text(face="bold"),
                   axis.text.x = ggplot2::element_text(face="bold"),
                   axis.title.y = ggplot2::element_text(face="bold"),
                   axis.title.x = ggplot2::element_text(face="bold"),
                   plot.title = ggplot2::element_blank(),
                   plot.margin = ggplot2::margin(25, 20, 5, 20))

# Memory plot
memory_data <- stats[, c("total_memory", "dataset", "reads", "name")]
memory_plot <- ggplot2::ggplot(memory_data, ggplot2::aes(x = reads, y = total_memory / 10^3)) +
    ggplot2::geom_point(size=3) +
    ggrepel::geom_text_repel(ggplot2::aes(label=name), force=6, box.padding = 0.4, fontface="italic") +
    ggplot2::scale_y_continuous(limits = c(0, 1.2*max(memory_data$total_memory / 10^3)), expand = c(0, 0),
                                name = "RADSex peak memory (Gb)") +
    ggplot2::scale_x_continuous(name = "Millions of RAD-tags", limits = c(min(memory_data$reads), max(memory_data$reads)),
                                breaks = x_axis_scale, labels = names(x_axis_scale)) +
    cowplot::theme_cowplot() +
    ggplot2::theme(strip.text.x = ggplot2::element_blank(),
                   panel.grid.major.y = ggplot2::element_line(linetype=3, color="grey60"),
                   axis.text.y = ggplot2::element_text(face="bold"),
                   axis.text.x = ggplot2::element_text(face="bold"),
                   axis.title.y = ggplot2::element_text(face="bold"),
                   axis.title.x = ggplot2::element_text(face="bold"),
                   plot.title = ggplot2::element_blank(),
                   plot.margin = ggplot2::margin(25, 20, 5, 20))

combined = cowplot::plot_grid(runtime_plot, memory_plot, ncol = 2,
                              labels = c("A", "B"), label_fontface = "bold", label_size = 24, align="hv")

ggplot2::ggsave(png_output_file, combined, width=15, height=8)
ggplot2::ggsave(svg_output_file, combined, width=15, height=8)

