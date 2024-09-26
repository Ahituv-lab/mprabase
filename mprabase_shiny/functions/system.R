# generate pseudorandom id
generateId <- function(){
  id <- sprintf("%s_%s",
               stringi::stri_rand_strings(1,10),
               as.integer(as.numeric(Sys.time()))
               )
  return(id)
}

# print to stderr console ####
print_stderr <- function(str) {
  cat(sprintf("%s\n", str), 
      file = stderr()
  )
}

# popup rendering functions ####

renderModal <- function(prompt) {
  showModal(modalDialog(HTML(prompt), footer = NULL))
}

renderError <- function(prompt) {
  if (exists("session"))
    shinyalert::shinyalert("Error!", prompt, type = "error")
}

renderWarning <- function(prompt) {
  if (exists("session"))
    shinyalert::shinyalert("Warning!", prompt, type = "warning")
}


# DT rendering
renderShinyDataTable <- function(shinyOutputId, outputData,
                                 caption = NULL, fileName = "",
                                 scrollY = NULL, hiddenColumns = c(),
                                 dom = 'lfrtip',
                                 server = F
                                 ) {
  output[[shinyOutputId]] <- DT::renderDataTable(
    outputData,
    server = server, 
    extensions = c('Responsive', 'Buttons'),
    caption = caption,
    plugins = c("natural"),
    options = list(
      scrollY = scrollY, 
      scroller = T,
      "dom" = dom,
      buttons = c("copy", "csv", "excel"),
      columnDefs = list(
        list(visible = F, targets = hiddenColumns)
      )
    ),
    filter = 'none',
    rownames = F,
    escape = F,
    selection = 'none'
  )
}


# Add custom input function on table field

shinyInput <- function(FUN, id_list, id, ...) {
  inputs <- character(length(id_list))
  for (i in 1:length(id_list)) {
    inputs[i] <- as.character(FUN(sprintf("%s_%s", id, id_list[i]), label = NULL, ...))
  }
  return(inputs)
}

applyHyperlink <- function(ele, link_prefix) {
  if(!is.null(ele) && !is.na(ele) && trimws(ele) != "") {
   link <- sprintf("<a target='_blank' href='%s%s'>%s</a>", link_prefix, ele, ele) 
  }
  else {
    link <- "N/A"
  }
  return(link)
}