
//Nils COLLINET (With the participation of Melissa TOXE)
//2022

//Title : Micro-anatomical location of splenic IFNpos vs IFNneg pDC. 

//Application: This macro can be adapted to study the location of cells in different areas of an organ.

//Experimental design applied to our mouse model, in the spleen : 

//• SCRIPT mouse model : pDCs tdT+ that are producing or have produced IFN-1 (YFP+). 

//• Staining required to determine the spleen areas : 
//- 16 bit image acquisition in spectral mode
//-	anti-CD3 : T cell zone
//-	anti-CD169 : marginal zone
//-	the other areas will be deduced from these two labels (red pulp, B cell zone, marginal zone + T cell zone superposition )

//• Aim of the macro :
//-	Create masks for each area of the spleen, based on different staining
//- Determine and analyse the tdT+ clusters in each area
//-	Quantify the MFI of tdT+/YFP+/- pDCS and MCMV infected cells (IE1) in each area
//-	Determine the number of tdT+/YFP+/- pDCs and MCMV infected cells (IE1) in each area

// This macro was created for image acquisition of tissue sections in spectral mode. Thus an Aufluorescence spectrum could be added in the analysis. 
//The background of each fluorochrome is deduced during the code, so it is not necessary to apply any special processing to the images before starting.

// The macro contains a large number of stop points, which allows you to take your time in choosing the Color Balanced or Threshold.


////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block 1: attribution to each channel the stained target.
//Basic setting to start the analysis.
roiManager("Associate", "true");
	if (isOpen("ROI Manager")) {
	selectWindow("ROI Manager");
	run("Close");
	} 

setOption("BlackBackground", true);
setForegroundColor(255, 255, 255);
setBackgroundColor(0, 0, 0);
print("\\Clear");
run("Set Measurements...", " redirect=None decimal=6");
run("Clear Results");
resetThreshold();
run("Set Measurements...", "area mean integrated redirect=None decimal=6");
        
rename("Spleen_Analysis");
Dialog.create("Channel attribution");
Dialog.addChoice("Ch1:", newArray("CD3", "CD169", "TdT", "Autofluorescence", "YFP", "IE1", "not used"));
Dialog.addChoice("Ch2:", newArray("YFP", "CD3", "CD169", "TdT", "Autofluorescence", "IE1", "not used"));
Dialog.addChoice("Ch3:", newArray("TdT", "not used", "CD169", "CD3", "Autofluorescence", "IE1", "YFP"));
Dialog.addChoice("Ch4:", newArray("IE1", "TdT", "Autofluorescence", "CD3", "CD169", "YFP", "not used"));
Dialog.addChoice("Ch5:", newArray("CD169", "IE1", "Autofluorescence", "not used", "TdT", "CD3", "YFP"));
Dialog.addChoice("Ch6:", newArray("Autofluorescence", "not used", "YFP", "TdT", "CD3", "IE1", "CD169"));

Dialog.show();

Ch1_Name = Dialog.getChoice();
Ch2_Name = Dialog.getChoice();
Ch3_Name = Dialog.getChoice();
Ch4_Name = Dialog.getChoice();
Ch5_Name = Dialog.getChoice();
Ch6_Name = Dialog.getChoice();

run("Split Channels");

	if (Ch1_Name=="not used") {
	}
	else {
	selectWindow("C1-Spleen_Analysis");
	rename(Ch1_Name);
	}

	if (Ch2_Name=="not used") {
	}
	else {
	selectWindow("C2-Spleen_Analysis");
	rename(Ch2_Name);
	}

	if (Ch3_Name=="not used") {
	}
	else {
	selectWindow("C3-Spleen_Analysis");
	rename(Ch3_Name);
	}

	if (Ch4_Name=="not used") {
	}
	else {
	selectWindow("C4-Spleen_Analysis");
	rename(Ch4_Name);
	}

	if (Ch5_Name=="not used") {
	}
	else {
	selectWindow("C5-Spleen_Analysis");
	rename(Ch5_Name);
	}

	if (Ch6_Name=="not used") {
	}
	else {
	selectWindow("C6-Spleen_Analysis");
	rename(Ch6_Name);
	}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block 2: Creation of the Saturation mask. 
//The purpose of this step is to remove every saturation point, which can be found in all channels. This mask will be subtracted before determining the MFIs and counting the marker of the cells you wish to quantify.
//Since we did our acquisitions in spectral imaging, the Autofluorescent channel was chosen to determine the saturation points on the image.
//The mask will be saved in .tif format.

selectWindow("Autofluorescence");
run("Duplicate...", "title=saturation_mask");
setThreshold(55000, 65535);
run("Convert to Mask", "method=Otsu background=Dark black");
run("Create Selection");
getSelectionBounds(x, y, width, height);
	if (y==0) {
		waitForUser("No selection of saturation, create a off boundaries selection and click OK");
		roiManager("Add");
	}
	else {
		Dialog.create("enlarge region?");
		Dialog.addNumber("enlarge",4); 
		Dialog.show(); 
		a=Dialog.getNumber();
		run("Enlarge...", "enlarge="+ a +" pixel");
		waitForUser("Tissu saturation ok ? If not adjust it manually.");
		roiManager("Add");
	}
