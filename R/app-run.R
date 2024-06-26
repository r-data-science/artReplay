#' Run App
#'
#' Functions to run the package shiny app
#'
#' @import shiny
#' @import shinydashboardPlus
#' @importFrom shinyEffects setShadow
#' @importFrom shinydashboard dashboardBody
#' @importFrom waiter useWaiter waiter_preloader
#'
#' @name app-run
NULL


globalVariables(c("x2", "y2", "hours", "strokes", "x"))

#' @describeIn app-run returns app object for subsequent execution
#' @export
runReplayApp <- function() {
  shiny::shinyApp(
    ui = app_ui(),
    server = app_server(),
    onStart = function() {
      create_session_dir()

      fs::file_copy(
        get_app_dir("images/init.gif"),
        get_temp_dir("init.gif")
      )
      fs::file_copy(
        get_app_dir("images/init.jpeg"),
        get_temp_dir("init.jpeg")
      )
      fs::file_copy(
        get_app_dir("images/init.png"),
        get_temp_dir("init.png")
      )
      onStop(gc)
    }
  )
}


#' @importFrom lubridate today
#' @describeIn app-run UI function for app
app_ui <- function() {
  .colors <- get_app_colors()

  shinydashboardPlus::dashboardPage(
    header = shinydashboardPlus::dashboardHeader(
      controlbarIcon = icon("palette"),
      leftUi = tagList(),
      userOutput("user")
    ),
    sidebar = shinydashboardPlus::dashboardSidebar(disable = TRUE),
    footer = dashboardFooter(
      left = "By Bobby Fatemi",
      right = paste0("Last updated on ", lubridate::today())
    ),
    body = shinydashboard::dashboardBody(

      # use a bit of shinyEffects
      shinyEffects::setShadow(class = "dropdown-menu"),
      shinyEffects::setShadow(class = "box"),

      # some styling
      get_page_head(),

      waiter::useWaiter(),
      waiter::waiter_preloader(
        waiter_html("Starting Session"),
        .colors$bg,
        fadeout = 2000
      ),

      get_progress_stats(),
      get_input_box(),
      get_zoom_box(),
      get_replay_box(),
      get_frames_box()
    )
  )
}


