//Get the title and channels
imageTitle=getTitle();
Stack.getDimensions(width, height, channels, slices, frames);

//Check compatability of file to script
if (channels > 7) {
	print("The merging program can only merge up to 7 channels");
	exit
}

//This variable will determine what channel is flat-field corrected
if (channels > 1) {
	channelFFC = getNumber("Which channel should be Flat-field corrected?", 1);
	if (channelFFC > channels) {
		print("You wanted to flat-field correct channel", channelFFC);
		print("There are only", channels, "channels.");
		exit
	}
}
else {
	channelFFC = 1;
}

//gaussian blur pixel count
pixelSize = getNumber("Sigma (Radius)", 25); //Sigma(Radius)

//Define names in variables so computer knows what to use
channelIRM = "C" + channelFFC + "-";
originalIRM = channelIRM + imageTitle;
resultname = "Result of " + originalIRM;

//This variable is important for correctly merging/naming ALL channels
range = channels + 1;

//blurring string for flatfield correction
SigmaString = "sigma="+ pixelSize +" stack";

//flat-field correction
if (channels > 1) {
	run("Split Channels");
	selectWindow(originalIRM);
}
else {
	originalIRM = imageTitle;
	selectWindow(imageTitle);
}

run("Duplicate...", "duplicate");
blurredInvertIRM = getTitle();
selectWindow(blurredInvertIRM);
run("Gaussian Blur...", SigmaString);
run("Invert", "stack");
imageCalculator("Average create stack", originalIRM , blurredInvertIRM);

//close redundant windows
close(blurredInvertIRM);
close(originalIRM);

//exit point for single channel files
if (channels == 1) {
	rename(imageTitle);
	exit
}

//Renaming all channels
for (i = 1; i < range; i++) {
	additive = "C" + i + "-";
	if (channelFFC == i) {
	selectWindow("Result of "+ additive + imageTitle);
	rename("channel " + i);
	}
	else {
	selectWindow(additive + imageTitle);
	rename("channel " + i);
	}
}

//Creating the string for merging channels
endResultString = "c1=[channel 1] c2=[channel 2] c3=[channel 3] c4=[channel 4] c5=[channel 5] c6=[channel 6] c7=[channel 7] ";
indexNumber = channels*15; //one channel string has 15 chars
endResultSubString = substring(endResultString, 0, indexNumber);
resultString = endResultSubString + "create";

//Merging the channels
run("Merge Channels...", resultString);

//Rename Result into the original name
Merged=getTitle();
selectWindow(Merged);
rename(imageTitle);

//run("Channels Tool...");
Stack.setDisplayMode("grayscale");