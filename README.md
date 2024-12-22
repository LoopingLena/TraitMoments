
# TraitMoments

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

TraitMoments provides an efficient function to calculate all moments
(mean, variance, skewness and kurtosis) of trait distribution across
large community and traits datasets. The calculation is performed
according to the equations number 1 to 4 from Le Bagousse-Pinguet et
al. (2017). The calculation of all moments provides detailed insights
into the precise shape of trait distributions and allows the derived
parameters to be linked to established frameworks of functional
diversity (Bello et al. 2021, Bagousse-Pinguet et al. 2021) and the
filtering concept (Enquist et al. 2015).

## Installation

Install the latest version from GitHub with:

``` r
# install.packages("devtools")
devtools::install_github("SchreinerFR/TraitMoments")
```

## View documentation

Load the package and call the documentation for the function
‘trait_moments’:

``` r
library(TraitMoments)
?trait_moments
```

## Example data

TraitMoments provides two example data frames. The data frame
‘communities’ contains the abundances for 93 species from 20 communities
and the ‘traits’ provides information on seven traits for the
corresponding species. For some species, no information is available for
certain traits, so the data frame ‘traits’ contains some NAs. Since both
data frames are quite large, we will only inspect the heads in this
example:

``` r
data(trait_moments_data)
communities[1:20,1:5] 
```

    ##                 Species.1  Species.2 Species.3  Species.4 Species.5
    ##  Community.1   0.61633412 0.00000000 0.0000000 0.12326682 0.0000000
    ##  Community.2   0.00000000 0.00000000 0.0000000 0.00000000 0.0000000
    ##  Community.3   0.00000000 0.00000000 0.0000000 0.00000000 0.0000000
    ##  Community.4   0.00000000 0.00000000 0.0000000 0.78828164 0.0000000
    ##  Community.5   0.43530075 0.00000000 0.0000000 0.08706015 0.0000000
    ##  Community.6   0.00000000 0.00000000 0.0000000 0.00000000 0.0000000
    ##  Community.7   0.00000000 0.00000000 0.0000000 0.00000000 0.0000000
    ##  Community.8   0.00000000 0.00000000 0.0000000 0.00000000 0.0000000
    ##  Community.9   3.25955662 0.00000000 0.0000000 0.00000000 0.5432594
    ##  Community.10  0.00000000 0.00000000 0.0000000 0.00000000 0.0000000
    ##  Community.11 12.84311208 0.00000000 0.9173651 0.00000000 0.0000000
    ##  Community.12  0.38406433 0.07681287 0.0000000 0.00000000 0.0000000
    ##  Community.13  0.00000000 0.10573851 0.0000000 0.00000000 0.0000000
    ##  Community.14  0.00000000 0.00000000 0.0000000 0.00000000 0.0000000
    ##  Community.15  0.00000000 0.00000000 1.1812003 0.00000000 0.0000000
    ##  Community.16  3.49791397 0.00000000 0.0000000 0.00000000 0.0000000
    ##  Community.17  0.06640081 0.00000000 0.0000000 0.00000000 0.0000000
    ##  Community.18  1.22548008 0.00000000 0.0000000 0.00000000 0.0000000
    ##  Community.19  0.86297256 0.00000000 0.0000000 0.00000000 0.0000000
    ##  Community.20  0.07832944 0.00000000 0.0000000 0.00000000 0.0000000

``` r
traits[1:6,1:ncol(traits)] 
```

    ##             Trait.1    Trait.2  Trait.3   Trait.4   Trait.5  Trait.6  Trait.7
    ## Species.1 0.3009894 0.13734661 13.16769 0.1957314 0.2009811 462.6140 33.25711
    ## Species.2 0.5103779 8.88432577 16.03686 0.3298996 0.2631301 108.8362 77.89976
    ## Species.3 0.3518951 0.04110331 21.77802 0.2565824 0.1250949 519.5441 23.21299
    ## Species.4 0.3671649 0.35082449 15.38340 0.1978408        NA       NA       NA
    ## Species.5 0.4503360 3.43468944  9.43788 0.1614551        NA       NA       NA
    ## Species.6 0.6234141 1.08995680 27.80066 0.3848673 0.1804653 643.4836 19.22852

