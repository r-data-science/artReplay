#' Load Dependency
#'
#' @importFrom htmltools htmlDependency
#'
loadFontAwesome <- function() {
  list(
    htmltools::htmlDependency(name = "font-awesome",
                              version = "5.13.0",
                              src = get_app_dir("fontawesome"),
                              # package = "fontawesome",
                              stylesheet = c("css/all.min.css", "css/v4-shims.min.css")),

    # Custom CSS
    htmltools::htmlDependency(
      name = "summarybox-style",
      version = "0.1.0",
      src = get_app_dir("css"),
      stylesheet = "style.css"
    )
  )
}

#' Info / Value Box in Shiny Apps and RMarkdown
#'
#' @param title Text to be shown in the box
#' @param value Value to be shown in the box
#' @param width Width of Box. width = 4 means 3 boxes can be fitted (12 / 4)
#' @param icon Font Awesome 5 icons. E.g. "fas fa-chart-bar"
#' @param style Either "primary", "secondary", "info", "success", "danger", "warning", "light", "dark"
#'
#' @importFrom htmltools htmlDependency tags browsable
#'
summaryBox2 <- function(title, value, width = 4, icon = "fas fa-chart-bar", style = "info") {

  valuetag  <- tags$div(
    class = paste0("col-md-", width),
    tags$div(
      class = paste("card-counter", style),
      tags$i(class = icon),
      tags$span(
        class = "count-numbers",
        value
      ),
      tags$span(
        class = "count-name",
        title
      )
    )
  )

  htmltools::htmlDependencies(valuetag) <- loadFontAwesome()
  htmltools::browsable(valuetag)
}
