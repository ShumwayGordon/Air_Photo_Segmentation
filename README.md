# Methods of aerospace images segmentation

This work considers examples of classical methods of computer vision for image segmentation. Segmentation of aerial images is performed on two classical approaches: 
1) Texture Features ⛓,
2) Vegetation Index 🌳.

## ⛓ Segmentation of aerospace images by texture features

### Formal description of the method

The problem of texture segmentation, which consists in splitting the image into regions of constant texture, i.e., selecting regions within which the values of certain texture features are relatively constant, is solved to select texture regions.

In particular, the work uses a subset of methods called structural methods of analysis of texture areas of images.
Analysis methods in this case are based on the fact that the texture consists of a regularly repeated set of well-divided primitives (microtextures), which are arranged according to some placement rule and are hierarchically combined into spatially ordered structures (macrotextures). A structural description means a texture as a set of primitive texels arranged in a regular or repeated order. Thus, to describe textures using structural methods, primitives and rules for combining them must be defined. 

Structural methods are suitable for analyzing regular textures consisting of regular primitives. Once the texture elements are identified, two basic approaches to texture analysis are possible: 
1) Statistical features of extracted texture elements are computed and used as elementary texture features;
2) The principle of arrangement of primitives that describes the texture is extracted. 

The method of analysis is usually chosen based on the geometric properties of the texture elements. The advantage of these methods is that special importance is given to the shape of tonal non-derivative elements.

Examples of the regular structures:

<p align="center">
  <img src="https://user-images.githubusercontent.com/33491221/235626579-111a60a0-d1bd-4d31-9513-14f59972b803.png"/>
</p>

The structural method of segmentation based on area analysis is suitable for this task, since the texture on aerospace images usually consists of a regularly repeating set of primitives. Therefore, it was decided to calculate statistical features for the extracted texture elements and then use them as elementary texture features for direct segmentation.

One of the ways to obtain statistical characteristics is to build a scattering matrix. This matrix contains information about the frequency of occurrence in a local image fragment of a pair of pixels with given brightness values, spatially shifted relative to each other by the shift vector 

$$d = [d_r, d_c]^T,$$

where $d_r$ is the shift value by rows of pixels, and $d_c$ is the shift value by columns.

The scattering matrix $N_d$ of image $I$ for the displacement vector $d$ is formed as follows:
$$a = I(r, c)$$
$$b = I(r + d_r, c + d_c)$$
$$N_d(a, b) = N_d(a, b) + 1$$

The initial values of $N_d$ are equal to zero. The size of the scattering matrix is determined by the number $L$ of discrete brightness levels $(a = 0...L-1, b = 0...L-1])$, which the image pixels can have.

The normalized scattering matrix $p$ is used to calculate the statistical characteristics:

$$p(a, b) = \dfrac{N_d(a, b)}{\sum\limits_{a}\sum\limits_{b}N_d(a, b)}$$

The scatter matrix constructed in a such way can be regarded as a histogram of the second order. Based on the first- and second-order statistical moments on the normalized scatter matrix, we can calculate a set of statistical parameters that can be used as components of the feature vector describing the texture.

### Description of the practical solution

First of all, we need to find the optimal shift vector for the image. For this purpose, 8 directions are defined in the form of an array of coordinates corresponding to rotation angles from 0° to 360°. For convenience of processing and speed of calculations, it is advisable to lower the brightness quantization of the image to 8-16 levels. Further, for each shift vector, the scatter matrix is built for all pixels of the image to be segmented and the chi-square criterion is calculated. As a result, the index of the optimal (by chi-square) shift vector will be obtained from 8 initial vectors. After that, the reference feature vectors for the set of textures to be automatically recognized in the image to be segmented should be constructed. For each reference texture sample, a normalized scatter matrix is calculated using the shift vector already found. The corresponding components of the reference feature vector are calculated using the generated normalized scatter matrix according to the formulas given in the tables.

Auxiliary statistical characteristics of the scattering matrix:

