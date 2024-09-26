# parse search options for standard/synthetic MPRA ####

parseMPRASampleSearchFields <- function(synthetic = F) {
  tryCatch({
    prefix <- "STANDARD"
    if(synthetic == T) {
      prefix <- "SYNTHETIC"
    }
    
    #for the literature text search, parse the relevant text fields
    SEARCH_FIELDS[[sprintf("%s_LITERATURE", prefix)]] <<- input[[sprintf("%s_LITERATURE", prefix)]]
    SEARCH_FIELDS[[sprintf("%s_LITERATURE_INPUT", prefix)]] <<- input[[sprintf("%s_LITERATURE_INPUT", prefix)]]
    search_params <- c()
    if(sprintf("%s_SAMPLE_SPECIES", prefix) %in% names(SEARCH_FIELDS) && length(SEARCH_FIELDS[[sprintf("%s_SAMPLE_SPECIES", prefix)]]) > 0) {
      search_params <- c(search_params, sprintf("sample.Organism IN ('%s')",
                                                paste0(SEARCH_FIELDS[[sprintf("%s_SAMPLE_SPECIES", prefix)]], collapse = "', '")
      ))
    }
    if(sprintf("%s_SAMPLE_CELLTYPE", prefix) %in% names(SEARCH_FIELDS) && length(SEARCH_FIELDS[[sprintf("%s_SAMPLE_CELLTYPE", prefix)]]) > 0) {
      search_params <- c(search_params, sprintf("sample.Cell_line_tissue IN ('%s')",
                                                paste0(SEARCH_FIELDS[[sprintf("%s_SAMPLE_CELLTYPE", prefix)]], collapse = "', '")
      ))
    }
    if(sprintf("%s_SAMPLE_LIBRARY", prefix) %in% names(SEARCH_FIELDS) && length(SEARCH_FIELDS[[sprintf("%s_SAMPLE_LIBRARY", prefix)]]) > 0) {
      search_params <- c(search_params, sprintf("sample.Library_strategy IN ('%s')",
                                                paste0(SEARCH_FIELDS[[sprintf("%s_SAMPLE_LIBRARY", prefix)]], collapse = "', '")
      ))
    }
    if(sprintf("%s_LITERATURE", prefix) %in% names(SEARCH_FIELDS) && trimws(SEARCH_FIELDS[[sprintf("%s_LITERATURE_INPUT", prefix)]]) != "") {
      if(SEARCH_FIELDS[[sprintf("%s_LITERATURE", prefix)]] == "pmid") {
        pmids <- paste0(unlist(strsplit(trimws(SEARCH_FIELDS[[sprintf("%s_LITERATURE_INPUT", prefix)]]), " ")), collapse = ",")
        lit_search <- sprintf(" datasets.PMID in (%s)", pmids)
      }
      else if(SEARCH_FIELDS[[sprintf("%s_LITERATURE", prefix)]] == "geo") {
        geo <- paste0(unlist(strsplit(trimws(SEARCH_FIELDS[[sprintf("%s_LITERATURE_INPUT", prefix)]]), " ")), collapse = ",")
        lit_search <- sprintf(" datasets.GEO_number in ('%s')", geo)
      }
      else if(SEARCH_FIELDS[[sprintf("%s_LITERATURE", prefix)]] == "lab") {
        lit_search <- sprintf("datasets.labs like '%%%s%%'", trimws(SEARCH_FIELDS[[sprintf("%s_LITERATURE_INPUT", prefix)]]))
      }
      else {
        lit_search <- sprintf("datasets.Reference like '%%%s%%'", trimws(SEARCH_FIELDS[[sprintf("%s_LITERATURE_INPUT", prefix)]]))
      }
      search_params <- c(search_params, lit_search)
    }
    
    if(sprintf("%s_SAMPLE_REGULATORY_ELEMENTS", prefix) %in% names(SEARCH_FIELDS) && length(SEARCH_FIELDS[[sprintf("%s_SAMPLE_REGULATORY_ELEMENTS", prefix)]]) > 0) {
      elements <- c()
      lapply(SEARCH_FIELDS[[sprintf("%s_SAMPLE_REGULATORY_ELEMENTS", prefix)]], function(ele) {
        if(ele %in% STANDARD_MPRA_SELECTIZE_COORDS) {
          elements <<- c(elements, ele)
        }
        else {
          in_custom <- getCoordinatesFromCustomRange(ele, SEARCH_FIELDS[[sprintf("%s_SAMPLE_REGULATORY_SPECIES", prefix)]])
          if(!is.null(in_custom)) {
            lapply(in_custom, function(cus) {
              elements <<- c(elements, cus)
            })
          }
        }
      })
      if(length(elements) > 0) {
        
        searched_coordinates <- elements
        
        sql <- sprintf("sample.library_id in (SELECT DISTINCT(library_sequence.library_id) FROM library_sequence WHERE element_coordinate in ('%s')",
                       paste0(elements, collapse = "', '")
        )
        if(sprintf("%s_SAMPLE_REGULATORY_SPECIES", prefix) %in% names(SEARCH_FIELDS)) {
          
          if(SEARCH_FIELDS[[sprintf("%s_SAMPLE_REGULATORY_SPECIES", prefix)]]  == "all") {
            ele_lift_hg38 <- elements[elements %in% STANDARD_MPRA_LIFTOVER_COORDS$hg38$coord]
            hg38_liftover_libs <- unlist(unique(STANDARD_MPRA_LIFTOVER_COORDS$hg38[STANDARD_MPRA_LIFTOVER_COORDS$hg38$coord %in% ele_lift_hg38,]$library))
            ele_lift_mm10 <- elements[elements %in% STANDARD_MPRA_LIFTOVER_COORDS$mm10$coord]
            mm10_liftover_libs <- unlist(unique(STANDARD_MPRA_LIFTOVER_COORDS$mm10[STANDARD_MPRA_LIFTOVER_COORDS$mm10$coord %in% ele_lift_mm10,]$library))
            
            liftover_libs <- unique(c(hg38_liftover_libs, mm10_liftover_libs))
            if(length(liftover_libs) > 0) {
              sql <- sprintf("%s) OR sample.library_id in ('%s')", sql, paste0(liftover_libs, collapse = "', '") )
              searched_coordinates <- unique(c(searched_coordinates, liftover_libs))
            }
            
            else {
              sql<- sprintf("%s)", sql)
            }
          }
          else if(SEARCH_FIELDS[[sprintf("%s_SAMPLE_REGULATORY_SPECIES", prefix)]]  == "hg38"){
            hg38_liftover_libs <- unlist(unique(STANDARD_MPRA_LIFTOVER_COORDS$hg38[STANDARD_MPRA_LIFTOVER_COORDS$hg38$coord %in% elements,]$library))
            if(length(hg38_liftover_libs) > 0) {
              sql <- sprintf("sample.library_id in (select library_id from library_sequence where library_element_id in ('%s'))", paste0(hg38_liftover_libs, collapse = "', '"))
              searched_coordinates <- unique(c(searched_coordinates, hg38_liftover_libs))
            }
            else {
              sql<- sprintf("%s)", sql)
            }
          }
          else if(SEARCH_FIELDS[[sprintf("%s_SAMPLE_REGULATORY_SPECIES", prefix)]]  == "mm10") {
            ele_lift <- elements[elements %in% STANDARD_MPRA_LIFTOVER_COORDS$mm10$coord]
            mm10_liftover_libs <- unlist(unique(STANDARD_MPRA_LIFTOVER_COORDS$mm10[STANDARD_MPRA_LIFTOVER_COORDS$mm10$coord %in% ele_lift,]$library))
            if(length(mm10_liftover_libs) > 0) {
              sql <- sprintf("%s AND genome_build in ('mm10')) OR sample.library_id in (select library_id from library_sequence where library_element_id in ('%s'))", sql,
                             paste0(mm10_liftover_libs, collapse = "', '")
              )
              searched_coordinates <- unique(c(searched_coordinates, mm10_liftover_libs))
            }
            else {
              sql<- sprintf("%s)", sql)
            }
          }
          
          else if(SEARCH_FIELDS[[sprintf("%s_SAMPLE_REGULATORY_SPECIES", prefix)]]  == "synthetic") {
            coord_searches <- unlist(
              lapply(elements, function(e) {
                return(
                  sprintf("library_sequence.library_element_name LIKE '%%%s%%'", e)
                )
              })
            )
            coord_searches <- paste0(coord_searches, collapse = " OR ")
            sql <- sprintf("sample.library_id IN (SELECT DISTINCT(library_sequence.library_id) FROM library_sequence WHERE (genome_build IS NULL OR genome_build IN (' ', '')) AND (%s))", coord_searches)
            
            
          }
          
          else {
            sql <- sprintf("%s AND genome_build in ('%s'))", sql,
                           SEARCH_FIELDS[[sprintf("%s_SAMPLE_REGULATORY_SPECIES", prefix)]]
            )
          }
          
        }
        
        search_params <- c(search_params, sql)
        if(length(searched_coordinates) >0) {
          STANDARD_SAMPLES_SEARCHED_COORDS <<- searched_coordinates
        }
      }
    }
    if(length(search_params) > 0)
      search <- paste0(search_params, collapse = " AND ")
    else
      search <- NULL
  }, error = function(e) {
    print_stderr(e)
    search <- NULL
  },
  finally = function() {
    return(search)
  }
  )
}

