#' Convert colors to alpha-beta values
#'
#' See https://en.wikipedia.org/wiki/HSL_and_HSV#Hue_and_chroma for more information.
#'
#' @param color_vec A character vector with a set of hex color values or R colors
#'
#' @return a data.frame with columns for the original color, alpha, and beta values.
#' @export
#'
col2ab <- function(color_vec) {
  rgbs <- grDevices::col2rgb(color_vec) / 255
  alphas <- rgbs["red",] - 0.5 * (rgbs["green",] + rgbs["blue",])
  betas <- sqrt(3) / 2 * (rgbs["green",] - rgbs["blue",])
  data.frame(color = color_vec,
             alpha = alphas,
             beta = betas)
}

#' Compute the closest R color for a set of hex colors
#'
#' This uses colors(distinct = TRUE).
#'
#' @param color_vec A character vector of the hex color codes
#'
#' @return A character vector of color names.
#' @export
#'
nearest_r_color <- function(color_vec) {
  r_rgb <- grDevices::col2rgb(grDevices::colors(distinct = TRUE))
  colnames(r_rgb) <- grDevices::colors(distinct = TRUE)

  nearest_cols <- character(length(color_vec))

  for(i in 1:length(color_vec)) {
    hex <- color_vec[i]

    diffs <- apply(r_rgb,
                   2,
                   function(x) {
                     sum(abs(x - grDevices::col2rgb(hex)))
                   })

    nearest_cols[i] <- colnames(r_rgb)[which(diffs == min(diffs))][1]
  }

  nearest_cols
}

#' Convert values to colors along a color ramp
#'
#' @param x a numeric vector to be converted to colors
#' @param min_val a number that's used to set the low end of the color scale (default = 0)
#' @param max_val a number that's used to set the high end of the color scale. If NULL (default),
#' use the highest value in x
#' @param colorset a set of colors to interpolate between using colorRampPalette
#' (default = c("darkblue","dodgerblue","gray80","orangered","red"))
#' @param missing_color a color to use for missing (NA) values.
#'
#' @return a character vector of hex color values generated by colorRampPalette. Color values will
#' remain in the same order as x.
#' @export
#'
values_to_colors <- function(x,
                             min_val = NULL,
                             max_val = NULL,
                             colorset = c("darkblue","dodgerblue","gray80","orange","orangered"),
                             missing_color = "black") {

  heat_colors <- grDevices::colorRampPalette(colorset)(1001)

  if (is.null(max_val)) {
    max_val <- max(x, na.rm = T)
  } else {
    x[x > max_val] <- max_val
  }
  if (is.null(min_val)) {
    min_val <- min(x, na.rm = T)
  } else {
    x[x < min_val] <- min_val
  }

  if (sum(x == min_val, na.rm = TRUE) == length(x)) {
    colors <- rep(heat_colors[1],length(x))
  } else {
    if (length(x) > 1) {
      if (stats::var(x, na.rm = TRUE) == 0) {
        colors <- rep(heat_colors[500], length(x))
      } else {
        heat_positions <- unlist(round((x - min_val) / (max_val - min_val) * 1000 + 1, 0))

        colors <- heat_colors[heat_positions]
      }
    } else {
      colors <- heat_colors[500]
    }
  }

  if (!is.null(missing_color)) {
    colors[is.na(colors)] <- grDevices::rgb(t(grDevices::col2rgb(missing_color)/255))
  }

  colors
}