
downloadsPage <- function() {
  fluidPage(
    h1("Downloads", style="text-align:center"),
    hr(),
    fluidRow(
      column(12,
             h3("Database contents:"),
             p("The complete MPRA Database is available for download through the following Zenodo repository:"),
             HTML("<a href='https://zenodo.org/records/10920747' target='_blank'>https://zenodo.org/records/10920747</a>"),
             br(),
             p("The data are stored in an SQLite3 database package. Accessing them requires installing SQLite3 in your system, as well as a compatible viewer such as <a href='https://sqlitebrowser.org/'>DB4S</a>.")
      )
    ),
    hr(),
    fluidRow(
      column(12,
             h3("Offline version"),
             p("You can install and use MPRABase locally in your system by downloading the source code from the following GitHub repositoyr"),
             HTML("<a href='https://github.com/Ahituv-lab/mprabase' target='_blank'>https://github.com/Ahituv-lab/mprabase</a>"),
             p("Detailed instructions for installing MPRABase are given in the repository. ")
             )
    )
  )
}