# standard MPRA samples ####

queryStandardMPRASamples <- function(search = NULL) {
  sql <- "SELECT
        sample.sample_id AS sampleId,
        sample.sample_name as sampleName,
        sample.Organism AS organism,
        sample.Cell_line_tissue AS cellLine,
        sample.Library_strategy AS libraryStrategy,
        datasets.GEO_number AS geoNumber,
        datasets.PMID AS pmid
      FROM sample
      LEFT JOIN designed_library ON designed_library.library_id = sample.library_id
      LEFT JOIN datasets ON datasets.datasets_id = designed_library.datasets_id
      WHERE (sample.library_id NOT IN (SELECT DISTINCT(library_sequence.library_id) FROM library_sequence WHERE genome_build IS NULL OR genome_build IN (' ', ''))) "
  if (!is.null(search)) {
    sql <- sprintf("%s AND %s", sql, search)
  }
  result <- executeQuery(sql)
  return(result)
}

formatSamplesTable <- function(samplesTable, synthetic = F) {
  cb <- c()
  
  lapply(1:nrow(samplesTable), function(i) {
    
    samplesTable$pmid[i] <<- applyHyperlink(samplesTable$pmid[i], "https://pubmed.ncbi.nlm.nih.gov/")
    samplesTable$geoNumber[i] <<- applyHyperlink(samplesTable$geoNumber[i],"https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=")
    
    samplesTable$organism[i] <<- paste0("<i>", samplesTable$organism[i], "</i>")
    if(synthetic == T)
      samplesTable$organism[i] <<- paste( samplesTable$organism[i], "(synthetic)")
    onchange <- 'samples_updateSelected()'
    checkbox_name <- 'standard_samples_check[]'
    if(synthetic == T) {
      onchange <- 'samples_updateSelected(synthetic=true)'
      checkbox_name <- 'synthetic_samples_check[]'
    }
    cb[i] <<- sprintf("<input type='checkbox' name='%s' value='%s' onchange='%s'/>", checkbox_name, samplesTable$sampleId[i], onchange)
  })
  samplesTable$cb <- cb
  samplesTable <- samplesTable %>% select(cb, everything())
  colnames(samplesTable) <- c("View", "Sample ID", "Sample Name", "Species", "Cell Type", "Library Strategy", "GEO Number", "PMID")
  
  
  return(samplesTable)
}