saveAs("Tiff");


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block 3: Creation of the Whole spleen mask.
//Again based on the "Autofluorescent" channel, it allows to delimit the circumference of the tissue section. 
//A first selection is made at the beginning, but you should not hesitate to modify the Threshold during the Stop point to have the complete turn of the tissue section, well defined. 
//The mask will be saved in .tif format.

selectWindow("Autofluorescence");
run("Duplicate...", "title=Whole_spleen");
roiManager("Select", 0);
run("Clear", "stack");
run("Select None");
run("Mean...", "radius=20");
setAutoThreshold("Default dark");
run("Convert to Mask");
run("Analyze Particles...", "size=50000-Infinity show=Masks");
run("Invert LUT");
run("Fill Holes");
run("Make Inverse");
rename("Whole_spleen_mask");
run("Create Selection");
run("ROI Manager...");
waitForUser("Tissu contour ok ? If not adjust the threshold manually.");
roiManager("Add");
saveAs("Tiff");


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block 4: Creation of the T cell zone mask.
//Based on the "CD3" staining channel, the aim is to determine the T-zones on the tissue section. 
//A first selection is made at the beginning, but you should not hesitate to modify the Threshold during the Stop point to have the complete turn of the tissue section, well defined. 
//The mask will be saved in .tif format.
selectWindow("CD3");
run("Duplicate...", "title=Tcell_zone_mask");
roiManager("Select", 0);
run("Clear", "stack");
run("Select None");
run("Mean...", "radius=20");
setAutoThreshold("Default");
setOption("BlackBackground", true);
waitForUser("Mask creation OK? If not adjust manually");
run("Convert to Mask");
run("Invert");
run("Fill Holes");
run("Analyze Particles...", "size=6000-Infinity show=Masks");
run("Invert");
run("Create Selection");
run("Enlarge...", "enlarge=20 pixel");
run("Fill");
run("ROI Manager...");
waitForUser("Tissu contour ok ? If not adjust it manually. Parameters: Mean 20, analyse particles 6000-infinity, Fill holes, Enlarge selection 20 pixels.");
roiManager("Add");
saveAs("Tiff");


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block 5: Hand drawing of follicles : White pulp delimitation.
//An initial manual delineation of the white pulp is necessary to avoid over- or underestimating the size of areas of interest.
//From a merge of CD3 and CD169 staining, named "Composite":
//The first step is to delineate the white pulp by hand, with the "Polygon selection" tool, when the dialogue box opens. The follicule selection should include the marginal area (CD169).
//To facilitate this selection, it is possible to "Draw" (Ctrl+D) each selection and then reselect them at the end with the "Wand tool".
//This composite image with selections will be saved in .tif format.

selectWindow("CD3");
run("Select None");
run("Duplicate...", "title=T_cell_zone");
selectWindow("CD169");
run("Duplicate...", "title=Marginal_zone");
run("Merge Channels...", "c1=[T_cell_zone] c2=[Marginal_zone] create");
run("Color Balance...");
run("Channels Tool...");
run("ROI Manager...");
waitForUser("Select follicle zone contours manually with th Polygon selection tool. Keep the marginal zone (CD169) in the selection.");
roiManager("Add");
saveAs("Tiff");

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block 6: Creation of the B+T cell zone mask.
//Based on the CD169 staining and the previously delineated follicles, the macro will deduce the marginal zone (CD169) of the drawn follicles, allowing a mask of the T and B zone to be obtained. 
//The mask will be saved in .tif format.

selectWindow("CD169");
run("Duplicate...", "title=B+Tcell_zone_Creation");
roiManager("Select", 3);
run("Clear Outside");
run("Mean...", "radius=10");
setAutoThreshold("Otsu dark");
run("Create Selection");
run("Enlarge...", "enlarge=10 pixel");
run("Fill");
run("ROI Manager...");
roiManager("Add");
selectWindow("Whole_spleen_mask.tif");
run("Select None");
selectWindow("Whole_spleen_mask.tif");
run("Duplicate...", "title=B+Tcell_zone");
roiManager("Select", 3);
run("Enlarge...", "enlarge=-15 pixel");
run("Clear Outside");
roiManager("Select", 4);
run("Clear");
run("Select None");
run("Analyze Particles...", "size=5000-Infinity show=Masks");
selectWindow("Mask of B+Tcell_zone");
run("Invert");
run("Create Selection");
run("Enlarge...", "enlarge=-20 pixel");
run("Enlarge...", "enlarge=20 pixel");
roiManager("Add");
roiManager("Select", 5);
run("Clear Outside");
run("Select None");
run("Fill Holes");
run("Invert");
run("Analyze Particles...", "size=5000-Infinity show=Masks");
run("Invert");
run("Create Selection");
run("ROI Manager...");
waitForUser("B+T cell zone OK? If not, draw it manually on COMPOSITE image.");
roiManager("Add");
saveAs("Tiff");


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block 7 : Creation of masks: Red pulp, Marginal zone, B cell zone, T cell zone + Marginal zone superposition
//Each one comes from the addition or subtraction of previously created masks:
//All masks will be saved in .tif format.

