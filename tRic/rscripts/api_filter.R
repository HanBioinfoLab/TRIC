#!/usr/bin/R

# Load library ------------------------------------------------------------
library(magrittr)
library(methods)
library(ggplot2)

# Arguments ---------------------------------------------------------------
args <- commandArgs(TRUE)
# The first arg is the root_path
stopifnot(length(args) == 3)
q <- args[2]
val <- args[3]

# q <- "AAA"
# val <- 0.1

# Path --------------------------------------------------------------------
root_path <- args[1]
# root_path <- here::here("../")
resource <- file.path(root_path, "resource")
resource_jsons <- file.path(resource, "jsons")
resource_pngs <- file.path(resource, "pngs")
resource_data <- file.path(resource, "data")

# Load data ---------------------------------------------------------------
codon_filter <- readr::read_rds(path = file.path(resource_data, "codon_filter.rds.gz"))

codon_filter %>% 
  dplyr::select(1, 2, q) %>% 
  dplyr::filter(rlang::UQ(rlang::sym(q)) > val) ->
  filter_data

# Save to json ------------------------------------------------------------

json_file <- file.path(resource_jsons, glue::glue("api_filter.{q}.{val}.json"))

if (nrow(filter_data) < 1) {
  jsonlite::write_json(x = NULL, path = json_file)
  quit(save = "no", status = 0)
} else {
  filter_data %>% jsonlite::write_json( path = json_file)
}

