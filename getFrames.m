function getFrames()

   global ImageFolder;
   global NumFrames;
   global RefImageName;
   global Frames;
   global NumImagesProcessed;
   global ImageInfo;
   
   gotFrames = false;
   
   while not(gotFrames)
         %TODO: move this out of loop
         tifFiles = dir(strcat(ImageFolder,'/*.tif')); 
 
         if ~isempty(tifFiles);              
            RefImageName = tifFiles(1).name;
            refImageName = strcat(ImageFolder,'/',RefImageName);  %finds the filepath
            refImage = imread(refImageName);

            for i = 1:NumFrames
                fig1 = figure();
                [~,~,refImage,Frames(i,:)] = imcrop(refImage(:,:,1));
                
            end

            gotFrames = true;
         end
   end
   
   %this draws rectangle on top of figure
   for i = 1:NumFrames
   
        rectangle('Position',Frames(i,:))
   end
    
   NumImagesProcessed = 1;
   ImageInfo(1).imageName = RefImageName;
   close;
end