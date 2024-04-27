#' Get Frames Box
#'
get_frames_box <- function() {
  shinydashboardPlus::box(
    id = "box_frame_viewer",
    title = "",
    width = 12,
    icon = icon("chart-line"),
    closable = TRUE,
    collapsible = TRUE,
    headerBorder = FALSE,


    column(
      width = 12,
      sliderInput(
        width = "100%",
        inputId = "frame_slider",
        min = 0,
        max = 10,
        value = 0,
        label = NULL,
        animate = animationOptions(interval = 200, loop = TRUE),
        ticks = FALSE
      )
    ),

    column(
      width = 12,
      fluidRow(
        summaryBox2(width = 6,
                    value = textOutput("sumbox_strokes"),
                    style = "primary",
                    icon = "fas fa-paintbrush",
                    title = "Brush Strokes"),
        summaryBox2(width = 6,
                    value = textOutput("sumbox_hours"),
                    style = "primary",
                    icon = "fas fa-clock",
                    title = "Hours Drawing")
      )
    ),


    footer = tagList(
      column(
        width = 6,
        imageOutput("frame_graphic", fill = TRUE, inline = TRUE)
      ),
      column(
        width = 6,
        imageOutput("frame_portrait", fill = TRUE, inline = TRUE)
      )
    )
  )
}

