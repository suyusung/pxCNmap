## A named vector of 34 colours, one per province, built from CN_TILE_ORDER.
fills34 <- function() {
  region <- rep(c("#2E649E", "#2B8274", "#B36119", "#2B823E",
                  "#D02A25", "#8A4BC8", "#817337"), length.out = 34)
  stats::setNames(region, CN_TILE_ORDER)
}

## Draw to a throwaway PNG so tests never depend on, or disturb, the
## session's current device.
draw <- function(...) {
  f <- tempfile(fileext = ".png")
  on.exit(unlink(f), add = TRUE)
  tile_map_cn(..., file = f, width = 3, height = 3, res = 72)
}

test_that("the tile table has 34 provinces plus the inset", {
  t <- cn_tiles()
  expect_s3_class(t, "data.frame")
  expect_equal(nrow(t), 35)
  expect_identical(names(t), c("short", "full", "row", "col", "inset"))
  expect_equal(sum(!t$inset), 34)
  expect_equal(sum(t$inset), 1)
  expect_true(t$inset[35])
  expect_identical(t$short[35], "南海诸岛")
  expect_false(anyDuplicated(t$short) > 0)
  expect_type(t$row, "double")
  expect_type(t$col, "double")
})

test_that("CN_TILE_ORDER matches the first 34 rows of the layout", {
  expect_length(CN_TILE_ORDER, 34)
  expect_identical(CN_TILE_ORDER, cn_tiles()$short[1:34])
})

test_that("unnamed colours must number exactly 34", {
  draw(rep("red", 34))
  expect_error(tile_map_cn(rep("red", 33), file = tempfile(fileext = ".png")),
               "must be a vector of 34")
  expect_error(tile_map_cn(rep("red", 35), file = tempfile(fileext = ".png")),
               "must be a vector of 34")
})

test_that("named colours are matched by short or full name, in any order", {
  n <- draw(fills34())$tiles$fill[1:34]

  ## reversed order, short names
  o <- draw(fills34()[rev(CN_TILE_ORDER)])$tiles$fill[1:34]
  expect_identical(o, n)

  ## full administrative names instead of abbreviations
  f <- stats::setNames(fills34(), cn_tiles()$full[1:34])
  expect_identical(draw(f)$tiles$fill[1:34], n)

  ## a missing province is an error, and the message names it
  expect_error(tile_map_cn(fills34()[-c(1, 5)], file = tempfile(fileext = ".png")),
               "no colour supplied for: 京, 蒙")
})

test_that("numbers are matched and validated like colours", {
  v <- stats::setNames(seq(1, 34), CN_TILE_ORDER)
  r <- draw(fills34(), numbers = v)
  expect_identical(r$tiles$num[1:34], as.character(1:34))
  expect_identical(r$tiles$num[35], "")          # the inset never gets one

  expect_error(tile_map_cn(fills34(), numbers = 1:33,
                           file = tempfile(fileext = ".png")),
               "must have 34 values")
  expect_error(tile_map_cn(fills34(), numbers = v[-2],
                           file = tempfile(fileext = ".png")),
               "no number supplied for: 津")
})

test_that("the inset takes nz_color, whatever the province colours are", {
  r <- draw(rep("#123456", 34), nz_color = "#ABCDEF")
  expect_identical(r$tiles$fill[35], "#ABCDEF")
  expect_true(all(r$tiles$fill[1:34] == "#123456"))
})

test_that("name_type selects abbreviations or full names", {
  expect_identical(draw(fills34())$tiles$lab[1], "京")
  expect_identical(draw(fills34(), name_type = "full")$tiles$lab[1], "北京市")
  ## labels = FALSE blanks them without changing the fills
  r <- draw(fills34(), labels = FALSE)
  expect_true(all(r$tiles$lab == ""))
  expect_equal(length(unique(r$tiles$fill[1:34])), 7)
})

test_that("full names are shrunk to fit inside a tile", {
  r <- draw(fills34(), name_type = "full")
  long <- which(nchar(r$tiles$lab) > 1)
  expect_true(length(long) > 0)
  ## the sizing rule guarantees a name spans at most 0.88 of a tile
  span <- r$label_pt[long] * nchar(r$tiles$lab[long])
  expect_true(all(span <= 0.88 * r$tile_pt + 1e-9))
  ## a single-character name keeps the size it was given ...
  r5 <- draw(fills34(), name_type = "full", label_size = 5)
  expect_equal(r5$label_pt[r5$tiles$lab == "北京市"], 5)
  ## ... while the longest one is shrunk below it
  expect_lt(r5$label_pt[r5$tiles$lab == "新疆维吾尔自治区"], 5)
})

test_that("number_size defaults to 0.8 of the label size", {
  r <- draw(fills34(), numbers = stats::setNames(1:34, CN_TILE_ORDER))
  expect_equal(r$number_pt, 0.8 * r$label_pt[1])
  r2 <- draw(fills34(), numbers = stats::setNames(1:34, CN_TILE_ORDER),
             number_size = 3)
  expect_equal(r2$number_pt, 3)
})

test_that("label_size and nz_label_size are honoured in points", {
  r <- draw(fills34(), label_size = 5)
  expect_equal(unique(r$label_pt[1:34]), 5)
  r2 <- draw(fills34(), label_size = 5, nz_label_size = 9)
  expect_equal(r2$label_pt[35], 9)
  expect_equal(r2$label_pt[1], 5)
})

test_that("a figure is actually written, and the function returns invisibly", {
  f <- tempfile(fileext = ".png")
  on.exit(unlink(f), add = TRUE)
  r <- withVisible(tile_map_cn(rep("steelblue", 34), file = f,
                               width = 3, height = 3, res = 100))
  expect_false(r$visible)
  expect_true(file.exists(f))
  expect_gt(file.size(f), 1000)
  expect_length(r$value$tiles$fill, 35)
})

test_that("drawing works on an already-open device, and restores par()", {
  f <- tempfile(fileext = ".png")
  on.exit(unlink(f), add = TRUE)
  grDevices::png(f, width = 300, height = 300)
  before <- graphics::par("mar")
  tile_map_cn(rep("grey30", 34))
  expect_equal(graphics::par("mar"), before)
  grDevices::dev.off()
  expect_true(file.exists(f))
  expect_gt(file.size(f), 1000)
})

test_that("input style does not change the colours that land on the tiles", {
  ## unnamed, in CN_TILE_ORDER ...
  unnamed <- rep(c("red", "green"), length.out = 34)
  ## ... and the same thing named
  named <- stats::setNames(unnamed, CN_TILE_ORDER)
  expect_identical(draw(unnamed)$tiles$fill, draw(named)$tiles$fill)
})