//Red pulp
//= Whole spleen - White pulp
selectWindow("Whole_spleen_mask.tif");
run("Select None");
run("Duplicate...", "title=Red_pulp_mask");
roiManager("Select", 3);
run("Clear", "stack");
selectWindow("Red_pulp_mask");
run("Create Selection");
run("ROI Manager...");
roiManager("Add");
saveAs("Tiff");

//Marginal zone
//= White pulp - B+T-cell zone
selectWindow("Whole_spleen_mask.tif");
run("Select None");
run("Duplicate...", "title=Marginal_zone");
roiManager("Select", 3);
run("Clear Outside", "stack");
roiManager("Select", 6);
run("Clear", "stack");
selectWindow("Marginal_zone");
run("Create Selection");
run("ROI Manager...");
roiManager("Add");
saveAs("Tiff");

//B cell zone
//= B+T cell zone - T cell zone
selectWindow("Whole_spleen_mask.tif");
run("Select None");
run("Duplicate...", "title=Bcell_zone");
roiManager("Select", 6);
run("Clear Outside", "stack");
roiManager("Select", 2);
run("Clear", "stack");
selectWindow("Bcell_zone");
run("Create Selection");
run("ROI Manager...");
roiManager("Add");
saveAs("Tiff");

//T cell zone + Marginal zone superposition
//The T-cell zone and marginal zone masks can be removed. If so, the cells of interest (tdT+, YFP or IE1+) would be counted on both masks, overestimating their MFI/number. 
//To overcome this, a separate area was created. The MFI or number of cells identified should be subtracted from both masks (T-cell and marginal zone). 
//The mask should be superimposed on the two masks and become a new separate zone to be included in the analyses.

selectWindow("Marginal_zone.tif");
run("Select None");
run("Duplicate...", "title=MZ_+_Tcell_zone_superposition");
roiManager("Select", 2);
run("Clear Outside", "stack");
selectWindow("MZ_+_Tcell_zone_superposition");
run("Create Selection");
run("ROI Manager...");
roiManager("Add");
saveAs("Tiff");


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block 8: Remove the background from the tdT staining
//For a more detailed analysis of tdT+ cells, the background is analysed and then deduced from the image. 
//When the dialogue box opens, choose an area without staining, representing the strongest background. Measure the MFI (Ctrl+M) and keep this value. 
//Use the "Color Balance" to remove the background, using the measured value. 
//This image with the deduced background will be saved as a .tif file.

selectWindow("TdT");
run("Duplicate...", "title=TdT_background_deduced");
roiManager("Select", 0);
run("Clear", "stack");
waitForUser("Analyse High background intensity zone and keep selection.");
run("ROI Manager...");
roiManager("Add");
roiManager("Select", 1);
run("Clear Outside", "stack");
run("Select None");
run("Color Balance...");
  title = "WaitForUser";
  msg = "If necessary, use the \"Color Balance\" tool to adjust the intensity, apply, then click \"OK\".";
  waitForUser(title, msg);
saveAs("tiff");

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block 9: Choice of whether to analyse TdT+ cell clusters. Uncheck if there is no cluster to analyse.

Dialog.create("TdT Cluster analysis");
Dialog.addMessage("Is there any TdT clusters to analyse on this image?")
Dialog.addCheckbox("TdT clusters", true); 
Dialog.show();
clusters = Dialog.getCheckbox(); 

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block 10: No cluster, start of tdT+ cell analysis.

	if (clusters==false) {

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block 10.1: MFI analysis of the TdT staining in the 6 different delimited areas of the spleen. 
//The MFI is measured in each of the masks created. It is possible to retrieve the data in the "Results" tab. Save them in an excel table. 
//This includes the MFI and the area of the analysed zone. 

//Whole spleen intensity (1)
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 1);
run("Measure");

//Red pulp intensity (2)
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 7);
run("Measure");

//Marginal zone intensity (3)
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 8);
run("Measure");

//B cell zone intensity (4)
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 9);
run("Measure");

//T cell zone intensity (5)
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 2);
run("Measure");

//Superposition MZ+Tcell intensity (6)
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 10);
run("Measure");

waitForUser("Save the measured data and click on OK.");

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block 10.2: TdT+ cell count in the 6 different delimited areas of the spleen. 

