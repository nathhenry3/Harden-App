FROM rocker/r-ver:3.6.3

# Install linux packages
RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev \
    libpq-dev \
    xtail \
    wget \ 
    nano \
    build-essential \
    libxml2-dev
    

# Install R packages
# RUN echo 'install.packages(c("shiny", "shinyMobile","plotly","dplyr","lubridate","ggdark","here","purrr","shinycssloaders","RPostgres","DBI","zoo","tidyr","magrittr","shiny.pwa","polished"), \
# repos="http://cran.us.r-project.org", \
# dependencies=TRUE)' > /tmp/packages.R \
#   && Rscript /tmp/packages.R

RUN R -e "install.packages('shiny', version='1.6.0', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \ 
# R -e "install.packages('shinyMobile', version='0.8.0', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
# Taking a risk here but installing dev version (1.0.0.9001, or 0.9.0?) of shinyMobile for now until they release on cran
R -e "install.packages('devtools', version='2.3.0', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
R -e "remotes::install_github('RinteRface/shinyMobile', dependencies=TRUE)" && \
R -e "install.packages('plotly', version='4.9.3', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
R -e "install.packages('dplyr', version='1.0.5', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
R -e "install.packages('lubridate', version='1.7.10', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
R -e "install.packages('ggdark', version='0.2.1', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
R -e "install.packages('here', version='1.0.1', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
R -e "install.packages('purrr', version='0.3.4', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
R -e "install.packages('shinycssloaders', version='1.0.0', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
R -e "install.packages('RPostgres', version='1.3.2', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
R -e "install.packages('DBI', version='1.1.1', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \ 
R -e "install.packages('zoo', version='1.8-9', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
R -e "install.packages('tidyr', version='1.1.3', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
R -e "install.packages('magrittr', version='2.0.1', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
R -e "install.packages('shiny.pwa', version='0.2.0', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
R -e "install.packages('sever', version='0.0.6', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
# Make shinyFeedback install explicit to fix polished namespace bug
R -e "install.packages('shinyFeedback', version='0.3.0', dependencies=TRUE, repos='http://cran.rstudio.com/')" && \
R -e "remotes::install_github('tychobra/polished', dependencies=TRUE)" && \
R -e "remotes::install_github('tychobra/polishedpayments', dependencies=TRUE)"

# # Install shiny server
# RUN wget --no-verbose https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.16.958-amd64.deb \ 
# && gdebi shiny-server-1.5.16.958-amd64.deb

# Download and install shiny server
RUN wget --no-verbose https://download3.rstudio.org/ubuntu-14.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb && \
    . /etc/environment

# Copy app to image
COPY /R_code/Shiny /srv/shiny-server/
COPY shiny-server.sh /usr/bin/shiny-server.sh

# Make files/folders readable and change ownership to shiny user
# RUN chmod -R +r /srv/shiny-server # +r is root?
# RUN chmod -R +r /var/log/shiny-server
# RUN sudo chown -R shiny:shiny /var/lib/shiny-server
RUN sudo chown -R shiny:shiny /srv/shiny-server
RUN sudo chown -R shiny:shiny /var/log/shiny-server
RUN ["chmod", "+x", "/usr/bin/shiny-server.sh"] # this allows logs to be stored, where they can be viewed in the 
# 'Logs Explorer' in Cloud Run

# Set shiny print statements to be entered into logfile - don't think this is necessary
# ENV SHINY_LOG_STDERR=1

# Select port
EXPOSE 3838

# Run app
CMD ["/usr/bin/shiny-server.sh"]

# Run on local server at folder level of dockerfile with commands below: (--name harden_container is optional)
# sudo docker build -t harden .
# sudo docker run --rm -p 3838:3838 --name harden_container harden
# Then open your web browser to http://localhost:3838
# To open docker filesystem in terminal:
# sudo docker exec -it harden_container bash
# Note: /etc/shiny-server/shiny-server.conf contains config arguments