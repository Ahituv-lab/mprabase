loadStudyMetaData <- function() {
  study_metadata <- read.table("data/tsv/study_metadata.tsv", sep = "\t", header = T, quote = "")
  SATURATION_MUTAGENESIS_METADATA <<- study_metadata
}

updateVariantStudySelectField <- function(selected = NULL) {
  choices <- c()
  lapply(1:nrow(SATURATION_MUTAGENESIS_METADATA), function(i) {
    choices[SATURATION_MUTAGENESIS_METADATA$study_genome[i]] <<- SATURATION_MUTAGENESIS_METADATA$pmid[i]
  })
  selected_val <- SATURATION_MUTAGENESIS_METADATA$pmid[1]
  if(!is.null(selected)) {
    selected_val <- SATURATION_MUTAGENESIS_METADATA[SATURATION_MUTAGENESIS_METADATA$pmid == selected,]$pmid
  }
  updateSelectInput(session, "variant_study", choices = choices, selected = selected_val)
}


loadVariants <- function(selected = NULL) {
  selected_val <- SATURATION_MUTAGENESIS_METADATA$pmid[1]
  if(!is.null(selected)) {
    selected_val <- SATURATION_MUTAGENESIS_METADATA[SATURATION_MUTAGENESIS_METADATA$pmid == selected,]$pmid
  }
  selected_dataset <- SATURATION_MUTAGENESIS_METADATA[SATURATION_MUTAGENESIS_METADATA$pmid == selected_val,]$dataset_file
  print(sprintf("data/tsv/%s", selected_dataset))
  VARIANTS <<- data.table::as.data.table(
    #readRDS("data/rds/variants.RDS")
    
    read.table(sprintf("data/tsv/%s", selected_dataset), sep = "\t", header = T, quote = "",
               col.names = c("Chromosome", "Position", "Ref", "Alt", "Tags", "DNA", "RNA", "Value", "P.Value", "Element")
    )
  )
  print(VARIANTS)
}

updateVariantsBasedOnSelectedStudy <- function(selected = NULL) {
  loadVariants(selected)
  genes <- formatVariantGeneList()
  updateSelectizeInput(session, "variant_gene", choices = genes, server = T)
  updateVariantGenePosFields(genes$value[1])
  updateVariantStudyDetails(selected)
}


sortVariantChromosomes <- function() {
  chr_tmp <- unique(VARIANTS$Chromosome)
  chromosomes <- sort(as.numeric(chr_tmp[(chr_tmp != "X") & (chr_tmp != "Y")]))
  if("X" %in% chr_tmp)
    chromosomes <- c(chromosomes, "X")
  if("Y" %in% chr_tmp)
    chromosomes <- c(chromosomes, "Y")
  return(chromosomes)
}

formatVariantGeneList <- function() {
  genes <- unique(VARIANTS$Element)
  geneList <- data.frame()
  lapply(genes, function(g) {
    chr <- unique(VARIANTS[VARIANTS$Element == g,]$Chromosome)
    geneList <<- rbind(geneList, 
                       c(
                         sprintf("%s (chr:%s)", g, chr), g
                       )
    )
  })
  colnames(geneList) <- c("label", "value")
  return(geneList)
}

updateVariantGenePosFields <- function(gene) {
  geneLines <- VARIANTS[VARIANTS$Element == gene,]
  
  ref <- sort(unique(geneLines$Ref))
  alt <- sort(unique(geneLines$Alt))
  pos <- c(min(geneLines$Position), max(geneLines$Position))
  tags <- c(min(geneLines$Tags), max(geneLines$Tags))
  coeff <- c(min(geneLines$Value), max(geneLines$Value))
  pval <- c(min(geneLines$P.Value), max(geneLines$P.Value))
  if(is.null(tags)||is.na(tags[1])||is.na(tags[2]))
    shinyjs::hide("wrapper_variant_tags")
  else {
    shinyjs::show("wrapper_variant_tags")
  }
  updateSliderInput(session, "variant_tags", min = tags[1], max = tags[2], value = tags)
  updateSliderInput(session, "variant_range", min = pos[1], max = pos[2], value = pos)
  updateSliderInput(session, "variant_coeff", min = coeff[1], max = coeff[2], value = coeff)
  print(pval)
  if(is.null(pval)||is.na(pval[1])||is.na(pval[2]))
    shinyjs::hide("wrapper_variant_pvalue")
  else {
    shinyjs::show("wrapper_variant_pvalue")
  }
  updateSliderInput(session, "variant_pvalue", min = pval[1], max = pval[2], value = pval)
  
}