## Example calculations

### First: with default settings

Now we use the function ‘trait_moments’ to calculate the moments of all
trait distributions for each trait and each community. The function will
perform the calculation for all 140 combinations of trait and community
at once. Since the resulting data frame is quite large, we will only
inspect the head in this example:

``` r
result <- trait_moments(communities, traits)
dim(result)
```

    ## [1] 140   6

``` r
result[1:20,1:ncol(result)]
```

    ## # A tibble: 20 × 6
    ##    comID          Trait      mean    variance skewness kurtosis
    ##    <chr>          <chr>     <dbl>       <dbl>    <dbl>    <dbl>
    ##  1 " Community.1" Trait.1   0.371     0.0378     0.989     2.88
    ##  2 " Community.1" Trait.2   1.93      6.48       1.76      4.83
    ##  3 " Community.1" Trait.3  25.2      73.6        1.76      5.51
    ##  4 " Community.1" Trait.4   0.266     0.00596    0.101     1.57
    ##  5 " Community.1" Trait.5  NA        NA         NA        NA   
    ##  6 " Community.1" Trait.6  NA        NA         NA        NA   
    ##  7 " Community.1" Trait.7  NA        NA         NA        NA   
    ##  8 " Community.2" Trait.1   0.368     0.0228     0.913     2.82
    ##  9 " Community.2" Trait.2   1.89      1.67       5.77     72.5 
    ## 10 " Community.2" Trait.3  NA        NA         NA        NA   
    ## 11 " Community.2" Trait.4   0.255     0.00555    0.741     1.97
    ## 12 " Community.2" Trait.5  NA        NA         NA        NA   
    ## 13 " Community.2" Trait.6  NA        NA         NA        NA   
    ## 14 " Community.2" Trait.7  NA        NA         NA        NA   
    ## 15 " Community.3" Trait.1   0.363     0.0343     0.412     2.01
    ## 16 " Community.3" Trait.2   1.37      2.18       4.78     41.1 
    ## 17 " Community.3" Trait.3  25.3      34.9        0.557     3.04
    ## 18 " Community.3" Trait.4   0.256     0.00418    0.839     2.38
    ## 19 " Community.3" Trait.5   0.178     0.00117    0.657     3.18
    ## 20 " Community.3" Trait.6 393.    28142.         0.584     1.74

### Second: with settings to control the trade-off between reliable results and the number of NAs obtained

``` r
result <- trait_moments(communities, traits, n_species = 1, abundance = 50)
```

    ## Warning in trait_moments(communities, traits, n_species = 1, abundance = 50):
    ## Calculations with n_species < 4 may lead to unreliable results.

