# Micro-anatomical location of splenic IFNpos vs IFNneg pDCs

## Application: This macro can be adapted to study the location of cells in different areas of an organ.

## Experimental design applied to our mouse model, in the spleen: 

#### • SCRIPT mouse model : pDCs tdT+ that are producing or have produced IFN-1 (YFP+). 

#### • Labelling required to determine the spleen areas : 
-	anti-CD3 : T cell zone
-	anti-CD169 : marginal zone
-	the others will be deduced from these two labels (red pulp, B cell zone)

#### • Aim of the macro :
-	Create masks for each area of the spleen, based on different staining
-	Quantify the MFI of tdT+/YFP+/- pDCS and MCMV infected cells (IE1) in each erea
-	Determine the number of tdT+/YFP+/- pDCs and MCMV infected cells (IE1) in each erea

## Contents:
##### • Block 1: Attribution to each channel the stained target.
##### • Block 2: Creation of the Saturation mask.
##### • Block 3 : Creation of the Whole spleen mask.
##### • Block 4 : Creation of the T cell zone mask.
##### • Block 5 : Hand drawing of follicles : White pulp delimitation.
##### • Block 6 : Creation of the B+T cell zone mask.
##### • Block 7 : Creation of masks: Red pulp, Marginal zone, B cell zone, T cell zone + Marginal zone superposition
##### • Block 8: Remove the background from the tdT staining
##### • Block 9: Choice of whether to analyse TdT+ cell clusters. Uncheck if there is no cluster to analyse.
##### • Block 10: No cluster, start of tdT+ cell analysis.
##### • Block 10.1: MFI analysis of the TdT staining in the 6 different delimited areas of the spleen.
##### • Block 10.2: TdT+ cell count in the 6 different delimited areas of the spleen.
##### • Block 11: Cluster identified on the images, start of cluster analysis.
##### • Block 11.1: Determination of clusters.
##### • Block 11.2: MFI analysis of the TdT cells + clusters in the 6 different delimited areas of the spleen.
##### • Block 11.3: TdT+ cells count in the 6 different delimited areas of the spleen.

##### • Block 12 : Choice of whether to analyse YFP+ cells. Uncheck if there is no YFP to analyse.
##### • Block 12.1 : Remove the background from the YFP staining.
##### • Block 12.2 : MFI analysis of the YFP cells in the 6 different delimited areas of the spleen + TdT clusters in each.
##### • Block 12.3 : YFP+ cells count in the 6 different delimited areas of the spleen + within TdT+ clusters.

##### • Block 13: Choice of whether to analyse IE1+ cells. Uncheck if there is no IE1 to analyse.
##### • Block 13.1: Remove the background from the IE1 staining
##### • Block 13.2: MFI analysis of the IE1 cells in the 6 different delimited areas of the spleen + TdT clusters in each.
##### • Block 13.3 : IE1+ cells count in the 6 different delimited areas of the spleen + within TdT+ clusters.

## ROI list:
##### • without TdT cell clusters : 
-	Saturation mask = 0
-	Whole spleen mask = 1
-	T-cell zone mask = 2
-	Composite (manual draw follicules) = 3
-	CD169 staining = 4
-	B+T cell zone mask = 5
-	Mask of B+T cell zone mask = 6
-	Red pulp mask = 7
-	Marginal zone mask = 8
-	B cell zone mask = 9
-	T cell zone + Marginal zone (MZ) superposition mask = 10
-	High background analysis (TdT) = 11
-	TdT cells mask = 12

##### • with TdT cell clusters : 
-	Saturation mask = 0
-	Whole spleen mask = 1
-	T-cell zone mask = 2
-	Composite (manual draw follicules) = 3
-	CD169 staining = 4
-	B+T cell zone mask = 5
-	Mask of B+T cell zone mask = 6
-	Red pulp mask = 7
-	Marginal zone mask = 8
-	B cell zone mask = 9
-	T cell zone + Marginal zone (MZ) superposition mask = 10
-	High backgroud analysis (TdT) = 11
-	TdT cell clusters mask = 12
-	TdT clusters whole spleen = 13
-	TdT clusters red pulp = 14
-	TdT clusters marginal zone = 15
-	TdT clusters B cell zone = 16
-	TdT clusters T cell zone = 17
-	TdT clusters MZ+T cell zone = 18
-	TdT cells mask = 19
-	High backgroud analysis (YFP) = 20
-	YFP cells mask = 21
-	High backgroud analysis (IE1) = 22
-	IE1 cells mask = 23

## Example of a mask obtained on an image : tdT + YFP analysis in each 6 zones ; SCRIPT mouse infected during 48h with MCMV.

![All area masks](https://user-images.githubusercontent.com/123481162/214363090-9ecbc555-da58-4081-a71d-ce2ffde63688.jpg)
![Cell TdT+ or YFP+ masks](https://user-images.githubusercontent.com/123481162/214363121-cd9621fc-c594-4fbb-a749-1b53763df49a.jpg)

