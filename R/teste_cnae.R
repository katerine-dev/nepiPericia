library(magrittr)
# Importação --------------------------------------------------------------

path_bases <-  "~/Documents/nepiPericia/data-raw/"
importar_bases <- fs::dir_ls(path = path_bases, pattern = ".xls")
# primeira base:
#base_receita <- readxl::read_excel(paste0(path = path_bases, "dados_receita.xlsx"))

base_pericia <-  readxl::read_excel(paste0(path = path_bases, "planilha_perito.xlsx"))

#base_join <-  readxl::read_excel(paste0(path = path_bases, "base_teste_2.xlsx"))


# tidy cnpjs --------------------------------------------------------------
base_com_cnpj_limpo <- base_pericia |>
  janitor::clean_names()  |>
  dplyr::filter(tem_pericia == "sim") |>
  dplyr::select(n_processo, cnpj, resultado_da_constatacao_deferimento_indeferimento, complementacao_doc) |>
  tidyr::separate_rows(cnpj, sep = ",") |>
  dplyr::filter(cnpj != "NA") |>
  dplyr::mutate(cnpj = abjutils::clean_cnj(cnpj))

# Base principal
#  base_receita_limpa <- base_receita %>%
#  dplyr::select(cnpj, razao_social, cnae_fiscal, codigo_natureza_juridica)



# solução alternativa
base_ramo <- obsFase2::out_ramo_atuacao # outra solução mais completa
# cruzar base -------------------------------------------------------------

 basend_pericia <- base_com_cnpj_limpo |>
  dplyr::inner_join(base_ramo, c("n_processo", "cnpj"))
  # com a solução alternativa seria aplicada base_ramo, no final faltariam 2 casos foi coletado de forma manual


# Exportar  ---------------------------------------------------------------

writexl::write_xlsx(basend_pericia, "~/Documents/nepiPericia/base_teste_2.xlsx")
# essa base serviu de exemplo para a base_principal


