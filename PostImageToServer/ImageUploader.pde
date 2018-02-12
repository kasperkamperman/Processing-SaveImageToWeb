/*  Implemented the JPEG compression sketch by Jeff Thompson
    https://gist.github.com/jeffThompson/ea54b5ea40482ec896d1e6f9f266c731
    
    Multipart uploader example:
    http://www.baeldung.com/httpclient-multipart-upload
    
    PHP file based on:
    https://www.w3schools.com/php/php_file_upload.asp
    
    Default Processing save is 90% compression. 
    I've defaulted the uploader now to 60%. 
    
    kasperkamperman.com - 11-02-2018
*/

import java.net.URI;
import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.entity.ContentType;

import org.apache.http.client.utils.URIBuilder;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.util.EntityUtils;

// for file-name with date
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Date;

// for saveJpeg
import java.awt.image.BufferedImage;
import javax.imageio.plugins.jpeg.*;
import javax.imageio.*;
import javax.imageio.stream.*;

class ImageUploader extends Thread {
  
  HttpClient httpclient = new DefaultHttpClient();
  URIBuilder builder;
  
  String baseUrl = "";
  String url = baseUrl+"saveImage.php";
  
  PImage image;
  String fileName;
  
  String returnedData = "";
  boolean isDataAvailable = false;
  
  boolean saveImageAlsoLocally = false;
  
  float compressionLevel = 0.6; // default Processing is 0.9
  
  ImageUploader(PImage _image) {
    
    if(baseUrl == "") {
      isDataAvailable = true;
      returnedData = "Make sure you point \'String baseUrl\' to the directory on your web-server with saveImage.php";
    }
    else {
      this.image = _image;
      
      DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd@HH_mm_ss");
      Date d = new Date();
      
      fileName = formatter.format(d) + ".jpg";
      
      super.start();
    }
  }
  
  boolean isDataAvailable() {
    return isDataAvailable;
  }
  
  String getDataString() {
    return returnedData;
  }
  
  void run() {
    try {
      
      File file;
      
      // save to a tempory file before uploading
      // simpler that converting a PImage to a jpeg bytestream
      // implemented saveJpeg to compress images (Processing save is standard 90% with JPEG)
      if(saveImageAlsoLocally) {
        //image.save(dataPath(fileName));
        file = new File(dataPath(fileName));
        saveJpeg(image,dataPath(fileName));
      }
      else {
        file = new File(dataPath("tempImageForUpload.jpg"));
        // if we don't do this, filesize always stays the same
        // so we delete a existing tempImageForUpload first. 
        if (file.exists()) file.delete(); 
        saveJpeg(image,dataPath("tempImageForUpload.jpg"));
      }
      
      // http://www.baeldung.com/httpclient-multipart-upload
      HttpPost post = new HttpPost(url);
      
      MultipartEntityBuilder builder = MultipartEntityBuilder.create();
      builder.setMode(HttpMultipartMode.BROWSER_COMPATIBLE);
      builder.addBinaryBody("imageFile", file, ContentType.create("image/jpeg"), fileName);
      
      HttpEntity postEntity = builder.build();
      post.setEntity(postEntity);
      
      // Execute the REST API call and get the response entity.
      HttpResponse response = httpclient.execute(post);
      
      HttpEntity responseEntity = response.getEntity();
  
      if (responseEntity != null) {
          returnedData = EntityUtils.toString(responseEntity).trim();
          isDataAvailable = true;
          
          println("Response:\n"+returnedData);
      }
    }
    catch (Exception e)
    {  // Display error message.
       System.out.println(e.getMessage());
    } 
  }
  
  void saveJpeg(PImage img, String outputFilename) {
  
    try {
  
      // setup JPG output
      JPEGImageWriteParam jpegParams = new JPEGImageWriteParam(null);
      jpegParams.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
      jpegParams.setCompressionQuality(compressionLevel);
      final ImageWriter writer = ImageIO.getImageWritersByFormatName("jpg").next();
      writer.setOutput(new FileImageOutputStream(new File(outputFilename)));
  
      // native PImage is ARGB, this needs to be converted to RGB. 
      // https://blog.idrsolutions.com/2009/10/converting-java-bufferedimage-between-colorspaces/
      BufferedImage in  = (BufferedImage) img.getNative();
      BufferedImage out = new BufferedImage(img.width, img.height, BufferedImage.TYPE_INT_RGB);
      out.getGraphics().drawImage(in,0,0,null);
      
      // save it!
      writer.write(null, new IIOImage(out, null, null), jpegParams);
      //println("Saved!");
    }
    catch (Exception e) {
      println("Problem saving... :(");
      println(e);
    }
  }
  
}