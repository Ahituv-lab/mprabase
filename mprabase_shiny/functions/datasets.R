# datasets ####
queryDatasets <- function(SAMPLE_ID = NULL) {
  sql <- "SELECT
datasets.datasets_id as datasetId,
datasets.datasets_name as datasetName,
sample.sample_id as sampleId,
datasets.PMID as pmid,
datasets.GEO_number as geoNumber,
datasets.Reference as reference,
datasets.labs as lab,
sample.sample_name as sampleName,
sample.Library_strategy as libraryStrategy,
sample.Organism as organism,
sample.Cell_line_tissue as cellLine,
sample.element_position as elementPosition,
sample.DNA_RNA_reps as replicates,
designed_library.library_name as libraryName,
designed_library.number_of_elements as numberElements,
sample.description as sampleDescription,
sample.GenomeBrowser as GenomeBrowser
FROM datasets
INNER JOIN designed_library ON datasets.datasets_id = designed_library.datasets_id
INNER JOIN sample ON designed_library.library_id = sample.library_id
"
  if(!is.null(SAMPLE_ID)) {
    sql <- sprintf("%s WHERE sample.sample_id in ('%s')",
                   sql,
                   paste0(SAMPLE_ID, collapse = "', '")
    )
  }
  result <- executeQuery(sql)
  return(result)
}

formatDatasetsTable <- function(datasetsTable, synthetic = F) {
  checkbuttons <- c()
    lapply(1:nrow(datasetsTable), function(i){
      gb <- datasetsTable$GenomeBrowser[i]
      if(!is.null(gb) && !is.na(gb) && trimws(gb) !="") {
        if(grepl(".bed", gb)) {
          bed <- unlist(strsplit(gb, ";"))
          links <- unlist(lapply(bed, function(b) {
            return(sprintf("<a target='_blank' href='https://data.cyverse.org/dav-anon/iplant/home/jjzhao123/mprabase/%s'>%s</a>", b, b))
          }))
          link <- paste(links, collapse = ", ")
        }
        else {
          link <- sprintf("<a target='_blank' href='%s'>%s</a>", gb, gb)
        }
      }
      else {
        link <- "N/A"
      }
      datasetsTable$GenomeBrowser[i] <<- link
      
      datasetsTable$pmid[i] <<- applyHyperlink(datasetsTable$pmid[i], "https://pubmed.ncbi.nlm.nih.gov/")
      datasetsTable$geoNumber[i] <<- applyHyperlink(datasetsTable$geoNumber[i],"https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=")
      
      datasetsTable$organism[i] <<- paste0("<i>", datasetsTable$organism[i], "</i>")
      checkbox_name <- 'standard_datasets_check[]'
      onchange <- 'datasets_updateSelected()'
      if(synthetic == T) {
        datasetsTable$organism[i] <<- paste(datasetsTable$organism[i], "(synthetic)")
        checkbox_name <- 'synthetic_datasets_check[]'
        onchange <- 'datasets_updateSelected(synthetic=true)'
      }
      checkbuttons[i] <<- sprintf("<input type='checkbox' name='%s' value='%s;%s' onchange='%s'/>", checkbox_name, datasetsTable$datasetId[i], datasetsTable$sampleId[i], onchange)
    })
  datasetsTable$cb <- checkbuttons
  datasetsTable <- datasetsTable %>% select(cb, everything())
  datasetsTable <- datasetsTable %>% select(-c("GenomeBrowser"))
  colnames(datasetsTable) <- c('Select', 'Dataset ID', 'Dataset Name', 'Sample ID', 'PMID', 'GEO Number', 'Reference', 'Labs', 'Sample Name', 
                               'Library Strategy', 'Species', 'Cell Type', 'Element Position', 'DNA/RNA replicates',
                               'Library Name', 'No. of elements', 'Description')
  return(datasetsTable)
}

handleDatasetsQuery <- function(SAMPLE_ID, synthetic = F) {
  prefix <- "standard"
  if(synthetic == T)
    prefix <- "synthetic"
  if(!is.null(SAMPLE_ID)) {
    SAMPLE_ID <- unlist(strsplit(SAMPLE_ID, ","))
    selectedDatasets <- queryDatasets(SAMPLE_ID)
    STANDARD_DATASETS_RESULT <<- selectedDatasets
    renderShinyDataTable(sprintf("%s_datasets_table", prefix), formatDatasetsTable(selectedDatasets, synthetic = synthetic), dom = 'rtp')
    shinyjs::show(sprintf("%s_datasets_panel", prefix))
    shinyjs::show(sprintf("%s_datasets_msg", prefix))
  }
  else {
    STANDARD_DATASETS_RESULT <<- data.frame()
    renderShinyDataTable("standard_datasets_table", STANDARD_DATASETS_RESULT)
    shinyjs::hide("datasets_panel")
    shinyjs::hide("datasets_msg")
  }
}