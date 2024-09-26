selectedDatasetsDownload <- function(download_selection, samples_df, datasets_df) {
  id <- generateId()
  path <- sprintf("www/tmp/%s", id)
  zippath <- sprintf("www/tmp/mprabase_data_%s.zip", id)
  downpath <- sprintf("tmp/mprabase_data_%s.zip", id)
  dir.create(path)
  samples <- c()
  datasets <- c()
  lapply(download_selection, function(did) {
    ids <- unlist(strsplit(did, ";"))
    samples <<- c(samples, ids[2])
    datasets <<- c(datasets, ids[1])
  })
  samples <- unique(samples)
  datasets <- unique(datasets)
  selected_samples <- samples_df[grepl(paste(samples, collapse="|"), samples_df$sampleId),]
  selected_datasets <- datasets_df[grepl(paste(datasets, collapse="|"), datasets_df$datasetId),]
  library_repl <- getAllLibraryMetadata(samples)
  
  write.csv(selected_samples, sprintf("%s/samples.csv", path), sep = ",", quote = F)
  write.csv(selected_datasets, sprintf("%s/datasets.csv", path), sep = ",", quote = F)
  write.csv(library_repl, sprintf("%s/replicates_element_scores.csv", path), sep=",", quote = F)
  zip(zippath, c(sprintf("%s/samples.csv", path), sprintf("%s/datasets.csv", path), sprintf("%s/replicates_element_scores.csv", path)), flags = "-j")
  unlink(path, recursive = T)
  shinyjs::runjs(sprintf("var file_path = '%s';
var a = document.createElement('A');
a.href = file_path;
a.download = file_path.substr(file_path.lastIndexOf('/') + 1);
document.body.appendChild(a);
a.click();
document.body.removeChild(a);", downpath))
  }

