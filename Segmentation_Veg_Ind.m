blue_2001 = double( imread('E:\Learning\Coursach\3kurs\maps\karlsruhe_2001-07-30_10-44_blu_aoi4.tif') );
green_2001 = double( imread('E:\Learning\Coursach\3kurs\maps\karlsruhe_2001-07-30_10-44_grn_aoi4.tif') );
nir_2001 = double( imread('E:\Learning\Coursach\3kurs\maps\karlsruhe_2001-07-30_10-44_nir_aoi4.tif' ) );
pan_2001 = imread('E:\Learning\Coursach\3kurs\maps\karlsruhe_2001-07-30_10-44_pan_aoi4.tif');
red_2001 = double( imread('E:\Learning\Coursach\3kurs\maps\karlsruhe_2001-07-30_10-44_red_aoi4.tif' ) );

blue_2003 = uint8( imread('E:\Learning\Coursach\3kurs\maps\karlsruhe_2003-06-08_10-53_1_blu_aoi4.tif') );
green_2003 = uint8( imread('E:\Learning\Coursach\3kurs\maps\karlsruhe_2003-06-08_10-53_1_grn_aoi4.tif') );
nir_2003 = uint8( imread('E:\Learning\Coursach\3kurs\maps\karlsruhe_2003-06-08_10-53_1_nir_aoi4.tif') );
pan_2003 = imread('E:\Learning\Coursach\3kurs\maps\karlsruhe_2003-06-08_10-53_1_pan_aoi4.tif');
red_2003 = uint8( imread('E:\Learning\Coursach\3kurs\maps\karlsruhe_2003-06-08_10-53_1_red_aoi4.tif') );

blue_ch = rgb2gray( imread('E:\Learning\Coursach\3kurs\maps\jpegi\karlsruhe_2001-07-30_10-44_blu_aoi4.jpg') );
green_ch = rgb2gray( imread('E:\Learning\Coursach\3kurs\maps\jpegi\karlsruhe_2001-07-30_10-44_grn_aoi4.jpg') );
red_ch = rgb2gray( imread('E:\Learning\Coursach\3kurs\maps\jpegi\karlsruhe_2001-07-30_10-44_red_aoi4.jpg' ) );

[ W, H ] = size( nir_2001 );


rgbImage_2001 = cat( 3, red_2001, green_2001, blue_2001 );
rgbImage_2003 = cat( 3, red_2003, green_2003, blue_2003 );

figure
imshow( rgbImage );

figure
subplot( 2, 2, 1); imshow( uint8( red_2001 ) ); title( 'RED 2001' );
subplot( 2, 2, 2); imshow( uint8( green_2001 ) ); title( 'GREEN 2001' );
subplot( 2, 2, 3); imshow( uint8( blue_2001 ) ); title( 'BLUE 2001' );
subplot( 2, 2, 4); imshow( uint8( nir_2001 ) ); title( 'NIR 2001' );

figure
subplot( 2, 2, 1); imshow( uint8( red_2003 ) ); title( 'RED 2003' );
subplot( 2, 2, 2); imshow( uint8( green_2003 ) ); title( 'GREEN 2003' );
subplot( 2, 2, 3); imshow( uint8( blue_2003 ) ); title( 'BLUE 2003' );
subplot( 2, 2, 4); imshow( uint8( nir_2003 ) ); title( 'NIR 2003' );

%I( j, i )

%color = [ 15 120 240 ];
color = [ 10 90 170 240 ];
% [ растительность, почва, вода, дороги ] от чёрного к белому

ndvi = zeros( 1, 3 );
ndvi( 1 ) = 0.5; %plants
ndvi( 2 ) = 0; %water
ndvi( 3 ) = -0.5; %roads

red = zeros( 1, 3 );
red( 1 ) = 0.1;
red( 2 ) = 0.02;
red( 3 ) = 0.3;

ir = zeros( 1, 3 );
ir( 1 ) = 0.3;
ir( 2 ) = 0.01;
ir( 3 ) = 0.1;

image_result = zeros( W, H );
NDVI = double(zeros( W, H ));

distance = zeros( 1, 3 );

for i = 1 : 1 : H
    for j = 1 : 1 : W
        
        NDVI( j, i ) = double(( nir_2003( j, i ) - red_2003( j, i ) ) / ( nir_2003( j, i ) + red_2003( j, i ) ));
        
        
        %{
        for k = 1 : 1 : 3
            
            distance( k ) = ( abs( NDVI( j, i ) - ndvi( k ) ) + abs( nir_2001( j, i ) - ir( k ) ) + abs( red_2001( j, i ) - red( k ) ) );
            %distance( k ) = abs(NDVI( j, i ) - ndvi( k ));
            
        end
        
        
        [ trash, color_id ] = min( distance );
        image_result( j, i ) = color( color_id );
        %}
        
        
        
        if( NDVI( j, i ) >= 0.4 )
            image_result( j, i ) = color( 1 );
        end
        
        if( ( NDVI( j, i ) < 0.4 ) && ( NDVI( j, i ) >= -0.1 ) )
            image_result( j, i ) = color( 2 );
        end
        
        if( ( NDVI( j, i ) < -0.1 ) && ( NDVI( j, i ) >= -0.23 ) )
            image_result( j, i ) = color( 3 );
        end
        
        if( NDVI( j, i ) < -0.23 )
            image_result( j, i ) = color( 4 );
        end
        
        
        
        %{
        if( NDVI( j, i ) >= 0 )
            image_result( j, i ) = color( 1 );
        end
        
        if( ( NDVI( j, i ) < 0 ) && ( NDVI( j, i ) >= -0.25 ) )
            image_result( j, i ) = color( 2 );
        end
        
        if( NDVI( j, i ) < -0.25  )
            image_result( j, i ) = color( 3 );
        end
        %}
        
        
    end
end


%subplot( 1, 3, 1); imshow( red_2001, []); title( 'Изображение red 2001' );
%subplot( 1, 3, 2); imshow( nir_2001, []); title( 'Изображение nir 2001' );
%subplot( 1, 3, 3); 
figure
imshow( image_result, []); title( 'Изображение после сегментации 2003' );
