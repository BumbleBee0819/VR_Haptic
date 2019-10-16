[![GitHub issues](https://img.shields.io/github/issues/Naereen/StrapDown.js.svg)](https://github.com/BumbleBee0819/https://github.com/BumbleBee0819/VR_Haptic/issues/)
[![C%23](https://img.shields.io/badge/language-C%23-red.svg)]()
[![Python](https://img.shields.io/badge/language-Python-red.svg)]()
![Total visitor](https://visitor-count-badge.herokuapp.com/total.svg?repo_id=VR_haptic)
![Visitors in today](https://visitor-count-badge.herokuapp.com/today.svg?repo_id=VR_haptic)
> since 2019-10-15 16:07

<h1 align="center"> Interaction between static visual cues and force-feedback on the perception of mass of virtual objects </h1>

<p align="center">
    <img width=90% src="https://github.com/BumbleBee0819/VR_Haptic/blob/master/demo/Task.jpg">


This immersive VR game is built in the [Unity](https://unity.com/) (version 2018.3.0f2) game engine with [Oculus Rift](https://www.oculus.com/) and [3D systems Touch X](https://www.3dsystems.com/haptics-devices/touch-x) haptic force-feedback device (as shown in A. Equipment). During the game, the user will see a cube rendered with different materials (C. Material) and different weights. The user needs to first transfer the cube to the left bucket (D. Task 3), then transfer it to the right bucket (D. Task 4). Lastly, the user will judge the heaviness of the cube from 0 (lightest) - 100 (heaviest). More information of this project can be found in the [project page](https://sites.google.com/site/wenyanbi0819/website-builder/sap18?authuser=0/) and the [paper](https://dl.acm.org/citation.cfm?id=3225177).



## System Requirements:
Software:
* [Unity 2018.3.0f2](https://unity3d.com/unity/whats-new/unity-2018.3.0).
* [3D Systems Openhaptics Unity Plugin](https://assetstore.unity.com/packages/tools/integration/3d-systems-openhaptics-unity-plugin-134024).
* [Openhaptics 3.5 SDK](https://3dssupport.microsoftcrmportals.com/knowledgebase/article/KA-01460/en-us).
* [Touch Device Drivers](https://softwaresupport.3dsystems.com/).

Hardware:
* [3D systems Touch X](https://www.3dsystems.com/haptics-devices/touch-x).
* [Oculus Rift](https://www.oculus.com/).




## Demo
Equipment ([High resolution](https://www.youtube.com/embed/r5r8Opkl3zw?autoplay=1))             |  User Interface ([High resolution](https://www.youtube.com/embed/9etHTGH1M8Y?autoplay=1))
:-------------------------:|:-------------------------:
![](https://github.com/BumbleBee0819/VR_Haptic/blob/master/demo/vid1.gif)  |  ![](https://github.com/BumbleBee0819/VR_Haptic/blob/master/demo/vid2.gif)


<p align="center">
    <img width=60% src="/demo/experiment.jpg">
<p align="center">Cubes rendered with different materials</strong></p>

## Usage:
* The experimental design is explained in [our paper](https://dl.acm.org/citation.cfm?id=3225177).
* For each user, you first need to run [GenerateConditionFile.py](https://github.com/BumbleBee0819/VR_Haptic/tree/master/VR_Oculus/Assets/Z_Trials/Input/GenerateConditionFile.py) to generate the condition files: [cup_mass.txt](https://github.com/BumbleBee0819/VR_Haptic/tree/master/VR_Oculus/Assets/Z_Trials/Input/cup_mass.txt), [cup_material.txt](https://github.com/BumbleBee0819/VR_Haptic/tree/master/VR_Oculus/Assets/Z_Trials/Input/cup_material.txt), and [cup_scale.txt](https://github.com/BumbleBee0819/VR_Haptic/tree/master/VR_Oculus/Assets/Z_Trials/Input/cup_scale.txt).
* The data for each user is saved in the [output](https://github.com/BumbleBee0819/VR_Haptic/tree/master/VR_Oculus/Assets/Z_Trials/Output) folder. It will automatically generate a result folder for each user (e.g., [bi](https://github.com/BumbleBee0819/VR_Haptic/tree/master/VR_Oculus/Assets/Z_Trials/Output/bi)). The results of each trial is saved in one .txt file (e.g., 1_11_43_29_Cloth_0.5_1.0.txt). The .txt file is named following the pattern: trialNumber_ timeHour_timeMinute_ratedMass_Material_Scale_groudTruthMass.txt.





## References
If you use the codes, please cite our paper.
```
Bi, W., Newport, J., & Xiao, B. (2018, August). Interaction between static visual cues and force-feedback on the perception of mass of virtual objects. In Proceedings of the 15th ACM Symposium on Applied Perception (p. 12). ACM.
```


## Contact
If you have any questions, please contact "wb1918a@american.edu".
