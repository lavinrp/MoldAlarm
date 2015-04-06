function processImage(newImName, minColor, maxColor, objSize)

    global Beep;
    global ImageInfo;
    global Frames;
    global NumFrames;
    global RefImageName;
    global NumImagesProcessed;
    global HasMold;
    global NumBeep;
    global ImageFolder;


    newImageNumber = NumImagesProcessed +1;
    
    %loads the current and reference image
    newImageName = strcat(ImageFolder,'/',newImName);
    newImage = imread(newImageName);
    
    refImageName = strcat(ImageFolder,'/',RefImageName);
    refImage = imread(refImageName);
    

    
    %crop the images 
    for i = 1:NumFrames
        
        %TODO: There is no need for frames to be an array. All rectangles
        %will be exactly the same. Make Frames a single rectangle and find
        %another way of keeping track on the number of frames
        rect = Frames(i,:);
        cropedNewImage(:,:,i) = imcrop(newImage(:,:,1),rect);
        cropedRefImage(:,:,i) = imcrop(refImage(:,:,1),rect);
    end
    
    
    %Set values for filter function
    %TODO: set from calibration
    min_obj_size = 1;
    min_mold_size = 290;
    
  %TODO: remove commented code after testing
%     min_mold_pix_val = centralColor - colorRange;
%     max_mold_pix_val = centralColor + colorRange;
% 
%     min_mold_pix_val = min_mold_pix_val + 30;
%     max_mold_pix_val = max_mold_pix_val + 30;
    
%TODO: remove magic numbetrs
%TODO: find why this is always 60
    min_mold_pix_val = minColor + 30;
    max_mold_pix_val = maxColor + 30;
 
    max_obj_size = .5 * objSize;

   
        for i = 1:NumFrames

            %calculates the difference between the current image and
            %the refrence 
            %TODO: testing here. Is subtracted needed?
            %subtracted =  cropedNewImage(:,:,i) - cropedRefImage(:,:,i);

            subtracted = cropedNewImage(:,:,i);

            %calculate number of valid objects in the image
            obj_num = ImAnalysis(subtracted, min_mold_pix_val, max_mold_pix_val, min_obj_size, max_obj_size, min_mold_size);

            %sound allarm if one or more valid object is present
            if (obj_num >= 1)
                    fprintf('Alarm tripped on image %i\n', i);
                    Beep = true;
                    NumBeep = NumBeep + 1;
                    HasMold(NumBeep).imageName = newImageName;
            end


%              WARNING: This saves every image generated in processImage to the
%              output folder. This will quickly fill memory. Do not use
%              except for debug purposes

%              %save the subtracted and the BW image
%              str = strcat(OutputFolder,'/images/','S',num2str(i),'_',newImName);
%              imwrite(subtracted,str,'jpg');
%              
%              str = strcat(OutputFolder,'/images/','BW',num2str(i),'_',newImName);
%              imwrite(BW,str,'jpg');
        end
    
        ImageInfo(newImageNumber).imageName = newImageName;
        NumImagesProcessed = NumImagesProcessed + 1;
    
end