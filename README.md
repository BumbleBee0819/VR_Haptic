[![GitHub issues](https://img.shields.io/github/issues/Naereen/StrapDown.js.svg)](https://github.com/BumbleBee0819/https://github.com/BumbleBee0819/VR_Haptic/issues/)
[![C%23](https://img.shields.io/badge/language-C%23-red.svg)]()
![Total visitor](https://visitor-count-badge.herokuapp.com/total.svg?repo_id=VR_haptic)
![Visitors in today](https://visitor-count-badge.herokuapp.com/today.svg?repo_id=VR_haptic)
> since 2019-10-15 16:07

<h1 align="center"> Interaction between static visual cues and force-feedback on the perception of mass of virtual objects </h1>

<p align="center">
    <img width=90% src="https://github.com/BumbleBee0819/VR_Haptic/blob/master/demo/Task.jpg">


This immersive VR game is built in the [Unity](https://unity.com/) (version 2018.3.0f2) game engine with [Oculus Rift](https://www.oculus.com/) and [3D systems Touch X](https://www.3dsystems.com/haptics-devices/touch-x) haptic force-feedback device (as shown in A. Equipment). During the game, the user will see a cube rendered with different materials (C. Material) and different weights. The user needs to first transfer the cube to the left bucket (D. Task 3), then transfer it to the right bucket (D. Task 4). Lastly, the user will judge the heaviness of the cube from 0 (lightest) - 100 (heaviest). More information can be found in the [project page](https://sites.google.com/site/wenyanbi0819/website-builder/sap18?authuser=0/).



## System Requirements:
Software:
* [Unity](https://unity3d.com/unity/whats-new/unity-2018.3.0) version 2018.3.0f2 .
* [3D Systems Openhaptics Unity Plugin](https://assetstore.unity.com/packages/tools/integration/3d-systems-openhaptics-unity-plugin-134024).
* [Openhaptics](https://3dssupport.microsoftcrmportals.com/knowledgebase/article/KA-01460/en-us) 3.5 SDK.
* [Touch Device Drivers](https://softwaresupport.3dsystems.com/).
Hardware:
* [3D systems Touch X](https://www.3dsystems.com/haptics-devices/touch-x).
* [Oculus Rift](https://www.oculus.com/).





## Demo
Equipment ([High resolution](https://www.youtube.com/embed/r5r8Opkl3zw?autoplay=1))             |  User Interface ([High resolution](https://www.youtube.com/embed/9etHTGH1M8Y?autoplay=1))
:-------------------------:|:-------------------------:
![](https://github.com/BumbleBee0819/VR_Haptic/blob/master/demo/vid1.gif)  |  ![](https://github.com/BumbleBee0819/VR_Haptic/blob/master/demo/vid2.gif)





* Next, we extracted the dense motion trajectory features of all the cloth videos.

<p align="center">
    <img width=90% src="MotionAnalysis/Z_demo/all.gif">
<p align="center">Dense motion trajectory features</strong></p>

* Using the extracted dense motion trajectory features, we built a support vector regression (SVR) model to predict the human perceptual scale of stiffness. Codes and instruction of this experiment can be found in the [MotionAnalysis](https://github.com/BumbleBee0819/Estimating_mechanical_properties_of_cloth/tree/master/MotionAnalysis) folder.

<p align="center">
    <img width=90% src="MotionAnalysis/Z_demo/demo.gif">
<p align="center">Computational modeling of human perceptual scale</strong></p>





## References
If you use the codes, please cite the following papers.
```
1. Bi, W., Jin, P., Nienborg, H., & Xiao, B. (2018). Estimating mechanical properties of cloth from videos using dense motion trajectories: Human psychophysics and machine learning. Journal of Vision, 18(5):12, 1–20.
2. Brainard, D. H., & Vision, S. (1997). The psychophysics toolbox. Spatial vision, 10, 433-436.
3. Knoblauch, K., & Maloney, L. T. (2008). MLDS: Maximum likelihood difference scaling in R. Journal of Statistical Software, 25(2), 1–26.
4. Maloney, L. T., & Yang, J. N. (2003). Maximum likelihood difference scaling. Journal of Vision, 3(8): 5, 573–585.
5. Wang, H., Kläser, A., Schmid, C., & Cheng-Lin, L. (2011, June). Action recognition by dense trajectories.
6. Wang, H., & Schmid, C. (2013). Action recognition with improved trajectories. In Proceedings of the IEEE international conference on computer vision (pp. 3551-3558).
```


## Contact
If you have any questions, please contact "wb1918a@american.edu".
