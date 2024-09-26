source("global.R", local = T)
source("server.R", local = T)

source("views/standard.R", local = T)
source("views/synthetic.R", local = T)
source("views/analysis.R", local = T)
source("views/variants.R", local = T)
source("views/documentation.R", local = T)
source("views/downloads.R", local = T)

ui <- shinyUI(
  fluidPage(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/style.css"),
      tags$script(src = "js/mprabase.js"),
      tags$script(src = "js/igv/dist/igv.min.js"),
      tags$script(src = "js/igvViewer.js"),
      shinyjs::useShinyjs()
    ),
    navbarPage(
      title = HTML("<a href='./'><img src='images/site-logo.svg' /></a>"),
      windowTitle = "MPRA Base",
      lang = "en",
      id = "top_menu",
      tabPanel(title = "Standard MPRA", value = "home_page",
               homePage()
      ),
      tabPanel(title = "Synthetic MPRA", value = "synthetic_page",
               syntheticPage()
      ),
      tabPanel(title = "MPRA Library View", value = "analysis_page",
               analysisPage()
      ),
      tabPanel(title = "Saturation Mutagenesis", value = "variants_page",
               variantsPage()
        
      ),
      tabPanel(title = "Downloads", value = "download_page",
               downloadsPage()
      ),
      tabPanel(title = "Help", value = "help_page",
               helpPage()
      ),
      tabPanel(title = "About", value = "about_page",
               aboutPage()
      )
    )
  )
)

shinyApp(ui, server)