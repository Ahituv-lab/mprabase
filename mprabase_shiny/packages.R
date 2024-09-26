cran_packages <- c(
  "shiny",
  "shinyBS",
  "shinyjs",
  "shinyWidgets",
  "RColorBrewer",
  "markdown",
  "DBI",
  "RSQLite",
  "DT",
  "plotly",
  "dplyr",
  "stringi",
  "data.table"
)

local({
  r <- getOption('repos')
  r['CRAN'] <- 'https://cran.r-project.org'; options(repos=r)
})


missing_packages <- subset(cran_packages, !(cran_packages %in% rownames(installed.packages())))
if(length(missing_packages) > 0){
  cat(
    sprintf("The following packages are missing from the system: %s \n\ninstalling them now...",
            paste(missing_packages, sep=", ", collapse = ", ")
    ),
    file = stderr())
  install.packages(missing_packages)
}


