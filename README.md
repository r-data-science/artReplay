# artReplay <img src="man/figures/logo.png" align="right" height="120" alt="" />


<!-- badges: start -->

[![R-CMD-check](https://github.com/r-data-science/artReplay/actions/workflows/R-CMD-check.yaml/badge.svg?branch=main)](https://github.com/r-data-science/artReplay/actions/workflows/R-CMD-check.yaml)
[![test-coverage](https://github.com/r-data-science/artReplay/actions/workflows/test-coverage.yaml/badge.svg?branch=main)](https://github.com/r-data-science/artReplay/actions/workflows/test-coverage.yaml)
[![codecov](https://codecov.io/gh/r-data-science/artReplay/graph/badge.svg?token=KPUgJxBDR8)](https://codecov.io/gh/r-data-science/artReplay)

<!-- badges: end -->

## Install & Run App

#### In R Session

This package exports a single R function that launches the packaged
shiny app:

``` r
# remotes::install_github("r-data-science/artReplay")
artReplay::runReplayApp()
```

#### In Docker Container

To run this as a docker container, perform the following bash commands:

```{bash}
sudo docker pull bfatemi/replayapp:latest
sudo docker run --name demo-app \
  -p 3939:3939 --rm -dt bfatemi/replayapp:latest
```

------------------------------------------------------------------------

Proprietary - Do Not Distribute
