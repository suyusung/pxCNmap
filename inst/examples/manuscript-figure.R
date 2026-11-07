## =====================================================================
## Manuscript-style figures, using the installed pxCNmap package.
## Run with:  Rscript manuscript-figure.R
## =====================================================================
library(pxCNmap)

## seven geographic regions, white names, no numbers, no borders
pal <- c(华北 = "#2E649E", 东北 = "#2B8274", 华东 = "#B36119", 华中 = "#2B823E",
         华南 = "#D02A25", 西南 = "#8A4BC8", 西北 = "#817337")
region_of <- c(京 = "华北", 津 = "华北", 冀 = "华北", 晋 = "华北", 蒙 = "华北",
               辽 = "东北", 吉 = "东北", 黑 = "东北",
               沪 = "华东", 苏 = "华东", 浙 = "华东", 皖 = "华东", 闽 = "华东",
               赣 = "华东", 鲁 = "华东", 台 = "华东",
               豫 = "华中", 鄂 = "华中", 湘 = "华中",
               粤 = "华南", 桂 = "华南", 琼 = "华南", 港 = "华南", 澳 = "华南",
               渝 = "西南", 川 = "西南", 贵 = "西南", 滇 = "西南", 藏 = "西南",
               陕 = "西北", 甘 = "西北", 青 = "西北", 宁 = "西北", 新 = "西北")
colors34 <- setNames(unname(pal[region_of]), CN_TILE_ORDER)

tile_map_cn(colors34,                      # 34 填色
            labels = TRUE,                 # 画省名
            label_colors = "white",        # 字体色（可给 34 个）
            name_position = "top",         # 名字居中偏上
            border_color = NA,             # 无边框
            file = "china_tile_map.png",
            width = 6.6, height = 6.6, res = 300)

## with numbers under the names and a border, for another figure
set.seed(1)
vals <- round(runif(34, 3, 28), 1)
tile_map_cn(colors34, numbers = vals, number_size = 11,
            label_size = 22, nz_label_size = 12,
            border_color = "white", border_size = 1,
            file = "china_tile_map_numbers.png",
            width = 6.6, height = 6.6, res = 300)

## English labels (ISO 3166-2:CN), for a version of the figure that does not
## depend on a CJK font being available
tile_map_cn(colors34, name_type = "en", label_colors = "white",
            border_color = NA,
            file = "china_tile_map_en.png",
            width = 6.6, height = 6.6, res = 300)

## to a vector PDF instead of a PNG (no `file=`, use your own device):
##   pdf("fig.pdf", width = 6.6, height = 6.6); tile_map_cn(colors34); dev.off()
##   Cairo::CairoPDF(...) or pdf(..., family = "GB1") for CJK on Linux
