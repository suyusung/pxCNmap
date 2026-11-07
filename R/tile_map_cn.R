## tile_map_cn() ------------------------------------------------------------
## Tile-grid (block) map of China's 34 province-level units -- 方块地图.
## Base R graphics only: graphics + grDevices, no other packages.
## Layout: minimum-displacement solution on a 480 km Albers grid
## (mean error 268 km, max 549 km, against the true provincial centroids).

#' Draw a tile-grid (block) map of China
#'
#' Draws the 34 province-level units of China as rounded squares on a regular
#' grid, positioned so that the overall arrangement preserves geographic
#' relationships (方块地图).  Values are shown by filling each tile, so the map
#' stays readable when the quantity plotted is a rate or an index rather than
#' an area total.  The 南海诸岛 inset is drawn as its own grey tile and is never
#' counted as one of the 34 units.
#'
#' The function draws onto the current graphics device.  Passing `file` opens a
#' PNG device, draws, and closes it, which is the usual way to produce a
#' figure for a manuscript.  Labels default to the Chinese abbreviations; use
#' `name_type = "en"` for ISO 3166-2:CN English abbreviations when the figure
#' should not depend on a CJK font.
#'
#' @param colors Fill colours for the 34 province-level units.  Either an
#'   unnamed vector of exactly 34 values, consumed in [CN_TILE_ORDER], or a
#'   named vector whose names are the short names (京, 津, ...) or the full
#'   names (北京市, ...).  A named vector may be in any order, but every
#'   province-level unit must be given a colour.  The 南海诸岛 tile always takes
#'   `nz_color`.
#' @param labels Logical; draw the province names?
#' @param label_colors Colour(s) for the names.  Recycled over the tiles, so a
#'   single value colours every name alike and a vector of 34 gives one colour
#'   each; the 南海诸岛 inset takes the next value in the recycle.
#' @param label_size Font size of the names, in points.  `NULL` (the default)
#'   derives the size from the tile, which keeps the labels in proportion
#'   whatever the device and figure size.  Longer names are shrunk so that
#'   `name_type = "full"` still fits inside its tile.
#' @param numbers Optional values printed under the names, one per
#'   province-level unit.  Unnamed (34 values, in [CN_TILE_ORDER]) or named,
#'   matched like `colors`.  `NULL` draws no numbers.
#' @param number_size Font size of the numbers, in points.  `NULL` uses 0.8
#'   times the name size.
#' @param number_colors Colours of the numbers.  `NULL` uses `label_colors`.
#' @param nz_label_size Font size for the 南海诸岛 inset label, in points.
#'   `NULL` uses `label_size`, which suits one- or two-character names but
#'   leaves the four-character inset label small; give a larger value to
#'   enlarge it.
#' @param name_position `"top"` places the name above the tile centre, always
#'   leaving room for a number underneath; `"auto"` centres the name
#'   vertically when no numbers are drawn.
#' @param border_color Colour of the tile outlines.  `NA` (the default) draws
#'   no outline, which lets the tiles read as one continuous surface.
#' @param border_size Outline width in points (graphics `lwd`).
#' @param corner_radius Corner radius as a fraction of the tile side; `0` gives
#'   plain squares.  Clipped to half the tile side.
#' @param name_type Which label to draw: `"short"` for the conventional
#'   abbreviations (京), `"full"` for the administrative names (北京市), or
#'   `"en"` for the ISO 3166-2:CN English abbreviations (BJ) in [CN_TILE_EN].
#'   `"en"` gives a figure whose labels do not depend on a CJK font; the
#'   南海诸岛 inset is labelled `"SCS"`.
#' @param nz_color Fill colour of the 南海诸岛 inset tile.
#' @param tile_size Side of one tile in grid units.  The default of 1 leaves a
#'   small gap between neighbours; scaling it does not rescale the labels.
#' @param family Font family passed to [graphics::par()].  The default `""`
#'   uses the device default.  On a device that does not fall back for CJK
#'   automatically, pass a font that has Chinese glyphs, for example
#'   `"WenQuanYi Zen Hei"`.
#' @param background Canvas colour.
#' @param file Optional path; when given, a PNG device of `width` x `height`
#'   inches at `res` dpi is opened and closed around the drawing.
#' @param width,height,res Figure size in inches and resolution in dpi, used
#'   only when `file` is given.
#' @param pad Margin around the tiles, in grid units.
#'
#' @return Invisibly, a list with the tile table `tiles` (as returned by
#'   [cn_tiles()], plus the drawn fill, name, colour and size of each tile) and
#'   the computed font sizes `tile_pt`, `label_pt` and `number_pt`.  Called for
#'   its side effect of drawing.
#'
#' @seealso [cn_tiles()], [CN_TILE_ORDER]
#'
#' @examples
#' ## 34 fills in CN_TILE_ORDER -- here, one colour per broad region
#' region <- rep(c("#2E649E", "#2B8274", "#B36119", "#2B823E",
#'                 "#D02A25", "#8A4BC8", "#817337"), length.out = 34)
#'
#' ## write a figure straight to a file ...
#' f <- tempfile(fileext = ".png")
#' tile_map_cn(region, file = f, width = 5, height = 5, res = 100)
#' unlink(f)
#'
#' ## ... or just draw on the current device
#' tile_map_cn(region, label_colors = "white")
#'
#' ## names may be given in any order, and values printed under the names
#' fills <- setNames(region, CN_TILE_ORDER)
#' tile_map_cn(fills, numbers = round(seq(3, 28, length.out = 34), 1))
#'
#' ## full administrative names, square corners and an outline
#' tile_map_cn(fills, name_type = "full", label_colors = "black",
#'             label_size = 4, corner_radius = 0, border_color = "grey20")
#'
#' ## English abbreviations, for a figure that must not depend on a CJK font
#' tile_map_cn(fills, name_type = "en", label_colors = "black")
#'
#' @seealso [cn_tiles()], [CN_TILE_ORDER], [CN_TILE_EN]
#'
#' @export
tile_map_cn <- function(colors,
                        labels        = TRUE,       # draw the province names?
                        label_colors  = "white",    # font colours (recycled)
                        label_size    = NULL,       # points; NULL -> from tile
                        numbers       = NULL,       # values under the names
                        number_size   = NULL,       # points; NULL -> 0.8 * label
                        number_colors = NULL,       # NULL -> label_colors
                        nz_label_size = NULL,       # 南海诸岛 override, points
                        name_position = c("top", "auto"),
                        border_color  = NA,         # NA = no border
                        border_size   = 0.5,        # lwd
                        corner_radius = 0.153,      # fraction of the tile side
                        name_type     = c("short", "full", "en"),
                        nz_color      = "grey45",
                        tile_size     = 1,
                        family        = "",         # e.g. "WenQuanYi Zen Hei"
                        background    = "white",
                        file          = NULL,       # e.g. "fig.png"
                        width = 6.6, height = 6.6, res = 300,
                        pad = 0.3) {

  name_type     <- match.arg(name_type)
  name_position <- match.arg(name_position)
  d <- cn_tiles()

  ## ---- fills: unnamed = 34 in CN_TILE_ORDER, named = any order ----------
  if (!is.null(names(colors))) {
    i <- match(d$short, names(colors)); j <- match(d$full, names(colors))
    idx <- ifelse(is.na(i), j, i)
    miss <- which(is.na(idx) & !d$inset)
    if (length(miss)) stop("no colour supplied for: ", paste(d$short[miss], collapse = ", "))
    d$fill <- colors[idx]
  } else {
    if (length(colors) != 34L)
      stop("`colors` must be a vector of 34 values (one per province-level unit).")
    d$fill <- rep(NA_character_, nrow(d)); d$fill[!d$inset] <- colors
  }
  d$fill[d$inset] <- nz_color

  ## ---- optional numbers -------------------------------------------------
  if (is.null(numbers)) {
    d$num <- ""
  } else if (!is.null(names(numbers))) {
    i <- match(d$short, names(numbers)); j <- match(d$full, names(numbers))
    idx <- ifelse(is.na(i), j, i)
    miss <- which(is.na(idx) & !d$inset)
    if (length(miss)) stop("no number supplied for: ", paste(d$short[miss], collapse = ", "))
    d$num <- as.character(numbers[idx]); d$num[d$inset] <- ""
  } else {
    if (length(numbers) != 34L)
      stop("`numbers` must have 34 values (one per province-level unit).")
    d$num <- c(as.character(numbers), "")
  }
  has_num <- any(nzchar(d$num))

  ## ---- device + coordinate system ---------------------------------------
  if (!is.null(file))
    grDevices::png(file, width = width, height = height, units = "in",
                   res = res, bg = background)
  op <- graphics::par(mar = c(0, 0, 0, 0), xpd = NA, family = family, bg = background)
  on.exit({ graphics::par(op); if (!is.null(file)) grDevices::dev.off() }, add = TRUE)

  xlim <- c(min(d$col) - 0.5 - pad, max(d$col) + 0.5 + pad)
  ylim <- c(-max(d$row) - 0.5 - pad, -min(d$row) + 0.5 + pad)  # row 1 at the top
  graphics::plot.new()
  graphics::plot.window(xlim = xlim, ylim = ylim, asp = 1)

  ## side of one tile, in points, from the actual device
  tile_pt <- tile_size * 0.92 * graphics::par("pin")[1] * 72 / diff(xlim)

  ## ---- sizes (points -> cex) --------------------------------------------
  ps <- graphics::par("ps")
  if (is.null(label_size)) label_size <- 0.41 * tile_pt     # the Word-figure ratio
  d$lab <- if (isTRUE(labels)) d[[name_type]] else ""
  nc <- pmax(nchar(d$lab), 1L)
  lab_pt <- label_size * ifelse(nc > 1, pmin(1, 0.88 * tile_pt / (nc * label_size)), 1)
  if (!is.null(nz_label_size)) lab_pt[d$inset] <- nz_label_size
  num_pt <- if (is.null(number_size)) 0.8 * label_size else number_size

  d$lab_col <- rep(label_colors, length.out = nrow(d))
  d$num_col <- if (is.null(number_colors)) d$lab_col else rep(number_colors, length.out = nrow(d))
  ## names sit above the centre so a number can go underneath
  shift <- if (has_num || identical(name_position, "top")) 0.20 * tile_size else 0
  name_y <- -d$row + shift
  num_y  <- -d$row - 0.22 * tile_size

  ## ---- draw -------------------------------------------------------------
  tile_xy <- rounded_square(tile_size * 0.92, tile_size * 0.92,
                            corner_radius * tile_size)
  for (k in seq_len(nrow(d)))
    graphics::polygon(d$col[k] + tile_xy$x, -d$row[k] + tile_xy$y,
                      col = d$fill[k], border = border_color, lwd = border_size)
  if (isTRUE(labels))
    graphics::text(d$col, name_y, d$lab, col = d$lab_col, cex = lab_pt / ps)
  if (has_num)
    graphics::text(d$col, num_y, d$num, col = d$num_col, cex = num_pt / ps)

  invisible(list(tiles = d, tile_pt = tile_pt, label_pt = lab_pt, number_pt = num_pt))
}