//A first selection of tdT+ cells will be proposed, do not hesitate to modify the detection threshold when the dialog box appears. 
//At this stage, care should be taken when setting the threshold to ensure that the number of cells is not underestimated or overestimated. 
//Tissue sections from the same acquisition parameters will be processed with the same threshold.
//The selection of tdT+ cells will be saved in .tif format.
selectWindow("TdT_background_deduced.tif");
run("Select None");
selectWindow("TdT_background_deduced.tif");
run("Duplicate...", "title=TdT_number_count");
run("Mean...", "radius=2");
roiManager("Select", 1);
run("Enlarge...", "enlarge=-50 pixel");
run("Clear Outside");
run("Select None");
selectWindow("TdT_number_count");
setAutoThreshold("Default dark");
waitForUser("Is the mask ok? If not adjust it manually.");
run("Convert to Mask");
run("Watershed");
run("Analyze Particles...", "size=5-500 show=Masks");
run("Invert");
run("Create Selection");
waitForUser("Is the TdT cell selection OK? If not adjust the threshold manually.");
roiManager("Add");
saveAs("Tiff");

//The cells will then be counted in each of the 6 zones of the spleen. 
//Do not forget to report the number of cells in each zone in an excel table, they are visible in the "Summary" tab.

//Whole spleen count (1)
selectWindow("Mask of TdT_number_count.tif");
roiManager("Select", 1);
run("Analyze Particles...", "size=0-500 summarize");

//Red pulp count (2)
selectWindow("Mask of TdT_number_count.tif");
roiManager("Select", 7);
run("Analyze Particles...", "size=0-500 summarize");

//Marginal zone count (3)
selectWindow("Mask of TdT_number_count.tif");
roiManager("Select", 8);
run("Analyze Particles...", "size=0-500 summarize");

//B cell zone count (4)
selectWindow("Mask of TdT_number_count.tif");
roiManager("Select", 9);
run("Analyze Particles...", "size=0-500 summarize");

//T cell zone count (5)
selectWindow("Mask of TdT_number_count.tif");
roiManager("Select", 2);
run("Analyze Particles...", "size=0-500 summarize");

//Superposition MZ+Tcell count (6)
selectWindow("Mask of TdT_number_count.tif");
roiManager("Select", 10);
run("Analyze Particles...", "size=0-500 summarize");

waitForUser("Save the count data and click on OK.");

	}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block 11: Cluster identified on the images, start of cluster analysis.
//If cluster presence had been checked in Block 9 :

	if (clusters==true) {

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block 11.1: Determination of clusters.
//At the beginning, a square of 55/55 appears (100µm2). This size, in our case, was chosen because it represents about 10 tdT+ cells (pDC). 
//Move this square to areas where the frequency of tdT+ cells varies, and measure the MFI (Ctrl+M). 
//Depending on the MFI obtained, a threshold can be established: generally in our case, if in this square the group of cells has an MFI > 10 000-12 000, this grouping is considered as a cluster. 
//Do not hesitate to increase the selection tolerance of the Wand Tool. To change it, simply double click on the tool and move the tolerance threshold. 
//Once done, click just next to the identified cluster to select it.
//Do not hesitate to "Draw" (Ctrl+D) the clusters selected with Wand tool, then reselect all the drawings before clicking on Ok.

selectWindow("TdT_background_deduced.tif");
run("Duplicate...", "title=TdT_Clusters_selection");
makeRectangle(600, 500, 55, 55);
waitForUser("Analyse intensity of clustered and non-clustered pDCs with the scare. Create selection of the clusters.");
run("ROI Manager...");
roiManager("Add");
saveAs("Tiff");

//During this step, either clusters have been detected in the area or it will be necessary to make a selection outside the tissue to continue. 
//The aim is that the ROI numbers do not shift.
//The cluster mask for each of the 6 zones will be saved as a .tif file.

//Whole spleen clusters (1)
selectWindow("Whole_spleen_mask.tif");
run("Select None");
run("Duplicate...", "title=Clusters_whole_spleen_mask");
roiManager("Select", 12);
run("Clear Outside", "stack");
selectWindow("Clusters_whole_spleen_mask");
run("Create Selection");
getSelectionBounds(x, y, width, height);
	if (x==0) {
		waitForUser("No clusters detected in the Whole spleen, please select an area outside the tissue to continue.");
		run("ROI Manager...");
		roiManager("Add");
		saveAs("Tiff");
	}
	else {
	run("ROI Manager...");
	roiManager("Add");
	saveAs("Tiff");
	}

//Red pulp clusters (2)
selectWindow("Clusters_whole_spleen_mask.tif");
run("Select None");
run("Duplicate...", "title=Clusters_red_pulp_mask");
roiManager("Select", 7);
run("Clear Outside", "stack");
selectWindow("Clusters_red_pulp_mask");
run("Create Selection");
getSelectionBounds(x, y, width, height);
	if (x==0) {
		waitForUser("No clusters detected in the Red pulp, please select an area outside the tissue to continue.");
		run("ROI Manager...");
		roiManager("Add");
		saveAs("Tiff");
	}
	else {
	run("ROI Manager...");
	roiManager("Add");
	saveAs("Tiff");
	}

//Marginal zone clusters (3)
selectWindow("Clusters_whole_spleen_mask.tif");
run("Select None");
run("Duplicate...", "title=Clusters_marginal_zone_mask");
roiManager("Select", 8);
run("Clear Outside", "stack");
selectWindow("Clusters_marginal_zone_mask");
run("Create Selection");
getSelectionBounds(x, y, width, height);
	if (x==0) {
		waitForUser("No clusters detected in the marginal zone, please select an area outside the tissue to continue.");
		run("ROI Manager...");
		roiManager("Add");
		saveAs("Tiff");
	}
	else {
	run("ROI Manager...");
	roiManager("Add");
	saveAs("Tiff");
	}

//B cell zone clusters (4)
selectWindow("Clusters_whole_spleen_mask.tif");
run("Select None");
run("Duplicate...", "title=Clusters_Bcell_zone_mask");
roiManager("Select", 9);
run("Clear Outside", "stack");
selectWindow("Clusters_Bcell_zone_mask");
run("Create Selection");
getSelectionBounds(x, y, width, height);
	if (x==0) {
		waitForUser("No clusters detected in the B cell zone, please select an area outside the tissue to continue.");
		run("ROI Manager...");
		roiManager("Add");
		saveAs("Tiff");
	}
	else {
	run("ROI Manager...");
	roiManager("Add");
	saveAs("Tiff");
	}

//T cell zone clusters (5)
selectWindow("Clusters_whole_spleen_mask.tif");
run("Select None");
run("Duplicate...", "title=Clusters_Tcell_zone_mask");
roiManager("Select", 2);
run("Clear Outside", "stack");
selectWindow("Clusters_Tcell_zone_mask");
run("Create Selection");
getSelectionBounds(x, y, width, height);
	if (x==0) {
		waitForUser("No clusters detected in the T cell zone, please select an area outside the tissue to continue.");
		run("ROI Manager...");
		roiManager("Add");
		saveAs("Tiff");
	}
	else {
	run("ROI Manager...");
	roiManager("Add");
	saveAs("Tiff");
	}

//T cell + MZ superposition clusters (6)
selectWindow("Clusters_whole_spleen_mask.tif");
run("Select None");
run("Duplicate...", "title=Clusters_Tcell-MZ_mask");
roiManager("Select", 10);
run("Clear Outside", "stack");
selectWindow("Clusters_Tcell-MZ_mask");
run("Create Selection");
getSelectionBounds(x, y, width, height);
	if (x==0) {
		waitForUser("No clusters detected in the T cell + marginal zone superposition, please select an area outside the tissue to continue.");
		run("ROI Manager...");
		roiManager("Add");
		saveAs("Tiff");
	}
	else {
	run("ROI Manager...");
	roiManager("Add");
	saveAs("Tiff");
	}

	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block 11.2: MFI analysis of the TdT cells + clusters in the 6 different delimited areas of the spleen. 
//The TdT MFI is analysed for each of the six zone masks + cluster masks determined in the previous block (11.1). 
//It is possible to retrieve the data in the "Results" tab. Save them in an excel table. 

//Analysis of the six zones :
//Whole spleen intensity (1)
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 1);
run("Measure");

