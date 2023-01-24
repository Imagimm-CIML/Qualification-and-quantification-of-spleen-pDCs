 ////////////////////////////////////////////////////////////////////////////////////////////////////////////

/***************************************initialisation******************************************************/

////////////////////////////////////////////////////////////////////////////////////////////////////////////



// options, initialisation
//function Initialisation () {

// delete all region in ROI manager
//list = getList("image.titles");
//if (list.length != 0) {
//    close();
//}
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
        

{
rename("Spleen_Analysis");
Dialog.create("Channel attribution");
Dialog.addChoice("Ch1:", newArray("CD3", "MOMA-1", "TdT", "Autofluorescence", "YFP", "IE1", "not used"));
Dialog.addChoice("Ch2:", newArray("YFP", "CD3", "MOMA-1", "TdT", "Autofluorescence", "IE1", "not used"));
Dialog.addChoice("Ch3:", newArray("TdT", "not used", "MOMA-1", "CD3", "Autofluorescence", "IE1", "YFP"));
Dialog.addChoice("Ch4:", newArray("IE1", "TdT", "Autofluorescence", "CD3", "MOMA-1", "YFP", "not used"));
Dialog.addChoice("Ch5:", newArray("MOMA-1", "IE1", "Autofluorescence", "not used", "TdT", "CD3", "YFP"));
Dialog.addChoice("Ch6:", newArray("Autofluorescence", "not used", "YFP", "TdT", "CD3", "IE1", "MOMA-1"));

//Dialog.addCheckbox("USE A BINARY MASK (named Mask.tif) ?", 0);

Dialog.show();

Ch1_Name = Dialog.getChoice();
Ch2_Name = Dialog.getChoice();
Ch3_Name = Dialog.getChoice();
Ch4_Name = Dialog.getChoice();
Ch5_Name = Dialog.getChoice();
Ch6_Name = Dialog.getChoice();


//mask_exist = Dialog.getCheckbox();

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


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Split channel
//ID = getImageID();
//rename("Spleen Test");
//run("Make Substack...", "channels=1-6");

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//function saturation_mask (){

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
	waitForUser("tissu saturation ok, if not do it manually");
	roiManager("Add");
}
saveAs("Tiff");


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//function Whole_spleen_mask (){

