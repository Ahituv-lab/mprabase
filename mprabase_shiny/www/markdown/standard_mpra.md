### Browse standard MPRA Samples: 

The interface of the Standard MPRA browser is shown in the figure below:

<br/>

<img src="images/mpra_browser.png" style="border: 1px solid grey;width:80%"/>

<br/><br/>

**A.** The left side of the browser contains a series of panels with search filters, enabling users to perform refined queries. Each panel can be expanded or collapsed by clicking on the <i class='fa fa-caret-down'></i> symbol.  The following types of filters are provided:
  - *Library Cis-regulatory elements*: Filter samples using genomic coordinates (genome name, chromosome and coordinate ranges). Searches can be performed for three organisms, namely, Homo sapiens (human), Mus musculus (mouse) and Drosophila melanogaster (fruit fly). In addition, searches can also be performed against a collection of synthetic library elements. <br/> You can use the cis-regulatory element search through these steps:
  
    1. Select library genome assembly: click the button corresponding to your desired genomic assembly. In case you want to search for synthetic data, click the button labeled "Synthetic Libraries".
    
    2. Enter one or more library elements (i.e. genomic coordinates). These elements are in the format `chromosome:start-end`, e.g. `chr1:10003159-10003837` or `chr1:10,003,159-10,003,837`. Clicking on the input field will open a drop down list, from which you can select a pre-existing option. Alternatively, you can type your own custom coordinates and hit the Enter button to submit them. Multiple ranges can be entered at the same time.
  
  - *Species & Library Strategies*: Filter samples by species (left) and/or the applied library strategy). You check one or multiple options both for species and for library, based on your needs.
  
  - *Cell Type*: Filter samples by cell type. You can select one or more options based on your needs.

- *Associated Literature*: Filter samples based on their associated publications, using the following steps:
    1. Search By: Select the filter type to perform the search. Available choices include the PubMed ID, Article Title, Name of the research group, or sample GEO number.
    
    2. Enter your search terms: type your search terms in the text box, in accordance with the filter type you chose in step 1. For PubMed IDs or GEO numbers, you can enter one or more identifiers separated by spaces, e.g. `27831498 23328393` or `GSE83894 	GSE77213`. For the article title or research group name, you can enter free text, e.g. `enhancer`.

After selecting the desired search filters, you can perform a search by clicking on the `Search Samples` button. Clicking on the `Clear` button will reset the form fields.


**B.** The top of the browser contains pie charts showing the distribution of the displayed samples, in terms of species, cell types and library strategies. The left plot is a dual pie chart; The outer ring shows the samples' cell types, while the inner pie chart shows the samples' species. The right plot shows the samples' library strategies. Both plots are interactive; hovering over one of their elements will display a pop-up box containing the name of the category and the number & percentage of samples belonging to it. The plots are updated to match the results of search queries.

**C**: The table below the pie charts contains an overview of the MPRA samples. Annotations include the sample identifier and name, the species, cell type, library strategy, and the corresponding Gene Expression Omnibus (GEO) and PubMed (PMID) identifiers.  In cases when the user access the website through a small screen, some columns may be collapsed (depending on the user's screen width). These hidden elements can be accessed by clicking on the green "+" icon at the start of each table row.


---

### Access to MPRA data and replicate visualization

The standard MPRA browser enables viewing the underlying datasets of each MPRA sample. To access the datasets behind one or more samples, click on the corresponding checkboxes located at the start of their respective rows:

<br/>

<img src="images/dataset_selection.png" style="border: 1px solid grey;width:80%"/>

<br/><br/>

Checking one or more samples will open a new table at the bottom of the page, showing their corresponding MPRA datasets. You can select one or more sets by clicking on their respective checkboxes. The selected datasets can then be downloaded, by clicking on the `Download Selected` button, or be visualized by clicking on the `Replicate Visualization` button.

<br/>

To visualize the contents of a dataset, select it from the list and click on the `Replicate Visualization` button. After a brief loading period, you will be redirected to a new view, the `MPRA Library Viewer`:

<br/>

<img src="images/library_viewer.png" style="border: 1px solid grey;width:80%"/>

<br/><br/>

The top of the viewer shows the distribution of DNA/RNA replicates in the datasets. Three scatter plots are given, showing the NT-1 vs NT-2, NT-1 vs NT-3 and NT-2 vs NT-3 distributions. All plots are interactive and can be manipulated using the mouse and the plot tools available at the bottom right of each plot. The tools saving the plot as an image (camera icon), and a series of zooming controls.

Clicking on the `View Library elements` button below the plots will display all the cis regulatory elements of the plot in table format. Furthermore, you can visualize each of these coordinates in the *UCSC Genome Browser*, by clicking on the `View in UCSC` buttons.