//Red pulp intensity (2)
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 7);
run("Measure");

//Marginal zone intensity (3)
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 8);
run("Measure");

//B cell zone intensity (4)
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 9);
run("Measure");

//T cell zone intensity (5)
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 2);
run("Measure");

//Superposition MZ+Tcell intensity (6)
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 10);
run("Measure");


//Cluster analysis of the six zones :

//Clusters Whole spleen intensity (7)
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 13);
run("Measure");

//Clusters Red pulp intensity (8)
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 14);
run("Measure");

//Clusters Marginal zone intensity (9)
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 15);
run("Measure");

//Clusters B cell zone intensity (10)
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 16);
run("Measure");

//Clusters T cell zone intensity (11)
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 17);
run("Measure");

//Clusters Superposition MZ+Tcell intensity (12)
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 18);
run("Measure");

waitForUser("Save the measured data and click on OK.");


/////////////////////////////////////////////////////////////////////////////////////////////////
//Block 11.3: TdT+ cells count in the 6 different delimited areas of the spleen. 

//A first selection of tdT+ cells will be proposed, do not hesitate to modify the detection threshold when the dialog box appears. 
//At this stage, care should be taken when setting the threshold to ensure that the number of cells is not underestimated or overestimated. 
//Tissue sections from the same acquisition parameters will be processed with the same threshold.
//Before counting the tdT+ cells in each zone, the clusters are removed from the analysis. Clustering of cells with cytoplasmic labelling makes accurate counting impossible.
//The selection of tdT+ cells will be saved in .tif format.

selectWindow("TdT_background_deduced.tif");
run("Select None");
selectWindow("TdT_background_deduced.tif");
run("Duplicate...", "title=TdT_number_count");
run("Mean...", "radius=2");
roiManager("Select", 1);
run("Enlarge...", "enlarge=-50 pixel");
run("Clear Outside");
roiManager("Select", 13);
run("Clear");
run("Select None");
selectWindow("TdT_number_count");
setAutoThreshold("Default dark");
waitForUser("Is the mask Ok? If not adjust it manually.");
run("Convert to Mask");
run("Watershed");
run("Analyze Particles...", "size=5-500 show=Masks");
run("Invert");
run("Create Selection");
waitForUser("Is the TdT cell mask OK? If not adjust it manually.");
roiManager("Add");
saveAs("Tiff");

