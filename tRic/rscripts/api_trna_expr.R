#!/usr/bin/R

# Load library ------------------------------------------------------------
library(magrittr)
library(methods)
library(ggplot2)

# Arguments ---------------------------------------------------------------
args <- commandArgs(TRUE)
# The first arg is the root_path
stopifnot(length(args) == 5)
dsid <- args[2] 
stid <- args[3]
q <- args[4]
module <- args[5]

# dsid <- "TCGA-BRCA"
# stid <- "Negative"
# q <- "ala"
# module <- "aa"

# Path --------------------------------------------------------------------
root_path <- args[1]
# root_path <- here::here("../")
resource <- file.path(root_path, "resource")
resource_jsons <- file.path(resource, "jsons")
resource_pngs <- file.path(resource, "pngs")
resource_data <- file.path(resource, "data")

# Load data ---------------------------------------------------------------
ct <- dsid %>% stringr::str_replace(pattern = "TCGA-", replacement = "")

filename <- file.path(resource_data, ct, glue::glue("{ct}.{module}_expr.rds.gz"))

expr <- readr::read_rds(path = filename) %>% 
  dplyr::filter(rlang::UQ(rlang::sym(module)) == q) %>% 
  tidyr::gather(key = "barcode", value = "expr", -rlang::UQ(rlang::sym(module))) %>% 
  dplyr::select(-rlang::UQ(rlang::sym(module))) %>% 
  tidyr::replace_na(replace = list(expr = 0)) %>% 
  dplyr::mutate(expr = log2(expr + 0.001)) %>% 
  dplyr::mutate(type = stringr::str_sub(string = barcode, start = 14, end = 14)) %>% 
  dplyr::mutate(type = ifelse(type == "0", "Tumor", "Normal")) %>% 
  dplyr::mutate(sample_id = stringr::str_sub(string = barcode, start = 1, end = 12)) %>% 
  dplyr::mutate(sample_id = glue::glue("{ct}-{type}-{sample_id}")) %>% 
  dplyr::select(-barcode)

expr_normal <- 
  expr %>% 
  dplyr::filter(type == "Normal")

if (!stid %in% c("all", "0")) {
  subtype <- readr::read_rds(path = file.path(resource_data, ct, glue::glue("{ct}.clinical_dataset.rds.gz"))) %>% 
    dplyr::filter(stage == stid) %>% 
    dplyr::mutate(sample_id = glue::glue("{ct}-Tumor-{sample_id}"))
  expr <- expr %>% dplyr::semi_join(subtype, by = c("sample_id"))
}

# Save to json ------------------------------------------------------------
json_file <- file.path(resource_jsons, glue::glue("api_trna_expr.{dsid}.{stid}.{q}.{module}.json"))

if (nrow(expr) < 1) {
  jsonlite::write_json(x = NULL, path = json_file)
  quit(save = "no", status = 0)
} else {
  expr %>% 
    dplyr::select(-type) %>% 
    jsonlite::write_json( path = json_file)
}

# Tumor vs. Normal --------------------------------------------------------
if (!stid %in% c("all", "0")) {
  expr <- dplyr::bind_rows(expr, expr_normal)
}

expr %>% 
  dplyr::group_by(type) %>% 
  dplyr::count() %>% 
  dplyr::ungroup() %>% 
  dplyr::mutate(nss = n >= 8) %>%  # nss for number of samples 
  dplyr::pull(nss) -> nss

if (all(nss) && length(nss) == 2) {
  expr %>% 
    ggpubr::ggboxplot(x = "type", y = "expr", color = "type", add = "jitter") +
    ggpubr::stat_compare_means(method = "t.test") +
    ggsci::scale_color_npg() -> p
  
  png_file <- file.path(resource_pngs, glue::glue("tm_comparison.{dsid}.{stid}.{q}.{module}.png"))
  if (! file.exists(png_file)) ggsave(filename = png_file, plot = p, device = "png")
}
