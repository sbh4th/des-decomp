dag_plot <- function(dag, node_col = "black", edge_col = "black",
                      curve = list(), cex = 2.4, lwd = 2,
                      pad = 0.6, shrink = 0.16) {
  coords <- dagitty::coordinates(dag)
  labels <- names(coords$x)
  y <- -coords$y

  if (length(node_col) == 1) node_col <- setNames(rep(node_col, length(labels)), labels)
  if (is.null(names(edge_col))) edge_col <- setNames(rep(edge_col, 1), "__default__")

  ex <- dagitty::edges(dag)

  par(mar = rep(0.3, 4), family = "serif")
  plot(NA, xlim = range(coords$x) + c(-pad, pad), 
       ylim = range(y) + c(-pad, pad),
       xlab = "", ylab = "", bty = "n", xaxt = "n", yaxt = "n")

  ecol_for <- function(l1, l2) {
    key <- paste0(l1, "->", l2)
    if (key %in% names(edge_col)) return(edge_col[[key]])
    if ("__default__" %in% names(edge_col)) return(edge_col[["__default__"]])
    "black"
  }

  for (i in seq_len(nrow(ex))) {
    l1 <- as.character(ex[i, 1]); l2 <- as.character(ex[i, 2])
    x1 <- coords$x[l1]; y1 <- y[l1]
    x2 <- coords$x[l2]; y2 <- y[l2]
    col_i <- ecol_for(l1, l2)
    key <- paste0(l1, "->", l2)

    if (!is.null(curve[[key]])) {
      cx <- (x1 + x2) / 2 + curve[[key]][1]
      cy <- (y1 + y2) / 2 + curve[[key]][2]
      # shrink both ends toward the control point too, or the arrow
      # tip and line start overlap the node letters
      x1s <- x1 + shrink * (cx - x1); y1s <- y1 + shrink * (cy - y1)
      x2s <- x2 + shrink * (cx - x2); y2s <- y2 + shrink * (cy - y2)
      res <- xspline(c(x1s, cx, x2s), c(y1s, cy, y2s), 
                     shape = 1, draw = FALSE)
      lines(res, col = col_i, lwd = lwd)
      nr <- length(res$x)
      shape::Arrows(res$x[nr - 3], res$y[nr - 3], res$x[nr], res$y[nr],
        arr.length = 0.22, arr.width = 0.14, col = col_i, 
        lwd = lwd, arr.adj = 1, arr.type = "curved")
    } else {
      dx <- x2 - x1; dy <- y2 - y1
      xs1 <- x1 + shrink * dx; ys1 <- y1 + shrink * dy
      xs2 <- x2 - shrink * dx; ys2 <- y2 - shrink * dy
      shape::Arrows(xs1, ys1, xs2, ys2, 
        arr.length = 0.22, arr.width = 0.14,
        col = col_i, lwd = lwd, arr.adj = 1, 
        arr.type = "curved")
    }
  }

  for (l in labels) {
    text(coords$x[l], y[l], l, cex = cex, 
         col = node_col[[l]], font = 4)
  }

  invisible(list(coords = coords, y = y))
}