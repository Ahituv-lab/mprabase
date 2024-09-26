analysisPage <- function() {
  fluidPage(
    h1("Library Viewer", style="text-align:center"),
    hr(),
    div(id = "library_viewer", style="display:none",
        tabsetPanel(id = "library_viewer_graphs",
                    tabPanel("RNA/DNA Correlations",
                             value = "library_viewer_graphs_plots",
                             id = "library_viewer_graphs_plots",
                             fluidRow(
                               column(4,
                                      h4("RNA/DNA Replicate Distribution")
                               ),
                               column(8,
                                      div(id = "wrapper_library_subset_selector", style="display:none",
                                          HTML("<span class='bg-secondary-subtle'><b>Note:</b> Results by default are shown for the subset of library elements matching the user's coordinate search. To change this, use the selector below.</span>"),
                                          radioButtons(
                                            inputId = "library_subset_selector",
                                            label = "Select coordinates to view:",
                                            choiceNames = c("User-defined", "All"),
                                            choiceValues = c("subset", "total"),
                                            selected = "subset",
                                            inline = T
                                          ),
                                          uiOutput("library_custom_user_coordinates")
                                      )
                               )
                             ),
                             
                             fluidRow(
                               column(4,
                                      shinycssloaders::withSpinner(
                                        plotly::plotlyOutput("scatter_rep1_2")
                                      )
                               ),
                               column(4,
                                      shinycssloaders::withSpinner(
                                        plotly::plotlyOutput("scatter_rep1_3")
                                      )
                               ),
                               column(4,
                                      shinycssloaders::withSpinner(
                                        plotly::plotlyOutput("scatter_rep2_3")
                                      )
                               )
                             ),
                             
                    ),
                    tabPanel("Genome Viewer",
                             value = "library_viewer_graphs_igv",
                             id = "library_viewer_graphs_igv",
                             shinycssloaders::withSpinner(
                               uiOutput("igv_library")
                               
                               
                             )
                    )
        ),
        br(),
        hr(),
        actionButton(
          inputId = "library_show_table",
          label = "View library elements",
          class = "btn-success",
          icon = icon("table")
        ),
        
        br(),
        div(id = "library_table_div", style="display:none",
            h4("Library Elements"),
            tags$br(),
            shinycssloaders::withSpinner(
              DT::dataTableOutput("dt_library")
            )
        )
    )
  ) 
}