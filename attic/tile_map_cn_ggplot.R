## tile_map_cn.R -----------------------------------------------------------
## Tile-grid (block) map of China's 34 province-level units — 方块地图.
## Layout: minimum-displacement solution on a 480 km Albers grid
## (mean error 268 km, max 549 km against the true provincial centroids).
##
## tile_map_cn() returns a ggplot object.
##
##   colors        34 fill colours, one per province. Either an unnamed vector
##                 in the order documented in CN_TILE_ORDER below, or a named
##                 vector whose names are the abbreviations (京, 津, …) or the
##                 full names (北京市, …) in any order.
##   labels        logical, draw the province names or not (default TRUE).
##   label_colors  34 colours for the names (recycled; the 南海诸岛 inset
##                 takes the 35th value, i.e. the first one recycled).
##   label_size    font size in points.  Names sit at the centre-top of the
##                 tile so that a number can be printed underneath.
##   numbers       optional 34 values printed under the name (NULL = none).
##                 Named vectors are matched like `colors`.
##   number_size   font size of the numbers (default 0.8 * label_size).
##   number_colors colours of the numbers (default: same as label_colors).
##   nz_label_size font size of the 南海诸岛 inset (default: shrunk to
##                 ~0.85 * label_size so its 4 characters fill the tile).
##   name_position "top" (always centre-top) or "auto" (centre the name
##                 vertically when no numbers are drawn).
##   border_color  tile outline colour; NA (default) = no border.
##   border_size   outline width in points.
##   corner_radius rounded-corner radius as a fraction of the tile size
##                 (0 = plain squares).
##   name_type     "short" (京) or "full" (北京市).

CN_TILE_ORDER <- c("京", "津", "冀", "晋", "蒙", "辽", "吉", "黑", "沪", "苏",
                   "浙", "皖", "闽", "赣", "鲁", "台", "豫", "鄂", "湘", "粤",
                   "桂", "琼", "港", "澳", "渝", "川", "贵", "滇", "藏", "陕",
                   "甘", "青", "宁", "新")

cn_tiles <- function() {
  b <- data.frame(
    short = c("京", "津", "冀", "晋", "蒙", "辽", "吉", "黑", "沪", "苏",
              "浙", "皖", "闽", "赣", "鲁", "台", "豫", "鄂", "湘", "粤",
              "桂", "琼", "港", "澳", "渝", "川", "贵", "滇", "藏", "陕",
              "甘", "青", "宁", "新"),
    full  = c("北京市", "天津市", "河北省", "山西省", "内蒙古自治区",
              "辽宁省", "吉林省", "黑龙江省", "上海市", "江苏省",
              "浙江省", "安徽省", "福建省", "江西省", "山东省", "台湾省",
              "河南省", "湖北省", "湖南省", "广东省", "广西壮族自治区",
              "海南省", "香港特别行政区", "澳门特别行政区", "重庆市",
              "四川省", "贵州省", "云南省", "西藏自治区", "陕西省",
              "甘肃省", "青海省", "宁夏回族自治区", "新疆维吾尔自治区"),
    row = c(2, 3, 3, 3, 2, 2, 1, 1, 5, 4, 5, 5, 6, 6, 4, 7, 4, 5, 6, 7,
            7, 8, 7, 7, 5, 5, 6, 6, 4, 4, 4, 4, 3, 3),
    col = c(6, 7, 6, 5, 5, 7, 7, 8, 8, 7, 7, 6, 7, 6, 6, 8, 5, 5, 5, 5,
            4, 5, 7, 6, 4, 3, 4, 3, 1, 4, 3, 2, 4, 1),
    inset = FALSE, stringsAsFactors = FALSE)
  ## 南海诸岛: grey inset, never counted as a province
  rbind(b, data.frame(short = "南海诸岛", full = "南海诸岛", row = 8, col = 7,
                      inset = TRUE, stringsAsFactors = FALSE))
}

## polygon for one rounded square, centred on (cx, cy)
rounded_square <- function(cx, cy, w, h, r, n = 6) {
  r <- min(r, w / 2, h / 2); hw <- w / 2 - r; hh <- h / 2 - r
  corners <- list(c(hw, -hh, -pi / 2, 0), c(hw, hh, 0, pi / 2),
                  c(-hw, hh, pi / 2, pi), c(-hw, -hh, pi, 3 * pi / 2))
  xs <- ys <- numeric(0)
  for (k in corners) {
    th <- seq(k[3], k[4], length.out = n)
    xs <- c(xs, cx + k[1] + r * cos(th))
    ys <- c(ys, cy + k[2] + r * sin(th))
  }
  data.frame(x = xs, y = ys)
}