calcStatistics <- function(samplesTable) {
  species <- unique(unlist(samplesTable$organism))
  counts_species <- unlist(
    lapply(species, function(i) {
      return(nrow(samplesTable[samplesTable$organism == i,]))
    })
  )
  cells <- unique(unlist(samplesTable$cellLine))
  counts_cells <- unlist(
    lapply(cells, function(i) {
      return(nrow(samplesTable[samplesTable$cellLine == i,]))
    })
  )
  libraries <- unique(unlist(samplesTable$libraryStrategy))
  counts_libraries <- unlist(
    lapply(libraries, function(i) {
      return(nrow(samplesTable[samplesTable$libraryStrategy == i,]))
    })
  )
  return(
    list(
      "libraries" = libraries,
      "counts_libraries" = counts_libraries,
      "cells" = cells,
      "counts_cells" = counts_cells,
      "species" = species,
      "counts_species" = counts_species
    )
  )
}


updateStandardMPRASampleSearchFields <- function(statistics) {
  updateCheckboxGroupInput(inputId = "STANDARD_SAMPLE_SPECIES",
                           choiceNames = paste0(statistics[["species"]], " (", statistics[["counts_species"]], ")"),
                           choiceValues = statistics[["species"]])
  updateCheckboxGroupInput(inputId = "STANDARD_SAMPLE_CELLTYPE",
                           choiceNames = paste0(statistics[["cells"]], " (", statistics[["counts_cells"]], ")"),
                           choiceValues = statistics[["cells"]])
  updateCheckboxGroupInput(inputId = "STANDARD_SAMPLE_LIBRARY",
                           choiceNames = paste0(statistics[["libraries"]], " (", statistics[["counts_libraries"]], ")"),
                           choiceValues = statistics[["libraries"]])
}


