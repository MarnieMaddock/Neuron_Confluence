// USAGE: Use in FIJI
//
// Author: Marnie L Maddock (University of Wollongong)
// mmaddock@uow.edu.au, mlm715@uowmail.edu.au
// 30.05.23
// This work is licensed under a MIT License.
/* Instructions
	Take images on Incucyte (Sartorious)
	Make sure each image name is unique (the automatic format of well_picturenumber_yearmonthday is perfect)
	Save all images to a folder as a TIFF
	Run macro :)
	This determines the confluency of every image. To get an average confluency per well, use excel/R script)
	Note: This macro only works well if it is a good image. If you feed it  bad (e.g. out of focus images) you will get poor results.
*/
dir1 = getDirectory("Choose Source Directory ");
resultsDir = dir1+"results/";
roiDir = resultsDir+"Mask_results/";
File.makeDirectory(resultsDir); // Make results directory 
File.makeDirectory(roiDir); //Make mask results directory
list = getFileList(dir1);

processFolder(dir1);

function processFolder(dir1){
	list = getFileList(dir1);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(dir1 + File.separator + list[i]))
			processFolder(dir1 + File.separator + list[i]);
		if(endsWith(list[i], ".tif"))
			processFile(dir1, resultsDir, list[i]);
	}
}	 

function processFile(dir1, resultsDir, file){
	inputPath = dir1 + File.separator + file;
    outputPath = roiDir + file;
        if (!File.exists(outputPath)) {
			open(inputPath);
			title = getTitle(); //save image name
			print("Processing: " + title);  // Print the name of the image being processed
			// Convert to 8-bit grayscale
			run("8-bit");
			
			// Apply consistent automatic threshold
			setAutoThreshold("Default dark");
			
			// Ensure binary masks have black background
			setOption("BlackBackground", true);
			
			// Convert to binary mask
			run("Convert to Mask");
			
			// Ensure consistent display
			run("Grays");
			saveAs("Tiff", roiDir + title); //save mask image to mask_results folder
			run("Set Measurements...", "area area_fraction display redirect=None decimal=3");
			setThreshold(0, 0);
			run("Measure");
			// Add original image filename to Results table
			row = nResults - 1;
			setResult("Image", row, file);
			updateResults();
			close(title);
    } else{
    	 print("Skipping: " + file);  // Skip the image already processed
    }
}
// Rename the Results table columns
selectWindow("Results");

Table.renameColumn("%Area", "Confluency % of Image");

// Prompt for output filename
fileName = getString("Enter the file name to save the results:", "results");

// Save results
saveAs("Results", resultsDir + fileName + ".csv");

// Close windows
run("Close All");
close("Results");
exit("Done");
