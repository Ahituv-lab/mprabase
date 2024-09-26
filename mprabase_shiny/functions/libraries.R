# library sequence queries ####
getLibraryCisElements <- function() {
  sql <- "SELECT library_sequence.element_coordinate as coord, library_sequence.genome_build as genome FROM library_sequence"
  results <- executeQuery(sql)
  results <- results[!is.na(results$coord),]
  coords <-list()
  lapply(unique(results$genome), function(i) {
    coords[[i]] <<- sort(unique(results[results$genome == i,]$coord))
  })
  coords[['all']] <- sort(unique(results$coord))
  
  # now, for the synthetic libraries, where the coords are in 'library_element_name'
  sql <- "SELECT library_sequence.library_element_name, library_sequence.genome_build  FROM library_sequence WHERE genome_build = '' OR genome_build IS NULL"
  results <- executeQuery(sql)
  results <- results[!is.na(results$library_element_name),]
  coord_synth <- unlist(
    lapply(results$library_element_name, function(r) {
      c <- unlist(regmatches(r,
                             regexec(".*\\:(\\w+\\d+\\:\\d+\\-\\d+)\\:*", r, fixed = F, perl = T)
      ))
      if(length(c)>1)
        return(c[2])
    })
  )
  coords[['synthetic']] <- sort(unique(coord_synth))
  return(coords)
}


loadLibraryCoordinates <- function(rds = T) {
  if(!file.exists("data/rds/cisRegElements.RDS")){
    rds <- F
  }
  if(rds == T) {
    print_stderr("Reading cis-regulatory elements from RDS file...")
    STANDARD_MPRA_SELECTIZE_COORDS <<- readRDS("data/rds/cisRegElements.RDS")
  }
  else {
    print_stderr("No RDS found, querying cis-regulatory elements from DB...")
    STANDARD_MPRA_SELECTIZE_COORDS <<- getLibraryCisElements()
    saveRDS(STANDARD_MPRA_SELECTIZE_COORDS, "data/rds/cisRegElements.RDS")
  }
}

loadLiftoverCoordinates <- function() {
  hg38 <- readRDS("data/rds/hg38CustomLiftover.RDS")
  mm10 <- readRDS("data/rds/mm10CustomLiftover.RDS")
  
  if ("hg38" %in% names(STANDARD_MPRA_SELECTIZE_COORDS)) {
    hg38_new_coords <- unique(c(unlist(STANDARD_MPRA_SELECTIZE_COORDS[["hg38"]]), (hg38$coord)))
    STANDARD_MPRA_SELECTIZE_COORDS[["hg38"]] <<- hg38_new_coords
  }
  else {
    STANDARD_MPRA_SELECTIZE_COORDS[["hg38"]] <<- unique(unlist(hg38$coord))
  }
  
  if ("mm10" %in% names(STANDARD_MPRA_SELECTIZE_COORDS)) {
    mm10_new_coords <- unique(c(unlist(STANDARD_MPRA_SELECTIZE_COORDS[["mm10"]]), (mm10$coord)))
    STANDARD_MPRA_SELECTIZE_COORDS[["mm10"]] <<- mm10_new_coords
  }
  else {
    STANDARD_MPRA_SELECTIZE_COORDS[["mm10"]] <<- unique(unlist(mm10$coord))
  }
  
  STANDARD_MPRA_LIFTOVER_COORDS[["hg38"]] <<- hg38
  STANDARD_MPRA_LIFTOVER_COORDS[["mm10"]] <<- mm10
}



updateLibraryCoordinateRelativeSearch <- function(genome = NULL, rds = T) {
  if(is.null(genome)) {
    vals <- STANDARD_MPRA_SELECTIZE_COORDS[['all']]
  }
  # else if(genome == "synthetic") {
  #   vals <- NULL
  # }
  else {
    vals <- STANDARD_MPRA_SELECTIZE_COORDS[[genome]]
  }
  updateSelectizeInput(inputId = "STANDARD_SAMPLE_REGULATORY_ELEMENTS", choices = vals, server = T)
  updateSelectizeInput(inputId = "SYNTHETIC_SAMPLE_REGULATORY_ELEMENTS", choices = STANDARD_MPRA_SELECTIZE_COORDS[['synthetic']], server = T)
}

