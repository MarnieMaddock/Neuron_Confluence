// USAGE: Use in FIJI
//
// Author: Marnie L Maddock (University of Wollongong)
// mmaddock@uow.edu.au, mlm715@uowmail.edu.au
// 30.05.23
// This work is licensed under a Creative Commons Attribution 4.0 International License.
//<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Creative Commons Attribution 4.0 International License</a>.

/* Instructions
	Take images on Incucyte (I did 25 images per 24well)
	Make sure each image name is unique (the automatic format of well_picturenumber_yearmonthday is perfect)
	Save all images to a folder as a TIFF
	Run macro :)
	This determines the confluency of every image. To get an average confluency per well, use excel/R script)
*/
dir1 = getDirectory("Choose Source Directory ");
resultsDir = dir1+"results/";
File.makeDirectory(resultsDir);
dir2 = getDirectory("Choose Destination Directory ");
list = getFileList(dir1);

processFolder(dir1);
function processFolder(dir1){
	list = getFileList(dir1);
	list = Array.sort(list);
	for (i = 0; i < list.length; i++) {
		if(File.isDirectory(dir1 + File.separator + list[i]))
			processFolder(dir1 + File.separator + list[i]);
		if(endsWith(list[i], ".tif"))
			processFile(dir1, dir2, list[i]);
	}
}	 

function processFile(dir1, dir2, file){
	open(dir1 + File.separator + file);
			setOption("BlackBackground", true);
			run("Convert to Mask");
			run("Invert LUT");
			setAutoThreshold("Default dark");
			//run("Threshold...");
			//setThreshold(0, 0);
			run("Convert to Mask");
			run("Measure");
			selectWindow("Results");
			saveAs("Results", dir2 + "23MM07_1_day7_confluence.csv"); 
}
close("*");
exit("Done");