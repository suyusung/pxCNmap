## Tile layout for China's province-level units -----------------------------
##
## The layout is a minimum-displacement solution on a 480 km Albers grid
## (mean error 268 km, max 549 km, against the true provincial centroids).
##
## The Chinese names themselves live in R/sysdata.rda rather than in this
## file, because R CMD check requires the R code of a package to be ASCII.
## data-raw/tiles.R is the readable source of truth; run it to regenerate
## sysdata.  Everything below is pure ASCII.
##
## The layout table has one row per tile:
##   short  conventional one-character abbreviation (CN_TILE_ORDER)
##   full   full administrative name
##   row    grid row, row 1 at the top
##   col    grid column
##   inset  TRUE for the 南海诸岛 tile, which is not a province-level unit

#' Province short names in tile order
#'
#' The order in which the 34 province-level units are laid out, and therefore
#' the order in which an *unnamed* vector of 34 values is consumed by
#' [tile_map_cn()].  The 南海诸岛 inset is not part of this vector: it is not a
#' province-level unit.
#'
#' @format A character vector of length 34, holding the conventional
#'   one-character abbreviations (京, 津, 冀, ...) in row-major tile order.
#'
#' @seealso [cn_tiles()], [tile_map_cn()]
#'
#' @examples
#' CN_TILE_ORDER
#' length(CN_TILE_ORDER)
#'
#' @name CN_TILE_ORDER
#' @export
NULL

#' Tile positions for China's province-level units
#'
#' Returns the grid layout behind [tile_map_cn()]: one row per tile, giving
#' the conventional short name, the full administrative name, the grid row and
#' column, and whether the row is the 南海诸岛 inset rather than a province.
#'
#' @return A data frame with 35 rows and the columns
#'   \describe{
#'     \item{`short`}{the conventional one-character abbreviation (京).}
#'     \item{`full`}{the full administrative name (北京市).}
#'     \item{`row`, `col`}{integer position on the tile grid, row 1 at the top.}
#'     \item{`inset`}{`TRUE` for the 南海诸岛 tile, which is drawn in grey and
#'       is never counted as one of the 34 province-level units.}
#'   }
#'   The first 34 rows are in [CN_TILE_ORDER]; the inset is the last row.
#'
#' @seealso [CN_TILE_ORDER], [tile_map_cn()]
#'
#' @examples
#' tiles <- cn_tiles()
#' nrow(tiles)
#' sum(!tiles$inset)          # 34 province-level units
#' tiles[tiles$inset, ]
#'
#' @export
cn_tiles <- function() {
  cn_tile_table
}

#' Outline of one rounded square centred on the origin
#'
#' Internal helper: returns the polygon that [tile_map_cn()] shifts to each
#' tile centre.  `n` points are used per rounded corner.
#'
#' @param w,h Side lengths of the square.
#' @param r Corner radius, clipped to half the shorter side.
#' @param n Number of points per rounded corner.
#' @return A list with numeric vectors `x` and `y`.
#' @noRd
rounded_square <- function(w, h, r, n = 8) {
  r <- min(r, w / 2, h / 2); hw <- w / 2 - r; hh <- h / 2 - r
  corners <- list(c(hw, -hh, -pi / 2, 0), c(hw, hh, 0, pi / 2),
                  c(-hw, hh, pi / 2, pi), c(-hw, -hh, pi, 3 * pi / 2))
  xs <- ys <- numeric(0)
  for (k in corners) {
    th <- seq(k[3], k[4], length.out = n)
    xs <- c(xs, k[1] + r * cos(th)); ys <- c(ys, k[2] + r * sin(th))
  }
  list(x = xs, y = ys)
}
