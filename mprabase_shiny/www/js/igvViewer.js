function genomeViewer(div_id, genome_id, locus)   {    
    var igvDiv = document.getElementById(div_id);
    
    var options = {
      genome: genome_id,
      showAllChromosomes: false
    };
    igv.createBrowser(igvDiv, options).then(function(browser) {
      browser.search(locus);
    });
    
      
}


function openViewerEvent(genome_id, locus) {
  Shiny.setInputValue('IGV_GENOME_AND_LOCUS', genome_id + "@" + locus, {priority: "event"});
  return true;
}