#' @importFrom scales percent
#' @describeIn app-run server function for app
app_server <- function() {
  function(input, output, session) {

    shinydashboardPlus::updateBox("box_zoom_viewer", action = "remove")
    shinydashboardPlus::updateBox("box_replay_viewer", action = "remove")
    shinydashboardPlus::updateBox("box_frame_viewer", action = "remove")

    output$user <- shinydashboardPlus::renderUser(get_user_box())

    onSessionEnded(fun = clear_temp_dir)

    w <- new_waiter()

    ## Init reactives to hold image/plot objects
    r_plot_1k <- reactiveVal( get_base_plot() ) # dynamic in future
    r_gif_2k <- reactiveVal() # Set this value on first submit
    r_jpg_4k <- reactiveVal() # Set this value on first submit

    ## Initial coordinates for plot click on app load
    r_click_x <- reactiveVal(300)
    r_click_y <- reactiveVal(425)

    ## On plot click, get x and y coordinates in pixels and shift by 100
    ## to get the start coordinates of the box
    observeEvent(input$plot_click, {
      x <- input$plot_click$x
      y <- input$plot_click$y

      # Depending on where this is deployed, scale into pixel coords
      if (x < 1) x <- x * 1000
      if (y < 1) y <- y * 1000

      r_click_x(max(round(x, 0) - 100, 0))
      r_click_y(max(round(y, 0) - 100, 0))
    })

    ## Plot the base image with the box corresponding to the
    ## click or initial location
    output$base_portrait <- renderPlot({
      get_click_plot(r_plot_1k(), r_click_x(), r_click_y())
    })

    ## These hold the file paths to images on disk for shiny to display on UI
    ##
    r_tmp_gif <- reactiveVal()
    r_tmp_jpg <- reactiveVal()
    r_tmp_png <- reactiveVal()

    ## Holds the brush stroke/hours data for a given selected region
    r_region_data <- reactiveVal()

    observeEvent(input$btn_submit, {
      w$show()

      # This will run on first submit only
      # Read gif and image and save into reactive var
      if ( is.null(r_gif_2k()) ) {
        w$update(html = waiter_html("Reading Timelapse Images"))
        r_gif_2k(get_replay_gif())
      }
      if ( is.null(r_jpg_4k()) ) {
        r_jpg_4k(get_full_img())
      }
      replay_gif <- r_gif_2k()
      full_img <- r_jpg_4k()

      w$update(html = waiter_html("Generating Replay"))

      clear_frames_dir() ## Clear previous frames on last submit
      clear_graphics_dir() ## Clear previous graphics on last submit

      ## Get and adjust click position so that click is in the middle of region
      xmin <- r_click_x()
      xmax <- min(r_click_x() + 200, 1000)
      ymin <- r_click_y()
      ymax <- min(r_click_y() + 200, 1000)

      ## Scale coords to map selected region to res of files and crop
      gif <- image_crop2(replay_gif, xmin * 2, xmax * 2, ymin * 2, ymax * 2)
      img <- image_crop2(full_img,   xmin * 4, xmax * 4, ymin * 4, ymax * 4)

      ## Drop frames that haven't changed since prior
      gif <- gif[which(get_comp_vec(gif))]

      ## Temporary data, replace with real info later
      DT <- data.table(x = 0:length(gif))
      DT[, strokes := x*100]
      DT[, hours := (x + 5)*(x > 0)]

      r_region_data(DT)

      ## Write and save path to reactive object
      write_gif(gif, input$fps_slider) |> r_tmp_gif()

      w$update(html = waiter_html("Saving Timelapse Frames"))

      for (i in 1:length(gif)) {
        if (i %% 5 == 0) {
          # Update Progress Screen
          w$update(html = waiter_html(
            paste0("Saving Timelapse Frames...",
                   scales::percent(i/length(gif), accuracy = 1))
          ))
        }
        img_file <- paste0(i, ".jpeg")
        write_frame(gif, i, get_temp_dir("frames", img_file))      # Save Frame

        print(i)
        write_graphic(DT, i, get_temp_dir("graphics", img_file)) # Save Graphic
      }

      updateSliderInput(
        inputId = "frame_slider",
        label = NULL,
        value = 1,
        min = 1,
        max = length(gif),
        step = 1
      )

      w$update(html = waiter_html("Finalizing Output"))

      ## Write out and save paths in reactive obj
      r_tmp_jpg(write_jpg(img))
      r_tmp_png(write_png(img))

      w$hide()
    })

    observe({
      req(r_tmp_gif(), r_tmp_jpg(), r_tmp_png())
      updateBox("box_frame_viewer", action = "restore")
      updateBox("box_frame_viewer", action = "update", options = list(closable = FALSE))
      updateBox("box_replay_viewer", action = "restore")
      updateBox("box_replay_viewer", action = "update", options = list(closable = FALSE))
      updateBox("box_zoom_viewer", action = "restore")
      updateBox("box_zoom_viewer", action = "update", options = list(closable = FALSE))
    })

    ## Render image and gif
    output$gif_replay <- renderImage({
      list(src = req(r_tmp_gif()), contentType = "image/gif")
    }, deleteFile = FALSE)
    output$img_zoom <- renderImage({
      list(src = req(r_tmp_jpg()), contentType = "image/jpeg")
    }, deleteFile = FALSE)

    ## Download Zoomed image as png or jpeg
    observeEvent(input$dl_zoom, {
      w$show()
      w$update(html = waiter_html("Download Image"))
      if (input$dl_zoom == "PNG") {
        trigger_image_dl(req(r_tmp_png()), session)
      } else {
        trigger_image_dl(req(r_tmp_jpg()), session)
      }
      w$hide()
    }, ignoreNULL = TRUE)

    ## Download timelapse as video or gif
    observeEvent(input$dl_replay, {
      w$show()
      w$update(html = waiter_html("Download Timelapse"))
      if (input$dl_replay == "GIF") {
        trigger_gif_dl(req(r_tmp_gif()), session)
      } else {
        w$update(html = waiter_html("Converting to MP4"))
        trigger_vid_dl(req(r_tmp_gif()), input$fps_slider, session)
      }
      w$hide()
    })

    output$frame_portrait <- renderImage({
      list(
        src = get_temp_dir("frames", paste0(input$frame_slider, ".jpeg")),
        width = "100%", height = "100%"
      )
    }, deleteFile = FALSE)

    output$frame_graphic <- renderImage({
      list(
        src = get_temp_dir("graphics", paste0(input$frame_slider, ".jpeg")),
        width = "100%", height = "100%"
      )
    }, deleteFile = FALSE)

    output$sumbox_strokes <- renderText(req(r_region_data())[input$frame_slider, strokes])
    output$sumbox_hours <- renderText(req(r_region_data())[input$frame_slider, hours])
  }
}






