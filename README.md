# Sea Turtle Migration Network

Utilizing sea turtle migration data provided by OBIS-SEAMAP to build a migration network of endangered sea turtle species for indications of conservation prioritization. Build a directed movement network from tagged sea turtle tracks, cluster habitat nodes, and analyze connectivity/centrality across the Caribbean subregion.

This analysis is based on the following publications: [Kot et al., 2021](https://doi.org/10.1111/ddi.13485) and [Lamb et al., 2019](https://doi.org/10.1002/eap.1919).

* Species: Loggerhead, Hawksbill, Green sea turtle.
* Platform: platform == "tag" only.
* Time: year >= 2000.
* Region bounds: lon ∈ (-90, -60), lat ∈ (5, 25).
* Daily normalization: per animal per day → mean(lat), mean(lon) for that date.

## Partitioning (node construction)
**Goal:** turn continuous points into discrete habitat nodes.
* R script uses NbClust to evaluate clusterings with Euclidean distance, Ward.D2 linkage, Duda index, with k ∈ [2, 15].
* Writes a single column CSV: Data_tidy/partition.csv with integer labels (1..K).
* In MATLAB post-step, each record is assigned a partition and centroids are plotted (mean lat/lon per partition).

## Results
* Network size: nodes n=9, edges m=31.
* Degrees: mean(k_in)=3.44, mean(k_out)=3.44; top out-degree node = Node 1, top in-degree node = Node 1; lowest in-degree nodes = 8, 7, 9.
* Connectivity proxy: 3 of 9 nodes cover ~50% of outflow.
* Interpretation:
  + Isla de Margarita (Node 8) is the most confined node.
  + Bonaire/Kralendijk (Node 1) is the most connected node.
  + Node 4 (Cayos Miskitos, E. Nicaragua) appears central/important, consistent with a reserve hotspot for turtles.
