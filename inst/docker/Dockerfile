#------------------------------------------------------------
# Base image
#
FROM rocker/r-ubuntu:22.04


#------------------------------------------------------------
# Expose port for app to listen on
#
EXPOSE 3838

#------------------------------------------------------------
# Install system dependencies
#
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    pandoc \
    libcurl4-gnutls-dev \
    libxt-dev \
    libssl-dev \
    libxml2-dev \
    libssh2-1-dev \
    libpq-dev \
    libmagick++-dev \
    libfftw3-dev \
    libtiff-dev \
    libglpk40 \
    libavfilter-dev \
    && rm -rf /var/lib/apt/lists/*

#------------------------------------------------------------
# Setup R profile and install remotes package needed for
# additional dependencies below
#
ENV _R_SHLIB_STRIP_=true
COPY ./inst/docker/Rprofile.site /etc/R
RUN install.r remotes

#------------------------------------------------------------
# Install cran and gh dependencies using the remotes package
# and the current package's DESCRIPTION file
#
ADD . rpkg
RUN Rscript -e "remotes::install_local('rpkg')"
RUN Rscript -e "stopifnot('artReplay' %in% installed.packages()[,'Package'])"

# Also needs the following
RUN Rscript -e "install.packages(c('av', 'gifski'))"

#------------------------------------------------------------
# Specify shiny runtime options in Rprofile.site that was
# copied in prior step
#
RUN echo "local(options(shiny.port = 3838, shiny.host = '0.0.0.0'))" > \
    /usr/lib/R/etc/Rprofile.site

#------------------------------------------------------------
#Increase memory limits for ImageMagick just for this runReplayApp
#
RUN sed -i -E 's/name="memory" value=".+"/name="memory" value="16GiB"/g' /etc/ImageMagick-6/policy.xml
RUN sed -i -E 's/name="map" value=".+"/name="map" value="16GiB"/g' /etc/ImageMagick-6/policy.xml
RUN sed -i -E 's/name="area" value=".+"/name="area" value="16GiB"/g' /etc/ImageMagick-6/policy.xml
RUN sed -i -E 's/name="disk" value=".+"/name="disk" value="16GiB"/g' /etc/ImageMagick-6/policy.xml


#------------------------------------------------------------
# Add non-root system user that runs the app
#
RUN addgroup --system app && adduser --system --ingroup app app
WORKDIR /home/app


#------------------------------------------------------------
# Set permissions, switch user, and run the app
#
RUN chown app:app -R /home/app
USER app


CMD ["R", "-e", "artReplay::runReplayApp()"]

