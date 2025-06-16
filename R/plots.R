plot_outcome_by_quarter <- function(plot_data,outcome = "PSS drug_deaths"){
  year_quarter <- model <- NULL
  outcome_label <- stringr::str_replace_all(outcome,"_"," ")
  g <- plot_data |>
    ggplot2::ggplot(ggplot2::aes(x=year_quarter,y=.data[[outcome]],
                                 fill=model)) +
    ggplot2::geom_boxplot() +
    ggplot2::theme_classic()

  return(g)
}