{
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
waitForUser("tissu contour ok, if not do it manually");
roiManager("Add");
saveAs("Tiff");
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//function Tcell zone mask ()
{
selectWindow("CD3");
run("Duplicate...", "title=Tcell_zone_mask");
roiManager("Select", 0);
run("Clear", "stack");
run("Select None");
run("Mean...", "radius=20");
setAutoThreshold("Default");
setOption("BlackBackground", true);
waitForUser("Mask creation OK? if not adjust manually");
run("Convert to Mask");
run("Invert");
run("Fill Holes");
run("Analyze Particles...", "size=6000-Infinity show=Masks");
run("Invert");
run("Create Selection");
run("Enlarge...", "enlarge=20 pixel");
run("Fill");
run("ROI Manager...");
waitForUser("tissu contour ok, if not do it manually.Parameters : Mean 20, analyse particles 3000-infinity, Fill holes, Enlarge selection 20 pixels");
roiManager("Add");
saveAs("Tiff");
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//function Manual_draw_follicles ()
{

selectWindow("CD3");
run("Select None");
run("Duplicate...", "title=T_cell_zone");
selectWindow("MOMA-1");
run("Duplicate...", "title=Marginal_zone");
run("Merge Channels...", "c1=[T_cell_zone] c2=[Marginal_zone] create");
run("Color Balance...");
run("Channels Tool...");
run("ROI Manager...");
waitForUser("Select follicle zone contour manually");
roiManager("Add");
saveAs("Tiff");
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
selectWindow("MOMA-1");
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
waitForUser("B+T cell zone OK? if not, draw it manually on COMPOSITE image");
roiManager("Add");
saveAs("Tiff");
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//function Create_every_masks ()
{

// red pulp
selectWindow("Whole_spleen_mask.tif");
run("Select None");
run("Duplicate...", "title=Red_pulp_mask");
roiManager("Select", 3);
run("Clear", "stack");
selectWindow("Red_pulp_mask");
run("Create Selection");
//run("Make Inverse");
run("ROI Manager...");
roiManager("Add");
saveAs("Tiff");

//Marginal zone
selectWindow("Whole_spleen_mask.tif");
run("Select None");
run("Duplicate...", "title=Marginal_zone");
roiManager("Select", 3);
run("Clear Outside", "stack");
roiManager("Select", 6);
run("Clear", "stack");
selectWindow("Marginal_zone");
run("Create Selection");
//run("Make Inverse");
run("ROI Manager...");
roiManager("Add");
saveAs("Tiff");

//B cell zone
selectWindow("Whole_spleen_mask.tif");
run("Select None");
run("Duplicate...", "title=Bcell_zone");
roiManager("Select", 6);
run("Clear Outside", "stack");
roiManager("Select", 2);
run("Clear", "stack");
selectWindow("Bcell_zone");
run("Create Selection");
//run("Make Inverse");
run("ROI Manager...");
roiManager("Add");
saveAs("Tiff");

//T cell zone + Marginal zone superposition
selectWindow("Marginal_zone.tif");
run("Select None");
run("Duplicate...", "title=MZ_+_Tcell_zone_superposition");
roiManager("Select", 2);
run("Clear Outside", "stack");
selectWindow("MZ_+_Tcell_zone_superposition");
run("Create Selection");
//run("Make Inverse");
run("ROI Manager...");
roiManager("Add");
saveAs("Tiff");
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//function TdT_background ()
{

selectWindow("TdT");
run("Duplicate...", "title=TdT_background_deduced");
roiManager("Select", 0);
run("Clear", "stack");
waitForUser("Analyse High background intensity zone and keep selection");
run("ROI Manager...");
roiManager("Add");
roiManager("Select", 1);
run("Clear Outside", "stack");
run("Select None");
run("Color Balance...");
  title = "WaitForUser";
  msg = "If necessary, use the \"Color Balance\" tool to adjust the intensity, apply, then click \"OK\".";
  waitForUser(title, msg);
//  selectImage("TdT_background_deduced"); 
//  getMinAndMax(min, max);
//  if (lower==-1)
//      exit("Intensity was not set");
saveAs("tiff");
}

Dialog.create("TdT Cluster analysis");
Dialog.addMessage("Is there any TdT clusters to analyse on this image?")
Dialog.addCheckbox("TdT clusters", true); // Checkbox 1, save as tiff stack
Dialog.show();
clusters = Dialog.getCheckbox(); //Checkbox 1 ( Save as Stack)

if (clusters==false) {

//function TdT_intensity_analyse ()

//Whole spleen intensity
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 1);
run("Measure");

//Red pulp intensity
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 7);
run("Measure");

//Marginal zone intensity
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 8);
run("Measure");

//B cell zone intensity
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 9);
run("Measure");

//T cell zone intensity
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 2);
run("Measure");

//Superposition MZ+Tcell intensity
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 10);
run("Measure");

///////////////////////////////Number of TdT cells analysis////////////////////////////////
selectWindow("TdT_background_deduced.tif");
run("Select None");
selectWindow("TdT_background_deduced.tif");
run("Duplicate...", "title=TdT_number_count");
run("Mean...", "radius=2");
roiManager("Select", 1);
run("Enlarge...", "enlarge=-50 pixel");
run("Clear Outside");
//roiManager("Select", 13);
//run("Clear");
run("Select None");
selectWindow("TdT_number_count");
setAutoThreshold("Default dark");
waitForUser("Is the mask? if not adjust it manually");
run("Convert to Mask");
run("Watershed");
run("Analyze Particles...", "size=5-500 show=Masks");
run("Invert");
run("Create Selection");
waitForUser("Is the TdT cell mask OK? if not do it manually");
roiManager("Add");
saveAs("Tiff");
//run("Analyze Particles...", "size=0-500 show=Masks");

//Whole spleen count
selectWindow("Mask of TdT_number_count.tif");
//run("Select None");
//run("Invert");
roiManager("Select", 1);
run("Analyze Particles...", "size=0-500 summarize");

//Red pulp count
selectWindow("Mask of TdT_number_count.tif");
roiManager("Select", 7);
run("Analyze Particles...", "size=0-500 summarize");

//Marginal zone count
selectWindow("Mask of TdT_number_count.tif");
roiManager("Select", 8);
run("Analyze Particles...", "size=0-500 summarize");

//B cell zone count
selectWindow("Mask of TdT_number_count.tif");
roiManager("Select", 9);
run("Analyze Particles...", "size=0-500 summarize");

//T cell zone count
selectWindow("Mask of TdT_number_count.tif");
roiManager("Select", 2);
run("Analyze Particles...", "size=0-500 summarize");

