server <- function(input, output, session) {
  source("functions/system.R", local = T)
  source("functions/plots.R", local = T)
  source("functions/sqlite.R", local = T)
  source("functions/samples.R", local = T)
  source("functions/datasets.R", local = T)
  source("functions/genomeViewer.R", local = T)
  source("functions/libraries.R", local = T)
  source("functions/variants.R", local = T)
  source("functions/init.R", local = T)
  source("functions/downloads.R", local = T)
  
  #app initialization ####
  initializeApp()

  # Standard MPRA Controls ####
  
  # Search field events ####
  observeEvent(input$STANDARD_SAMPLE_REGULATORY_SPECIES, {
    SEARCH_FIELDS[["STANDARD_SAMPLE_REGULATORY_SPECIES"]] <<- input$STANDARD_SAMPLE_REGULATORY_SPECIES
    updateLibraryCoordinateRelativeSearch(SEARCH_FIELDS[["STANDARD_SAMPLE_REGULATORY_SPECIES"]])
  }, ignoreInit = T, ignoreNULL = F)
  
  observeEvent(input$STANDARD_SAMPLE_REGULATORY_ELEMENTS, {
    SEARCH_FIELDS[["STANDARD_SAMPLE_REGULATORY_ELEMENTS"]] <<- input$STANDARD_SAMPLE_REGULATORY_ELEMENTS
    SEARCH_FIELDS[["STANDARD_SAMPLE_REGULATORY_SPECIES"]] <<- input$STANDARD_SAMPLE_REGULATORY_SPECIES
  }, ignoreInit = T, ignoreNULL = F)
  
  observeEvent(input$STANDARD_SAMPLE_SPECIES, {
    SEARCH_FIELDS[["STANDARD_SAMPLE_SPECIES"]] <<- input$STANDARD_SAMPLE_SPECIES
  }, ignoreInit = T, ignoreNULL = F)
  
  observeEvent(input$STANDARD_SAMPLE_CELLTYPE, {
    SEARCH_FIELDS[["STANDARD_SAMPLE_CELLTYPE"]] <<- input$STANDARD_SAMPLE_CELLTYPE
  }, ignoreInit = T, ignoreNULL = F)
  
  observeEvent(input$STANDARD_SAMPLE_LIBRARY, {
    SEARCH_FIELDS[["STANDARD_SAMPLE_LIBRARY"]] <<- input$STANDARD_SAMPLE_LIBRARY
  }, ignoreInit = T, ignoreNULL = F)
  
  observeEvent(input$standard_submit, {
    handleStandardMPRASamplesQuery()
  }, ignoreInit = T)
  
  observeEvent(input$standard_clear, {
  shinyjs::reset("STANDARD")
  shinyWidgets::updateRadioGroupButtons(session, "STANDARD_SAMPLE_REGULATORY_SPECIES", selected = "all")
    initializeStandardMPRA()
  }, ignoreInit = T)
  
  # select samples checkboxes ####
  observeEvent(input$STANDARD_SAMPLE_ID, {
    handleDatasetsQuery(input$STANDARD_SAMPLE_ID)
  }, ignoreInit = T, ignoreNULL = F)
  
  # select datasets checkboxes ####
  observeEvent(input$STANDARD_DATASET_SELECTED_ID, {
    if(!is.null(input$STANDARD_DATASET_SELECTED_ID)) {
      STANDARD_DOWNLOAD_SELECTION <<- unique(c(STANDARD_DOWNLOAD_SELECTION, unlist(strsplit(input$STANDARD_DATASET_SELECTED_ID, ","))))
      shinyjs::show("standard_dataset_download_btn")
      shinyjs::show("standard_dataset_analyze_btn")
    }
    else {
      shinyjs::hide("standard_dataset_download_btn")
      shinyjs::hide("standard_dataset_analyze_btn")
      STANDARD_DOWNLOAD_SELECTION <<- c()
    }
  }, ignoreInit = T, ignoreNULL = F)
  
  observeEvent(input$standard_dataset_download_btn, {
    selectedDatasetsDownload(STANDARD_DOWNLOAD_SELECTION, STANDARD_SAMPLES_RESULT, STANDARD_DATASETS_RESULT)
  }, ignoreInit = T)
  
  observeEvent(input$standard_dataset_analyze_btn, {
    analyzeLibraryReplicates(STANDARD_DOWNLOAD_SELECTION, F)
  }, ignoreInit = T)
  
  observeEvent(input$library_subset_selector, {
    force_total <- F
    if(input$library_subset_selector == "total") {
      force_total <- T
    }
    analyzeLibraryReplicates(STANDARD_DOWNLOAD_SELECTION, F, force_total)
  }, ignoreInit = T)
  
  
  
  # Synthetic MPRA Controls ####
  
  observeEvent(input$SYNTHETIC_SAMPLE_REGULATORY_ELEMENTS, {
    SEARCH_FIELDS[["SYNTHETIC_SAMPLE_REGULATORY_ELEMENTS"]] <<- input$SYNTHETIC_SAMPLE_REGULATORY_ELEMENTS
    SEARCH_FIELDS[["SYNTHETIC_SAMPLE_REGULATORY_SPECIES"]] <<- "all"
  }, ignoreInit = T, ignoreNULL = F)
  
  observeEvent(input$SYNTHETIC_SAMPLE_SPECIES, {
    SEARCH_FIELDS[["SYNTHETIC_SAMPLE_SPECIES"]] <<- input$SYNTHETIC_SAMPLE_SPECIES
  }, ignoreInit = T, ignoreNULL = F)
  
  observeEvent(input$SYNTHETIC_SAMPLE_CELLTYPE, {
    SEARCH_FIELDS[["SYNTHETIC_SAMPLE_CELLTYPE"]] <<- input$SYNTHETIC_SAMPLE_CELLTYPE
  }, ignoreInit = T, ignoreNULL = F)
  
  observeEvent(input$SYNTHETIC_SAMPLE_LIBRARY, {
    SEARCH_FIELDS[["SYNTHETIC_SAMPLE_LIBRARY"]] <<- input$SYNTHETIC_SAMPLE_LIBRARY
  }, ignoreInit = T, ignoreNULL = F)
  
  observeEvent(input$synthetic_submit, {
    handleSyntheticMPRASamplesQuery()
  }, ignoreInit = T)
  
  observeEvent(input$synthetic_clear, {
    shinyjs::reset("SYNTHETIC")
    shinyWidgets::updateRadioGroupButtons(session, "SYNTHETIC_SAMPLE_REGULATORY_SPECIES", selected = "all")
    initializeSyntheticMPRA()
  }, ignoreInit = T)
  
  
  # select samples checkboxes ####
  observeEvent(input$SYNTHETIC_SAMPLE_ID, {
    handleDatasetsQuery(input$SYNTHETIC_SAMPLE_ID, T)
  }, ignoreInit = T, ignoreNULL = F)
  
  # select datasets checkboxes ####
  observeEvent(input$SYNTHETIC_DATASET_SELECTED_ID, {
    if(!is.null(input$SYNTHETIC_DATASET_SELECTED_ID)) {
      SYNTHETIC_DOWNLOAD_SELECTION <<- unique(c(SYNTHETIC_DOWNLOAD_SELECTION, unlist(strsplit(input$SYNTHETIC_DATASET_SELECTED_ID, ","))))
      shinyjs::show("synthetic_dataset_download_btn")
      shinyjs::show("synthetic_dataset_analyze_btn")
    }
    else {
      shinyjs::hide("synthetic_dataset_download_btn")
      shinyjs::hide("synthetic_dataset_analyze_btn")
      SYNTHETIC_DOWNLOAD_SELECTION <<- c()
    }
  }, ignoreInit = T, ignoreNULL = F)
  
  
  observeEvent(input$synthetic_dataset_download_btn, {
    selectedDatasetsDownload(SYNTHETIC_DOWNLOAD_SELECTION, SYNTHETIC_SAMPLES_RESULT, SYNTHETIC_DATASETS_RESULT)
  }, ignoreInit = T)
  
  observeEvent(input$synthetic_dataset_analyze_btn, {
    analyzeLibraryReplicates(SYNTHETIC_DOWNLOAD_SELECTION, synthetic = T)
  }, ignoreInit = T)
  
  
  # replicates library viewer controls ####
  observeEvent(input$library_show_table, {
    handleReplicatesTableViewer()
  }, ignoreInit = T)
  
  observeEvent(input$IGV_GENOME_AND_LOCUS, {
     
     handleGenomeViewerInput(update = T)
  }, ignoreInit = T, ignoreNULL = T)
  
  
  # saturation-mutagenesis controls ####
  observeEvent(input$variant_study, {
    updateVariantsBasedOnSelectedStudy(input$variant_study)
  }, ignoreInit = T, ignoreNULL = T)
  
  
  observeEvent(input$variant_chromosome, {
    updateVariantFieldsByChromosome(input$variant_chromosome)
  }, ignoreInit = T)
  
  observeEvent(input$variant_gene, {
    updateVariantGenePosFields(input$variant_gene)
  }, ignoreInit = T)
  
  observeEvent(input$variant_submit, {
    searchVariantData()
  }, ignoreInit = T)
  
  observeEvent(input$variant_clear, {
    initVariantSearchFields()
  }, ignoreInit = T)
  
  # on session end, close the SQLite DB ####
  shiny::onSessionEnded(
    function() {
      closeDatabaseConnection()
      initializeGlobalsStandardMPRA()
      initializeGlobalsVariant()
    },
    session = session
  )
}