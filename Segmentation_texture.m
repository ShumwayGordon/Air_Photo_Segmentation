path = 'AirSpaceShots/1/space.jpg';

% Initial image
subplot(1, 2, 1); 
imshow(imread(path) ,[]);
I = rgb2gray(imread(path)); 
[W, H] = size(I);

% Reducing brightness quantization for computational speed
srcBitDepth = 8;
dstBitDepth = 4;
graylevels = 2^dstBitDepth;
I = bitshift(I, dstBitDepth-srcBitDepth);

step = 5;
% Arrays that form the direction of the vector shift
dr = [0 step step step 0 -step -step -step]; % X-axis
dc = [step step 0 -step -step -step 0 step]; % Y-axis

% Array of 8 scattering matrices
matr_rass = zeros(8, graylevels, graylevels);

% Generation of 8 scattering matrices for 8 displacement vector directions
for i = 1 : 1 : 8 
    for j = 1 : 1 : H
        for k = 1 : 1 : W
            if ((k + dr(i)) <= W)
                if ((k + dr(i)) > 0)
                    if ((j + dc(i)) <= H)
                        if((j + dc(i)) > 0)
                            a = I(k, j) + 1;
                            b = I(k + dr(i), j + dc(i)) + 1;
                            matr_rass(i, a, b) = matr_rass(i, a, b) + 1 ;
                        end
                    end
                end
            end
        end
    end
end

% Array for the sum of the elements for each of the 8 scatter matrices
matr_rass_sum = zeros(1, 8);

% An array of normalized scattering matrices
norm_matras = zeros(8, graylevels, graylevels);

% Generation of normalized scattering matrices
for i = 1 : 1 : 8
    
    for a = 1 : 1 : graylevels
        for b = 1 : 1 : graylevels
            matr_rass_sum(i) = matr_rass_sum(i) + matr_rass(i, a, b);
        end
    end
    
    if(matr_rass_sum(i) == 0)
        error('All elements of the scattering matrix %d are equal to 0', i);
    end
    
    for a = 1 : 1 : graylevels
        for b = 1 : 1 : graylevels
            norm_matras(i, a, b) = matr_rass(i, a, b) / matr_rass_sum(i);
        end
    end
    
end

% Chi-square criteria for each normalized matrix
hi_kv = zeros(1, 8);

p_a = squeeze(sum(norm_matras, 2));
p_b = squeeze(sum(norm_matras, 3));

for i = 1 : 1 : 8
    
    % Marginalization of scattering matrix norms
    for a = 1 : 1 : graylevels
        for b = 1 : 1 : graylevels
            hi_kv(i) = hi_kv(i) + (norm_matras(i, a, b)^2 / ...
                         (p_a(a) * p_b(b)));
        end
    end
    
    hi_kv(i) = hi_kv(i) - 1;
    
end

% hi_kv_max - the maximum value of the chi-squared criterion
% vect_id - index of the optimal displacement vector
[hi_kv_max, vect_id] = max(hi_kv);


% Calculate 8 normalized bias matrices 
% For each calculate the chi-square criterion
% Of these criteria by maximization determine the optimal vector, 
% with which further we can work with

side = 133;

texture_num = 3;

texture = zeros(texture_num, side, side);

path_texture_1 = 'AirSpaceShots/1/1.2.jpg';
path_texture_2 = 'AirSpaceShots/1/2.jpg';
path_texture_3 = 'AirSpaceShots/1/3.jpg';
%path_texture_4 = '';

texture(1,:,:) = bitshift(imcrop(rgb2gray(imread(path_texture_1)), ...
                    [1 1 side-1 side-1]), dstBitDepth-srcBitDepth);
texture(2,:,:) = bitshift(imcrop(rgb2gray(imread(path_texture_2)), ...
                    [1 1 side-1 side-1]), dstBitDepth-srcBitDepth);
texture(3,:,:) = bitshift(imcrop(rgb2gray(imread(path_texture_3)), ...
                    [1 1 side-1 side-1]), dstBitDepth-srcBitDepth);
%texture(4,:,:) = bitshift(imcrop(rgb2gray(imread(path_texture_3)), ...
%                    [1 1 side-1 side-1]), dstBitDepth-srcBitDepth);

% scatter matrix array        
texture_matr_rass = zeros(texture_num, graylevels, graylevels);

% scatter matrix generation - one for each texture
% vect_id - index of the optimal shift vector
for i = 1 : 1 : texture_num 
    for j = 1 : 1 : side
        for k = 1 : 1 : side
            if ((k + dr(vect_id)) <= side)
                if ((k + dr(vect_id)) > 0)
                    if ((j + dc(vect_id)) <= side)
                        if((j + dc(vect_id)) > 0)
                            a = texture(i, k, j) + 1;
                            b = texture(i, k + dr(vect_id), j + dc(vect_id)) + 1;
                            texture_matr_rass(i, a, b) = texture_matr_rass(i, a, b) + 1;
                        end
                    end
                end 
            end
        end
    end