//Superposition MZ+Tcell count
selectWindow("Mask of TdT_number_count.tif");
roiManager("Select", 10);
run("Analyze Particles...", "size=0-500 summarize");

waitForUser("Add datas to the excel sheet then click OK");
//waitForUser("Everything fine? Need to do something else? If no click OK");
//run("Close All");
}
if (clusters==true) {
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//function Clusters_selection ()
{
selectWindow("TdT_background_deduced.tif");
run("Duplicate...", "title=TdT_Clusters_selection");
makeRectangle(600, 500, 55, 55);
waitForUser("Analyse intensity of clustered and non-clustered pDCs and draw clusters on the image. Create selection of the clusters");
run("ROI Manager...");
roiManager("Add");
saveAs("Tiff");
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//function Clusters_mask_creation ()
{
// Whole spleen clusters
selectWindow("Whole_spleen_mask.tif");
run("Select None");
run("Duplicate...", "title=Clusters_whole_spleen_mask");
roiManager("Select", 12);
run("Clear Outside", "stack");
selectWindow("Clusters_whole_spleen_mask");
run("Create Selection");
getSelectionBounds(x, y, width, height);
if (x==0) {
	waitForUser("No selection of saturation, create a off boundaries selection and click OK");
	run("ROI Manager...");
	roiManager("Add");
	saveAs("Tiff");
}
else {
run("ROI Manager...");
roiManager("Add");
saveAs("Tiff");
}

// red pulp clusters
selectWindow("Clusters_whole_spleen_mask.tif");
run("Select None");
run("Duplicate...", "title=Clusters_red_pulp_mask");
roiManager("Select", 7);
run("Clear Outside", "stack");
selectWindow("Clusters_red_pulp_mask");
run("Create Selection");
//run("Make Inverse");
getSelectionBounds(x, y, width, height);
if (x==0) {
	waitForUser("No selection of saturation, create a off boundaries selection and click OK");
	run("ROI Manager...");
	roiManager("Add");
	saveAs("Tiff");
}
else {
run("ROI Manager...");
roiManager("Add");
saveAs("Tiff");
}
// Marginal zone clusters
selectWindow("Clusters_whole_spleen_mask.tif");
run("Select None");
run("Duplicate...", "title=Clusters_marginal_zone_mask");
roiManager("Select", 8);
run("Clear Outside", "stack");
selectWindow("Clusters_marginal_zone_mask");
run("Create Selection");
//run("Make Inverse");
getSelectionBounds(x, y, width, height);
if (x==0) {
	waitForUser("No selection of saturation, create a off boundaries selection and click OK");
	run("ROI Manager...");
	roiManager("Add");
	saveAs("Tiff");
}
else {
run("ROI Manager...");
roiManager("Add");
saveAs("Tiff");
}

// Bcell zone clusters
selectWindow("Clusters_whole_spleen_mask.tif");
run("Select None");
run("Duplicate...", "title=Clusters_Bcell_zone_mask");
roiManager("Select", 9);
run("Clear Outside", "stack");
selectWindow("Clusters_Bcell_zone_mask");
run("Create Selection");
//run("Make Inverse");
getSelectionBounds(x, y, width, height);
if (x==0) {
	waitForUser("No selection of saturation, create a off boundaries selection and click OK");
	run("ROI Manager...");
	roiManager("Add");
	saveAs("Tiff");
}
else {
run("ROI Manager...");
roiManager("Add");
saveAs("Tiff");
}

// Tcell zone clusters
selectWindow("Clusters_whole_spleen_mask.tif");
run("Select None");
run("Duplicate...", "title=Clusters_Tcell_zone_mask");
roiManager("Select", 2);
run("Clear Outside", "stack");
selectWindow("Clusters_Tcell_zone_mask");
run("Create Selection");
//run("Make Inverse");
getSelectionBounds(x, y, width, height);
if (x==0) {
	waitForUser("No selection of saturation, create a off boundaries selection and click OK");
	run("ROI Manager...");
	roiManager("Add");
	saveAs("Tiff");
}
else {
run("ROI Manager...");
roiManager("Add");
saveAs("Tiff");
}

// Tcell + MZ superposition clusters
selectWindow("Clusters_whole_spleen_mask.tif");
run("Select None");
run("Duplicate...", "title=Clusters_Tcell-MZ_mask");
roiManager("Select", 10);
run("Clear Outside", "stack");
selectWindow("Clusters_Tcell-MZ_mask");
run("Create Selection");
//run("Make Inverse");
getSelectionBounds(x, y, width, height);
if (x==0) {
	waitForUser("No selection of saturation, create a off boundaries selection and click OK");
	run("ROI Manager...");
	roiManager("Add");
	saveAs("Tiff");
}
else {
run("ROI Manager...");
roiManager("Add");
saveAs("Tiff");
}}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//function TdT_intensity_analyse ()
{
//Whole spleen intensity
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 1);
run("Measure");

//Red pulp intensity
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 7);
run("Measure");

//Marginal zone intensity
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 8);
run("Measure");