//The cells will then be counted in each of the 6 zones of the spleen. 
//Do not forget to report the number of cells in each zone in an excel table, they are visible in the "Summary" tab.

//Whole spleen count (1)
selectWindow("Mask of TdT_number_count.tif");
roiManager("Select", 1);
run("Analyze Particles...", "size=0-500 summarize");

//Red pulp count (2)
selectWindow("Mask of TdT_number_count.tif");
roiManager("Select", 7);
run("Analyze Particles...", "size=0-500 summarize");

//Marginal zone count (3)
selectWindow("Mask of TdT_number_count.tif");
roiManager("Select", 8);
run("Analyze Particles...", "size=0-500 summarize");

//B cell zone count (4)
selectWindow("Mask of TdT_number_count.tif");
roiManager("Select", 9);
run("Analyze Particles...", "size=0-500 summarize");

//T cell zone count (5)
selectWindow("Mask of TdT_number_count.tif");
roiManager("Select", 2);
run("Analyze Particles...", "size=0-500 summarize");

//Superposition MZ+Tcell count (6)
selectWindow("Mask of TdT_number_count.tif");
roiManager("Select", 10);
run("Analyze Particles...", "size=0-500 summarize");

waitForUser("Save the measured data and click on OK.");
	}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block 12 : Choice of whether to analyse YFP+ cells. Uncheck if there is no YFP to analyse.
//Can only be used directly if cluster analysis has been performed before : analysis also in clusters.

Dialog.create("YFP analysis");
Dialog.addMessage("Is there a YFP channel to analyse on this image?")
Dialog.addCheckbox("YFP channel", true); 
Dialog.show();
YFP = Dialog.getCheckbox(); 

	if (YFP==false) {
		waitForUser("Everything fine? Need to do something else? If no click OK");
		run("Close All");
	}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block 12.1 : Remove the background from the YFP staining.
