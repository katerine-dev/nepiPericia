# Funções  ----------------------------------------------------------------

limpa_nomes <- function(str) {
  str |>
    abjutils::rm_accent() |>
    stringr::str_to_lower() |>
    stringr::str_squish()
}
