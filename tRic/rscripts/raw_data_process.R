
# Load library ------------------------------------------------------------
library(magrittr)

# Paths -------------------------------------------------------------------
# script.dir <- dirname(sys.frame(1)$ofile)
root_path <- dirname(rstudioapi::getActiveDocumentContext()$path)
db_path <- file.path(root_path, "tric", "database")


trna <- list.files(path = db_path, pattern = "tRNA$")
codon <- list.files(path = db_path, pattern = "codon.mean$")
aa <- list.files(path = db_path, pattern = "aaExp.mean$")

trna %>% stringr::str_split(pattern = "\\.", simplify = T) %>% .[,1] -> ct

# Load data ---------------------------------------------------------------
load_data <- function(.x, path) {
  file.path(path, .x) %>% 
    readr::read_tsv() -> .d
  
  colnames(.d) %>% 
    stringr::str_replace_all(pattern = "\\.", replacement = "-") ->
    .names
  colnames(.d) <- .names
  .d
}

# tRNA --------------------------------------------------------------------

trna %>%
  purrr::map(
    .f = function(.x, path){
      file.path(path, .x) %>% 
        read.table() -> .d
      
      colnames(.d) %>% 
        stringr::str_replace_all(pattern = "\\.", replacement = "-") ->
        .names
      colnames(.d) <- .names
      
      .d %>% 
        tibble::rownames_to_column(var = 'trna') %>% 
        tibble::as_tibble()
    },
    path = db_path
    ) -> trna_expr

names(trna_expr) <- ct
trna_expr %>% 
  tibble::enframe(name = "cancer_types", value = "expr") ->
  trna_expr_ti
trna_expr_ti %>% readr::write_rds(path = file.path(root_path, "trna_expr.rds.gz"), compress = "gz")


# codon -------------------------------------------------------------------

codon %>% 
  purrr::map(
    .f = function(.x, path){
      load_data(.x, path) -> .d
    },
    path = db_path
  ) -> codon_expr
names(codon_expr) <- ct
codon_expr %>% 
  tibble::enframe(name = "cancer_types", value = "expr") ->
  codon_ti
codon_ti %>% readr::write_rds(path = file.path(root_path, "codon.rds.gz"), compress = "gz")

# AA ----------------------------------------------------------------------

aa %>% 
  purrr::map(
    .f = function(.x, path){
      load_data(.x, path) -> .d
    },
    path = db_path
  ) -> aa_expr
names(aa_expr) <- ct
aa_expr %>% 
  tibble::enframe(name = "cancer_types", value = "expr") -> 
  aa_ti
aa_ti %>% readr::write_rds(path = file.path(root_path, "aa.rds.gz"), compress = "gz")


# tRNA AA codon -----------------------------------------------------------

trna_expr_ti %>% 
  dplyr::rename(trna = expr) %>% 
  dplyr::left_join(codon_ti) %>% 
  dplyr::rename(codon = expr) %>% 
  dplyr::left_join(aa_ti) %>% 
  dplyr::rename(aa = expr) -> 
  trna_codon_aa
trna_codon_aa %>% readr::write_rds(path = file.path("trna_codon_aa.rds.gz"), compress = "gz")

# codon AA frequency ------------------------------------------------------

codon_aa_freq <- read.table(file = file.path(root_path, "tric", "codon-aa.freq")) %>% 
  tibble::rownames_to_column(var = "ensid") %>% 
  tibble::as_tibble()

codon_aa_freq %>%
  dplyr::pull(ensid) -> ensid


ENSEMBL = biomaRt::useMart("ENSEMBL_MART_ENSEMBL", dataset = "hsapiens_gene_ensembl", host = "asia.ensembl.org")
ENSEMBL.ATTRIBUTES = biomaRt::listAttributes(ENSEMBL)
ENSEMBL.FILTERS = biomaRt::listFilters(ENSEMBL)

biomaRt::getBM(attributes = c("ensembl_gene_id", "hgnc_symbol"), filters = "ensembl_gene_id", values = ensid, mart = ENSEMBL) -> .r

.r %>% 
  tibble::as_tibble() %>% 
  dplyr::filter(hgnc_symbol != "") %>% 
  dplyr::distinct(hgnc_symbol, .keep_all = T) %>% 
  dplyr::rename(ensid = ensembl_gene_id, symbol = hgnc_symbol) -> ensid2symbol

ensid2symbol %>% 
  dplyr::left_join(codon_aa_freq, by = "ensid") %>% 
  readr::write_rds(path = file.path(root_path, "freq.rds.gz"), compress = "gz")





# summary json ------------------------------------------------------------
root_path <- here::here("../")
data_path <- file.path(root_path, "resource", "data")

ta <- readr::read_tsv(file.path(data_path, "table-tRNA-Codon-AA.out")) %>% 
  dplyr::rename(
    tRNA = Trna,
    Codon = nodoG
  )

list(data = ta) %>% 
  jsonlite::write_json(path = file.path(data_path, "summary.json"))

