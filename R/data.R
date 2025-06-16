load_data <- function(){
  bcrom_data_file <- here::here("data","raw","BCROM_comparison_outputs.csv")
  otem_data_file <- here::here("data","raw","OTEM_comparison_outputs.csv")
  bcrom_data <- readr::read_csv(bcrom_data_file)
  otem_data <- readr::read_csv(otem_data_file)

  bcrom_data <- bcrom_data |>
    dplyr::mutate(model = "bcrom") |>
    dplyr::select(!`...1`)
  otem_data <- otem_data |>
    dplyr::mutate(model = "otem")
  all_data <- bcrom_data |>
    dplyr::bind_rows(otem_data)
  all_data <- all_data |>
    dplyr::mutate(date = lubridate::ymd(glue::glue("{year}-{month}-01")))
  return(all_data)
}