``` r
result[1:20,1:ncol(result)]
```

    ## # A tibble: 20 × 6
    ##    comID          Trait      mean     variance skewness kurtosis
    ##    <chr>          <chr>     <dbl>        <dbl>    <dbl>    <dbl>
    ##  1 " Community.1" Trait.1   0.371     0.0378      0.989     2.88
    ##  2 " Community.1" Trait.2   1.93      6.48        1.76      4.83
    ##  3 " Community.1" Trait.3  25.2      73.6         1.76      5.51
    ##  4 " Community.1" Trait.4   0.266     0.00596     0.101     1.57
    ##  5 " Community.1" Trait.5   0.170     0.000771    2.39      7.52
    ##  6 " Community.1" Trait.6 526.    43859.         -0.297     1.90
    ##  7 " Community.1" Trait.7  46.9     288.          2.61     12.1 
    ##  8 " Community.2" Trait.1   0.368     0.0228      0.913     2.82
    ##  9 " Community.2" Trait.2   1.89      1.67        5.77     72.5 
    ## 10 " Community.2" Trait.3  24.3      NA          NA        NA   
    ## 11 " Community.2" Trait.4   0.255     0.00555     0.741     1.97
    ## 12 " Community.2" Trait.5   0.171    NA          NA        NA   
    ## 13 " Community.2" Trait.6 450.       NA          NA        NA   
    ## 14 " Community.2" Trait.7  50.6      NA          NA        NA   
    ## 15 " Community.3" Trait.1   0.363     0.0343      0.412     2.01
    ## 16 " Community.3" Trait.2   1.37      2.18        4.78     41.1 
    ## 17 " Community.3" Trait.3  25.3      34.9         0.557     3.04
    ## 18 " Community.3" Trait.4   0.256     0.00418     0.839     2.38
    ## 19 " Community.3" Trait.5   0.178     0.00117     0.657     3.18
    ## 20 " Community.3" Trait.6 393.    28142.          0.584     1.74

## Visualisation of trait distributions based on moments

A function for visualising trait distributions based on the moments is
not yet available in ‘TraitMoments’, but I intend to implement it in
later versions. Here I show how to visualise trait distributions for
single communities using the package ‘PearsonDS’. Lets plot the
distributions of Trait 1 in Community 1, 9 and 10:

``` r
library(PearsonDS)

selected_results <- rbind(
  result[1, 1:ncol(result)],
  result[57, 1:ncol(result)],
  result[64, 1:ncol(result)])

selected_results
```

    ## # A tibble: 3 × 6
    ##   comID           Trait    mean variance skewness kurtosis
    ##   <chr>           <chr>   <dbl>    <dbl>    <dbl>    <dbl>
    ## 1 " Community.1"  Trait.1 0.371   0.0378   0.989      2.88
    ## 2 " Community.9"  Trait.1 0.429   0.0483  -0.0286     1.86
    ## 3 " Community.10" Trait.1 0.442   0.0355  -0.448      1.65

``` r
Community.1_Trait.1 <- result[1, 1:ncol(result)]
Community.9_Trait.1 <- result[57, 1:ncol(result)]
Community.10_Trait.1 <- result[64, 1:ncol(result)]

set.seed(123)
pearson_generation  <- rpearson(10000000,moments=c(mean = Community.1_Trait.1[3], variance = Community.1_Trait.1[4], skewness = Community.1_Trait.1[5], kurtosis = Community.1_Trait.1[6]))
dens_Community.1_Trait.1 <- density(pearson_generation)

pearson_generation  <- rpearson(10000000,moments=c(mean = Community.9_Trait.1[3], variance = Community.9_Trait.1[4], skewness = Community.9_Trait.1[5], kurtosis = Community.9_Trait.1[6]))
dens_Community.9_Trait.1 <- density(pearson_generation)

pearson_generation  <- rpearson(10000000,moments=c(mean = Community.10_Trait.1[3], variance = Community.10_Trait.1[4], skewness = Community.10_Trait.1[5], kurtosis = Community.10_Trait.1[6]))
dens_Community.10_Trait.1 <- density(pearson_generation)

par(mfrow = c(3, 1))
plot(dens_Community.1_Trait.1$x,length(dens_Community.1_Trait.1$x)*dens_Community.1_Trait.1$y,type="l",xlab="Value",ylab="Frequency", yaxt='n', main = "Community 1 Trait 1", xlim = c(0,1))
plot(dens_Community.9_Trait.1$x,length(dens_Community.9_Trait.1$x)*dens_Community.9_Trait.1$y,type="l",xlab="Value",ylab="Frequency", yaxt='n', main = "Community 9 Trait 1", xlim = c(0,1))
plot(dens_Community.10_Trait.1$x,length(dens_Community.10_Trait.1$x)*dens_Community.10_Trait.1$y,type="l",xlab="Value",ylab="Frequency", yaxt='n', main = "Community 10 Trait 1", xlim = c(0,1))
```

