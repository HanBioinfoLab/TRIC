
# Library -----------------------------------------------------------------

library(magrittr)


# Path --------------------------------------------------------------------
data_path <- here::here("../resource/data")


# Load data ---------------------------------------------------------------

split_data <- function(cancer_types, expr, name) {
  .dir <- file.path(data_path, cancer_types)
  if (!dir.exists(.dir)) dir.create(.dir)
  .filename <- glue::glue("{cancer_types}.{name}.rds.gz")
  if (!file.exists(file.path(.dir, .filename))) {
    expr %>% readr::write_rds(path = file.path(.dir, .filename), compress = "gz")
  }
}

trna_expr <- readr::read_rds(path = file.path(data_path, "trna_expr.rds.gz"))
trna_expr %>% purrr::pwalk(.f = split_data, name = "trna_expr")

codon <- readr::read_rds(path = file.path(data_path, "codon.rds.gz"))
codon %>% purrr::pwalk(.f = split_data, name = "codon_expr")

aa <- readr::read_rds(path = file.path(data_path, "aa.rds.gz"))
aa %>%
  dplyr::mutate(expr = purrr::map(.x = expr, .f = function(.x){.x %>% dplyr::rename(aa = codon)})) %>% 
  purrr::pwalk(.f = split_data, name = "aa_expr")

file.remove(file.path(data_path, list.files(data_path, pattern = ".rds.gz.rds.gz", recursive = T)))


# clinical ----------------------------------------------------------------

clinical_all <- readr::read_rds(file.path(data_path, "pancan34_clinical.rds.gz"))
intersect(trna_expr$cancer_types, clinical_all$cancer_types) -> cm
clinical_all %>% 
  dplyr::filter(cancer_types %in% cm) %>% 
  purrr::pwalk(
    .f = function(cancer_types, clinical) {
      clinical %>% 
        dplyr::select(
          dplyr::matches('Subtype|stage|grade|tobacco'),
          sample_id = barcode,
          time = os_days,
          status = os_status
        ) %>% 
        tidyr::gather(subtype,stage, -c(sample_id, time, status)) %>%
        dplyr::mutate(status = plyr::revalue(status, c("Alive" = 0, "Dead" = 1))) -> .d
      split_data(cancer_types = cancer_types, expr = .d, name = "clinical_dataset")
    }
  )

cst <- readr::read_rds(file.path(data_path, "clinical_subtype.rds.gz"))

clinical_all %>% 
  dplyr::filter(cancer_types %in% cm) %>% 
  dplyr::mutate(
    clinical = purrr::map(
      .x = clinical,
      .f = function(.x) {
        .x %>% 
          dplyr::select(
            dplyr::matches('Subtype|stage|grade|tobacco'),
            sample_id = barcode,
            time = os_days,
            status = os_status
          ) %>% 
          tidyr::gather(subtype,stage, -c(sample_id, time, status)) %>%
          dplyr::mutate(status = plyr::revalue(status, c("Alive" = 0, "Dead" = 1))) -> .d
        if (!tibble::has_name(.d, "subtype")) return(NULL)
        .d %>% 
          dplyr::group_by(subtype, stage) %>% 
          dplyr::count() %>% 
          tidyr::drop_na(stage) %>% 
          dplyr::ungroup()
      })
    ) -> .foo
.foo %>% 
  dplyr::filter(!purrr::map_lgl(.x = clinical, .f = function(.x) {is.null(.x)})) %>% 
  tidyr::unnest() %>% 
  dplyr::mutate(cancer_types = glue::glue("TCGA-{cancer_types}")) -> cst

cst %>% readr::write_rds(path = file.path(data_path, "clinical_subtype.rds.gz"), compress = "gz")


# Codon pickle ------------------------------------------------------------

write(x = codon$expr[[1]]$codon, file = file.path(data_path, "codon.txt"))



# AA pickle ---------------------------------------------------------------

write(x = aa$expr[[1]]$codon, file = file.path(data_path, "aa.txt"))



# freq -------------------------------------------------------------------
freq <- readr::read_rds(path = file.path(data_path, "freq.rds.gz"))
write(x = freq$symbol, file = file.path(data_path, "freq_list.txt"))


freq <- readr::read_rds(file.path(data_path, 'freq.rds.gz'))

freq %>% dplyr::select(1:TTT) -> freq_codon

freq_codon %>% readr::write_rds(path = file.path(data_path, "freq_codon.rds.gz"), compress = 'gz')

freq %>% dplyr::select(1:2, ala:sec) -> freq_aa
freq_aa %>% readr::write_rds(path = file.path(data_path, "freq_aa.rds.gz"), compress = "gz")


# json pattern ------------------------------------------------------------
table_out <- readr::read_tsv(file.path(data_path,'table-tRNA-Codon-AA.out'))

table_out %>% 
  dplyr::select(2:3) %>% 
  dplyr::distinct() %>%  
  tidyr::nest(-AA) %>% 
  dplyr::rename(name = AA, children = data) %>% 
  dplyr::mutate(
    children = purrr::map2(.x = children, .y = name, function(.x, .y) {
      .x %>% 
        dplyr::rename(name = nodoG) %>% 
        dplyr::mutate(name = glue::glue("{name}")) %>% 
        tibble::add_row(name = glue::glue("{.y}")) %>% 
        dplyr::mutate(size = 0)
    })
  ) %>% 
  dplyr::mutate(name = glue::glue("size_{name}")) -> json_pattern

json_pattern %>% readr::write_rds(path = file.path(data_path, 'freq_json_pattern.rds.gz'), compress = "gz")
