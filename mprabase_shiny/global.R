library(shiny)
library(shinyBS)
library(dplyr)





# GLOBAL VARIABLES ####
if(file.exists("data/db/mprabase_current.db")) {
  SQLITE_DB <- "data/db/mprabase_current.db"
} else if(file.exists("data/db/mprabase_backup.db")) {
  SQLITE_DB <- "data/db/mprabase_backup.db"
} else {
  SQLITE_DB <- NULL
}


# COLUMNS TO INDEX PER TABLE
COLUMNS_TO_INDEX <- list(
  "datasets" = c("datasets_id"),
  "designed_library" = c("library_id", "datasets_id"),
  "element_rep_score" = c("element_rep_id", "sample_id", "library_element_id", "REP1", "REP2", "REP3"),
  "element_score" = c("element_sample_id", "library_element_id"),
  "library_sequence" = c("library_element_id", "library_id", "genome_build", "element_coordinate"),
  "sample" = c("sample_id", "Library_strategy", "Organism", "Cell_line_tissue", "library_id")
  
)

# SYSTEM VARIABLES ####
# general
DB_CONNECTION <- NULL
SEARCH_FIELDS <- list()
SELECTED_LIBRARY_REPLICATES <- data.frame()
# standard MPRA
STANDARD_MPRA_SELECTIZE_COORDS <- list()
STANDARD_MPRA_LIFTOVER_COORDS <- list()
STANDARD_SAMPLES_RESULT <- data.frame()
STANDARD_DATASETS_RESULT <- data.frame()
DTANDARD_SAMPLES_SEARCHED_COORDS <- c()
STANDARD_DOWNLOAD_SELECTION <- c()
#synthetic MPRA
SYNTHETIC_SAMPLES_RESULT <- data.frame()
SYNTHETIC_DATASETS_RESULT <- data.frame()
SYNTHETIC_DOWNLOAD_SELECTION <- c()
# saturation/mutagenesis
SATURATION_MUTAGENESIS_METADATA <- data.frame()
VARIANTS <- data.frame()
