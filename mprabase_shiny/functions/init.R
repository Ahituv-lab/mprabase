initializeGlobalsStandardMPRA <- function() {
  SEARCH_FIELDS <<- list()
  STANDARD_MPRA_SELECTIZE_COORDS <<- list()
  STANDARD_MPRA_LIFTOVER_COORDS <<- list()
  STANDARD_DOWNLOAD_SELECTION <<- c()
  STANDARD_SAMPLES_SEARCHED_COORDS <<- c()
  STANDARD_SAMPLES_RESULT <<- data.frame()
  STANDARD_DATASETS_RESULT <<- data.frame()
  SELECTED_LIBRARY_REPLICATES <<- data.frame()
}

initializeGlobalsSyntheticMPRA <- function() {
  SYNTHETIC_SAMPLES_RESULT <- data.frame()
  SYNTHETIC_DATASETS_RESULT <- data.frame()
  SYNTHETIC_DOWNLOAD_SELECTION <- c()
}

initializeGlobalsVariant <- function() {
  SATURATION_MUTAGENESIS_METADATA <<- data.frame()
  VARIANTS <<- data.frame()
  
}


initVariantSearchFields <- function() {
  if(nrow(SATURATION_MUTAGENESIS_METADATA) ==0) {
    loadStudyMetaData()
  }
  updateVariantStudySelectField()
  updateVariantsBasedOnSelectedStudy()
}

intializeDatabase <- function() {
  DB_CONNECTION <<- NULL
  openDatabaseConnection()
  checkIndexing()
}

initializeStandardMPRA <- function() {
  initializeGlobalsStandardMPRA()
  loadLibraryCoordinates()
  loadLiftoverCoordinates()
  updateLibraryCoordinateRelativeSearch()
  handleStandardMPRASamplesQuery(init = T)
}


initializeSyntheticMPRA <- function() {
  initializeGlobalsSyntheticMPRA()
  #loadLibraryCoordinates()
  #loadLiftoverCoordinates()
  #updateLibraryCoordinateRelativeSearch()
  handleSyntheticMPRASamplesQuery(init = T)
}

initializeVariantMPRA <- function() {
  initializeGlobalsVariant()
  initVariantSearchFields()
}
initializeApp <- function() {
  tryCatch({
    hideTab(inputId = "top_menu", target = "analysis_page")
    hideTab(inputId = "library_viewer_graphs", target = "library_viewer_graphs_igv")
    intializeDatabase()
    initializeStandardMPRA()
    initializeSyntheticMPRA()
    initializeVariantMPRA()

  }, error = function(e) {
    print_stderr(sprintf("Error: %s", e))
  }
  )
}