<div align="center">
<table>
  <thead>
    <tr>
      <th>Momentum name</th>
      <th colspan="2">Formula</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Mathematical expectation</td>
      <td>$$\bar a = \sum_{a=0}^{L-1}\sum_{b=0}^{L-1}ap(a, b)$$</td>
      <td>$$\bar b = \sum_{a=0}^{L-1}\sum_{b=0}^{L-1}bp(a, b)$$</td>
    </tr>
    <tr>
      <td>Standard deviation</td>
      <td>$$\sigma_a = \sqrt{\sum_{a=0}^{L-1}\sum_{b=0}^{L-1}a^2p(a, b) - \bar a^2}$$</td>
      <td>$$\sigma_b = \sqrt{\sum_{a=0}^{L-1}\sum_{b=0}^{L-1}b^2p(a, b) - \bar b^2}$$</td>
    </tr>
  </tbody>
</table>
</div>

The characteristics used as a descriptive feature:

<div align="center">
  <table>
  <thead>
    <tr>
      <th>Feature</th>
      <th>Formula</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Covariance</td>
      <td>$$B_C = \sum_{a=0}^{L-1}\sum_{b=0}^{L-1}(a - \bar a)(b - \bar b)p(a,b)$$</td>
    </tr>
    <tr>
      <td>Moment of inertia</td>
      <td>$$B_I = \sum_{a=0}^{L-1}\sum_{b=0}^{L-1}(a - b)^2p(a,b)$$</td>
    </tr>
    <tr>
      <td>Average absolute difference</td>
      <td>$$B_V = \sum_{a=0}^{L-1}\sum_{b=0}^{L-1}|a - b|p(a,b)$$</td>
    </tr>
    <tr>
      <td>Energy</td>
      <td>$$B_N = \sum_{a=0}^{L-1}\sum_{b=0}^{L-1}[p(a,b)]^2$$</td>
    </tr>
    <tr>
      <td>Entropy</td>
      <td>$$B_E = - \sum_{a=0}^{L-1}\sum_{b=0}^{L-1}log_{2}[p(a,b)]p(a,b)$$</td>
    </tr>
    <tr>
      <td>Inverse difference</td>
      <td>$$B_D = \sum_{a=0}^{L-1}\sum_{b=0}^{L-1}\dfrac{p(a,b)}{1+(a-b)^2}$$</td>
    </tr>
    <tr>
      <td>Homogeneity</td>
      <td>$$B_{hom} = \sum_{a=0}^{L-1}\sum_{b=0}^{L-1}\dfrac{p(a,b)}{1+|a-b|}$$</td>
    </tr>
    <tr>
      <td>Correlation coefficient</td>
      <td>$$r_c = \dfrac{ \sum\limits_{a=0}^{L-1}\sum\limits_{b=0}^{L-1}abp(a-b) - \bar a\bar b } {\sigma_a\sigma_b}$$</td>
    </tr>
  </tbody>
  </table>
</div>


The generation of the feature vector for each pixel of the image is performed similarly to the method described for determining the optimum shift vector. But at this stage, the scattering matrix elements are formed separately for each pixel by summing up the information not over the whole image area, but inside a local window of size NxN with the center in the current pixel. When scanning pixels along the edges of the image, the problem of the local window exceeding the limits of the image arose. As a solution, it was decided to artificially expand the original image from each edge, making a mirror image of N pixels. Such an edge addition locally creates a texture that differs little from the texture of the original image, so it will not negatively affect the result.

Comparison of feature vectors for each pixel with the feature vectors of the reference set of textures is performed by calculating the Euclidean distance between them and selecting the texture for which the distance was the smallest

For testing and demonstrating the algorithm, four regular textures were selected: flowers, grass, metal and wood. As a result, the program was expected to display four large segments, each of which was marked with the appropriate flag (specific color).

<p align="center">
  <img src="https://user-images.githubusercontent.com/33491221/235681168-4f8de50f-cf3b-4b8d-a324-6484f9029d56.png"/>
</p>

In the figure above, you can see that the algorithm resulted in an image divided into 4 different segments, in which each flag corresponds to a particular texture. Small inconsistencies in the texture intersections are caused by the close proximity of the textures and depend on the size of the local scanning window.

Finally, the program was tested on an aerial image. As an example, a satellite image of the Itaipu Dam in Brazil was taken in which the following textures were selected for segmentation: tropical forest, urban area and a nearby body of water. The final result of the program can be seen in the figure below.

<p align="center">
  <img src="https://user-images.githubusercontent.com/33491221/235682510-6d2bef83-f174-4c7f-a16e-4a5080eb56c6.png"/>
</p>

The output of the program was a segmented image in which white color corresponds to water space, gray to the urban area and black to the rainforest.

## 🌳 Segmentation of aerospace images by vegetation index