//B cell zone intensity
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 9);
run("Measure");

//T cell zone intensity
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 2);
run("Measure");

//Superposition MZ+Tcell intensity
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 10);
run("Measure");

//Clusters Whole spleen intensity
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 13);
run("Measure");

//Clusters Red pulp intensity
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 14);
run("Measure");

//Clusters Marginal zone intensity
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 15);
run("Measure");

//Clusters B cell zone intensity
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 16);
run("Measure");

//Clusters T cell zone intensity
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 17);
run("Measure");

//Clusters Superposition MZ+Tcell intensity
selectWindow("TdT_background_deduced.tif");
roiManager("Select", 18);
run("Measure");

waitForUser("Add datas to the excel sheet then click OK to continue");
}

/////////////////////////////////////////////////////////////////////////////////////////////////
//Number of TdT cells analysis 
{
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
waitForUser("Is the mask? if not adjust it manually");
run("Convert to Mask");
run("Watershed");
run("Analyze Particles...", "size=5-500 show=Masks");
run("Invert");
run("Create Selection");
waitForUser("Is the TdT cell mask OK? if not do it manually");
roiManager("Add");
saveAs("Tiff");
//run("Analyze Particles...", "size=0-500 show=Masks");

//Whole spleen count
selectWindow("Mask of TdT_number_count.tif");
//run("Select None");
//run("Invert");
roiManager("Select", 1);
run("Analyze Particles...", "size=0-500 summarize");

//Red pulp count
selectWindow("Mask of TdT_number_count.tif");
roiManager("Select", 7);
run("Analyze Particles...", "size=0-500 summarize");

//Marginal zone count
selectWindow("Mask of TdT_number_count.tif");
roiManager("Select", 8);
run("Analyze Particles...", "size=0-500 summarize");

//B cell zone count
selectWindow("Mask of TdT_number_count.tif");
roiManager("Select", 9);
run("Analyze Particles...", "size=0-500 summarize");

//T cell zone count
selectWindow("Mask of TdT_number_count.tif");
roiManager("Select", 2);
run("Analyze Particles...", "size=0-500 summarize");

//Superposition MZ+Tcell count
selectWindow("Mask of TdT_number_count.tif");
roiManager("Select", 10);
run("Analyze Particles...", "size=0-500 summarize");

waitForUser("Add datas to the excel sheet then click OK");
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
//YFP Analysis

Dialog.create("YFP analysis");
Dialog.addMessage("Is there a YFP channel to analyse on this image?")
Dialog.addCheckbox("YFP channel", true); // Checkbox 1, save as tiff stack
Dialog.show();
YFP = Dialog.getCheckbox(); //Checkbox 1 ( Save as Stack)

if (YFP==false) {
	waitForUser("Everything fine? Need to do something else? If no click OK");
	run("Close All");
}
if (YFP==true) {
selectWindow("YFP");
run("Duplicate...", "title=YFP_intensity");
roiManager("Select", 0);
run("Clear", "stack");
roiManager("Select", 1);
run("Enlarge...", "enlarge=-50 pixel");
run("Clear Outside");
//waitForUser("Analyse High background intensity zone and keep selection");
//run("ROI Manager...");
//roiManager("Add");
run("Color Balance...");
  title = "WaitForUser";
  msg = "If necessary, use the \"Color Balance\" tool to adjust the intensity, apply, then click \"OK\".";
  waitForUser(title, msg);
//  selectImage("TdT_background_deduced"); 
//  getMinAndMax(min, max);
//  if (lower==-1)
//      exit("Intensity was not set");
saveAs("tiff");

//Whole spleen intensity
selectWindow("YFP_intensity.tif");
roiManager("Select", 1);
run("Measure");

//Red pulp intensity
selectWindow("YFP_intensity.tif");
roiManager("Select", 7);
run("Measure");

//Marginal zone intensity
selectWindow("YFP_intensity.tif");
roiManager("Select", 8);
run("Measure");

//B cell zone intensity
selectWindow("YFP_intensity.tif");
roiManager("Select", 9);
run("Measure");

//T cell zone intensity
selectWindow("YFP_intensity.tif");
roiManager("Select", 2);
run("Measure");

//Superposition MZ+Tcell intensity
selectWindow("YFP_intensity.tif");
roiManager("Select", 10);
run("Measure");

//Clusters Whole spleen intensity
selectWindow("YFP_intensity.tif");
roiManager("Select", 13);
run("Measure");

//Clusters Red pulp intensity
selectWindow("YFP_intensity.tif");
roiManager("Select", 14);
run("Measure");

//Clusters Marginal zone intensity
selectWindow("YFP_intensity.tif");
roiManager("Select", 15);
run("Measure");

//Clusters B cell zone intensity
selectWindow("YFP_intensity.tif");
roiManager("Select", 16);
run("Measure");

//Clusters T cell zone intensity
selectWindow("YFP_intensity.tif");
roiManager("Select", 17);
run("Measure");

//Clusters Superposition MZ+Tcell intensity
selectWindow("YFP_intensity.tif");
roiManager("Select", 18);
run("Measure");

waitForUser("Add datas to the excel sheet then click OK");

///////////////////////////////////////////////////////////////////////////////////////
//YFP count analysis

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
waitForUser("YFP count OK? If not do it manually then clik OK");
roiManager("Add");
saveAs("tiff");

//Whole spleen intensity
selectWindow("Mask of YFP_count.tif");
run("Select None");
//run("Invert");
roiManager("Select", 1);
run("Analyze Particles...", "size=0-500 summarize");

//Red pulp intensity
selectWindow("Mask of YFP_count.tif");
roiManager("Select", 7);
run("Analyze Particles...", "size=0-500 summarize");

//Marginal zone intensity
selectWindow("Mask of YFP_count.tif");
roiManager("Select", 8);
run("Analyze Particles...", "size=0-500 summarize");

//B cell zone intensity
selectWindow("Mask of YFP_count.tif");
roiManager("Select", 9);
run("Analyze Particles...", "size=0-500 summarize");

//T cell zone intensity
selectWindow("Mask of YFP_count.tif");
roiManager("Select", 2);
run("Analyze Particles...", "size=0-500 summarize");

//Superposition MZ+Tcell intensity
selectWindow("Mask of YFP_count.tif");
roiManager("Select", 10);
run("Analyze Particles...", "size=0-500 summarize");

//Clusters Whole spleen intensity
selectWindow("Mask of YFP_count.tif");
roiManager("Select", 13);
run("Analyze Particles...", "size=0-500 summarize");

//Clusters Red pulp intensity
selectWindow("Mask of YFP_count.tif");
roiManager("Select", 14);
run("Analyze Particles...", "size=0-500 summarize");

//Clusters Marginal zone intensity
selectWindow("Mask of YFP_count.tif");
roiManager("Select", 15);
run("Analyze Particles...", "size=0-500 summarize");

//Clusters B cell zone intensity
selectWindow("Mask of YFP_count.tif");
roiManager("Select", 16);
run("Analyze Particles...", "size=0-500 summarize");

//Clusters T cell zone intensity
selectWindow("Mask of YFP_count.tif");
roiManager("Select", 17);
run("Analyze Particles...", "size=0-500 summarize");

//Clusters Superposition MZ+Tcell intensity
selectWindow("Mask of YFP_count.tif");
roiManager("Select", 18);
run("Analyze Particles...", "size=0-500 summarize");

waitForUser("Add datas to the excel sheet then click OK to continue");
//waitForUser("Everything fine? Need to do something else? If no click OK");
//run("Close All");

}}


