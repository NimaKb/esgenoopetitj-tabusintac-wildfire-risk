fire_exp_dir_custom <- function (exposure, value, t_lengths = c(5000, 5000, 5000, 10000), interval = 1, 
                                 thresh_exp = 0.6, thresh_viable = 0.8, table = FALSE) {
  
  stopifnot(`\`exposure\` must be a SpatRaster object` = class(exposure) == "SpatRaster")
  stopifnot(`\`exposure\` layer must have values between 0-1` = (round(terra::minmax(exposure)[1], 0) >= 0 &&
                                                                   round(terra::minmax(exposure)[2], 0) <= 1))
  stopifnot(`\`value\` must be a SpatVector object` = class(value) == "SpatVector")
  stopifnot(`\`t_lengths\` must be a vector of four numeric values` = class(t_lengths) == "numeric" && length(t_lengths) == 4)
  stopifnot(`\`interval\` must be one of: 0.5, 1, 2, 3, 4, 5, 6, 8, or 10` = interval %in% c(1, 2, 3, 4, 5, 6, 8, 10, 0.5))
  stopifnot(`\`thresh_exp\` must be a numeric value between 0-1` = thresh_exp >= 0 && thresh_exp <= 1)
  stopifnot(`\`thresh_viable\` must be a numeric value between 0-1` = thresh_viable >= 0 && thresh_viable <= 1)
  
  names(exposure) <- "exposure"
  expl <- exposure
  
  stopifnot(`\`exposure\` layer must have a CRS defined` = terra::crs(expl, describe = TRUE)$name != "unknown")
  stopifnot(`\`exposure\` and \`value\` must have the same CRS` = terra::crs(expl) == terra::crs(value))
  
  if (length(value) > 1) {
    value <- value[1]
    message("Value object provided has more than one feature, only the first point or polygon will be used.")
  }
  
  degs <- seq(0, 359, interval) + interval
  num_transects <- length(degs)
  wgs <- terra::project(value, "EPSG:4326")
  
  if (terra::geomtype(value) == "points") {
    x <- as.data.frame(wgs, geom = "XY")$x
    y <- as.data.frame(wgs, geom = "XY")$y
    linestart <- data.frame(deg = degs) %>% 
      dplyr::mutate(x0 = x) %>% 
      dplyr::mutate(y0 = y)
  } else if (terra::geomtype(value) == "polygons") {
    x <- as.data.frame(terra::centroids(wgs), geom = "XY")$x
    y <- as.data.frame(terra::centroids(wgs), geom = "XY")$y
    linegeom0 <- data.frame(deg = degs) %>% 
      dplyr::mutate(x0 = x) %>% 
      dplyr::mutate(y0 = y) %>% 
      dplyr::mutate(x1 = geosphere::destPoint(cbind(.data$x0, .data$y0), .data$deg, 25000)[, 1]) %>%
      dplyr::mutate(y1 = geosphere::destPoint(cbind(.data$x0, .data$y0), .data$deg, 25000)[, 2]) %>%
      dplyr::mutate(wkt = paste("LINESTRING(", .data$x0, " ", .data$y0, ", ", .data$x1, " ", .data$y1, ")", sep = ""))
    
    transects0 <- terra::vect(linegeom0, geom = "wkt", crs = "EPSG:4326") %>% terra::crop(wgs)
    
    if (length(terra::geom(transects0)) == num_transects * 10) {
      linestart <- as.data.frame(terra::geom(transects0)) %>% 
        dplyr::select("geom", x, y) %>%
        dplyr::mutate(deg = .data$geom) %>%
        dplyr::mutate(loc = rep(c(1, 0), times = num_transects)) %>%
        tidyr::pivot_wider(names_from = "loc", values_from = c(x, y), names_sep = "") %>%
        dplyr::select("deg", "x0", "y0")
    } else {
      stop("Polygon shape too irregular, please simplify further and try again")
    }
  } else {
    stop("value feature must be a point or polygon")
  }
  
  seg1length <- t_lengths[1]
  seg2length <- t_lengths[2]
  seg3length <- t_lengths[3]
  seg4length <- t_lengths[4]
  
  linegeom <- linestart %>%
    dplyr::mutate(x1 = geosphere::destPoint(cbind(.data$x0, .data$y0), .data$deg, seg1length)[, 1],
                  y1 = geosphere::destPoint(cbind(.data$x0, .data$y0), .data$deg, seg1length)[, 2],
                  seg1 = paste("LINESTRING(", .data$x0, " ", .data$y0, ", ", .data$x1, " ", .data$y1, ")", sep = "")) %>%
    dplyr::mutate(x2 = geosphere::destPoint(cbind(.data$x1, .data$y1), .data$deg, seg2length)[, 1],
                  y2 = geosphere::destPoint(cbind(.data$x1, .data$y1), .data$deg, seg2length)[, 2],
                  seg2 = paste("LINESTRING(", .data$x1, " ", .data$y1, ", ", .data$x2, " ", .data$y2, ")", sep = "")) %>%
    dplyr::mutate(x3 = geosphere::destPoint(cbind(.data$x2, .data$y2), .data$deg, seg3length)[, 1],
                  y3 = geosphere::destPoint(cbind(.data$x2, .data$y2), .data$deg, seg3length)[, 2],
                  seg3 = paste("LINESTRING(", .data$x2, " ", .data$y2, ", ", .data$x3, " ", .data$y3, ")", sep = "")) %>%
    dplyr::mutate(x4 = geosphere::destPoint(cbind(.data$x3, .data$y3), .data$deg, seg4length)[, 1],
                  y4 = geosphere::destPoint(cbind(.data$x3, .data$y3), .data$deg, seg4length)[, 2],
                  seg4 = paste("LINESTRING(", .data$x3, " ", .data$y3, ", ", .data$x4, " ", .data$y4, ")", sep = ""))
  
  linegeomlong <- linegeom %>%
    dplyr::select(c("deg", "seg1", "seg2", "seg3", "seg4")) %>%
    tidyr::pivot_longer(cols = c("seg1", "seg2", "seg3", "seg4"), names_to = "seg", values_to = "wkt")
  
  transects <- terra::vect(linegeomlong, geom = "wkt", crs = "EPSG:4326", keepgeom = TRUE) %>%
    terra::project(expl)
  
  exp <- terra::crop(expl, terra::rescale(transects, 1.1))
  rcm <- c(0, thresh_exp, NA, thresh_exp, 1, 1)
  rcmat <- matrix(rcm, ncol = 3, byrow = TRUE)
  highexp <- terra::classify(exp, rcmat, include.lowest = TRUE)
  highexppoly <- terra::as.polygons(highexp)
  
  if (length(highexppoly) > 0) {
    inters <- terra::crop(transects, highexppoly) %>%
      tidyterra::select(-"wkt")
    interslength <- terra::perim(inters)
    intdt <- cbind(as.data.frame(inters), interslength)
    transectlength <- terra::perim(transects)
    trdt <- cbind(as.data.frame(transects), transectlength)
    transects_length <- terra::merge(transects, trdt, by = c("deg", "seg", "wkt"), all = TRUE)
    transects2 <- terra::merge(transects_length, intdt, by = c("deg", "seg"), all = TRUE) %>%
      dplyr::mutate(interslength = tidyr::replace_na(interslength, 0)) %>%
      dplyr::mutate(viable = ifelse(interslength / transectlength >= thresh_viable, 1, 0)) %>%
      tidyterra::select(-interslength, -transectlength)
  } else {
    transects2 <- transects %>% dplyr::mutate(viable = 0)
  }
  
  if (table == TRUE) {
    return(as.data.frame(transects2))
  } else {
    transects3 <- transects2 %>% dplyr::select(-"wkt")
    return(transects3)
  }
}