![](README_files/figure-gfm/unnamed-chunk-5-1.png)<!-- -->

## Final note on CWMs

The function ‘functcomp’ from the package ‘FD’ is often used to
calculate community weighted means (CWMs). Here this function is applied
to our data:

``` r
library(FD)
functcomp(traits, as.matrix(communities))
```

    ##                 Trait.1   Trait.2  Trait.3   Trait.4   Trait.5  Trait.6
    ##  Community.1  0.3711024 1.9321757 25.24934 0.2664765 0.1701620 526.1603
    ##  Community.2  0.3682858 1.8883485 24.29788 0.2545458 0.1712572 449.8064
    ##  Community.3  0.3632115 1.3659117 25.27505 0.2562308 0.1781169 393.2414
    ##  Community.4  0.3812156 1.9150422 23.27704 0.2426291 0.1638830 358.2445
    ##  Community.5  0.5123229 0.7965969 28.55508 0.3125493 0.1692056 660.3596
    ##  Community.6  0.4751714 1.4579142 26.48890 0.3281365 0.1691134 592.1892
    ##  Community.7  0.4866869 1.0830359 26.35931 0.3162064 0.1732428 583.8485
    ##  Community.8  0.4470373 1.6317999 28.21371 0.2529728 0.1793524 587.6480
    ##  Community.9  0.4290053 0.8766702 29.50861 0.2409701 0.1765722 467.6702
    ##  Community.10 0.4418142 1.4423856 26.44587 0.2929882 0.1644753 466.0545
    ##  Community.11 0.3034790 1.1262754 21.52881 0.2274629 0.1657275 368.1959
    ##  Community.12 0.3657468 0.7369618 25.47587 0.3026888 0.1867092 620.4412
    ##  Community.13 0.5507248 1.5713105 30.09605 0.2964033 0.1756577 438.8303
    ##  Community.14 0.7397078 1.3747179 22.68627 0.3306666 0.1668824 435.8542
    ##  Community.15 0.3097454 0.3395123 20.72012 0.3586663 0.1599153 634.8580
    ##  Community.16 0.5483496 2.5656955 28.55644 0.2844488 0.1659508 382.7778
    ##  Community.17 0.2939200 1.3773304 20.33092 0.2582288 0.1548343 361.9863
    ##  Community.18 0.3949284 1.2847193 21.12148 0.3473668 0.1637132 569.1058
    ##  Community.19 0.3844592 1.3889136 22.07464 0.3040158 0.1668605 473.7622
    ##  Community.20 0.4393824 2.2494794 25.05227 0.2843167 0.1741615 394.5651
    ##                Trait.7
    ##  Community.1  46.91850
    ##  Community.2  50.56856
    ##  Community.3  48.79971
    ##  Community.4  54.03910
    ##  Community.5  51.25010
    ##  Community.6  61.46782
    ##  Community.7  38.98214
    ##  Community.8  42.05837
    ##  Community.9  72.37470
    ##  Community.10 75.95299
    ##  Community.11 54.45321
    ##  Community.12 46.08509
    ##  Community.13 34.85442
    ##  Community.14 63.81702
    ##  Community.15 38.92798
    ##  Community.16 33.70594
    ##  Community.17 54.76670
    ##  Community.18 56.43345
    ##  Community.19 78.73701
    ##  Community.20 82.00967

However, ‘functcomp’ does not contain any options to define a cumulative
relative abundance for which trait information should be present, in
order to obtain reliable results. In many cases it is advisable to set a
threshold value of 80 % for the cumulative relative abundance.

Now a calculation is performed with ‘trait_moments’, we set n_species =
0 and abundance = 80:

