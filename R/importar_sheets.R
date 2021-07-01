library(magrittr)
# Importação --------------------------------------------------------------

path_bases <-  "~/Documents/nepiPericia/data-raw/"
importar_bases <- fs::dir_ls(path = path_bases, pattern = ".xls")

base_receita <- readxl::read_excel(paste0(path = path_bases, "dados_receita.xlsx"))
base_pericia <-  readxl::read_excel(paste0(path = path_bases, "planilha_pericia.xlsx"))


# tidy cnpjs --------------------------------------------------------------
base_com_cnpj_limpo <- base_pericia %>%
  janitor::clean_names() %>%
  dplyr::filter(tem_pericia == "sim") %>%
  dplyr::select(n_processo, cnpj, resultado_da_constatacao_deferimento_indeferimento) %>%
  tidyr::separate_rows(cnpj, sep = ",") %>%
  dplyr::filter(cnpj != "NA") %>%
  dplyr::mutate(cnpj = abjutils::clean_cnj(cnpj))

base_receita_limpa <- base_receita %>%
  dplyr::select(cnpj, razao_social, cnae_fiscal, codigo_natureza_juridica)


# cruzar base -------------------------------------------------------------

 basend_pericia <- base_com_cnpj_limpo %>%
  dplyr::inner_join(base_receita_limpa, "cnpj")