end

% array for the sum of the elements for each of the 4 scatter matrices
texture_matr_rass_sum = zeros(1, texture_num);

% array of normalized scattering matrices
texture_norm_matras = zeros(texture_num, graylevels, graylevels);

% generation of normalized scattering matrices
for i = 1 : 1 : texture_num
    
    for a = 1 : 1 : graylevels
        for b = 1 : 1 : graylevels
            texture_matr_rass_sum(i) = texture_matr_rass_sum(i) + texture_matr_rass(i, a, b);
        end
    end
    
    if( texture_matr_rass_sum(i) == 0)
        error('All elements of the scattering matrix %d are equal to 0', i);
    end
    
    for a = 1 : 1 : graylevels
        for b = 1 : 1 : graylevels
            texture_norm_matras(i, a, b) = texture_matr_rass(i, a, b) / texture_matr_rass_sum(i);
        end
    end
    
end

% Calculation of the mathematical expectation and the standard deviation
math_expect_a = zeros(texture_num);
math_expect_b = zeros(texture_num);
for i = 1 : 1 : texture_num
    for a = 1 : 1 : graylevels
        for b = 1 : 1 : graylevels
            math_expect_a(i) = math_expect_a(i) + (a - 1) * texture_norm_matras(i, a, b);
            math_expect_b(i) = math_expect_b(i) + (b - 1) * texture_norm_matras(i, a, b);
        end
    end
end

sr_kv_otcl_a = zeros(texture_num);
sr_kv_otcl_b = zeros(texture_num);
for i = 1 : 1 : texture_num
    
    for a = 1 : 1 : graylevels
        for b = 1 : 1 : graylevels
            sr_kv_otcl_a(i) = sr_kv_otcl_a(i) + (a - 1)^2 * texture_norm_matras(i, a, b) - math_expect_a(i)^2;
            sr_kv_otcl_b(i) = sr_kv_otcl_a(i) + (b - 1)^2 * texture_norm_matras(i, a, b) - math_expect_b(i)^2;
        end
    end
    
    sr_kv_otcl_a(i) = sqrt(sr_kv_otcl_a(i));
    sr_kv_otcl_b(i) = sqrt(sr_kv_otcl_b(i));
    
end

%{
Calculations of features used as a feature description

4 textures, 8 features in the following order:
- covariance
- moment of inertia
- mean absolute difference
- energy
- entropy
- inverse difference
- homogeneity
- correlation coefficient
%}

priznaki = zeros(texture_num, 8);

for i = 1 : 1 : texture_num
    
    for a = 1 : 1 : graylevels
        for b = 1 : 1 : graylevels
            priznaki(i, 1) = priznaki(i, 1) + ((a - 1) - math_expect_a(i)) * ((b - 1) - math_expect_b(i)) * texture_norm_matras(i, a, b);
            priznaki(i, 2) = priznaki(i, 2) + ((a - 1) - (b - 1))^2 * texture_norm_matras(i, a, b);
            priznaki(i, 3) = priznaki(i, 3) + abs((a - 1) - (b - 1)) * texture_norm_matras(i, a, b);
            priznaki(i, 4) = priznaki(i, 4) + texture_norm_matras(i, a, b)^2;
            if(texture_norm_matras(i, a, b) ~= 0)
                priznaki(i, 5) = priznaki(i, 5) + texture_norm_matras(i, a, b) * log2(texture_norm_matras(i, a, b));
            end
            priznaki(i, 6) = priznaki(i, 6) + texture_norm_matras(i, a, b) / (1 + ((a - 1) - (b - 1))^2);
            priznaki(i, 7) = priznaki(i, 7) + texture_norm_matras(i, a, b) / (1 + abs((a - 1) - (b - 1)));
            priznaki(i, 8) = priznaki(i, 8) + (a - 1) * (b - 1) * texture_norm_matras(i, a, b) - math_expect_a(i) * math_expect_b(i);
        end
    end
    priznaki(i, 5) = -priznaki(i, 5);
    priznaki(i, 8) = priznaki(i, 8) / (sr_kv_otcl_a(i) * sr_kv_otcl_b(i));
    
end

% side of the local scanning window, size 2*N+1
% tunable parameter
N = 20; %35

% mirror reflection mask
mask = zeros(2 * N + 1, 2 * N + 1);
mask(N, N) = 1;
% artificial magnification of the image by mirror reflection 
image_sized = imfilter(I, mask, 'symmetric', 'full');

