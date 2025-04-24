// USAGE: Use in FIJI
//
// Author: Marnie L Maddock (University of Wollongong)
// mmaddock@uow.edu.au, mlm715@uowmail.edu.au
// 30.05.23
// This work is licensed under a MIT License.
/* Instructions
	Take images on Incucyte (I did 25 images per 24well)
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
run("Set Measurements...", "area area_fraction redirect=None decimal=3");

function processFile(dir1, resultsDir, file){
	inputPath = dir1 + File.separator + file;
    outputPath = roiDir + file;
        if (!File.exists(outputPath)) {
			open(inputPath);
			title = getTitle(); //save image name
			print("Processing: " + title);  // Print the name of the image being processed
			setOption("BlackBackground", true);
			run("Convert to Mask"); //Make binary
			run("Invert LUT");
			setAutoThreshold("Default dark");
			//run("Threshold...");
			//setThreshold(0, 0);
			run("Convert to Mask");
			saveAs("Tiff", roiDir + title + ".tif"); //save mask image to mask_results folder
			run("Analyze Particles...", "  show=Overlay clear summarize"); //calculate area an confluency
			run("Measure");
			close(title + ".tif");
    } else{
    	 print("Skipping: " + file);  // Skip the image already processed
    }
}

selectWindow("Summary");
// Use Table.applyMacro() to manipulate the table
code = ""; // No need to apply any macro code in this case
Table.applyMacro(code);

// Remove the "Count" and "Average Size" column
Table.deleteColumn("Count");
Table.deleteColumn("Average Size");

// Rename the columns
Table.renameColumn("Slice", "Image");
Table.renameColumn("Total Area", "Area (White Pixels)");
Table.renameColumn("%Area", "Confluency % of Image");

// Prompt the user for the file name
fileName = getString("Enter the file name to save the results:", "results");

saveAs("Results", resultsDir + File.separator + fileName + ".csv");
close("*");
close("Results");
close(fileName + ".csv");
close("Log");
exit("Done");
