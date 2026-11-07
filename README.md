# China Tile Map (Base R)

A lightweight, zero-dependency R function for rendering pixel-art style tile-grid maps of China's administrative divisions.

Built entirely with base R graphics, this tool requires no external packages (no `ggplot2`, no `sf`, no `grid`). It uses a minimum-displacement layout on a grid to accurately represent geographic relationships while maintaining a clean, retro aesthetic.

## Installation

Since this is a standalone script, you don't need to install it from CRAN. Simply download the `tile_map_cn.R` file and source it in your R environment:

```r
# Source the script directly
source("tile_map_cn.R")
