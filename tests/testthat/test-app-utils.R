
test_that("Testing Waiter", {
  w <- new_waiter()
  expect_s3_class(w, "waiter")
  html <- waiter_html("hello")
  expect_s3_class(html, "shiny.tag.list")
})


test_that("Testing dev/test utils (On CI)", {
  skip_if(is_ci(), "On CI")
  expect_true(is_testing())
  expect_false(is_ci())
})

test_that("Testing dev/test utils (No CI)", {
  skip_if_not(is_ci(), "Not on CI")
  expect_true(is_testing())
  expect_true(is_ci())
})

test_that("Testing app utils", {
  get_app_colors() |>
    expect_named(
      c("bg", "fg", "primary", "secondary",  "success",
        "info", "warning", "danger")
    )
})

test_that("Testing plot creation", {
  # outdir <- lubridate::today() |>
  #   as.integer() |>
  #   fs::path("temp/graphics") |>
  #   fs::dir_create(recurse = TRUE)
  #
  # DT <- data.table(x = 0:100)
  # DT[, strokes := x*100]
  # DT[, hours := (x + 5)*(x > 0)]
  #
  # i <- 50
  # write_graphic(DT, i, fs::path(outdir, paste0(i, ".jpeg")))
  # fs::dir_delete(outdir)
  #
})
