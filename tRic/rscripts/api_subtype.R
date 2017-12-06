#!/usr/bin/R

# Load library ------------------------------------------------------------
library(magrittr)
library(methods)

# Arguments ---------------------------------------------------------------
args <- commandArgs(TRUE)
# The first arg is the root_path
stopifnot(length(args) == 2)
dsid <- args[2]
# dsid <- 'TCGA-ACC'

# Path --------------------------------------------------------------------
root_path <- args[1]
resource <- file.path(root_path, "resource")
resource_jsons <- file.path(resource, "jsons")
resource_pngs <- file.path(resource, "pngs")
resource_data <- file.path(resource, "data")

# Load data ---------------------------------------------------------------

clinical_subtype <- readr::read_rds(path = file.path(resource_data, "clinical_subtype.rds.gz"))

clinical_subtype %>% dplyr::filter(cancer_types == dsid) -> cst

json_file <- file.path(resource_jsons, glue::glue("api_subtype.{dsid}.json"))
if (nrow(cst) < 1) {
  jsonlite::write_json(x = NULL, path = json_file)
  quit(save = "no", status = 0)
} else {
  jsonlite::write_json(x = cst, path = json_file)
}



