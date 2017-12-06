#!/usr/bin/R

# Load library ------------------------------------------------------------
library(magrittr)
library(methods)

# Arguments ---------------------------------------------------------------
args <- commandArgs(TRUE)
# The first arg is the root_path
stopifnot(length(args) == 4)
dsid <- args[2] %>% stringr::str_replace(pattern = "TCGA-", replacement = "")
stid <- args[3]
q <- args[4]

dsid <- "TCGA-ACC" %>% stringr::str_replace(pattern = "TCGA-", replacement = "")
stid <- "All"
q <- "tRNA-Ala-AGC-1-1"

# Path --------------------------------------------------------------------
root_path <- args[1] <- here::here("../")
resource <- file.path(root_path, "resource")
resource_jsons <- file.path(resource, "jsons")
resource_pngs <- file.path(resource, "pngs")
resource_data <- file.path(resource, "data")

# Load data ---------------------------------------------------------------

expr <- readr::read_rds(path = file.path(resource_data, "trna_expr.rds.gz"))

# Filter dsid and q
expr %>% 
  dplyr::filter(cancer_types == dsid) %>% 
  .$expr %>% .[[1]] %>% 
  dplyr::filter(trna == q) %>% 
  tidyr::gather(key = "barcode", value = "expr", -trna) %>% 
  tidyr::replace_na(replace = list(expr = 0)) %>% 
  dplyr::mutate(expr = log2(expr + 0.001)) -> 
  trna_expr

json_file <- file.path(resource_jsons, glue::glue("api_trna_expr.{dsid}.{stid}.json"))
if (nrow(cst) < 1) {
  jsonlite::write_json(x = NULL, path = json_file)
  quit(save = "no", status = 0)
} else {
  jsonlite::write_json(x = cst, path = json_file)
}
