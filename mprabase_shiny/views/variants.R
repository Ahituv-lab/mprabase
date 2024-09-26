variantsPage <- function() {
  fluidPage(
    h1("MPRA Saturation - Mutagenesis Browser", style="text-align:center"),
    hr(),
    sidebarPanel(id = "variant",
                 bsCollapse( id = "variant_studyselect",
                             multiple = T,
                             open = c("variant_studyselect", "variant_genomereg", "variant_statistics"),
                             bsCollapsePanel("Mutagenesis Study",
                                             value = "variant_studyselect",
                                             fluidRow(
                                               column(12,
                                                      selectInput(
                                                        inputId = "variant_study",
                                                        label = "Selected Study:",
                                                        choices = c("Homo sapiens Genes" = "hg38",
                                                                    "Bacteriophages" = "bacteriophage",
                                                                    "Mammalian core promoters" = "mammalian"),
                                                        selected = "mammalian"
                                                      ))
                                             ),
                                             fluidRow(
                                               column(12,
                                                      uiOutput("variant_study_details")
                                                      )
                                             )
                                             
                             ),
                             bsCollapsePanel("Genomic Region",
                                             value = "variant_genomereg",
                                             fluidRow(
                                               column(5,
                                                      selectizeInput(
                                                        inputId = "variant_gene",
                                                        label = "Selected Element:",
                                                        choices = c("BLC11A1 (chr:2)"),
                                                        selected = "BLC11A1 (chr:2)"
                                                      )
                                               ),
                                               column(7,
                                                      br(),
                                                      checkboxInput(
                                                        inputId = "variant_deletions",
                                                        label = "Also include single base deletions",
                                                        value = T
                                                      )
                                               )
                                             ),
                                             fluidRow(
                                               column(12,
                                                      sliderInput(
                                                        inputId = "variant_range",
                                                        label = "Genomic Position range:",
                                                        min = 1,
                                                        max = 99999999999999999,
                                                        value = c(1,99999999999999999),
                                                        step = 1,
                                                        ticks = T
                                                      )
                                               )
                                             ),
                                             fluidRow(
                                               column(12)
                                             ),
                                             fluidRow(
                                               column(12,
                                                      div(id="wrapper_variant_tags",
                                                      sliderInput(
                                                        inputId = "variant_tags",
                                                        label = "Number of unique tags:",
                                                        min = 1,
                                                        max = 10000,
                                                        value = c(1,10000),
                                                        ticks = T
                                                      )
                                                      )
                                               )
                                             )
                             ),
                             bsCollapsePanel("Variant Expression Effect",
                                             value = "variant_statistics",
                                             fluidRow(
                                               column(12,
                                                      sliderInput(
                                                        inputId = "variant_coeff",
                                                        label = "Log2 variant expression:",
                                                        min = -100,
                                                        max = 100,
                                                        value = c(-100, 100),
                                                        step = 0.01,
                                                        ticks = T
                                                      )
                                               )
                                             ),
                                             fluidRow(
                                               column(12,
                                                      div(id="wrapper_variant_pvalue",
                                                      sliderInput(
                                                        inputId = "variant_pvalue",
                                                        label = "P-value:",
                                                        min = 0,
                                                        max = 1,
                                                        value = c(0, 1),
                                                        step = 0.0001,
                                                        ticks = T
                                                      )
                                                      )
                                               )
                                             )
                                             
                                             
                             )
                 ),
                 fluidRow(
                   column(6,
                          actionButton(inputId = "variant_submit", label = "View Data", class="btn-primary", style="width:100%")
                   ),
                   column(6,
                          actionButton(inputId = "variant_clear", label = "Reset Form", class="btn-danger", style="width:100%")
                   )
                 )
    ),
    mainPanel( id = "variant_panels", style="display:none",
               uiOutput("variant_title"),
               tabsetPanel(
                 id = "variant_panel_results",
                 tabPanel(
                   "Data",
                   value = "variant_data",
                   br(),
                   shinycssloaders::withSpinner(
                     DT::dataTableOutput("variant_datatable")
                   )
                 ),
                 tabPanel(
                   "Viewer",
                   value = "variant_viewer",
                   br(),
                   shinycssloaders::withSpinner(
                     plotly::plotlyOutput("variant_plot", height = "600px")
                   )
                 )
               ),
               br(),
               fluidRow(
                 h4("Search parameters:", style="font-weight:bold"),
                 DT::dataTableOutput("variant_searchterms")
               )
               
    )
  )  
}