human_numbers <- function(x = NULL, smbl ="", signif = 1){
  humanity <- function(y){
    if (!is.na(y)){
      tn <- round(abs(y) / 1e12, signif)
      b <- round(abs(y) / 1e9, signif)
      m <- round(abs(y) / 1e6, signif)
      k <- round(abs(y) / 1e3, signif)
      if ( y >= 0) {
        y_is_positive <- ""
      } else {
        y_is_positive <- "-"
      }
      if ( k < 1) {
        paste0(y_is_positive, smbl, round(abs(y), signif))
      } else if (m < 1) {
        paste0(y_is_positive, smbl,  k, "k")
      } else if (b < 1) {
        paste0 (y_is_positive, smbl, m, "m")
      }else if (tn < 1) {
        paste0(y_is_positive, smbl, b, "bn")
      } else {
        paste0(y_is_positive, smbl,  comma(tn), "tn")
      }
    } else if (is.na(y) | is.null(y)) {
      "-"
    }
  }
  sapply(x, humanity)
}
human_usd   <- function(x){human_numbers( x, smbl = "$")}
#Density Test
myDCdensity <- function(runvar, cutpoint, filename,
my_abline = 0, my_x_axis = "Incumbent Vote Percent (%)",
                        my_y_axis = "Density"){
  # get the default plot
  png(filename)
  myplot <- DCdensity(runvar, cutpoint)
  # 'additional graphical options to modify the plot'
  abline(v = my_abline)
  title(xlab=my_x_axis,ylab=my_y_axis)
}
IVS_RDD<-function(df){
  output<-lm(OffMenu ~ IW + IVS + IW * IVS, data = df)
}
bandwidth_implement<-function(df, band_l, band_u){
  df %>%
    filter(IVS>band_l, IVS<band_u)
}

