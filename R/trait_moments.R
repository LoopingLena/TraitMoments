
#' trait_moments
#'
#' trait_moments returns the community weighted means and all higher moments (variance, skewness and kurtosis) of trait distributions calculated from a species-plot-matrix and a species-trait-matrix.
#' @param communities The species-plot-matrix as data frame. Column names must be species IDs and row names community IDs.
#' @param traits The species-trait-matrix as data frame. Column names must be trait IDs and row names species IDs. The species IDs must be consistent with those from the species-plot-matrix.
#' @param n_species Number of predominant species for which trait information must be present. If the criterion is not met, NA is returned for the trait-plot-combination. Default is 4.
#' @param abundance Cumulative relative abundance for which trait information must be present. If the criterion is not met, NA is returned for the trait-plot-combination. Default is 80%.
#' @return Community weighted means and all higher moments (variance, skewness and kurtosis) of trait distributions.
#' @examples
#' result <- trait_moments(example_communitys, example_traits, n_species = 5, abundance = 80)
#' @export

trait_moments <- function(communities, traits, n_species = 4, abundance = 80) {

  if (is.data.frame(communities) != TRUE) {stop("Species-plot-matrix is not a dataframe.")}
  if (is.data.frame(traits) != TRUE) {stop("Species-trait-matrix is not a dataframe.")}
  if (identical(sort(colnames(communities)), sort(rownames(traits))) != TRUE) {stop("Species-IDs in species-plot-matrix and species-trait-matrix are not identical.")}
  if (n_species == 0) {warning("If n_species = 0 no moments but only cwms can be calculated.")}
  if (n_species < 4) {warning("Calculations with n_species < 4 should be interpreted with caution.")}

  cover_com <- rowSums(communities) # total cover per plot
  communities <- communities * (100/cover_com) # calculate relative cover
  communities$comID <- row.names(communities)
  communities <- gather(communities, "Species", "Cover", -comID)

  traits$Species <- row.names(traits)
  traits <- gather(traits, "Trait", "Value", -Species)

  communities_traits <- full_join(communities, traits, by = "Species", relationship = "many-to-many")

  com_trait <- community_traits %>%
    select(comID, Trait) %>%
    unique()

  community_traits$isValue <- 1
  community_traits[is.na(community_traits$Value), ]$isValue <- 0
  community_traits$Cover_isValue <- community_traits$Cover * community_traits$isValue

  community_traits <- community_traits %>%
    group_by(comID, Trait) %>%
    summarise(Plotcover_isValue = sum(Cover_isValue)) %>%
    right_join(community_traits, by = c("comID", "Trait")) %>%
    mutate(Cover_relativ = 0.01 * Cover * (100/Plotcover_isValue)) %>%
    mutate(Value_x_Cover_relativ = Value * Cover_relativ)

  community_traits <- community_traits %>%
    group_by(comID, Trait) %>%
    summarise(
      mean = sum(Value_x_Cover_relativ, na.rm=TRUE),
      variance = sum(Cover_relativ*(Value -mean)^2, na.rm=TRUE),
      skewness = sum((Cover_relativ*(Value -mean)^3) / variance^(3/2), na.rm=TRUE),
      kurtosis = sum((Cover_relativ*(Value -mean)^4) / variance^2, na.rm=TRUE)) %>%
    right_join(community_traits, by = c("comID", "Trait"))

  community_traits <- community_traits %>%
    group_by(comID, Trait) %>%
    arrange(desc(Cover_relativ), .by_group = TRUE) %>%
    slice_head(n = n_species) %>%
    summarise(nValues = sum(isValue, na.rm=TRUE)) %>%
    right_join(community_traits, by = c("comID", "Trait"))

  community_traits1 <- community_traits %>%
    filter(Plotcover_isValue > abundance) %>%
    select(
      comID,
      Trait,
      mean) %>%
    unique()

  community_traits2 <- community_traits %>%
    filter(Plotcover_isValue > abundance & nValues == n_species) %>%
    select(
      comID,
      Trait,
      variance,
      skewness,
      kurtosis) %>%
    unique()


  community_traits1 <- full_join(com_trait, community_traits1, by=c("comID","Trait"))
  community_traits <- full_join(community_traits1, community_traits2, by=c("comID","Trait"))

  return(community_traits)
}





