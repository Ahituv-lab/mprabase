### Explore Saturation-Mutagenesis Data:

The Saturation Mutagenesis Browser allows searching for and visualizing saturation-mutagenesis MPRA experiments. In these experiments, a specific sequence is mutated at various positions, end the effect of these mutations is tested in parallel using MPRAs.

The browser is available from the navigation bar. An overview of its interface is given in the following figure:

<br/>

<img src="images/saturation_mutagenesis_table.png" style="border: 1px solid grey;width:80%"/>

<br/><br/>

**A**. This panel contains the input options for the mutagenesis browser:

 - *Mutagenesis Study*: Through this sub-panel, you can select the Saturation Mutagenesis study you want to explore. The default option is a study of human sequence elements from the GRCh38 assembly, described in *Kircher et al, 2019*. Changing the study will update all the subsequent form fields (*Genomic Region*, *Variant Expression Effect*). The reference associated with each study data will appear below the selector.

 - *Genomic Region*: Through this sub-panel, you can define genomic region options:
 
   1. Selected Element: The name of the mutated sequence. The element name, followed by the chromosome number in parenthesis is given [ e.g. FOXE1 (chr:9) for FOXE1 in chromosome 9]. Selecting a different element will update the values of all subsequent input fields.
   
   2. Also include single base deletions: Choose whether to include or not include single-base deletion mutations in the analysis. By default, this field is activated.
   
   3. Position range: The coordinate range of the selected sequence in the genome. Use the two points of the slider to define the starting and ending coordinates.
   
   4. Number of unique tags: the minimum and maximum number of unique tags to consider in the analysis.

 - *Variant Expression Effect*: Through this sub-panel, you can adjust filters related to the reported effects of the mutations:
 
   1. Log2 variant expression: Adjust the variant expression effect range.
   
   2. P-value: filter mutations based on the computed P-value.
   
When you are ready, click on the **View Data** Button. Clicking on the **Reset Form** button will clear the input field.


**B**. The results of your search will be shown to the right of the screen. A panel with two tabs will appear. The tab labeled "Data" contains a table with the reported mutations matching your search, while a graphical representation is also available, through the tab labeled "Viewer".

The table in the "Data" tab contains the following columns:

 - Chromosome - Chromosome of the variant.
 - Position - Chromosomal position (GRCh38 or GRCH38) of the variant.
 - Ref: Reference allele of the variant (A, T, G, or C).
 - Alt: Alternative allele of the variant (A, T, G, or C). One base-pair deletions are represented as -.
 - Tags: Number of unique tags associated with the variant.
 - DNA: Count of DNA sequences that contain the variant (used for fitting the linear model).
 - RNA: Count of RNA sequences that contain the variant (used for fitting the linear model).
 - Variant Expression Effect - Log2 variant expression effect derived from the fit of the linear model (coefficient).
 - P-Value: P-value of the coefficient.
 - Gene: Name of the promoter/enhancer gene.

The displayed data can be visualized by visiting the "Viewer Tab". A graph like the one shown in this image will appear:

<br/>

<img src="images/saturation_mutagenesis_plot.png" style="border: 1px solid grey;width:80%"/>

<br/><br/>

The horizontal axis of the graph shows the genomic coordinates of the analyzed region, while the vertical axis shows the Log2 of the variant expression effect. Dots represent the analyzed positions in the sequence, with each dot having a different symbol, based on the reference and alternative DNA base in that position. Hovering over a dot will display the mutation details of that position. The plot is interactive, and can be manipulated using the mouse and/or the tools available through the menu at the bottom right of the plot.

**C**. Finally, the panel at the bottom of the results contains details on the search parameters used in the last query of the browser.

