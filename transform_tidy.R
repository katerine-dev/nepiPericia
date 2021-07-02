library(magrittr)
# Importação --------------------------------------------------------------

path_bases <-  "~/Documents/nepiPericia/data-raw/"
importar_bases <- fs::dir_ls(path = path_bases, pattern = ".xls")

base_cnae <-
  readxl::read_excel(paste0(path = path_bases, "base_cnae.xlsx"))
base_perito <-
  readxl::read_excel(paste0(path = path_bases, "planilha_perito.xlsx"))


# Funções  ----------------------------------------------------------------

# função que limpa nome
limpa_nomes <- function(str) {
  str %>%
    abjutils::rm_accent() %>%
    stringr::str_to_lower() %>%
    stringr::str_squish()
}

# tidy --------------------------------------------------------------------
base_cnae_tidy <- base_cnae %>%
  dplyr::mutate(razao_social = stringr::str_to_lower(razao_social))


base_perito_tidy <- base_perito %>%
  janitor::clean_names() %>%
  dplyr::rename(resultado_constatacao = resultado_da_constatacao_deferimento_indeferimento,
                responsavel_constatacao = resposavel_constatacao) %>%
    dplyr::select(
    n_processo,
    # colunas base para o join (precisa decidir se relmente faz sentido dar join)
    deferido,
    tem_pericia,
    comarca,
    juizo,
    recuperanda,
    cnpj,
    responsavel_constatacao,
    resultado_final,
  )  %>%
  dplyr::mutate(
    deferido = limpa_nomes(deferido),
    tem_pericia = limpa_nomes(tem_pericia),
    comarca = limpa_nomes(comarca),
    juizo = limpa_nomes(juizo),
    recuperanda = limpa_nomes(limpa_nomes(juizo)),
    responsavel_constatacao = limpa_nomes(responsavel_constatacao),
    resultado_final = limpa_nomes(resultado_final)
  )


