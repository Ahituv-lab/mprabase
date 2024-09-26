### Browse synthetic MRPA Samples:

Similar to the Standard MPRA Browser, the Synthetic MPRA Browser is available through the navigation bar. An overview of its interface is shown in the figure below:

<br/>

<img src="images/synthetic_mpra_browser.png" style="border: 1px solid grey;width:80%"/>

<br/><br/>

**A.** The left side of the browser contains a series of panels with search filters, enabling users to perform refined queries. Each panel can be expanded or collapsed by clicking on the <i class='fa fa-caret-down'></i> symbol.  The following types of filters are provided:

  - *Species & Library Strategies*: Filter samples by species (left) and/or the applied library strategy). You check one or multiple options both for species and for library, based on your needs.
  
  - *Cell Type*: Filter samples by cell type. You can select one or more options based on your needs. 
  
  - *Associated Literature*: Filter samples based on their associated publications, using the following steps:
    1. Search By: Select the filter type to perform the search. Available choices include the PubMed ID, Article Title, Name of the research group, or sample GEO number.
    
    2. Enter your search terms: type your search terms in the text box, in accordance with the filter type you chose in step 1. For PubMed IDs or GEO numbers, you can enter one or more identifiers separated by spaces, e.g. `23892608 33046894` or `GSE118242 GSE142696`. For the article title or research group name, you can enter free text, e.g. `enhancer`.
    
After selecting the desired search filters, you can perform a search by clicking on the `Search Samples` button. Clicking on the `Clear` button will reset the form fields.

**B.** The top of the browser contains pie charts showing the distribution of the displayed samples, in terms of species, cell types and library strategies. The left plot is a dual pie chart; The outer ring shows the samples' cell types, while the inner pie chart shows the samples' species. The right plot shows the samples' library strategies. Both plots are interactive; hovering over one of their elements will display a pop-up box containing the name of the category and the number & percentage of samples belonging to it. The plots are updated to match the results of search queries.

**C**: The table below the pie charts contains an overview of the MPRA samples. Annotations include the sample identifier and name, the species, cell type, library strategy, and the corresponding Gene Expression Omnibus (GEO) and PubMed (PMID) identifiers.  In cases when the user access the website through a small screen, some columns may be collapsed (depending on the user's screen width). These hidden elements can be accessed by clicking on the green "+" icon at the start of each table row.


<br/><br/>

Similar to the Standard Browser, the Synthetic MPRA browser allows for selecting one or multiple samples, by checking their equivalent checkboxes. The datasets associated with the selected samples will appear at the bottom of the screen. The datasets, like in the standard browser, can also be selected by clicking on their checkboxes, downloaded using the **Download Selected** button or visualized using the **Replicate Visualization** button.