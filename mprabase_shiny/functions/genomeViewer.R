genomeViewer <- function(genome, locus) {
  
  genomeViewerWindow <- renderUI({
    HTML(sprintf("<div id='igv_viewer'></div>
         
         <script>
         genomeViewer('igv_viewer', '%s', '%s');
         </script>
         ", genome, locus))
  })
  
  return(genomeViewerWindow)
}


handleGenomeViewerInput <- function(update = F) {
  splt <- unlist(strsplit(input$IGV_GENOME_AND_LOCUS, "@"))
  genomeViewerWindow <- renderUI({
    HTML(sprintf("<div id='igv_viewer'></div>
         
         <script>
         genomeViewer('igv_viewer', '%s', '%s');
         </script>
         ", splt[1], splt[2]))
  })
  showTab(inputId = "library_viewer_graphs", target = "library_viewer_graphs_igv")
  if(update == T)
    updateTabsetPanel(session, "library_viewer_graphs", "library_viewer_graphs_igv")
  
  output$igv_library <- genomeViewerWindow
}