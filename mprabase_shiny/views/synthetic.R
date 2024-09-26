syntheticPage <- function() {
  fluidPage(
    h1("Browse synthetic MPRA samples", style="text-align:center"),
    hr(),
    fluidRow(
      sidebarPanel(id = "SYNTHETIC",
                   p(HTML("<b>Note:</b> Click on the <i class='fa fa-caret-down'></i> / <i class='fa fa-caret-up'></i> symbols to expand or collapse search form fields")),
                   bsCollapse(id = "synthetic_searchfuncs_collapse",
                              multiple = T,
                              open = c("synthetic_species_libraries"),
                              # bsCollapsePanel(
                              #   "Library Cis-regulatory elements",
                              #   value = "synthetic_cis_elements",
                              #   selectizeInput(
                              #     inputId = "SYNTHETIC_SAMPLE_REGULATORY_ELEMENTS",
                              #     label = "Filter by cis-regulatory elements:",
                              #     choices = NULL,
                              #     multiple = T,
                              #     
                              #     options = list(placeholder = "Start typing and select from list or enter a custom value...",
                              #                    delimiter = " ",
                              #                    create = TRUE)
                              #   )
                              # ),
                              bsCollapsePanel(
                                "Species & Library Strategies", value = "synthetic_species_libraries",
                                fluidRow(
                                  column(6, checkboxGroupInput(inputId = "SYNTHETIC_SAMPLE_SPECIES",
                                                               label = "Filter by species:",
                                                               choiceNames = NULL,
                                                               choiceValues = NULL)
                                  ),
                                  column(6,
                                         checkboxGroupInput(inputId = "SYNTHETIC_SAMPLE_LIBRARY",
                                                            label = "Filter by library strategy:",
                                                            choiceNames = NULL,
                                                            choiceValues = NULL))
                                )
                              ),
                              bsCollapsePanel(
                                "Cell Type", value = "synthetic_cell_types",
                                div(class="multicol",
                                    checkboxGroupInput(inputId = "SYNTHETIC_SAMPLE_CELLTYPE",
                                                       label = "Filter by cell type:",
                                                       choiceNames = NULL,
                                                       choiceValues = NULL,
                                                       inline = T
                                    )   
                                ) 
                                
                              ),
                              bsCollapsePanel(
                                "Associated Literature",
                                value = "synthetic_literature",
                                radioButtons(
                                  inputId = "SYNTHETIC_LITERATURE",
                                  label = "1. Search By:",
                                  choiceNames = c("PubMed ID", "Article Title", "Research Group", "GEO Number"),
                                  choiceValues = c("pmid", "title", "lab", "geo"),
                                  selected = "pmid",
                                  inline = T
                                ),
                                textInput(
                                  inputId = "SYNTHETIC_LITERATURE_INPUT",
                                  label = "2. Enter your search terms:",
                                  placeholder = "Enter text here..."
                                ),
                                p(HTML("<b>Note:</b> For PubMed or GEO, enter one or more IDs separated by spaces. For article titles, use free text."))
                              )
                   ),
                   fluidRow(
                     column(6,
                            actionButton(inputId = "synthetic_submit", label = "Search Samples", icon=icon("search"), class="btn-primary", style="width:100%")
                     ),
                     column(6,
                            actionButton(inputId = "synthetic_clear", label = "Clear", icon=icon("trash"), class="btn-danger", style="width:100%")
                     )
                   )
      ),
      mainPanel(
        fluidRow(
          column(6,
                 h4("Species / Cell Lines (synthetic)", style='text-align:center !important;'),
                 shinycssloaders::withSpinner(
                   plotly::plotlyOutput("synthetic_pie_species_celltypes", height="300px")
                 )
          ),
          column(6,
                 h4("Library Strategy", style='text-align:center !important;'),
                 shinycssloaders::withSpinner(
                   plotly::plotlyOutput("synthetic_pie_libraries", height="300px")
                 )
          )
        ),
        fluidRow(
          column(12,
                 div(id="synthetic_datasets_msg", span("Scroll down to view the samples of the selected datasets."),
                     style="display:none"),
                 shinycssloaders::withSpinner(
                   DT::dataTableOutput("synthetic_samples_table")
                 )
          )
        )
        
      )
    ),
    fluidRow(
      column(12,
             div(id = "synthetic_datasets_panel", style="display:none",
                 h3("Selected datasets (synthetic)"),
                 div(style="height:30px",
                     actionButton(inputId = "synthetic_dataset_download_btn", label = "Download Selected", class = "btn-success", icon = icon("download"), style="display:none"),
                     actionButton(inputId = "synthetic_dataset_analyze_btn", label = "Replicate Visualization", class = "btn-info", icon = icon("chart-line"), style="display:none")
                 ),
                 shinycssloaders::withSpinner(
                   DT::dataTableOutput("synthetic_datasets_table")
                 )
             )
      )
    )
    
    
  )
}