image_output = zeros(W, H);

for j = 1 + N : 1 : H + N
        for k = 1 + N : 1 : W + N
            
            temp_matr_rass = zeros(graylevels, graylevels);
            
            for m = j - N : 1 : j + N
                for n = k - N : 1 : k + N
                    
                    if ((n + dr(vect_id)) <= k + N)
                        if ((n + dr(vect_id)) >= k - N)
                            if ((m + dc(vect_id)) <= j + N)
                                if((m + dc(vect_id)) >= j - N)
                                    a = image_sized(n, m) + 1;    
                                    b = image_sized(n + dr(vect_id), m + dc(vect_id)) + 1;
                                    temp_matr_rass(a, b) = temp_matr_rass(a, b) + 1 ;
                                end
                            end
                        end
                    end
                end
            end

            temp_matr_sum = sum(temp_matr_rass);
            temp_matr_sum = sum(temp_matr_sum);
            temp_norm_matras = zeros(graylevels, graylevels);
            
            for a = 1 : 1 : graylevels
                for b = 1 : 1 : graylevels
                    temp_norm_matras(a, b) = temp_matr_rass(a, b) / temp_matr_sum;
                end
            end
            %
            math_expect_a = 0;
            math_expect_b = 0;
            
            for a = 1 : 1 : graylevels
                for b = 1 : 1 : graylevels
                    math_expect_a = math_expect_a + a * temp_norm_matras(a, b);
                    math_expect_b = math_expect_b + b * temp_norm_matras(a, b);
                end
            end

            sr_kv_otcl_a = 0;
            sr_kv_otcl_b = 0;

            for a = 1 : 1 : graylevels
                for b = 1 : 1 : graylevels
                    sr_kv_otcl_a = sr_kv_otcl_a + a^2 * temp_norm_matras(a, b) - math_expect_a^2;
                    sr_kv_otcl_b = sr_kv_otcl_a + b^2 * temp_norm_matras(a, b) - math_expect_b^2;
                end
            end

            sr_kv_otcl_a = sqrt(sr_kv_otcl_a);
            
            sr_kv_otcl_b = sqrt(sr_kv_otcl_b);
            
            % calculation of histogram features for each pixel
            temp_priznaki = zeros(8);
            
            for a = 1 : 1 : graylevels
                for b = 1 : 1 : graylevels
                    temp_priznaki(1) = temp_priznaki(1) + ((a - 1) - math_expect_a) * ((b - 1) - math_expect_b) * temp_norm_matras(a, b);
                    temp_priznaki(2) = temp_priznaki(2) + ((a - 1) - (b - 1))^2 * temp_norm_matras(a, b);
                    temp_priznaki(3) = temp_priznaki(3) + abs((a - 1) - (b - 1)) * temp_norm_matras(a, b);
                    temp_priznaki(4) = temp_priznaki(4) + temp_norm_matras(a, b)^2;
                    if (temp_norm_matras(a, b) ~= 0)
                        temp_priznaki(5) = temp_priznaki(5) + temp_norm_matras(a, b) * log2(temp_norm_matras(a, b));
                    end
                    temp_priznaki(6) = temp_priznaki(6) + temp_norm_matras(a, b) / (1 + ((a - 1) - (b - 1))^2);
                    temp_priznaki(7) = temp_priznaki(7) + temp_norm_matras(a, b) / (1 + abs((a - 1) - (b - 1)));
                    temp_priznaki(8) = temp_priznaki(8) + (a - 1) * (b - 1) * temp_norm_matras(a, b) - math_expect_a * math_expect_b;
                end
            end
            
            temp_priznaki(5) = -temp_priznaki(5);
            temp_priznaki(8) = temp_priznaki(8) / (sr_kv_otcl_a * sr_kv_otcl_b);
                    
            choose_hist = [0 0 0 0];
            color = [15 80 170 240];
            
            for i = [1 2 3 4 5 6 7 8]
                
                min = abs(temp_priznaki(i) - priznaki(1, i));
                text_id = 1;
                
                for kc = 1 : 1 : texture_num
                    
                    temp = abs(temp_priznaki(i) - priznaki(kc, i));
                    if(temp < min)
                        text_id = kc;
                        min = temp;
                    end
                    
                end
                
                % histogram for determining the texture by the greatest number of matching features 
                choose_hist(text_id) = choose_hist(text_id) + 1;
                
            end
            
            [trash, texture_id] = max(choose_hist);
            image_output(k - N, j - N) = color(texture_id);
            
        end
end

subplot(1, 2, 2); imshow(image_output, []);
