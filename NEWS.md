# pxCNmap 0.1.0

First release.

* `tile_map_cn()` draws China's 34 province-level units as rounded squares on
  a regular grid, positioned so that the arrangement preserves geographic
  relationships, using **base R graphics only**.
* `cn_tiles()` returns the layout; `CN_TILE_ORDER` gives the order in which an
  unnamed vector of 34 values is consumed.
* Fill colours may be given unnamed (in `CN_TILE_ORDER`) or named by short
  (京) or full (北京市) province name, in any order.
* Optional numeric annotations under each label, configurable tile outlines,
  corner rounding, label size, family and colour, and an adjustable
  `南海诸岛` inset.
* Output may be drawn on the current device or written straight to a PNG file.
