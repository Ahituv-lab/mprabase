homePage <- function() {
  fluidPage(
    h1("Browse standard MPRA samples", style="text-align:center"),
    hr(),
    fluidRow(
      sidebarPanel(id="STANDARD",
                   p(HTML("<b>Note:</b> Click on the <i class='fa fa-caret-down'></i> / <i class='fa fa-caret-up'></i> symbols to expand or collapse search form fields")),
                   bsCollapse(
                     id = "standard_searchfuncs_collapse",
                     multiple = T,
                     open = c("standard_cis_elements"),
                     bsCollapsePanel("Library Cis-regulatory Elements", value = "standard_cis_elements",
                                     shinyWidgets::radioGroupButtons(inputId = "STANDARD_SAMPLE_REGULATORY_SPECIES",
                                                                     label = "1. Select library genome assembly:",
                                                                     choiceNames = c('All', 
                                                                                     'Human hg38 (GRCh38)',
                                                                                     'Human hg19 (GRCh37)',
                                                                                     'Human hg18 (NCBI36)',
                                                                                     'Mouse mm10 (GRCm38)',
                                                                                     'Mouse mm9 (MGSCv37)',
                                                                                     'D. melanogaster dm3 (BDGP R5)'),
                                                                     choiceValues = c('all', 'hg38', 'hg19', 'hg18', 'mm10', 'mm9', 'dm3'),
                                                                     selected = "all",
                                                                     checkIcon = list(
                                                                       yes = icon("ok",
                                                                                  lib = "glyphicon"),
                                                                       no = icon("remove",
                                                                                 lib = "glyphicon")
                                                                     )
                                                                     
                                     ),
                                     selectizeInput(
                                       inputId = "STANDARD_SAMPLE_REGULATORY_ELEMENTS",
                                       label = "2. Filter by cis-regulatory elements:",
                                       choices = NULL,
                                       multiple = T,
                                       
                                       options = list(placeholder = "Start typing and select from list or enter a custom value...",
                                                      delimiter = " ",
                                                      create = TRUE)
                                     )
                     ),
                     bsCollapsePanel("Species & Library Strategies", value = "standard_species_libraries",
                                     fluidRow(
                                       column(6, checkboxGroupInput(inputId = "STANDARD_SAMPLE_SPECIES",
                                                                    label = "Filter by species:",
                                                                    choiceNames = NULL,
                                                                    choiceValues = NULL)
                                       ),
                                       column(6,
                                              checkboxGroupInput(inputId = "STANDARD_SAMPLE_LIBRARY",
                                                                 label = "Filter by library strategy:",
                                                                 choiceNames = NULL,
                                                                 choiceValues = NULL))
                                     )
                     ),
                     bsCollapsePanel("Cell Type", value = "standard_cell_types",
                                     div(class="multicol",
                                         checkboxGroupInput(inputId = "STANDARD_SAMPLE_CELLTYPE",
                                                            label = "Filter by cell type:",
                                                            choiceNames = NULL,
                                                            choiceValues = NULL,
                                                            inline = T
                                         )   
                                     )                       
                     ),
                     bsCollapsePanel("Associated Literature", value = "standard_literature",
                                     radioButtons(
                                       inputId = "STANDARD_LITERATURE",
                                       label = "1. Search By:",
                                       choiceNames = c("PubMed ID", "Article Title", "Research Group", "GEO Number"),
                                       choiceValues = c("pmid", "title", "lab", "geo"),
                                       selected = "pmid",
                                       inline = T
                                     ),
                                     textInput(
                                       inputId = "STANDARD_LITERATURE_INPUT",
                                       label = "2. Enter your search terms:",
                                       placeholder = "Enter text here..."
                                     ),
                                     p(HTML("<b>Note:</b> For PubMed or GEO, enter one or more IDs separated by spaces. For article titles, use free text."))
                     )
                   ),
                   fluidRow(
                     column(6,
                            actionButton(inputId = "standard_submit", label = "Search Samples", icon=icon("search"), class="btn-primary", style="width:100%")
                     ),
                     column(6,
                            actionButton(inputId = "standard_clear", label = "Clear", icon=icon("trash"), class="btn-danger", style="width:100%")
                     )
                   )
      ),
      mainPanel(
        fluidRow(
          column(6,
                 h4("Species / Cell Lines", style='text-align:center !important;'),
                 shinycssloaders::withSpinner(
                   plotly::plotlyOutput("standard_pie_species_celltypes", height="300px")
                 )
          ),
          column(6,
                 h4("Library Strategy", style='text-align:center !important;'),
                 shinycssloaders::withSpinner(
                   plotly::plotlyOutput("standard_pie_libraries", height="300px")
                 )
          )
        ),
        fluidRow(
          column(12,
                 div(id="standard_datasets_msg", span("Scroll down to view the samples of the selected datasets."),
                     style="display:none"),
                 shinycssloaders::withSpinner(
                   DT::dataTableOutput("standard_samples_table")
                 )
          )
        )
      )
    ),
    fluidRow(
      column(12,
             div(id = "standard_datasets_panel", style="display:none",
                 h3("Selected datasets"),
                 div(style="height:30px",
                     actionButton(inputId = "standard_dataset_download_btn", label = "Download Selected", class = "btn-success", icon = icon("download"), style="display:none"),
                     actionButton(inputId = "standard_dataset_analyze_btn", label = "Replicate Visualization", class = "btn-info", icon = icon("chart-line"), style="display:none")
                 ),
                 shinycssloaders::withSpinner(
                   DT::dataTableOutput("standard_datasets_table")
                 )
             )
      )
    )
  )
}