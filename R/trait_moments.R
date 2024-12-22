
#' trait_moments
#'
#' trait_moments calculates all moments (mean, variance, skewness and kurtosis) of trait distribution across large community and traits datasets. The calculation is performed according to the equations number 1 to 4 from Le Bagousse-Pinguet et al. (2017).
#' @param communities The species-plot-matrix as data frame. Column names must be species IDs and row names community IDs. It is not mandatory to provide relative abundances, but abundances should be on a nominal scale.
#' @param traits The species-trait-matrix as data frame. Column names must be trait IDs and row names species IDs. The species IDs must be consistent with those from the species-plot-matrix. Trait values have to be numeric.
#' @param n_species Number of predominant species for which trait information must be present. If the criterion is not met, NA is returned for the trait-plot-combination. Default is 4.
#' @param abundance Cumulative relative abundance for which trait information must be present. If the criterion is not met, NA is returned for the trait-plot-combination. Default is 80%.
#' @return Mean (CWM), variance, skewness and kurtosis of all trait distributions for each trait and each community.
#' @examples
#' result <- trait_moments(example_communitys, example_traits, n_species = 5, abundance = 80)
#' @references
#' Le Bagousse-Pinguet, Y., Gross, N., Maestre, F.T., Maire, V., Bello, F. de & Fonseca, C.R. et al. (2017) Testing the environmental filtering concept in global drylands. Journal of Ecology, 105(4), 1058–1069. Available from: https://doi.org/10.1111/1365-2745.12735.
#' @export

trait_moments <- function(communities, traits, n_species = 4, abundance = 80) {

  # Warnings and Errors
  if (is.data.frame(communities) != TRUE) {stop("Species-plot-matrix is not a dataframe.")}
  if (is.data.frame(traits) != TRUE) {stop("Species-trait-matrix is not a dataframe.")}
  if (identical(sort(colnames(communities)), sort(rownames(traits))) != TRUE) {stop("Species-IDs in species-plot-matrix and species-trait-matrix are not identical.")}
  if (n_species == 0) {warning("If n_species = 0 no moments but only cwms can be calculated.")}
  if (n_species < 4) {warning("Calculations with n_species < 4 may lead to unreliable results.")}

  # Calculate relative abundances and gather communities to long format
  cover_com <- rowSums(communities)
  communities <- communities * (100/cover_com)
  communities$comID <- row.names(communities)
  #communities <- tidyr::gather(communities, "Species", "Cover", -comID)
  communities <- communities %>% pivot_longer(!comID, names_to = "Species", values_to = "Cover")

  # Gather traits to long format
  traits$Species <- row.names(traits)
  #traits <- tidyr::gather(traits, "Trait", "Value", -Species)
  traits <- traits %>% pivot_longer(!Species, names_to = "Trait", values_to = "Value")

  # Full join of communities and traits
  community_traits <- full_join(communities, traits, by = "Species", relationship = "many-to-many")

  # Store the complete set of all possible trait-plot-combinations
  com_trait <- community_traits %>%
    select(comID, Trait) %>%
    unique()

  # Calculate the cumulative relative abundance for which trait information is available
  community_traits$isValue <- 1
  community_traits[is.na(community_traits$Value), ]$isValue <- 0
  community_traits$Cover_isValue <- community_traits$Cover * community_traits$isValue

  community_traits <- community_traits %>%
    group_by(comID, Trait) %>%
    summarise(Plotcover_isValue = sum(Cover_isValue)) %>%
    right_join(community_traits, by = c("comID", "Trait")) %>%
    mutate(Cover_relativ = 0.01 * Cover * (100/Plotcover_isValue)) %>%
    mutate(Value_x_Cover_relativ = Value * Cover_relativ)

  # Calculate moments
  community_traits <- community_traits %>%
    group_by(comID, Trait) %>%
    summarise(
      mean = sum(Value_x_Cover_relativ, na.rm=TRUE),
      variance = sum(Cover_relativ*(Value -mean)^2, na.rm=TRUE),
      skewness = sum((Cover_relativ*(Value -mean)^3) / variance^(3/2), na.rm=TRUE),
      kurtosis = sum((Cover_relativ*(Value -mean)^4) / variance^2, na.rm=TRUE)) %>%
    right_join(community_traits, by = c("comID", "Trait"))

  # Check if trait information is available for the predominant species
  community_traits <- community_traits %>%
    group_by(comID, Trait) %>%
    arrange(desc(Cover_relativ), .by_group = TRUE) %>%
    slice_head(n = n_species) %>%
    summarise(nValues = sum(isValue, na.rm=TRUE)) %>%
    right_join(community_traits, by = c("comID", "Trait"))

  # For the mean: select if cumulative relative abundance is high enough
  community_traits1 <- community_traits %>%
    filter(Plotcover_isValue > abundance) %>%
    select(
      comID,
      Trait,
      mean) %>%
    unique()

  # For the higher moments: select if cumulative relative abundance is high enough and if trait information is available for the predominant species
  community_traits2 <- community_traits %>%
    filter(Plotcover_isValue > abundance & nValues == n_species) %>%
    select(
      comID,
      Trait,
      variance,
      skewness,
      kurtosis) %>%
    unique()

# Join the complete set of all possible trait-plot-combinations with the calculated moments
  community_traits1 <- full_join(com_trait, community_traits1, by=c("comID","Trait"))
  community_traits <- full_join(community_traits1, community_traits2, by=c("comID","Trait"))

  return(community_traits)
}





