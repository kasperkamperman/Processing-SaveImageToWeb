<?php

	//https://www.w3schools.com/php/php_file_upload.asp
	
	$targetDir = "processing_upload/";
	$targetFile = $targetDir . basename($_FILES['imageFile']['name']);

	$imageFileType = strtolower(pathinfo($targetFile,PATHINFO_EXTENSION));

	$uploadOk = true;

	// Check if image file is a actual image or fake image
	$checkRealImage = getimagesize($_FILES["imageFile"]["tmp_name"]);
	    
    if($checkRealImage !== false) {
        //echo "File is an image - " . $checkRealImage["mime"] . ".";
        $uploadOk = true;
    } else {
        echo "File is not an image.";
        $uploadOk = false;
    }

	// Check if file already exists
	if (file_exists($targetFile)) {
	    echo "Sorry, file already exists.";
	    $uploadOk = false;
	}

	// if the file is larger than 2000KB
	if ($_FILES['imageFile']["size"] > 2000000) {
    	echo "Sorry, your file is too large.";
    	$uploadOk = false;
	}

	// Allow certain file formats
	if($imageFileType != "jpg" && $imageFileType != "png" && $imageFileType != "jpeg" && $imageFileType != "gif" ) {
    	echo "Sorry, only JPG, JPEG, PNG & GIF files are allowed.";
   		$uploadOk = false;
	}

	if ($uploadOk == false) {
	    echo "Sorry, your file was not uploaded.";
		// if everything is ok, try to upload file
	} else {
		if (move_uploaded_file($_FILES['imageFile']['tmp_name'], $targetFile)) {
		    echo "The file ". basename( $_FILES["imageFile"]["name"]). " has been uploaded.\n\n";
		} else {
		    echo "Sorry, there was an error uploading your file.";
		}
	}

	//echo 'Here is some more debugging info:\n';
	//print_r($_FILES);

?>
