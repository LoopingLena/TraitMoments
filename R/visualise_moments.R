
#' visualise_moments
#'
#' visualise_moments visualises trait distributions for selected traits and communities based on density estimation from calculated moments.
#' See detailed information on in the github documentation
#' [TraitMoments](https://github.com/SchreinerFR/TraitMoments).
#'
#' @param result The result of a calculation of trait distribution moments as returned by trait_moments.
#' @param traitID The ID of a trait.
#' @param comID The ID of one or several communities as vector.
#' @param smooth Degree of smoothness of the curves. Default is 10000000. Increasing the value improves the smoothness but also increases the calculation time.
#' @return Visualization of trait distributions based on ggplot2.
#' @examples
#' \dontrun{
#' my_moment_plot <- visualise_moments(result = result,
#'traitID = "Trait.1",
#'comID = c(" Community.1", " Community.5", " Community.9"))
#'
#'my_moment_plot
#'
#'my_moment_plot +
#'  ggtitle("Distribution of trait 1 for three communities") +
#'  xlab("Trait 1") +
#'  scale_color_manual(values = c("black", "red", "orange")) +
#'  coord_cartesian(xlim = c(0,1), ylim = c(0,12), expand = FALSE)
#' }
#' @export

visualise_moments <- function(result, traitID, comID, smooth = 10000000) {

  set.seed(123)

  tID <- traitID
  cID <- comID

  sub <- subset(result, Trait == tID)
  sub <- subset(sub, comID %in% cID)

  gg_list <- list()

  for (i in 1:nrow(sub)) {
    com_name <- sub$comID[i]
    moments_i=c(mean = sub$mean[i],
                variance = sub$variance[i],
                skewness = sub$skewness[i],
                kurtosis = sub$kurtosis[i])

    pearson_generation  <- rpearson(smooth,
                                    moments=moments_i)
    dens <- density(pearson_generation)

    output <- cbind(rep(com_name, length(dens$x)),
                    dens$x,
                    dens$y)
    gg_list[[com_name]] <- output
  }


  gg_table <- as.data.frame(do.call(rbind, gg_list))
  gg_table$V2 <- as.numeric(gg_table$V2)
  gg_table$V3 <- as.numeric(gg_table$V3)

  return(
    ggplot(data = gg_table, aes(x = V2, y = V3, colour = V1)) +
      geom_line() +
      xlab(traitID) + ylab("Density") + labs(colour = "Communities") +
      theme_classic()
  )

}