getCoordinatesFromCustomRange <- function(range = NULL, genome = NULL) {
  if(is.null(genome)) {
    vals <- STANDARD_MPRA_SELECTIZE_COORDS[['all']]
  }
  # else if(genome == "synthetic") {
  #   vals <- NULL
  # }
  else {
    vals <- STANDARD_MPRA_SELECTIZE_COORDS[[genome]]
  }
  if(!is.null(vals)) {
    input_fields <- unlist(strsplit(range, ":|-"))
    input_chr <- input_fields[1]
    input_range <- as.numeric(
      c(
        gsub(",", "", input_fields[2]), 
        gsub(",", "", input_fields[3])
      )
    )
    test_vals <- vals[grepl(sprintf("%s:",input_chr), vals)]
    vals_df <- data.frame()
    lapply(test_vals, function(val) {
      row <- unlist(strsplit(val, ":|-"))
      vals_df <<- rbind(
        vals_df, c(
          row[1], as.numeric(gsub(",", "", row[2])), as.numeric(gsub(",", "", row[3]))
        )
      )
    })
    colnames(vals_df) <- c("chr","start", "end")
    vals_selected <- dplyr::filter(vals_df, start >= input_range[1] & end <= input_range[2])
    if(!is.null(vals_selected) && nrow(vals_selected) > 0) {
      selected_ranges <- unlist(
        lapply(1:nrow(vals_selected), function(i) {
          return(sprintf("%s:%s-%s", vals_selected$chr[i], as.character(vals_selected$start[i]), as.character(vals_selected$end[i])))
        })
      )
    }
    else {
      selected_ranges <- NULL
    }
  } 
  else {
    selected_ranges <- NULL
  }
  if(!is.null(selected_ranges))
    return(selected_ranges)
  else
    return(range)
}


getAllLibraryMetadata <- function(samples = NULL) {
  sql <- "SELECT library_sequence.library_element_id, library_sequence.genome_build, designed_library.library_name, library_sequence.library_element_name, library_sequence.element_coordinate, \
  element_rep_score.REP1, element_rep_score.REP2, element_rep_score.REP3, element_score.score, library_sequence.sequence \
  FROM library_sequence INNER JOIN element_rep_score ON library_sequence.library_element_id = element_rep_score.library_element_id \
  INNER JOIN designed_library on library_sequence.library_id = designed_library.library_id \
  INNER JOIN element_score on element_rep_score.library_element_id = element_score.library_element_id"
  if (!is.null(samples)) {
    sql <- sprintf("%s WHERE element_rep_score.sample_id in ('%s')", sql,
                   paste0(samples, collapse = "', '")
    )
    result <- executeQuery(sql)
    return(result)
  }
}


filterLibraryMetadataByUserSearch <- function(lib, synthetic = T) {
  if(synthetic == F){
    if(length(STANDARD_SAMPLES_SEARCHED_COORDS)) {
      total <- lib
      subset <- lib[lib$element_coordinate %in% STANDARD_SAMPLES_SEARCHED_COORDS,]
    }
    else {
      subset <- lib
      total <- lib
    }
  }
  else {
    subset <- lib
    total <- lib
  }
  return(
    list("total" = total, "subset" = subset)
  )
}


