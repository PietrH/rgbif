context("dataset_search")

test_that("type query returns the correct class", {
  vcr::use_cassette("dataset_search", {
    tt <- dataset_search(type="OCCURRENCE")
  }, preserve_exact_body_bytes = TRUE)

  expect_is(tt, "list")
  expect_is(tt$data, "data.frame")
  expect_is(tt$data, "tbl_df")
  expect_is(tt$descriptions, "list")
  expect_is(tt$data[1,1], "tbl_df")
  expect_is(tt$data[1,1]$datasetTitle, "character")
})

# Gets all datasets tagged with keyword "france".
test_that("keyword query returns the correct", {
  vcr::use_cassette("dataset_search_keyword", {
    tt <- dataset_search(keyword = "bird")
  }, preserve_exact_body_bytes = TRUE)

  # class
  expect_is(tt, "list")
  expect_is(tt$data, "tbl_df")
  expect_is(tt$data[1,1], "tbl_df")
  expect_is(tt$data[1,1]$datasetTitle, "character")

  # value
  expect_true(any(grepl("bird", tt$data$datasetTitle, ignore.case = TRUE)))
})

# Fulltext search for all datasets having the word "amsterdam" somewhere in
# its metadata (title, description, etc).
test_that("search query returns the correct class", {
  vcr::use_cassette("dataset_search_query", {
    tt <- dataset_search(query = "amsterdam")
  }, preserve_exact_body_bytes = TRUE)

  expect_is(tt, "list")
  expect_is(tt$data, "data.frame")
  expect_is(tt$data, "tbl_df")
  expect_is(tt$meta, "data.frame")
  expect_is(tt$descriptions, "list")
  expect_null(tt$facets)
  expect_is(tt$data[1,1], "tbl_df")
  expect_is(tt$data[1,1]$datasetTitle, "character")
})

# Limited search
test_that("limited search returns the correct", {
  vcr::use_cassette("dataset_search_limit", {
    tt <- dataset_search(type="OCCURRENCE", limit=2)
  }, preserve_exact_body_bytes = TRUE)

  # class
  expect_is(tt$data, "data.frame")
  expect_is(tt$data, "tbl_df")
  expect_is(tt$data[1,1], "tbl_df")
  expect_is(tt$data[1,1]$datasetTitle, "character")

  # dims
  expect_equal(dim(tt$data), c(2,8))
})

# Return throws warning
test_that("return defunct, throws warning", {
  vcr::use_cassette("dataset_search_return", {
    expect_warning(dataset_search(type="OCCURRENCE", return="descriptions"),
      "`return` param in `dataset_search` function is defunct")
  }, preserve_exact_body_bytes = TRUE)
})

# Return just descriptions
test_that("args that support many repeated uses in one request", {
  vcr::use_cassette("dataset_search_repeated_params", {
    aa <- dataset_search(type = c("metadata", "checklist"))
    bb <- dataset_search(publishingCountry = c("DE", "NZ"))
  }, preserve_exact_body_bytes = TRUE)

  expect_is(aa, "list")
  expect_named(aa, c('meta', 'data', 'facets', 'descriptions'))
  expect_is(aa$data, "tbl_df")
  expect_true(any(tolower(unique(aa$data$type)) %in% c("checklist", "metadata")))

  expect_is(bb, "list")
  expect_named(bb, c('meta', 'data', 'facets', 'descriptions'))
  expect_is(bb$data, "tbl_df")
  expect_true(any(tolower(unique(bb$data$publishingCountry)) %in% c("de", "nz")))
})

# check that $meta$count and $data are the same length
# https://github.com/ropensci/rgbif/issues/595
test_that("meta count and data are the same length", {
vcr::use_cassette("dataset_search_same_length", {
   ll <- dataset_search(publishingOrg = "80420c96-95d0-44eb-9f77-339ac92051fb",
                        limit=3)
  }, preserve_exact_body_bytes = TRUE)
  expect_is(ll, "list")
  expect_is(ll$data, "data.frame")
  expect_is(ll$data, "tbl_df")
  expect_is(ll$meta, "data.frame")
  expect_is(ll$descriptions, "list")
  expect_null(ll$facets)
  # equal to count or limit=3
  expect_true(nrow(ll$data) == ll$meta$count | nrow(ll$data) == 3)
  
})

