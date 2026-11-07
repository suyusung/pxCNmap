# pxCNmap

Pixel-art tile-grid (block) maps of China's province-level units — 方块地图 —
drawn with **base R graphics only**. No `ggplot2`, no `sf`, no `grid`; the
package needs nothing beyond `graphics` and `grDevices`, which ship with R.

Each of the 34 province-level units is drawn as a rounded square on a regular
grid. The layout is a minimum-displacement solution on a 480 km Albers grid,
so the tiles keep their geographic relationships (mean error 268 km, max
549 km against the true provincial centroids) while every unit gets the same
visual weight. That makes the maps well suited to rates, indices and
categorical groupings, and it lets values be printed straight onto the tiles.

Chinese labels, with a value under each name:

![A tile-grid map of China's province-level units, with values printed under the names](man/figures/README-example.png)

The same map using English ISO 3166-2:CN codes (`name_type = "en"`), for
figures that should not depend on a CJK font:

![The same map with English ISO codes instead of Chinese characters](man/figures/README-english.png)

## Installation

```r
# install.packages("remotes")
remotes::install_github("suyusung/pxCNmap")
```

## Usage

`colors` is either an unnamed vector of exactly 34 values, consumed in
`CN_TILE_ORDER`, or a named vector matched by short name (京) or full name
(北京市) in any order.

```r
library(pxCNmap)

## one colour per broad region, in CN_TILE_ORDER
region <- rep(c("#2E649E", "#2B8274", "#B36119", "#2B823E",
                "#D02A25", "#8A4BC8", "#817337"), length.out = 34)
fills  <- setNames(region, CN_TILE_ORDER)

## a value for each unit, printed under its name
set.seed(1)
values <- setNames(round(runif(34, 3, 28), 1), CN_TILE_ORDER)

tile_map_cn(fills, numbers = values,
            label_colors = "white",
            border_color = "white", border_size = 1)

## or write the figure straight to a file
tile_map_cn(fills, numbers = values,
            label_colors = "white",
            border_color = "white", border_size = 1,
            file = "china_tile_map.png", width = 6.6, height = 6.6, res = 300)
```

### English labels

For a figure that should not depend on a CJK font — a journal that does not
render the characters, or a machine without one installed — use
`name_type = "en"`. The labels are then the ISO 3166-2:CN two-letter codes
(`CN_TILE_EN`: `BJ`, `TJ`, `HE`, ...), and the 南海诸岛 inset is labelled
`"SCS"`:

```r
## the figure above, right, with numbers
tile_map_cn(fills, name_type = "en", numbers = values,
            label_colors = "white",
            border_color = "white", border_size = 1)

## the codes and the layout line up
data.frame(code = CN_TILE_EN, full = cn_tiles()$full[1:34])
```

### Full administrative names

Longer labels are shrunk automatically, so the full names also fit:

```r
tile_map_cn(fills, name_type = "full", label_colors = "black",
            label_size = 4, corner_radius = 0, border_color = "grey20")
```

### When there are no numbers

Without `numbers`, `name_position = "top"` still leaves a gap for one;
`name_position = "auto"` centres the name in the tile instead:

```r
tile_map_cn(fills, name_position = "auto")
```

### Useful arguments

| argument | purpose |
|---|---|
| `colors` | 34 fills, unnamed in `CN_TILE_ORDER` or named by province |
| `labels`, `name_type`, `label_size`, `label_colors` | the province names; `name_type` is `"short"` (京), `"full"` (北京市) or `"en"` (`BJ`) |
| `numbers`, `number_size`, `number_colors` | values printed under the names |
| `name_position` | `"top"` (leaves room for numbers) or `"auto"` |
| `border_color`, `border_size` | tile outlines (`NA` = none) |
| `corner_radius` | `0` for plain squares, higher for rounder ones |
| `nz_color`, `nz_label_size` | the 南海诸岛 inset tile |
| `family` | font family; set a CJK font if your device does not fall back |
| `file`, `width`, `height`, `res` | draw straight to a PNG |

`cn_tiles()` returns the layout itself — short name, English abbreviation,
full name, grid row and column, and whether the row is the inset — and
`CN_TILE_ORDER` / `CN_TILE_EN` give the two label vectors in tile order:

```r
cn_tiles()
CN_TILE_ORDER
CN_TILE_EN
```

## Note on CJK fonts

The default labels are Chinese characters. Most devices find a CJK font
automatically; if yours does not, pass one explicitly, for example
`family = "WenQuanYi Zen Hei"` on Linux or `family = "SimHei"` on Windows.
Alternatively use `name_type = "en"`, which needs no CJK font at all.

## Repository layout

`attic/` holds an earlier `ggplot2`-based implementation of the same map. It
is not part of the package (it is listed in `.Rbuildignore`) and is kept only
for reference. `data-raw/tiles.R` is the readable source of the tile layout:
run it to regenerate `R/sysdata.rda` after changing positions or names.

## License

GPL (>= 3).
