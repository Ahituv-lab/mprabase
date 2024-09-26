helpPage <- function() {
  fluidPage(
    h1("Help", style="text-align:center"),
    hr(),
    tabsetPanel(id = "help_tabset",
                tabPanel("Standard MPRA Browser", value = "help_standard_mpra",
                         tags$br(),
                         includeMarkdown("www/markdown/standard_mpra.md")
                ),
                tabPanel("Synthetic MPRA Browser", value = "help_synthetic_mpra",
                         tags$br(),
                         includeMarkdown("www/markdown/synthetic_mpra.md")
                ),
                tabPanel("Saturation-Mutagenesis Browser", value = "help_saturation",
                         tags$br(),
                         includeMarkdown("www/markdown/saturation_mutagenesis.md")
                ),
                tabPanel("Submit New Data", value = "help_submit_data",
                         tags$br(),
                         includeMarkdown("www/markdown/data_submission.md")
                )
    )
    
  )
}


aboutPage <- function() {
  fluidPage(
    h1("About MPRABase", style="text-align:center"),
    hr(),
    tabsetPanel(id = "about_tabset",
                tabPanel("Overview", value = "about_overview",
                         tags$br(),
                         includeMarkdown("www/markdown/overview.md")
                ),
                tabPanel("License & Disclaimer", value = "about_license",
                         tags$br(),
                         includeMarkdown("www/markdown/license.md")
                         )
    )
  )
}