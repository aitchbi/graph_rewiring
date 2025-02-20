# graph_rewiring
Statistical inference in connectomics relies on testing findings against null models. Various classes of null models exist in the literature, each aiming to destroy the structure of the input graph while preserving some characteristic. Here we look at two models. 

### Degree Sequence Preserving Null
One specific graph null model is that obtained by rewiring edges such that the degree sequence is preserved:

> Maslov and Sneppen, 2002. Specificity and stability in topology of protein networks. Science 296(5569): 910-913.

The demo script compares two degree-preserving rewiring approaches, where one is an extension of the other. In the original method, which is given as a nested function in:

`utils/fcn_randomize_str.m`  -by Richard Betzel

rewiring is done by wiring new edges in places where an edge does not exist. For non-sparse graphs, the methods works very efficiently. However, for dense graphs, especially those close to complete, the computational cost can be large to deliver the desired number of rewritings (swpas). The method does not work on complete graphs. 

Given that rewiring while preserving "degree sequence" does not imply that all newly rewired edges should be wired to nodes that have an available synapse, one may instead swap the weights of existing edges. This approach gives a practical solution to obtain rewired graphs when the graph is non-sparse, close-to-complete, or even complete. Furthermore, even if one is given a non-sparse graph, with the same number of requested rewires (swaps), the original method does not fully destroy the connectivity structure of the input graph. As such, if the rewired graph is intended to serve as a null, it may retain much of the original graph's structural information, beyond that of the degree sequence. 

The `demo.m` script compares these two approaches. To use it for your own data, simply place your own data (graph adjacency matrix) inside the `data` folder; see first line in the demo script. Figures as shown below can then be generated.   

The example below shows the functional connectivity (FC) matrix of a given individual (see first row, left), derived from resting-state fMRI data. The FC matrix is rewired using the original method (`betz`) and the extended method (`behj`), for two different requested number of rewires (swaps); see second row. All four rewired graphs retain the degree sequence of the original graph (see first row, right). The original methods performs much faster than the extended method. However, when the requested number of swaps is large, the resulting rewired graph notably differs between the two methods; the extended method better destroys the connectivity structure of the input graph. 

![degree preserving rewiring, subject 1](figs/figs_readme/sample_FC_1_degree_preserve.png?raw=true)

The example below shows the FC matrix of another individual (see first row, left), which is not as sparse as that of the previous individual. In the same way as explained above, the FC matrix rewired using four different settings. All four rewired graphs retain the degree sequence of the original graph (see first row, right). The original methods this time performs slower than the extended method. Moreover, as in the previous individual, the extended method better destroys the connectivity structure of the input graph when the requested number of swaps is large.

![degree preserving rewiring, subject 2](figs/figs_readme/sample_FC_2_degree_preserve.png?raw=true)

### Strength Sequence Preserving Null
Another recently proposed graph null model is that obtained by rewiring edges such that not only the degree sequence is preserved but also, approximately, the strength sequence. For this model, a degree-preserved rewired graph can be considered as the starting point, which is then processed to recover the strength sequence; methodological details about this null model can be found in: 

> Milisav et al., 2025. A simulated annealing algorithm for randomizing weighted networks. Nat Comput Sci 5(1): 48-64.

By using the degree-preserved rewired graphs from individual one, we obtain sequence-preserved rewired graphs as:

![sequence preserving rewiring, subject 1](figs/figs_readme/sample_FC_2_sequence_preserve.png?raw=true)

and for the second individual we get: 

![sequence preserving rewiring, subject 2](figs/figs_readme/sample_FC_2_sequence_preserve.png?raw=true)

For both individuals, and for all rewired graphs, the strength sequence is very well reserved. Visually, computational time-wise, and also based on the minimum energy (min E) criterion discussed in `Milisav et al., 2025` all graphs are seemingly equally well rewired. The key observation here is that if one aims to compare results from only this model (strength-sequence preserving null) to the original graph, then there is not much of a problem in selecting either the `betz` or `behj` methods as base. However, if one is to also compare this null also with degree-sequence preserving null, it can be more accurate to compare against `behj` with large number of swaps since that model very notably destroys all structure in the original graph aside from the degrees while strength-sequence preserving null ends up retaining a lower extent of the connectivity structure in order to retain strengths. 

           

 