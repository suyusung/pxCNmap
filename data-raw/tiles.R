## =====================================================================
## Source of truth for the tile layout.  Regenerate with:
##
##     Rscript data-raw/tiles.R          (from the package root)
##
## which rewrites R/sysdata.rda.
##
## Why this file exists rather than plain R/ code: R CMD check requires the
## R code of a package to be ASCII ("Portable packages must use only ASCII
## characters in their R code"), and CRAN rejects the resulting WARNING.  The
## Chinese strings therefore live here -- as readable text, in git -- and are
## compiled into the binary R/sysdata.rda that ships with the package.
## data-raw/ is listed in .Rbuildignore, so it never enters the tarball.
## =====================================================================

## The 34 province-level units, in row-major tile order.  This is the order
## in which an unnamed vector of 34 values is consumed by tile_map_cn().
CN_TILE_ORDER <- c("京", "津", "冀", "晋", "蒙", "辽", "吉", "黑", "沪", "苏",
                   "浙", "皖", "闽", "赣", "鲁", "台", "豫", "鄂", "湘", "粤",
                   "桂", "琼", "港", "澳", "渝", "川", "贵", "滇", "藏", "陕",
                   "甘", "青", "宁", "新")

## English abbreviations, same order.  These are the ISO 3166-2:CN
## subdivision codes, the conventional two-letter labels used in
## English-language maps and tables.  The 南海诸岛 inset is "SCS" (South
## China Sea), which has no ISO code of its own.
CN_TILE_EN <- c("BJ", "TJ", "HE", "SX", "NM", "LN", "JL", "HL", "SH", "JS",
                "ZJ", "AH", "FJ", "JX", "SD", "TW", "HA", "HB", "HN", "GD",
                "GX", "HI", "HK", "MO", "CQ", "SC", "GZ", "YN", "XZ", "SN",
                "GS", "QH", "NX", "XJ")

## grid position of each unit; the layout is a minimum-displacement solution
## on a 480 km Albers grid (mean error 268 km, max 549 km, against the true
## provincial centroids)
cn_tile_table <- data.frame(
  short = CN_TILE_ORDER,
  en    = CN_TILE_EN,
  full  = c("北京市", "天津市", "河北省", "山西省", "内蒙古自治区",
            "辽宁省", "吉林省", "黑龙江省", "上海市", "江苏省",
            "浙江省", "安徽省", "福建省", "江西省", "山东省", "台湾省",
            "河南省", "湖北省", "湖南省", "广东省", "广西壮族自治区",
            "海南省", "香港特别行政区", "澳门特别行政区", "重庆市",
            "四川省", "贵州省", "云南省", "西藏自治区", "陕西省",
            "甘肃省", "青海省", "宁夏回族自治区", "新疆维吾尔自治区"),
  row = c(2, 3, 3, 3, 2, 2, 1, 1, 5, 4,
          5, 5, 6, 6, 4, 7, 4, 5, 6, 7,
          7, 8, 7, 7, 5, 5, 6, 6, 4, 4,
          4, 4, 3, 3),
  col = c(6, 7, 6, 5, 5, 7, 7, 8, 8, 7,
          7, 6, 7, 6, 6, 8, 5, 5, 5, 5,
          4, 5, 7, 6, 4, 3, 4, 3, 1, 4,
          3, 2, 4, 1),
  inset = FALSE, stringsAsFactors = FALSE)

## 南海诸岛: grey inset, never counted as a province
cn_tile_table <- rbind(
  cn_tile_table,
  data.frame(short = "南海诸岛", en = "SCS", full = "南海诸岛",
             row = 8, col = 7, inset = TRUE, stringsAsFactors = FALSE))

stopifnot(nrow(cn_tile_table) == 35L,
          sum(!cn_tile_table$inset) == 34L,
          !anyDuplicated(cn_tile_table$short),
          !anyDuplicated(cn_tile_table$en),
          all(nchar(cn_tile_table$en[!cn_tile_table$inset]) == 2L),
          identical(cn_tile_table$en[35], "SCS"))

save(CN_TILE_ORDER, CN_TILE_EN, cn_tile_table,
     file = "R/sysdata.rda", version = 2)
cat("wrote R/sysdata.rda:", nrow(cn_tile_table), "rows,",
    length(unique(cn_tile_table$en)), "distinct English codes\n")