updateVariantFieldsByChromosome <- function(chr) {
  genes <- sort(unique(VARIANTS[VARIANTS$Chromosome == chr,]$Element))
  updateSelectInput(session, "variant_gene", choices = genes, selected = genes[1])
  updateVariantGenePosFields(genes[1])
}


updateVariantStudyDetails <- function(selected = NULL) {
  if(is.null(selected))
    selected_line <- SATURATION_MUTAGENESIS_METADATA[1,]
  else
    selected_line <- SATURATION_MUTAGENESIS_METADATA[SATURATION_MUTAGENESIS_METADATA$pmid == selected,]
  pmid <- unlist(strsplit(selected_line$pmid, "_"))[1]
  reference <- selected_line$reference
  output$variant_study_details <- renderUI({
    HTML(sprintf("<div style='font-size:12px !important'><b>Reference:</b><br>%s (<a href='https://pubmed.ncbi.nlm.nih.gov/%s/' target='_blank' rel='noreferrer'>View on Pubmed</a>)</div>", reference, pmid))
    
  })
}



searchVariantData <- function() {
  shinyjs::hide("variant_panels")
  renderModal("Searching Variant Data...")
  
  gene <- input$variant_gene
  
  chr <- unique(VARIANTS[VARIANTS$Element == gene,]$Chromosome)
  pos_range <- input$variant_range
  
  keep_delete <- input$variant_deletions
  if("variant_tags" %in% names(input))
    tags_range <- input$variant_tags
  else
    tags_range <- NULL
  coeff <- input$variant_coeff
  if("variant_pvalue" %in% names(input))
    pvalue <- input$variant_pvalue
  else
    pvalue <- NULL
  
  print(pvalue)
  variants <-  VARIANTS[VARIANTS$Position >= pos_range[1] & VARIANTS$Position <= pos_range[2],]
  variants <- variants[variants$Element == gene,]
  if(!is.null(tags_range))
    variants <- variants[variants$Tags >=  tags_range[1] & variants$Tags <= tags_range[2],]
  
  
  if(keep_delete == F)
    variants <- variants[variants$Alt != "-",]
  
  variants <- variants[variants$Value >= coeff[1] & variants$Value <= coeff[2],]
  if(!is.null(pvalue))
    variants <- variants[variants$P.Value >= pvalue[1] & variants$P.Value <= pvalue[2],]
  
  
  # order by genome position
  variants <- variants[order(variants$Position),]
  
  #Viewer output
  if(is.null(pvalue))
    output$variant_plot <- plotVariantGraph_noPval(variants)
  else
    output$variant_plot <- plotVariantGraph(variants)
  
  #Table output
  variants_table <- variants
  variants_table$Position <- format(variants_table$Position, big.mark=",")
  colnames(variants_table) <- c("Chromosome", "Position", "Ref", "Alt", "Tags", "DNA", "RNA", "Variant<br>Expression<br>Effect (log2)", "P-value", "Element")
  renderShinyDataTable("variant_datatable", variants_table, dom = 'Bfrtip', server = F)
  
  
  #search terms
  searchTerms <- list("Chromosome" = chr, "Gene" = gene, "Position" = sprintf("%s - %s", format(pos_range[1], big.mark=","), format(pos_range[2], big.mark=",")),
                      "Single base deletions" = keep_delete, "Variant Coeff." = sprintf("%s - %s", coeff[1], coeff[2]))
  
  if(!is.null(tags_range))
    searchTerms[["No. of tags"]] = sprintf("%s - %s", format(tags_range[1], big.mark=","), format(tags_range[2], big.mark=","))
  if(!is.null(pvalue))
    searchTerms[["P-value"]] = sprintf("%.4f - %.4f", pvalue[1], pvalue[2])
  searchTerms <- t(as.matrix(searchTerms))
  renderShinyDataTable("variant_searchterms", searchTerms, dom="t")
  
  # finally, the title
  output$variant_title <- renderUI({
    h3(sprintf("Saturation Mutagenesis data for %s", gene))
  })
  
  shinyjs::show("variant_panels")
  updateTabsetPanel(session, "variant_panel_results", "variant_data")
  removeModal()
}