analyzeLibraryReplicates <- function(sample, synthetic = F, force_total = F) {
  renderModal("Gathering data for replicate analysis...")
  shinyjs::hide("library_viewer")
  shinyjs::hide("library_table_div")
  hideTab(inputId = "library_viewer_graphs", target = "library_viewer_graphs_igv")
  samples <- unlist(lapply(sample, function(i) {
    d <- unlist(strsplit(i, ";"))
    return(d[2])
  }))
  library_all <- getAllLibraryMetadata(samples)
  if(nrow(library_all)>0) {
    library_processed <- filterLibraryMetadataByUserSearch(library_all, synthetic = synthetic)
    
    SELECTED_LIBRARY_REPLICATES <<- library_processed
    if(nrow(SELECTED_LIBRARY_REPLICATES$subset) != nrow(SELECTED_LIBRARY_REPLICATES$total))
      shinyjs::show("wrapper_library_subset_selector")
    else
      shinyjs::hide("wrapper_library_subset_selector")
    lib <- library_processed$subset
    if(force_total == T)
      lib <- library_processed$total
    rep1_log <- c()
    rep2_log <- c()
    rep3_log <- c()
    lapply(1:nrow(lib), function(i) {
      if(lib$REP1[i] != 0 && trimws(lib$REP1[i]) != "" && !is.null(lib$REP1[i]) && !is.na(lib$REP1[i]))
        rep1_log[i] <<- log(as.numeric(lib$REP1[i]), 2)
      else
        rep1_log[i] <<- log(0.0001, 2)
      if(lib$REP2[i] != 0 && trimws(lib$REP2[i]) != "" && !is.null(lib$REP2[i]) && !is.na(lib$REP2[i]))
        rep2_log[i] <<- log(as.numeric(lib$REP2[i]), 2)
      else
        rep2_log[i] <<- log(0.0001, 2)
      if(lib$REP3[i] != 0 && trimws(lib$REP3[i]) != "" && !is.null(lib$REP3[i]) && !is.na(lib$REP3[i]))
        rep3_log[i] <<- log(as.numeric(lib$REP3[i]), 2)
      else
        rep3_log[i] <<- log(0.0001, 2)
    })
    
    output$scatter_rep1_2 <- renderScatterPlot(rep1_log, rep2_log, title = "RNA/DNA NT-1 vs NT-2", xaxis = "NT-1 (log2)", yaxis = "NT-2 (log2)")
    output$scatter_rep1_3 <- renderScatterPlot(rep1_log, rep3_log, title = "RNA/DNA NT-1 vs NT-3", xaxis = "NT-1 (log2)", yaxis = "NT-3 (log2)")
    output$scatter_rep2_3 <- renderScatterPlot(rep2_log, rep3_log, title = "RNA/DNA NT-2 vs NT-3", xaxis = "NT-2 (log2)", yaxis = "NT-3 (log2)")
    
    
    showTab(inputId = "top_menu", target = "analysis_page")
    
    updateNavbarPage(session, "top_menu", "analysis_page") 
    shinyjs::show("library_viewer")
    updateTabsetPanel(session, "library_viewer_graphs", "library_viewer_graphs_plots")
  }
  else {
    renderError("The selected dataset has no element coordinates.")
  }
  removeModal()
}

prepareLibraryReplicatesTable <- function(subset = F) {
  renderModal("Preparing replicate data for viewing...")
  lib <- SELECTED_LIBRARY_REPLICATES$total
  if(subset == T)
    lib <- SELECTED_LIBRARY_REPLICATES$subset
  
  if(lib$genome_build[1] == "" || is.null(lib$genome_build[1]) || is.na(lib$genome_build[1]) || is.nan(lib$genome_build[1]))
    synthetic <- T
  else
    synthetic <- F
  if(nrow(lib)>0) {
    shinyjs::show("library_table_div")
    links <- c()
    igvButtons <- c()
    lapply(1:nrow(lib), function(i) {
      if (synthetic == T) {
        splt <- unlist(strsplit(lib$library_element_name[i], ":"))
        lib$genome_build[i] <<- splt[1]
        lib$element_coordinate[i] <<- sprintf("%s:%s", splt[2], splt[3])
      }
      url <- sprintf("https://genome.ucsc.edu/cgi-bin/hgTracks?db=%s&position=%s", lib$genome_build[i], lib$element_coordinate[i])
      links <<- c(links,
                  sprintf("<a href='%s' target='_blank' class='btn btn-info' role='button'>Open in UCSC</a>", url)
      )
      btn <- sprintf("<a class='btn btn-primary' role='button' onclick='openViewerEvent(\"%s\", \"%s\")'>View</a>", lib$genome_build[i], lib$element_coordinate[i])
      igvButtons <<- c(igvButtons,
                       btn
      )
    })
    lib$igv <- igvButtons
    lib$links <- links
    
    lib_render <- subset(lib, select = c(library_name, library_element_name, genome_build, element_coordinate, score, REP1, REP2, REP3, igv, links))
    colnames(lib_render) <- c("Library", "Library Element", "Genome Assembly", "Element coordinates", "Score", "NT-1", "NT-2", "NT-3", " ","  ")
    renderShinyDataTable("dt_library", lib_render, server = T)
    
    
    #handleGenomeViewerInput(lib$genome_build[1], lib$element_coordinate[1])
    
  }
  else {
    renderError("The selected dataset has no element coordinates.")
  }
  removeModal()
}

handleReplicatesTableViewer <- function() {
  subset <- F
  if("library_subset_selector" %in% names(input)) {
    if(input$library_subset_selector == "subset")
      subset <- T
  }
  prepareLibraryReplicatesTable(subset)
}