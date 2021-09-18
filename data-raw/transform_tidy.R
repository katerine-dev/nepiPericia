library(magrittr)
# Importação --------------------------------------------------------------
base_perito <-
  readxl::read_excel("~/Documents/nepiPericia/data-raw/perito_manual.xlsx") # base só com os deferidos análise dos administradores judiciais

observatorio <- obsFase2::da_relatorio # base completa

# ramos de atuação
base_ramo <- obsFase2::out_ramo_atuacao

# tidy --------------------------------------------------------------------

base_perito <- base_perito |>
  janitor::clean_names() |>
  dplyr::mutate(dplyr::across(c(
      deferido,
      tem_pericia,
      comarca,
      juizo,
      recuperanda,
      responsavel_constatacao,
      resultado_final
    ),
    limpa_nomes
  )) |>
  dplyr::rename(pericia = tem_pericia)


# BASE COMPLETA ---------------------------------------------------------------------------------------------------------------------------------

observatorio_correcao <- observatorio |>
  dplyr::select(
    n_processo,
    epp_ou_me,
    cnpj,
    comarca,
    data_dist,
    capital,
    deferido,
    data_deferimento,
    data_indeferimento,
    pericia,
    data_pericia,
    desfecho_final
  ) |>
  dplyr::left_join(correcao_deferidos, "n_processo") # corrigir manual.

writexl::write_xlsx(observatorio_correcao, "~/Documents/nepiPericia/data/observatorio_correcao.xlsx")

observatorio_corrigida <-
  readxl::read_excel("~/Documents/nepiPericia/data/observatorio_correcao.xlsx")


correcao_deferidos <- base_perito |>
  dplyr::filter(pericia == "nao") |>
  dplyr::rename(correcao = pericia) |>
  dplyr::select(n_processo, correcao)

# cruzar base -------------------------------------------------------------


base_perito_cnpj <- base_perito |>
  janitor::clean_names()  |>
  dplyr::filter(pericia == "sim") |>
  tidyr::separate_rows(cnpj, sep = ",") |>
  dplyr::filter(cnpj != "NA") |>
  dplyr::mutate(cnpj = abjutils::clean_cnj(cnpj))


observatorio_cnae <- base_perito_cnpj |>
  dplyr::left_join(base_ramo, c("n_processo", "cnpj")) |>
  dplyr::rename(desfecho_final = resultado_final) |>
  dplyr::select(n_processo, deferido, pericia, cod_cnae, nm_secao, nm_divisao, nm_grupo, nm_classe, nm_cnae, desfecho_final) # com pericia com cnae

observatorio_cnae_nao <- observatorio |>
  dplyr::anti_join(base_perito, "n_processo") |>  # não tem pericia sem cnae
  tidyr::separate_rows(cnpj, sep = ",") |>
  dplyr::filter(cnpj != "NA") |>
  dplyr::mutate(cnpj = abjutils::clean_cnj(cnpj))

observatorio_analise_cnae <- observatorio_cnae_nao |>
  dplyr::left_join(base_ramo, c("n_processo", "cnpj")) |>
  dplyr::select(n_processo, deferido, pericia, cod_cnae, nm_secao, nm_divisao, nm_grupo, nm_classe, nm_cnae, desfecho_final)

#writexl::write_xlsx(observatorio_analise_cnae, "~/Documents/nepiPericia/data/observatorio_analise_cnae.xlsx")
#writexl::write_xlsx(observatorio_cnae, "~/Documents/nepiPericia/data/observatorio_cnae.xlsx") #vrificação dos dados

observatorio_pronta_cnae <- readxl::read_excel("~/Documents/nepiPericia/data/observatorio_cnae_corrigido.xlsx")




# Exportar  ---------------------------------------------------------------


readr::write_rds(observatorio_corrigida, "data/observatorio_corrigida.rds") # disponibilizar na pasta .rds
readr::write_rds(base_perito, "data/base_perito.rds") # disponibilizar na pasta .rds
readr::write_rds(observatorio_pronta_cnae , "data/observatorio_pronta_cnae.rds") # disponibilizar na pasta .rds


