#' Get Input Box
#'
get_input_box <- function () {
  shinydashboardPlus::box(
    title = shinydashboardPlus::boxLabel("Signature", status = "primary"),
    label = "Click Image to Select Region",
    collapsible = TRUE,
    collapsed = FALSE,
    headerBorder = FALSE,
    sidebar = shinydashboardPlus::boxSidebar(
      id = "box_sidebar",
      column(
        width = 12,
        sliderInput(
          inputId = "fps_slider",
          post = " fps",
          min = 1,
          max = 50,
          value = 25,
          step = 1,
          width = "100%",
          label = "Timelapse Speed",
          ticks = FALSE
        )
      )
    ),
    width = 12,

    column(
      width = 12,
      plotOutput(
        outputId = "base_portrait",
        fill = TRUE,
        width = "100%",
        height = "500px",
        click = clickOpts("plot_click", clip = TRUE)
      )
    ),
    footer = tagList(
      shinyWidgets::actionBttn(
        inputId = "btn_submit",
        label = "Create Replay",
        block = TRUE,
        color = "warning",
        size = "sm",
        style = "material-flat",
        icon = icon("clock-rotate-left"),
        no_outline = FALSE
      )
    ),
    status = "warning"
  )
}
