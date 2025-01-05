
#' trait_moments
#'
#' trait_moments calculates all moments (community-weighted mean, variance, skewness and kurtosis) of trait distribution across large community and traits datasets. The calculation is performed according to the equations number 1 to 4 from Le Bagousse-Pinguet et al. (2017).
#' See detailed information on the calculation in the github documentation
#' [TraitMoments](https://github.com/SchreinerFR/TraitMoments).
#'
#' @param communities The species-plot-matrix as data frame. Column names must be species IDs and row names community IDs. It is not mandatory to provide relative abundances, but abundances should be on a nominal scale.
#' @param traits The species-trait-matrix as data frame. Column names must be trait IDs and row names species IDs. The species IDs must be consistent with those from the species-plot-matrix. Trait values have to be numeric.
#' @param n_species Number of predominant species for which trait information must be present. If the criterion is not met, NA is returned for the trait-plot-combination. Default is 4.
#' @param abundance Cumulative relative abundance for which trait information must be present. If the criterion is not met, NA is returned for the trait-plot-combination. Default is 80%.
#' @return Mean (CWM), variance (CWV), skewness (CWS) and kurtosis (CWK) of all trait distributions for each trait and each community.
#' @examples
#' \dontrun{
#' result <- trait_moments(example_communitys, example_traits, n_species = 5, abundance = 80)
#' }
#' @references
#' Le Bagousse-Pinguet, Y., Gross, N., Maestre, F.T., Maire, V., Bello, F. de & Fonseca, C.R. et al. (2017) Testing the environmental filtering concept in global drylands. Journal of Ecology, 105(4), 1058–1069. Available from: https://doi.org/10.1111/1365-2745.12735.
#' @export

trait_moments <- function(communities, traits, n_species = 4, abundance = 80) {

  # Warnings and Errors
  if (is.data.frame(communities) != TRUE) {stop("The object 'communities' is not a dataframe.")}
  if (is.data.frame(traits) != TRUE) {stop("The object 'traits' is not a dataframe.")}
  if (identical(sort(colnames(communities)), sort(rownames(traits))) != TRUE) {stop("Species-IDs in 'communities' and 'traits' are not identical.")}
  if (any(is.na(communities))) {stop("The 'communities' dataframe contains missing values (NA). Consider replacing NAs by 0.")}
  if (n_species == 0) {warning("If 'n_species' = 0 no moments but only CWMs can be calculated.")}
  if (n_species < 4) {warning("It is not recommended to use 'n_species' < 4 for the calculation of higher moments. Consider to increase 'n_species'.")}

  # Calculate relative abundances
  cover_com <- rowSums(communities)
  communities <- communities * (100/cover_com)
  communities$comID <- row.names(communities)

  # Reshape communities to long format
  communities <- reshape(
    communities,
    varying = colnames(communities)[-ncol(communities)],
    v.names = "Cover",
    timevar = "Species",
    times = colnames(communities)[-ncol(communities)],
    idvar = "comID",
    direction = "long")

  rownames(communities) <- NULL

  # Reshape traits to long format
  traits$Species <- row.names(traits)

  traits <- reshape(
    traits,
    varying = colnames(traits)[-ncol(traits)],
    v.names = "Value",
    timevar = "Trait",
    times = colnames(traits)[-ncol(traits)],
    idvar = "Species",
    direction = "long")

  rownames(traits) <- NULL


  # Merge communities and traits
  community_traits <- merge(communities, traits, by = "Species", all = TRUE)

  # Store the complete set of all possible trait-plot-combinations
  com_trait <- unique(community_traits[1:nrow(community_traits), c(2,4)])

  # Calculate the cumulative relative abundance for which trait information is available
  community_traits$isValue <- 1
  community_traits[is.na(community_traits$Value), ]$isValue <- 0
  community_traits$Cover_isValue <- community_traits$Cover * community_traits$isValue

  agg_cover_isValue <- aggregate(Cover_isValue ~ comID + Trait, data = community_traits, FUN = function(x) sum(x, na.rm = TRUE))
  community_traits <- merge(community_traits, agg_cover_isValue, by = c("comID", "Trait"), suffixes = c("", "_sum"))
  community_traits$Cover_relativ <- 0.01 * community_traits$Cover * (100 / community_traits$Cover_isValue_sum)
  community_traits$Value_x_Cover_relativ <- community_traits$Value * community_traits$Cover_relativ

  # Calculate moments
  means <- aggregate(Value_x_Cover_relativ ~ comID + Trait, data = community_traits, FUN = function(x) sum(x, na.rm = TRUE))
  colnames(means)[3] <- "mean"
  community_traits <- merge(community_traits, means, by = c("comID", "Trait"))

  community_traits$variance <- ave(
    community_traits$Cover_relativ * (community_traits$Value - community_traits$mean)^2,
    community_traits$comID, community_traits$Trait, FUN = function(x) sum(x, na.rm = TRUE))

  community_traits$skewness <- ave(
    community_traits$Cover_relativ * (community_traits$Value - community_traits$mean)^3 / community_traits$variance^(3/2),
    community_traits$comID, community_traits$Trait, FUN = function(x) sum(x, na.rm = TRUE))

  community_traits$kurtosis <- ave(
    community_traits$Cover_relativ * (community_traits$Value - community_traits$mean)^4 / community_traits$variance^2,
    community_traits$comID, community_traits$Trait, FUN = function(x) sum(x, na.rm = TRUE))


  # Check if trait information is available for the predominant species
  community_traits <- community_traits[order(community_traits$comID,
                                             community_traits$Trait,
                                             -community_traits$Cover_relativ), ]

  predominant <- do.call(rbind, lapply(split(community_traits, list(community_traits$comID, community_traits$Trait)),
                                       function(sub) {
                                         if (nrow(sub) >= n_species) {
                                           sub[1:n_species, ]
                                         } else {
                                           sub
                                         }
                                       }))

  n_values_predominant <- aggregate(isValue ~ comID + Trait, data = predominant, FUN = sum)
  colnames(n_values_predominant)[3] <- "n_values_predominant"

  community_traits <- merge(community_traits, n_values_predominant, by = c("comID", "Trait"), all.x = TRUE)

  # For the mean: select if cumulative relative abundance is high enough
  community_traits1 <- unique(
    subset(community_traits, Cover_isValue_sum > abundance,
           select = c(comID, Trait, mean)))

  # For the higher moments: select if cumulative relative abundance is high enough and if trait information is available for the predominant species
  community_traits2 <- unique(
    subset(community_traits, Cover_isValue_sum > abundance & n_values_predominant == n_species,
           select = c(comID, Trait, variance, skewness, kurtosis)))

  # Merge the complete set of all possible trait-plot-combinations with the calculated moments
  community_traits1 <- merge(com_trait, community_traits1, by=c("comID","Trait"), all.x = TRUE)
  community_traits <- merge(community_traits1, community_traits2, by=c("comID","Trait"), all.x = TRUE)

  community_traits <- as.data.frame(community_traits)

  return(community_traits)
}



