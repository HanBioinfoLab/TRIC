
# Library -----------------------------------------------------------------

library(magrittr)


# Path --------------------------------------------------------------------
data_path <- here::here("../../static/download") 



# Load data ---------------------------------------------------------------

freq <- readr::read_rds(file.path(data_path, "freq.rds.gz"))

# Transform ---------------------------------------------------------------

freq %>% readr::write_tsv(path = file.path(data_path, "freq.txt"))

c("aa", "codon", "trna") %>% 
  purrr::walk(.f = function(.x){
    
    .name <- ifelse(.x == "trna", glue::glue("{.x}_expr"), glue::glue("{.x}"))
    .filename <- glue::glue("{.name}.rds.gz")
    
    .d <- readr::read_rds(file.path(data_path, .filename))
    
    .d %>% purrr::pmap(
      .f = function(cancer_types, expr){
        .t <- ifelse(.x == "aa", "codon", .x)
        expr %>% 
          tidyr::gather(key = barcode, value = expr, -.t) %>% 
          tidyr::spread(key = .t, value = expr) %>% 
          tibble::add_column(cancer_types = cancer_types, .before = 1)
      }
    ) %>% 
      dplyr::bind_rows() %>% 
      readr::write_tsv(path = file.path(data_path, glue::glue("{.name}.expr.TMM.txt")))
  })






