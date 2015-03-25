% % This will read images form given files and determine if any of the
% % objects have the size and color of a mold(unsure if correct terminology)
% 
% %main function
% %TODO: should be renamed and made as a subfunction of processImage
% function remainingObjects = Main(img, min_mold_pix_val, max_mold_pix_val, min_obj_size, max_obj_size, min_mold_size)
%     set(0,'RecursionLimit',500)
%     
%     %apply grey scale
%     %only looking at red
%     img = img(:,:,1);
%     
%                                                                            %optimal range for mold: 150 - 170
%     %restrict image to a range of pixel values                             %optimal range for orig body: 130 - 150
%     bwimg = img > min_mold_pix_val & img < max_mold_pix_val; 
%     
%     %display
%     figure;
%     imshow(bwimg);
%     title('filtered for color');
%     
%     %~~~~~~~~~~~~~~~~~~~~~~FIRST FILTER PASS~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%     CC = bwconncomp(bwimg);    
%     pixelArray = cellfun(@numel, CC.PixelIdxList);
%     
%     %identify invalid structures
%     invalid_structures = find(pixelArray > max_obj_size | pixelArray <= min_obj_size);
%     
%     %use to print the number of invalid structures found
%     %size(invalid_structures)
%     
%     %remove invalid structures
%     for k = 1:length(invalid_structures)
%         invalid_pix = CC.PixelIdxList{invalid_structures(k)};
%         %every invalid pixel gets set to black
%         bwimg(invalid_pix) = 0;
%     end
%     
%     %display
%     figure;
%     imshow(bwimg);
%     title('filtered for size');
%     %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%     
%     %!!!!!!!!!!!!!!!!!!!!ENHANCE REMAINING OBJECTS!!!!!!!!!!!!!!!!!!!!!!!!!
%     %shape that dilation will use
%     structureElement = strel('disk', 3, 0);
%     %structureElement = strel('square', 5); alternate dialation option
%     bwimg = imdilate(bwimg, structureElement);
%     figure;
%     imshow(bwimg);
%     title('dialated');
%     %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%     
%     
%     %~~~~~~~~~~~~~~~~~~~~~SECOND FILTER PASS~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%     CC = bwconncomp(bwimg);    
%     pixelArray = cellfun(@numel, CC.PixelIdxList);
%     
%     %find invalid structures
%     invalid_structures = find(pixelArray < min_mold_size);
%     
%     %use to print the # of invalid structures found
%     %size(invalid_structures)
%     
%     %remove invalid structures
%     for k = 1:length(invalid_structures)
%         invalid_pix = CC.PixelIdxList{invalid_structures(k)};
%         %every invalid pixel gets set to black
%         bwimg(invalid_pix) = 0;
%     end
%     
%     %display
%     figure;
%     imshow(bwimg);
%     title('second size filter');
%     
%     %use to find num of lit pixels after second pass
%     %sum(sum(bwimg))
%     %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%     
%     %!!!!!!!!!!!!!!!!!!!COUNT REMAINING OBJECTS!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%     CC = bwconncomp(bwimg); 
%     remainingObjects = CC.NumObjects();
%     %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
% end 
% 