tile_map_cn <- function(colors,
                        labels = TRUE,
                        label_colors = "white",
                        label_size = 7,
                        numbers = NULL,
                        number_size = NULL,
                        number_colors = NULL,
                        nz_label_size = NULL,
                        name_position = c("top", "auto"),
                        border_color = NA,
                        border_size = 0.5,
                        corner_radius = 0.16,
                        name_type = c("short", "full"),
                        nz_color = "grey45",
                        tile_size = 1,
                        background = "white") {

  name_type <- match.arg(name_type)
  d <- cn_tiles()

  ## ---- fills ------------------------------------------------------------
  if (!is.null(names(colors))) {
    i <- match(d$short, names(colors)); j <- match(d$full, names(colors))
    idx <- ifelse(is.na(i), j, i)
    miss <- which(is.na(idx) & !d$inset)
    if (length(miss)) stop("no colour supplied for: ", paste(d$short[miss], collapse = ", "))
    d$fill <- colors[idx]
  } else {
    if (length(colors) != 34L)
      stop("`colors` must be a vector of 34 values (one per province-level unit).")
    d$fill <- rep(NA_character_, nrow(d))
    d$fill[!d$inset] <- colors
  }
  d$fill[d$inset] <- nz_color

  ## ---- numbers ----------------------------------------------------------
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

  ## ---- labels -----------------------------------------------------------
  d$lab <- if (isTRUE(labels)) d[[name_type]] else ""
  d$lab_col <- rep(label_colors, length.out = nrow(d))
  d$num_col <- if (is.null(number_colors)) d$lab_col else rep(number_colors, length.out = nrow(d))
  ## single-character names keep full size, longer ones shrink, the
  ## 南海诸岛 inset gets its own (larger) size
  d$lab_size <- (label_size / ggplot2::.pt) * ifelse(nchar(d$lab) > 1, 3.4 / pmax(nchar(d$lab), 1L), 1)
  if (!is.null(nz_label_size) && any(d$inset)) d$lab_size[d$inset] <- nz_label_size / ggplot2::.pt
  d$num_size <- (if (is.null(number_size)) 0.8 * label_size else number_size) / ggplot2::.pt

  ## vertical placement inside the tile
  name_position <- match.arg(name_position)
  shift <- if (has_num || identical(name_position, "top")) 0.20 * tile_size else 0
  d$name_y <- -d$row + shift
  d$num_y <- -d$row - 0.22 * tile_size

  ## ---- tile outlines ----------------------------------------------------
  w <- h <- tile_size * 0.92
  polys <- do.call(rbind, lapply(seq_len(nrow(d)), function(k)
    cbind(group = k,
          rounded_square(cx = d$col[k], cy = -d$row[k], w = w, h = h,
                         r = corner_radius * tile_size),
          fill = d$fill[k])))
  labs <- data.frame(x = d$col, y = d$name_y, lab = d$lab,
                     col = d$lab_col, size = d$lab_size)
  nums <- data.frame(x = d$col, y = d$num_y, num = d$num,
                     col = d$num_col, size = d$num_size)

  ggplot2::ggplot(polys, ggplot2::aes(x = .data$x, y = .data$y,
                                      group = .data$group, fill = .data$fill)) +
    ggplot2::geom_polygon(colour = border_color, linewidth = border_size) +
    ggplot2::geom_text(data = labs,
                       ggplot2::aes(x = .data$x, y = .data$y, label = .data$lab,
                                    size = .data$size),
                       colour = labs$col, inherit.aes = FALSE, show.legend = FALSE) +
    ggplot2::geom_text(data = nums,
                       ggplot2::aes(x = .data$x, y = .data$y, label = .data$num,
                                    size = .data$size),
                       colour = nums$col, inherit.aes = FALSE, show.legend = FALSE) +
    ggplot2::scale_fill_identity() +
    ggplot2::scale_size_identity() +
    ggplot2::coord_equal(clip = "off") +
    ggplot2::labs(x = NULL, y = NULL) +
    ggplot2::theme_void(base_size = 12) +
    ggplot2::theme(plot.background = ggplot2::element_rect(fill = background,
                                                           colour = NA),
                   plot.margin = ggplot2::margin(6, 6, 6, 6))
}