``` r
result <- trait_moments(communities, traits, n_species = 0, abundance = 80)
```

    ## Warning in trait_moments(communities, traits, n_species = 0, abundance = 80):
    ## If n_species = 0 no moments but only cwms can be calculated.

    ## Warning in trait_moments(communities, traits, n_species = 0, abundance = 80):
    ## Calculations with n_species < 4 may lead to unreliable results.

``` r
result[1:20,1:ncol(result)]
```

    ## # A tibble: 20 × 6
    ##    comID          Trait      mean variance skewness kurtosis
    ##    <chr>          <chr>     <dbl>    <dbl>    <dbl>    <dbl>
    ##  1 " Community.1" Trait.1   0.371       NA       NA       NA
    ##  2 " Community.1" Trait.2   1.93        NA       NA       NA
    ##  3 " Community.1" Trait.3  25.2         NA       NA       NA
    ##  4 " Community.1" Trait.4   0.266       NA       NA       NA
    ##  5 " Community.1" Trait.5  NA           NA       NA       NA
    ##  6 " Community.1" Trait.6  NA           NA       NA       NA
    ##  7 " Community.1" Trait.7  NA           NA       NA       NA
    ##  8 " Community.2" Trait.1   0.368       NA       NA       NA
    ##  9 " Community.2" Trait.2   1.89        NA       NA       NA
    ## 10 " Community.2" Trait.3  NA           NA       NA       NA
    ## 11 " Community.2" Trait.4   0.255       NA       NA       NA
    ## 12 " Community.2" Trait.5  NA           NA       NA       NA
    ## 13 " Community.2" Trait.6  NA           NA       NA       NA
    ## 14 " Community.2" Trait.7  NA           NA       NA       NA
    ## 15 " Community.3" Trait.1   0.363       NA       NA       NA
    ## 16 " Community.3" Trait.2   1.37        NA       NA       NA
    ## 17 " Community.3" Trait.3  25.3         NA       NA       NA
    ## 18 " Community.3" Trait.4   0.256       NA       NA       NA
    ## 19 " Community.3" Trait.5   0.178       NA       NA       NA
    ## 20 " Community.3" Trait.6 393.          NA       NA       NA

We get a warning that for n_species = 0 only CWMs but no moments can be
calculated. Since this is our goal in this case we can ignore this
warning. ‘Trait_moments’ generates exactly the same CWMs as ‘functcomp’,
but if there is not enough trait information available to obtain
reliable results (level can be chosen by the user), an NA is returned.

# Citation

Please cite as:

> Falk-Rudhard Schreiner (2024). TraitMoments: Efficient calculation of
> trait distribution moments. Online at
> <https://github.com/SchreinerFR/TraitMoments>.

# References

Bello, F. de, Carmona, C.P., Dias, A.T.C., Götzenberger, L., Moretti, M.
& Berg, M.P. (2021) Handbook of Trait-Based Ecology. Cambridge
University Press.

Enquist, B.J., Norberg, J., Bonser, S.P., Violle, C., Webb, C.T. &
Henderson, A. et al. (2015) Chapter Nine - Scaling from Traits to
Ecosystems: Developing a General Trait Driver Theory via Integrating
Trait-Based and Metabolic Scaling Theories. In: Pawar, S., Woodward, G.
& Dell, A.I. (Eds.) Trait-Based Ecology - From Structure to Function.
Academic Press.

Le Bagousse-Pinguet, Y., Gross, N., Maestre, F.T., Maire, V., Bello, F.
de & Fonseca, C.R. et al. (2017) Testing the environmental filtering
concept in global drylands. Journal of Ecology, 105(4), 1058–1069.
Available from: <https://doi.org/10.1111/1365-2745.12735>.

Le Bagousse-Pinguet, Y., Gross, N., Saiz, H., Maestre, F.T., Ruiz, S. &
Dacal, M. et al. (2021) Functional rarity and evenness are key facets of
biodiversity to boost multifunctionality. Proceedings of the National
Academy of Sciences of the United States of America, 118(7). Available
from: <https://doi.org/10.1073/pnas.2019355118>.
