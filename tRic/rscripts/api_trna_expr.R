#!/usr/bin/R

# Load library ------------------------------------------------------------
library(magrittr)
library(methods)

# Arguments ---------------------------------------------------------------
args <- commandArgs(TRUE)
# The first arg is the root_path
stopifnot(length(args) == 4)
dsid <- args[2] 
stid <- args[3]
q <- args[4]

# dsid <- "TCGA-ACC"
# stid <- "Stage I"
# q <- "tRNA-Ala-AGC-1-1"

# Path --------------------------------------------------------------------
root_path <- args[1]
# root_path <- here::here("../")
resource <- file.path(root_path, "resource")
resource_jsons <- file.path(resource, "jsons")
resource_pngs <- file.path(resource, "pngs")
resource_data <- file.path(resource, "data")

# Load data ---------------------------------------------------------------
ct <- dsid %>% stringr::str_replace(pattern = "TCGA-", replacement = "")

expr <- readr::read_rds(path = file.path(resource_data, ct, glue::glue("{ct}.trna_expr.rds.gz"))) %>% 
  dplyr::filter(trna == q) %>% 
  tidyr::gather(key = "barcode", value = "expr", -trna) %>% 
  dplyr::select(-trna) %>% 
  tidyr::replace_na(replace = list(expr = 0)) %>% 
  dplyr::mutate(expr = log2(expr + 0.001)) %>% 
  dplyr::mutate(type = stringr::str_sub(string = barcode, start = 14, end = 14)) %>% 
  dplyr::mutate(type = ifelse(type == "0", "Tumor", "Normal")) %>% 
  dplyr::mutate(sample_id = stringr::str_sub(string = barcode, start = 1, end = 12)) %>% 
  dplyr::mutate(sample_id = glue::glue("{ct}-{type}-{sample_id}")) %>% 
  dplyr::select(-barcode, -type)

if (!stid %in% c("all", "0")) {
  subtype <- readr::read_rds(path = file.path(resource_data, ct, glue::glue("{ct}.clinical_dataset.rds.gz"))) %>% 
    dplyr::filter(stage == stid) %>% 
    dplyr::mutate(sample_id = glue::glue("{ct}-Tumor-{sample_id}"))
  expr <- expr %>% dplyr::semi_join(subtype, by = c("sample_id"))
}

json_file <- file.path(resource_jsons, glue::glue("api_trna_expr.{dsid}.{stid}.{q}.json"))

if (nrow(expr) < 1) {
  jsonlite::write_json(x = NULL, path = json_file)
  quit(save = "no", status = 0)
} else {
  jsonlite::write_json(x = expr, path = json_file)
}