handleStandardMPRASamplesQuery <- function(init = F) {
  if(init == F) {
    search <- parseMPRASampleSearchFields()
    renderModal("Performing search based on your query parameters...")
  }
  else 
    search <- NULL
  samples <- queryStandardMPRASamples(search = search)
  if(!is.null(samples) && nrow(samples)>0) {
    STANDARD_SAMPLES_RESULT <<- samples
    statistics <- calcStatistics(samples)
    if (is.null(search)) {
      updateStandardMPRASampleSearchFields(statistics)
    }
    plotMPRASamplePieCharts(statistics)
    renderShinyDataTable("standard_samples_table", formatSamplesTable(samples))
    handleDatasetsQuery(NULL)
    removeModal()
  }
  else {
    renderError("No results found for your search parameters.")
    removeModal()
  }
}


# synthetic MPRA Samples ####


querySyntheticMPRASamples <- function(search = NULL) {
  sql <- "SELECT
        sample.sample_id AS sampleId,
        sample.sample_name as sampleName,
        sample.Organism AS organism,
        sample.Cell_line_tissue AS cellLine,
        sample.Library_strategy AS libraryStrategy,
        datasets.GEO_number AS geoNumber,
        datasets.PMID AS pmid
      FROM sample
      LEFT JOIN designed_library ON designed_library.library_id = sample.library_id
      LEFT JOIN datasets ON datasets.datasets_id = designed_library.datasets_id
      WHERE (sample.library_id in (SELECT DISTINCT(library_sequence.library_id) FROM library_sequence WHERE genome_build IS NULL OR genome_build IN (' ', '')))"
  if (!is.null(search)) {
    sql <- sprintf("%s AND %s", sql, search)
  }
  result <- executeQuery(sql)
  return(result)
}


updateSyntheticMPRASampleSearchFields <- function(statistics) {
  updateCheckboxGroupInput(inputId = "SYNTHETIC_SAMPLE_SPECIES",
                           choiceNames = paste0(statistics[["species"]], " (", statistics[["counts_species"]], ")"),
                           choiceValues = statistics[["species"]])
  updateCheckboxGroupInput(inputId = "SYNTHETIC_SAMPLE_CELLTYPE",
                           choiceNames = paste0(statistics[["cells"]], " (", statistics[["counts_cells"]], ")"),
                           choiceValues = statistics[["cells"]])
  updateCheckboxGroupInput(inputId = "SYNTHETIC_SAMPLE_LIBRARY",
                           choiceNames = paste0(statistics[["libraries"]], " (", statistics[["counts_libraries"]], ")"),
                           choiceValues = statistics[["libraries"]])
}

handleSyntheticMPRASamplesQuery <- function(init = F) {
  if(init == F) {
    search <- parseMPRASampleSearchFields(synthetic = T)
    renderModal("Performing search based on your query parameters...")
  }
  else 
    search <- NULL
  samples <- querySyntheticMPRASamples(search = search)
  if(!is.null(samples) && nrow(samples)>0) {
    SYNTHETIC_SAMPLES_RESULT <<- samples
    statistics <- calcStatistics(samples)
    if (is.null(search)) {
      updateSyntheticMPRASampleSearchFields(statistics)
    }
    plotMPRASamplePieCharts(statistics, synthetic = T)
    renderShinyDataTable("synthetic_samples_table", formatSamplesTable(samples, synthetic = T))
    handleDatasetsQuery(NULL, synthetic = T)
    removeModal()
  }
  else {
    renderError("No results found for your search parameters.")
    removeModal()
  }
  
}