Dialog.create("IE1 analysis");
Dialog.addMessage("Is there a IE1 channel to analyse on this image?")
Dialog.addCheckbox("IE1 channel", true); // Checkbox 1, save as tiff stack
Dialog.show();
IE1 = Dialog.getCheckbox(); //Checkbox 1 ( Save as Stack)

if (IE1==false) {
	waitForUser("Everything fine? Need to do something else? If no click OK");
	run("Close All");
}
if (IE1==true) {
////////////////////////IE1 quantification//////////////////////////

selectWindow("IE1");
run("Duplicate...", "title=IE1_background_deduced");
roiManager("Select", 0);
run("Clear", "stack");
roiManager("Select", 1);
run("Clear Outside", "stack");
run("Color Balance...");
  title = "WaitForUser";
  msg = "Use the \"Color Balance\" tool to adjust the intensity, apply, then click \"OK\".";
  waitForUser(title, msg);
//  selectImage("TdT_background_deduced"); 
//  getMinAndMax(min, max);
//  if (lower==-1)
//      exit("Intensity was not set");
saveAs("tiff");

//////////////////////////function IE1_intensity_analyse ()

//Whole spleen intensity
selectWindow("IE1_background_deduced.tif");
roiManager("Select", 1);
run("Measure");

//Red pulp intensity
selectWindow("IE1_background_deduced.tif");
roiManager("Select", 7);
run("Measure");

//Marginal zone intensity
selectWindow("IE1_background_deduced.tif");
roiManager("Select", 8);
run("Measure");

//B cell zone intensity
selectWindow("IE1_background_deduced.tif");
roiManager("Select", 9);
run("Measure");

//T cell zone intensity
selectWindow("IE1_background_deduced.tif");
roiManager("Select", 2);
run("Measure");

//Superposition MZ+Tcell intensity
selectWindow("IE1_background_deduced.tif");
roiManager("Select", 10);
run("Measure");

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

waitForUser("Add datas to the excel sheet then click OK to continue");

///////////////////////////////Number of IE1 cells analysis////////////////////////////////
selectWindow("IE1_background_deduced.tif");
run("Select None");
selectWindow("IE1_background_deduced.tif");
run("Duplicate...", "title=IE1_number_count");
run("Mean...", "radius=2");
roiManager("Select", 1);
run("Enlarge...", "enlarge=-50 pixel");
run("Clear Outside");
//roiManager("Select", 13);
//run("Clear");
run("Select None");
selectWindow("IE1_number_count");
setAutoThreshold("Default dark");
waitForUser("Is the mask? if not adjust it manually");
run("Convert to Mask");
run("Watershed");
run("Analyze Particles...", "size=10-1000 show=Masks");
run("Invert");
run("Create Selection");
waitForUser("Is the IE1 cell mask OK? if not do it manually");
roiManager("Add");
saveAs("Tiff");
//run("Analyze Particles...", "size=0-500 show=Masks");

//Whole spleen count
selectWindow("Mask of IE1_number_count.tif");
//run("Select None");
//run("Invert");
roiManager("Select", 1);
run("Analyze Particles...", "size=0-500 summarize");

//Red pulp count
selectWindow("Mask of IE1_number_count.tif");
roiManager("Select", 7);
run("Analyze Particles...", "size=0-500 summarize");

//Marginal zone count
selectWindow("Mask of IE1_number_count.tif");
roiManager("Select", 8);
run("Analyze Particles...", "size=0-500 summarize");

//B cell zone count
selectWindow("Mask of IE1_number_count.tif");
roiManager("Select", 9);
run("Analyze Particles...", "size=0-500 summarize");

//T cell zone count
selectWindow("Mask of IE1_number_count.tif");
roiManager("Select", 2);
run("Analyze Particles...", "size=0-500 summarize");

//Superposition MZ+Tcell count
selectWindow("Mask of IE1_number_count.tif");
roiManager("Select", 10);
run("Analyze Particles...", "size=0-500 summarize");

//Clusters Whole spleen intensity
selectWindow("Mask of IE1_number_count.tif");
roiManager("Select", 13);
run("Analyze Particles...", "size=0-500 summarize");

//Clusters Red pulp intensity
selectWindow("Mask of IE1_number_count.tif");
roiManager("Select", 14);
run("Analyze Particles...", "size=0-500 summarize");

//Clusters Marginal zone intensity
selectWindow("Mask of IE1_number_count.tif");
roiManager("Select", 15);
run("Analyze Particles...", "size=0-500 summarize");

//Clusters B cell zone intensity
selectWindow("Mask of IE1_number_count.tif");
roiManager("Select", 16);
run("Analyze Particles...", "size=0-500 summarize");

//Clusters T cell zone intensity
selectWindow("Mask of IE1_number_count.tif");
roiManager("Select", 17);
run("Analyze Particles...", "size=0-500 summarize");

//Clusters Superposition MZ+Tcell intensity
selectWindow("Mask of IE1_number_count.tif");
roiManager("Select", 18);
run("Analyze Particles...", "size=0-500 summarize");

}

waitForUser("Everything fine? Need to do something else? If no click OK");
run("Close All");
