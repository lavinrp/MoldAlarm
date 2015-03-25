function [centralColor, colorRange, validPix] = getObjectInfo(img)
    
    %here the user should select a single object
    singleObjectImg = imcrop(img);
    %imshow(singleObjectImg);
    
    % the value of 2 will cause the script to exit the crop/filter loop
    % the value of 1 indicates that the auto default color offset or the
    % initial crop was unacceptable
    acceptableImg = 3;
    
    %colorOffset greatly alters results. It is increadibly important
    %that this be set to a good value
    colorOffset = 0; %20;
 
    singleObjectImgBackup = singleObjectImg;
    %continue untill good result if found
    while acceptableImg ~= 2
        
        %if the last result was bad allow the user to add an offset
        if acceptableImg == 1
             %reset the img to its pre-croped state
             singleObjectImg = singleObjectImgBackup;
             prompt = 'Pick an offset less than 255 and greater than -255 to alter the color sensitivity by (Positive numbers increase sensitivity to dark pixels and negative numbers increase sensitivity to light pixels)';
             
             %userInput is a temp variable to facilitate the setting of
             %colorOffset        
             userInput = inputdlg(prompt);
             colorOffset = str2double(userInput{1,1});
     
        end
        
  
        %select the color to search for
        colorSample = imcrop(singleObjectImg);
        centralColor = (mean(mean(colorSample))) - colorOffset;
        colorRange = mean(range(colorSample)) / 2;

        %convert all invalid pixels to white and sum all valid pixels
        validPix = 0;
        for k = 1:size(singleObjectImg,1)
            for u = 1:size(singleObjectImg,2)
                if singleObjectImg(k,u) < (centralColor - colorRange) ||  singleObjectImg(k,u) > (centralColor + colorRange)
                    singleObjectImg(k,u) = intmax('uint8');
                else
                  validPix = validPix + 1;
                end
            end
        end

        % display image and ask user is result is acceptable
        imshow(singleObjectImg);
        acceptableImg = menu('Would you like to re-crop and alter the accepted color range?', 'Yes', 'No');
        
     end
    