//For a more detailed analysis of YFP+ cells, the background is analysed and then deduced from the image. 
//When the dialogue box opens, choose an area without staining, representing the strongest background. Measure the MFI (Ctrl+M) and keep this value. 
//Use the "Color Balance" to remove the background, using the measured value. 
//This image with the deduced background will be saved as a .tif file.

	if (YFP==true) {
selectWindow("YFP");
run("Duplicate...", "title=YFP_intensity");
roiManager("Select", 0);
run("Clear", "stack");
waitForUser("Analyse High background intensity zone and keep selection.");
run("ROI Manager...");
roiManager("Add");
roiManager("Select", 1);
run("Enlarge...", "enlarge=-50 pixel");
run("Clear Outside");
run("Color Balance...");
  title = "WaitForUser";
  msg = "If necessary, use the \"Color Balance\" tool to adjust the intensity, apply, then click \"OK\".";
  waitForUser(title, msg);
saveAs("tiff");

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block 12.2 : MFI analysis of the YFP cells in the 6 different delimited areas of the spleen + TdT clusters in each. 
//The YFP MFI is analysed for each of the six zone masks + cluster masks determined in the block 11.1. 
//It is possible to retrieve the data in the "Results" tab. Save them in an excel table.

//Whole spleen intensity (1)
selectWindow("YFP_intensity.tif");
roiManager("Select", 1);
run("Measure");

//Red pulp intensity (2)
selectWindow("YFP_intensity.tif");
roiManager("Select", 7);
run("Measure");

//Marginal zone intensity (3)
selectWindow("YFP_intensity.tif");
roiManager("Select", 8);
run("Measure");

//B cell zone intensity (4)
selectWindow("YFP_intensity.tif");
roiManager("Select", 9);
run("Measure");

//T cell zone intensity (5)
selectWindow("YFP_intensity.tif");
roiManager("Select", 2);
run("Measure");

//Superposition MZ+Tcell intensity (6)
selectWindow("YFP_intensity.tif");
roiManager("Select", 10);
run("Measure");


//Cluster analysis of the six zones :

//Clusters Whole spleen intensity (7)
selectWindow("YFP_intensity.tif");
roiManager("Select", 13);
run("Measure");

//Clusters Red pulp intensity (8)
selectWindow("YFP_intensity.tif");
roiManager("Select", 14);
run("Measure");

//Clusters Marginal zone intensity (9)
selectWindow("YFP_intensity.tif");
roiManager("Select", 15);
run("Measure");

//Clusters B cell zone intensity (10)
selectWindow("YFP_intensity.tif");
roiManager("Select", 16);
run("Measure");

//Clusters T cell zone intensity (11)
selectWindow("YFP_intensity.tif");
roiManager("Select", 17);
run("Measure");

//Clusters Superposition MZ+Tcell intensity (12)
selectWindow("YFP_intensity.tif");
roiManager("Select", 18);
run("Measure");

waitForUser("Save the measured data and click on OK.");

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block 12.3 : YFP+ cells count in the 6 different delimited areas of the spleen + within TdT+ clusters.
//A first selection of YFP+ cells will be proposed, do not hesitate to modify the detection threshold when the dialog box appears. 
//At this stage, care should be taken when setting the threshold to ensure that the number of cells is not underestimated or overestimated. 
//Tissue sections from the same acquisition parameters will be processed with the same threshold.
//The selection of YFP+ cells will be saved in .tif format.

selectWindow("YFP_intensity.tif");
run("Select None");
selectWindow("YFP_intensity.tif");
run("Duplicate...", "title=YFP_count");
run("Mean...", "radius=2");
waitForUser("Adjust Threshold and apply. Click OK when threshold is OK");
run("Watershed");
run("Analyze Particles...", "size=10-500 show=Masks");
run("Invert");
run("Create Selection");
waitForUser("YFP count OK? If not adjust it manually then clik OK");
roiManager("Add");
saveAs("tiff");

//Whole spleen count (1)
selectWindow("Mask of YFP_count.tif");
run("Select None");
//run("Invert");
roiManager("Select", 1);
run("Analyze Particles...", "size=0-500 summarize");

//Red pulp count (2)
selectWindow("Mask of YFP_count.tif");
roiManager("Select", 7);
run("Analyze Particles...", "size=0-500 summarize");

//Marginal zone count (3)
selectWindow("Mask of YFP_count.tif");
roiManager("Select", 8);
run("Analyze Particles...", "size=0-500 summarize");

//B cell zone count (4)
selectWindow("Mask of YFP_count.tif");
roiManager("Select", 9);
run("Analyze Particles...", "size=0-500 summarize");

//T cell zone count (5)
selectWindow("Mask of YFP_count.tif");
roiManager("Select", 2);
run("Analyze Particles...", "size=0-500 summarize");

//Superposition MZ+Tcell count (6)
selectWindow("Mask of YFP_count.tif");
roiManager("Select", 10);
run("Analyze Particles...", "size=0-500 summarize");

//Clusters Whole spleen count (7)
selectWindow("Mask of YFP_count.tif");
roiManager("Select", 13);
run("Analyze Particles...", "size=0-500 summarize");


// Analysis within clusters in each zone

//Clusters Red pulp count (8)
selectWindow("Mask of YFP_count.tif");
roiManager("Select", 14);
run("Analyze Particles...", "size=0-500 summarize");

//Clusters Marginal zone count (9)
selectWindow("Mask of YFP_count.tif");
roiManager("Select", 15);
run("Analyze Particles...", "size=0-500 summarize");

//Clusters B cell zone count (10)
selectWindow("Mask of YFP_count.tif");
roiManager("Select", 16);
run("Analyze Particles...", "size=0-500 summarize");

//Clusters T cell zone count (11)
selectWindow("Mask of YFP_count.tif");
roiManager("Select", 17);
run("Analyze Particles...", "size=0-500 summarize");

//Clusters Superposition MZ+Tcell count (12)
selectWindow("Mask of YFP_count.tif");
roiManager("Select", 18);
run("Analyze Particles...", "size=0-500 summarize");

waitForUser("Save the measured data and click on OK.");

	}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block 13: Choice of whether to analyse IE1+ cells. Uncheck if there is no IE1 to analyse.
