#!/usr/bin/R

# Load library ------------------------------------------------------------
library(magrittr)
library(methods)
library(ggplot2)

# Arguments ---------------------------------------------------------------
args <- commandArgs(TRUE)
# The first arg is the root_path
stopifnot(length(args) == 4)
dsid <- args[2] 
stid <- args[3]
q <- args[4]

# dsid <- "TCGA-BRCA"
# stid <- "all"
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

# expr --------------------------------------------------------------------

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
  dplyr::filter(type == "Tumor") %>% 
  dplyr::select(-barcode, -type) %>% 
  dplyr::distinct(sample_id, .keep_all = TRUE)

# clinical ----------------------------------------------------------------

clinical <- readr::read_rds(path = file.path(resource_data, ct, glue::glue("{ct}.clinical_dataset.rds.gz"))) %>% 
  dplyr::mutate(sample_id = glue::glue("{ct}-Tumor-{sample_id}"))

if (!stid %in% c("all", "0")) {clinical <- clinical %>% dplyr::filter(stage == stid)}

clinical %>% 
  dplyr::filter(!is.na(time), time > 0, !is.na(status)) %>% 
  dplyr::select(-subtype, -stage) %>% 
  dplyr::distinct() %>% 
  dplyr::mutate(status = as.integer(status))-> clinical

# Survival ----------------------------------------------------------------
expr %>% 
  dplyr::select(sample_id, expr) %>% 
  dplyr::inner_join(clinical, by = "sample_id") %>% 
  dplyr::mutate(group = as.factor(ifelse(expr <= median(expr), "Low", "High"))) %>% 
  dplyr::mutate(months = ifelse(time / 30 > 60, 60, time / 30)) %>% 
  dplyr::mutate(status = ifelse(months >= 60 & status == 1, 0, status)) -> 
  for_survival


# Save to json ------------------------------------------------------------
json_file <- file.path(resource_jsons, glue::glue("api_survival.{dsid}.{stid}.{q}.json"))

if(nrow(for_survival) < 20 || nlevels(for_survival$group) != 2 || mean(for_survival$expr) < 0){
  jsonlite::write_json(x = NULL, path = json_file)
  print("Not enough samples OR can't cut group OR mean expression less than 1!")
  quit("no", status = 0)
}


# coxph model -------------------------------------------------------------

for_survival %>%
  dplyr::do(
    broom::tidy(
      survival::coxph(
        survival::Surv(months, status) ~ expr, data = .
      )
    )
  ) %>% 
  dplyr::select(p.value) -> survival_coxph_model

survival_coxph_model %>% jsonlite::write_json(path = json_file)

# Surival plot ------------------------------------------------------------

png_file <- file.path(resource_pngs, glue::glue("api_survival.{dsid}.{stid}.{q}.png"))

surv_fit <- survival::survfit(
  survival::Surv(months, status) ~ group, 
  data = for_survival)

survminer::ggsurvplot(
  surv_fit, data = for_survival, pval = TRUE, pval.method = TRUE,
  title = glue::glue("5-year Survival, Coxph = {
                     ifelse(survival_coxph_model$p.value < 1e-04, 
                     0.0001, 
                     signif(survival_coxph_model$p.value, 3))}"),
  xlab = "5-year survival (months)",
  ylab = 'Probability of survival') -> surv_plot

if (! file.exists(png_file)) ggsave(filename = png_file, plot = surv_plot$plot, device = "png")
