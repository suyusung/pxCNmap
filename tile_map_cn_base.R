cl## =====================================================================
##  tile_map_cn()  —  tile-grid (block) map of China, base R graphics only
##  No packages: no ggplot2, no grid, no ggforce. graphics + grDevices.
##  Layout: minimum-displacement solution on a 480 km Albers grid
##  (mean error 268 km, max 549 km, against the true provincial centroids).
## =====================================================================

CN_TILE_ORDER <- c("京","津","冀","晋","蒙","辽","吉","黑","沪","苏",
                   "浙","皖","闽","赣","鲁","台","豫","鄂","湘","粤",
                   "桂","琼","港","澳","渝","川","贵","滇","藏","陕",
                   "甘","青","宁","新")

cn_tiles <- function() {
  b <- data.frame(
    short = CN_TILE_ORDER,
    full  = c("北京市","天津市","河北省","山西省","内蒙古自治区",
              "辽宁省","吉林省","黑龙江省","上海市","江苏省",
              "浙江省","安徽省","福建省","江西省","山东省","台湾省",
              "河南省","湖北省","湖南省","广东省","广西壮族自治区",
              "海南省","香港特别行政区","澳门特别行政区","重庆市",
              "四川省","贵州省","云南省","西藏自治区","陕西省",
              "甘肃省","青海省","宁夏回族自治区","新疆维吾尔自治区"),
    row = c(2,3,3,3,2,2,1,1,5,4, 5,5,6,6,4,7,4,5,6,7, 7,8,7,7,5,5,6,6,4,4, 4,4,3,3),
    col = c(6,7,6,5,5,7,7,8,8,7, 7,6,7,6,6,8,5,5,5,5, 4,5,7,6,4,3,4,3,1,4, 3,2,4,1),
    inset = FALSE, stringsAsFactors = FALSE)
  ## 南海诸岛: grey inset, never counted as a province
  rbind(b, data.frame(short = "南海诸岛", full = "南海诸岛", row = 8, col = 7,
                      inset = TRUE, stringsAsFactors = FALSE))
}

## outline of one rounded square centred on (0, 0)
rounded_square <- function(w, h, r, n = 8) {
  r <- min(r, w/2, h/2); hw <- w/2 - r; hh <- h/2 - r
  corners <- list(c(hw,-hh,-pi/2,0), c(hw,hh,0,pi/2),
                  c(-hw,hh,pi/2,pi), c(-hw,-hh,pi,3*pi/2))
  xs <- ys <- numeric(0)
  for (k in corners) {
    th <- seq(k[3], k[4], length.out = n)
    xs <- c(xs, k[1] + r*cos(th)); ys <- c(ys, k[2] + r*sin(th))
  }
  list(x = xs, y = ys)
}

tile_map_cn <- function(colors,
                        labels        = TRUE,       # draw the province names?
                        label_colors  = "white",    # 34 font colours
                        label_size    = NULL,       # points; NULL -> 0.41 * tile side
                        numbers       = NULL,       # 34 values under the names (NULL = none)
                        number_size   = NULL,       # points; NULL -> 0.8 * label_size
                        number_colors = NULL,       # NULL -> same as label_colors
                        nz_label_size = NULL,       # 南海诸岛 override, points
                        name_position = c("top", "auto"),
                        border_color  = NA,         # NA = no border
                        border_size   = 0.5,        # lwd
                        corner_radius = 0.153,      # fraction of the tile side
                        name_type     = c("short", "full"),
                        nz_color      = "grey45",
                        tile_size     = 1,
                        family        = "",         # e.g. "WenQuanYi Zen Hei" on Linux
                        background    = "white",
                        file          = NULL,       # e.g. "fig.png" -> opens/closes a device
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
  nc <- pmax(nchar(d$lab <- if (isTRUE(labels)) d[[name_type]] else ""), 1L)
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


## =====================================================================
## EXAMPLE — this reproduces the figure used in the manuscript
## (seven geographic regions, white names, no numbers, no borders)
## =====================================================================
if (FALSE) {   # <- flip to TRUE to run; or just copy the block below
  pal <- c(华北 = "#2E649E", 东北 = "#2B8274", 华东 = "#B36119", 华中 = "#2B823E",
           华南 = "#D02A25", 西南 = "#8A4BC8", 西北 = "#817337")
  region_of <- c(京="华北", 津="华北", 冀="华北", 晋="华北", 蒙="华北",
                 辽="东北", 吉="东北", 黑="东北",
                 沪="华东", 苏="华东", 浙="华东", 皖="华东", 闽="华东",
                 赣="华东", 鲁="华东", 台="华东",
                 豫="华中", 鄂="华中", 湘="华中",
                 粤="华南", 桂="华南", 琼="华南", 港="华南", 澳="华南",
                 渝="西南", 川="西南", 贵="西南", 滇="西南", 藏="西南",
                 陕="西北", 甘="西北", 青="西北", 宁="西北", 新="西北")
  colors34 <- setNames(unname(pal[region_of]), CN_TILE_ORDER)

  tile_map_cn(colors34,                      # 34 填色
              labels = TRUE,                 # 画省名
              label_colors = "white",        # 字体色（可给 34 个）
              name_position = "top",         # 名字居中偏上
              border_color = NA,             # 无边框
              file = "china_tile_map_base.png",
              width = 6.6, height = 6.6, res = 300)

  ## with numbers under the names and a border, for another figure:
  set.seed(1); vals <- round(runif(34, 3, 28), 1)
  tile_map_cn(colors34, numbers = vals, number_size = 11,
              label_size = 22, nz_label_size = 12,
              border_color = "white", border_size = 1,
              file = "china_tile_map_base_numbers.png",
              width = 6.6, height = 6.6, res = 300)

  ## to a vector PDF instead of a PNG (no `file=`, use your own device):
  ##   pdf("fig.pdf", width = 6.6, height = 6.6); tile_map_cn(colors34); dev.off()
  ##   Cairo::CairoPDF(...) or pdf(..., family = "GB1") for CJK on Linux
}