//Can only be used directly if cluster analysis has been performed before : analysis also in clusters.
Dialog.create("IE1 analysis");
Dialog.addMessage("Is there a IE1 channel to analyse on this image?")
Dialog.addCheckbox("IE1 channel", true); 
Dialog.show();
IE1 = Dialog.getCheckbox();

	if (IE1==false) {
		waitForUser("Everything fine? Need to do something else? If no click OK");
		run("Close All");
	}
	
	
	if (IE1==true) {

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block 13.1: Remove the background from the IE1 staining
//For a more detailed analysis of IE1+ cells, the background is analysed and then deduced from the image. 
//When the dialogue box opens, choose an area without staining, representing the strongest background. Measure the MFI (Ctrl+M) and keep this value. 
//Use the "Color Balance" to remove the background, using the measured value. 
//This image with the deduced background will be saved as a .tif file.

selectWindow("IE1");
run("Duplicate...", "title=IE1_background_deduced");
roiManager("Select", 0);
run("Clear", "stack");
waitForUser("Analyse High background intensity zone and keep selection.");
run("ROI Manager...");
roiManager("Add");
roiManager("Select", 1);
run("Clear Outside", "stack");
run("Color Balance...");
  title = "WaitForUser";
  msg = "Use the \"Color Balance\" tool to adjust the intensity, apply, then click \"OK\".";
  waitForUser(title, msg);
saveAs("tiff");

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block 13.2: MFI analysis of the IE1 cells in the 6 different delimited areas of the spleen + TdT clusters in each. 
//The IE1 MFI is analysed for each of the six zone masks + cluster masks determined in the block 11.1. 
//It is possible to retrieve the data in the "Results" tab. Save them in an excel table.

//Whole spleen intensity (1)
selectWindow("IE1_background_deduced.tif");
roiManager("Select", 1);
run("Measure");

//Red pulp intensity (2)
selectWindow("IE1_background_deduced.tif");
roiManager("Select", 7);
run("Measure");

//Marginal zone intensity (3)
selectWindow("IE1_background_deduced.tif");
roiManager("Select", 8);
run("Measure");

//B cell zone intensity (4)
selectWindow("IE1_background_deduced.tif");
roiManager("Select", 9);
run("Measure");

//T cell zone intensity (5)
selectWindow("IE1_background_deduced.tif");
roiManager("Select", 2);
run("Measure");

//Superposition MZ+Tcell intensity (6)
selectWindow("IE1_background_deduced.tif");
roiManager("Select", 10);
run("Measure");


// Analysis within clusters in each zone

//Clusters Whole spleen intensity
selectWindow("IE1_background_deduced.tif");
roiManager("Select", 13);
run("Measure");

//Clusters Red pulp intensity
selectWindow("IE1_background_deduced.tif");
roiManager("Select", 14);
run("Measure");

//Clusters Marginal zone intensity
selectWindow("IE1_background_deduced.tif");
roiManager("Select", 15);
run("Measure");

//Clusters B cell zone intensity
selectWindow("IE1_background_deduced.tif");
roiManager("Select", 16);
run("Measure");

//Clusters T cell zone intensity
selectWindow("IE1_background_deduced.tif");
roiManager("Select", 17);
run("Measure");

//Clusters Superposition MZ+Tcell intensity
selectWindow("IE1_background_deduced.tif");
roiManager("Select", 18);
run("Measure");

waitForUser("Save the measured data and click on OK.");

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//Block 13.3 : IE1+ cells count in the 6 different delimited areas of the spleen + within TdT+ clusters.
//A first selection of IE1+ cells will be proposed, do not hesitate to modify the detection threshold when the dialog box appears. 
//At this stage, care should be taken when setting the threshold to ensure that the number of cells is not underestimated or overestimated. 
//Tissue sections from the same acquisition parameters will be processed with the same threshold.
//The selection of IE1+ cells will be saved in .tif format.

selectWindow("IE1_background_deduced.tif");
run("Select None");
selectWindow("IE1_background_deduced.tif");
run("Duplicate...", "title=IE1_number_count");
run("Mean...", "radius=2");
roiManager("Select", 1);
run("Enlarge...", "enlarge=-50 pixel");
run("Clear Outside");
run("Select None");
selectWindow("IE1_number_count");
setAutoThreshold("Default dark");
waitForUser("Is the mask? if not adjust it manually");
run("Convert to Mask");
run("Watershed");
run("Analyze Particles...", "size=10-1000 show=Masks");
run("Invert");
run("Create Selection");
waitForUser("Is the IE1 cell mask OK? If not adjust it manually.");
roiManager("Add");
saveAs("Tiff");

//Whole spleen count (1)
selectWindow("Mask of IE1_number_count.tif");
roiManager("Select", 1);
run("Analyze Particles...", "size=0-500 summarize");

//Red pulp count (2)
selectWindow("Mask of IE1_number_count.tif");
roiManager("Select", 7);
run("Analyze Particles...", "size=0-500 summarize");

//Marginal zone count (3)
selectWindow("Mask of IE1_number_count.tif");
roiManager("Select", 8);
run("Analyze Particles...", "size=0-500 summarize");

//B cell zone count (4)
selectWindow("Mask of IE1_number_count.tif");
roiManager("Select", 9);
run("Analyze Particles...", "size=0-500 summarize");

//T cell zone count (5)
selectWindow("Mask of IE1_number_count.tif");
roiManager("Select", 2);
run("Analyze Particles...", "size=0-500 summarize");

//Superposition MZ+Tcell count (6)
selectWindow("Mask of IE1_number_count.tif");
roiManager("Select", 10);
run("Analyze Particles...", "size=0-500 summarize");


// Analysis within clusters in each zone

//Clusters Whole spleen count (7)
selectWindow("Mask of IE1_number_count.tif");
roiManager("Select", 13);
run("Analyze Particles...", "size=0-500 summarize");

//Clusters Red pulp count (8)
selectWindow("Mask of IE1_number_count.tif");
roiManager("Select", 14);
run("Analyze Particles...", "size=0-500 summarize");

//Clusters Marginal zone count (9)
selectWindow("Mask of IE1_number_count.tif");
roiManager("Select", 15);
run("Analyze Particles...", "size=0-500 summarize");

//Clusters B cell zone count (10)
selectWindow("Mask of IE1_number_count.tif");
roiManager("Select", 16);
run("Analyze Particles...", "size=0-500 summarize");

//Clusters T cell zone count (11)
selectWindow("Mask of IE1_number_count.tif");
roiManager("Select", 17);
run("Analyze Particles...", "size=0-500 summarize");

//Clusters Superposition MZ+Tcell count (12)
selectWindow("Mask of IE1_number_count.tif");
roiManager("Select", 18);
run("Analyze Particles...", "size=0-500 summarize");

	}

waitForUser("Everything fine? Need to do something else? If no click OK");
run("Close All");
