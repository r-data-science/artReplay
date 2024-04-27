#' Create and Write Plot
#'
#' @param DT Data
#' @param i Iteration
#' @param outpath Save Path
#'
#' @importFrom ggplot2 ggplot geom_line coord_cartesian aes element_line theme ggtitle element_blank unit element_text scale_x_continuous scale_y_continuous ggsave
#' @importFrom ggtext element_markdown
#' @importFrom scales breaks_extended label_comma
write_graphic_2 <- function(DT, i, outpath) {
  breaks <- function(x) scales::breaks_extended()(x)
  labels_y <- function(y) {
    cutoff <- DT[i + 1, strokes]
    scalef <- scales::label_comma(suffix = "K", scale = .001, accuracy = 1)
    y_blue <- y[!is.na(y) & y <= cutoff]
    y_gray <- y[!is.na(y) & y > cutoff]
    tmp_b <- paste0("<span style = 'color: ", "#3595ff", ";'>", scalef(y_blue), "</span>")
    tmp_g <- paste0("<span style = 'color: ", "#f39c12", ";'>", scalef(y_gray), "</span>")
    yl <- as.list(y)
    yl[!is.na(y) & y <= cutoff] <- tmp_b
    yl[!is.na(y) & y > cutoff] <- tmp_g
    unlist(yl)
  }
  labels_x <- function(x) {
    cutoff <- DT[i + 1, hours]
    x_blue <- x[!is.na(x) & x <= cutoff]
    x_gray <- x[!is.na(x) & x > cutoff]
    tmp_b <- paste0("<span style = 'color: ", "#3595ff", ";'>", x_blue, "</span>")
    tmp_g <- paste0("<span style = 'color: ", "#f39c12", ";'>", x_gray, "</span>")
    xl <- as.list(x)
    xl[!is.na(x) & x <= cutoff] <- tmp_b
    xl[!is.na(x) & x > cutoff] <- tmp_g
    unlist(xl)
  }

  graph <- ggplot() +
    geom_line(aes(hours, strokes), DT[(i+1):.N], lineend='round', linewidth = 1, color = "#f39c12") +
    geom_line(aes(hours, strokes), DT[1:(i+1)], lineend='round', linewidth = 3, color = "#3595ff") +
    coord_cartesian(xlim = c(0, nrow(DT)), ylim = c(min(DT$strokes), max(DT$strokes))) +
    ggtitle(label = "Brush Strokes By Hour") +
    theme(
      panel.grid.major = element_line(color = "gray", linewidth = .2),
      panel.grid.minor = element_blank(),
      panel.grid.major.x = element_blank(),
      panel.background = element_blank(),
      plot.margin = unit(c(1,0,1,1), "mm"),
      axis.ticks.length = unit(0, "mm"),
      plot.title.position = "plot",
      plot.title = element_text(colour = "#3595ff", face = "bold.italic"),
      axis.text.x = ggtext::element_markdown(size = 12, face = "bold"),
      axis.text.y = ggtext::element_markdown(size = 12, face = "bold"),
      axis.title = element_blank()
    ) +
    scale_x_continuous(breaks = breaks, labels = labels_x) +
    scale_y_continuous(breaks = breaks, labels = labels_y)

  ggplot2::ggsave(outpath,
                  graph,
                  dpi = 200,
                  units = "px",
                  width = 1000,
                  height = 1000)
}


