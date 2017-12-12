#!/usr/bin/R

# Load library ------------------------------------------------------------
library(magrittr)
library(methods)
library(ggplot2)

# Arguments ---------------------------------------------------------------
args <- commandArgs(TRUE)
# The first arg is the root_path
stopifnot(length(args) == 2)
q <- args[2]

# q <- "PTEN"


# Path --------------------------------------------------------------------
root_path <- args[1]
# root_path <- here::here("../")
resource <- file.path(root_path, "resource")
resource_jsons <- file.path(resource, "jsons")
resource_pngs <- file.path(resource, "pngs")
resource_data <- file.path(resource, "data")

# Load data ---------------------------------------------------------------
json_pattern <- readr::read_rds(path = file.path(resource_data, glue::glue("freq_json_pattern.rds.gz"))) %>% 
  dplyr::filter(name != "iMet")
filename <- file.path(resource_data, glue::glue("freq.rds.gz"))

freq_data <- 
  readr::read_rds(path = filename) %>% 
  dplyr::filter(symbol == q) %>% 
  dplyr::select(-c(1,2)) %>% 
  unlist()

names(freq_data) <- glue::glue("{names(freq_data)}") %>% stringr::str_to_lower()


json_pattern %>% 
  dplyr::mutate(
    children = purrr::map(
      .x = children,
      .f = function(.x){
        freq_data[dplyr::pull(.x, name) %>% stringr::str_to_lower()] -> .size
        dplyr::mutate(.x, size = .size) %>% 
          dplyr::filter(size != 0)
      }
    )
  ) %>% 
  dplyr::filter(name != "iMet") ->json_data


json_data %>% 
  dplyr::mutate(children = purrr::map(
    .x = children,
    .f = function(.x){
      .x %>% 
        dplyr::filter(stringr::str_detect(name, pattern = "[AGCT]{3}")) 
    }
  )) -> json_codon

json_data %>% 
  dplyr::mutate(children = purrr::map(
    .x = children,
    .f = function(.x){
      .x %>% 
        dplyr::filter(!stringr::str_detect(name, pattern = "[AGCT]{3}"))
    }
  )) -> json_aa

freq <- list(name = "flare", children = json_data)
freq_codon <- list(name = "flare", children = json_codon)
freq_aa <- list(name = "flare", children = json_aa)

jsons <- list(freq = freq, freq_aa = freq_aa, freq_codon = freq_codon)

# Save to json ------------------------------------------------------------
json_file <- file.path(resource_jsons, glue::glue("api_freq.{q}.json"))

jsons %>% jsonlite::write_json(json_file)


