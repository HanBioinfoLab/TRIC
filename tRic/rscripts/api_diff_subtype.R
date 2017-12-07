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

subtype <- readr::read_rds(path = file.path(resource_data, ct, glue::glue("{ct}.clinical_dataset.rds.gz"))) %>% 
    dplyr::mutate(sample_id = glue::glue("{ct}-Tumor-{sample_id}")) %>% 
  tidyr::drop_na(stage)

expr %>% 
  dplyr::left_join(subtype, by = "sample_id") %>% 
  dplyr::select(subtype, stage, expr) %>% 
  tidyr::drop_na() -> diff_subtype

diff_subtype %>% 
  dplyr::group_by(subtype) %>% 
  dplyr::do(
    broom::tidy(
      anova(lm(expr ~ stage, data = .))
    )
  ) %>% 
  dplyr::ungroup() %>% 
  dplyr::filter(term == "stage") %>% 
  dplyr::select(subtype, p.value)-> diff_subtype_pval

# Save to json ------------------------------------------------------------
json_file <- file.path(resource_jsons, glue::glue("api_diff_subtype.{dsid}.{stid}.{q}.json"))

if (nrow(expr) < 1) {
  jsonlite::write_json(x = NULL, path = json_file)
  quit(save = "no", status = 0)
} else {
  diff_subtype_pval %>% jsonlite::write_json( path = json_file)
}


# save to pngs ------------------------------------------------------------
diff_subtype_pval$subtype %>% 
  purrr::walk(
    .f = function(.x) {
      diff_subtype %>% 
        dplyr::filter(subtype == .x) %>% 
        ggplot(aes(x = stage, y = expr, color = stage)) +
        stat_boxplot(geom = "errorbar", width = 0.3) +
        geom_boxplot(outlier.shape = NA, width = 0.6) +
        scale_color_brewer(palette = "Dark2") +
        theme_bw() +
        theme(
          panel.grid.major = element_blank(),
          panel.grid.minor = element_blank(),
          axis.line = element_line(color = "black"),
          axis.text.x = element_text(angle=45, hjust = 1)
        ) +
        labs(
          y = latex2exp::TeX("tRNA expression ($log_2(RPKM)$)"),
          x = stringr::str_replace_all(.x, "_"," ")
        ) -> p
      
      png_file <- file.path(resource_pngs, glue::glue("api_diff_subtype.{dsid}.{stid}.{.x}.{q}.png"))
      if (! file.exists(png_file)) ggsave(filename = png_file, plot = p, device = "png")
    }
  )

