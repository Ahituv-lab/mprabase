renderScatterPlot <- function(x, y, title = "Title", xaxis = "X-axis", yaxis = "Y-axis") {
  
  # pearson and spearman correlation coefficients
  pearson <- cor(x, y, method = "pearson")
  spearman <- cor(x, y, method = "spearman")
  
  # linear regression curve
  fit <- lm(y~x)
  
  title <- sprintf("%s<br> <span style='font-size:13px'>Pearson: %.3f | Spearman : %.3f</span>", title, pearson, spearman)
  
  scatter <- plotly::renderPlotly({
    plotly::plot_ly(x = x, y = y, type = "scatter", mode = "markers") %>% 
      plotly::add_trace(x = x, y = fitted(fit), mode = "lines") %>%
      plotly::layout(title = list(text = title, y = 0.95, x = 0.5, xanchor = 'center', yanchor =  'top'), xaxis = list(title = xaxis), yaxis = list(title = yaxis)) %>% 
      plotly::hide_legend() %>%
      plotly::config(displayModeBar = T, displaylogo = F, modeBarButtonsToRemove = c('select2d','lasso2d'))
  })
  return(scatter)
}


plotMPRASamplePieCharts <- function(statistics, synthetic = F) {
  libraries_cols <- RColorBrewer::brewer.pal(length(unlist(statistics["libraries"])),"PuBuGn")
  cells_cols <- RColorBrewer::brewer.pal(length(unlist(statistics["libraries"])),"RdYlBu")
  species_cols <- RColorBrewer::brewer.pal(length(unlist(statistics["species"])),"PuOr")
  
  prefix <- "standard"
  if(synthetic == T)
    prefix <- "synthetic"
  
  output[[sprintf("%s_pie_libraries", prefix)]] <- plotly::renderPlotly({
    
    plotly::plot_ly(type='pie', labels=statistics[["libraries"]], values=statistics[["counts_libraries"]], marker = list(colors = libraries_cols),
                    textinfo='none', name = 'Library Strategies') %>% 
      plotly::hide_legend() %>%
      # plotly::layout(legend = list(orientation = "h", xanchor = "center", x = 0.5)) %>%
      plotly::config(displayModeBar = F)
  })
  output[[sprintf("%s_pie_species_celltypes", prefix)]] <- plotly::renderPlotly({
    plotly::plot_ly()  %>% 
      plotly::add_pie(labels = statistics[["cells"]], values = statistics[["counts_cells"]], marker = list(colors = cells_cols), name='Cell Lines', hole=0.8, textinfo='none') %>%
      plotly::add_pie(labels = statistics[["species"]], values = statistics[["counts_species"]], name='Species', marker = list(colors = species_cols), domain=list(
        x = c(0.15, 0.85),y = c(0.15, 0.85)), textinfo='none') %>% 
      plotly::hide_legend() %>%
      # plotly::layout(legend = list(orientation = "h", xanchor = "center", x = 0.5)) %>%
      plotly::config(displayModeBar = F)
  })
}


plotVariantGraph <- function(variants) {
  plot <- plotly::renderPlotly({
    plotly::plot_ly(variants, hoverinfo = "text", 
                    hovertext = ~paste0("Chromosome: ", Chromosome, "<br>Element: ", Element, "<br>Position: ", format(Position, big.mark=","), "<br>Ref: ", Ref, "<br>Alt: ", Alt, "<br>Var. expres.: ", Value, "<br>P-value: ", P.Value)
                    ) %>% 
      plotly::add_trace(x = ~Position, y = ~Value, type = "scatter", mode = "line", showlegend = F) %>%
      plotly::add_trace(x = ~Position, y = ~Value, size = ~(1/(P.Value+0.001)), color = ~as.factor(Ref), mode="markers", legendgroup = "Ref") %>%
      plotly::add_trace(x = ~Position, y = ~Value, size = ~(1/(P.Value+0.001)), symbol = ~as.factor(Alt), mode="markers", legendgroup = "Alt") %>%
      plotly::add_annotations( text="Ref:", xref="paper", yref="paper",
                               x=1.02, xanchor="left",
                               y=1.00, yanchor="bottom",    # Same y as legend below
                               legendtitle=TRUE, showarrow=FALSE ) %>%
      plotly::add_annotations( text="Alt:", xref="paper", yref="paper",
                               x=1.02, xanchor="left",
                               y=0.82, yanchor="bottom",    # Same y as legend below
                               legendtitle=TRUE, showarrow=FALSE ) %>%
      plotly::layout(xaxis = list(tickformat = ",d", hoverformat = ",d", separators = ",."), yaxis = list(title = "Log2 variant expression")) %>%
      plotly::config(displayModeBar = T, displaylogo = F, modeBarButtonsToRemove = c('select2d','lasso2d'))
  })
  
  return(plot)
}

plotVariantGraph_noPval <- function(variants) {
  plot <- plotly::renderPlotly({
    plotly::plot_ly(variants, hoverinfo = "text", 
                    hovertext = ~paste0("Chromosome: ", Chromosome, "<br>Element: ", Element, "<br>Position: ", format(Position, big.mark=","), "<br>Ref: ", Ref, "<br>Alt: ", Alt, "<br>Var. expres.: ", Value)
    ) %>% 
      plotly::add_trace(x = ~Position, y = ~Value, type = "scatter", mode = "line", showlegend = F) %>%
      plotly::add_trace(x = ~Position, y = ~Value, size = 10, color = ~as.factor(Ref), mode="markers", legendgroup = "Ref") %>%
      plotly::add_trace(x = ~Position, y = ~Value, size = 10, symbol = ~as.factor(Alt), mode="markers", legendgroup = "Alt") %>%
      plotly::add_annotations( text="Ref:", xref="paper", yref="paper",
                               x=1.02, xanchor="left",
                               y=1.00, yanchor="bottom",    # Same y as legend below
                               legendtitle=TRUE, showarrow=FALSE ) %>%
      plotly::add_annotations( text="Alt:", xref="paper", yref="paper",
                               x=1.02, xanchor="left",
                               y=0.82, yanchor="bottom",    # Same y as legend below
                               legendtitle=TRUE, showarrow=FALSE ) %>%
      plotly::layout(xaxis = list(tickformat = ",d", hoverformat = ",d", separators = ",."), yaxis = list(title = "Log2 variant expression")) %>%
      plotly::config(displayModeBar = T, displaylogo = F, modeBarButtonsToRemove = c('select2d','lasso2d'))
  })
  
  return(plot)
}