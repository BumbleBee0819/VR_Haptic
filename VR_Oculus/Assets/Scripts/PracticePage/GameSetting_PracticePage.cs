/*
 * Control the UI overflow of the Practice page.
 * 
 * @author:  Wenyan Bi <wb1918a@student.american.edu> 
 * @date:   2019-04-21
 */

using UnityEngine;
using System;
using UnityEngine.SceneManagement;
//using System.Collections;
//using UnityEngine.EventSystems;
//using UnityEngine.UI;


public class GameSetting_PracticePage : MonoBehaviour
{ 
    // [wb]: Edittable in the inspector
    public double currentThreshold = 10.0f; 
    public float menuChangeSpeed = 1.0f;
    public float secondTrialScale = 0.8f;

    GameObject testCube;

    HapticPlugin myHapticDevice = null;  //[wb]: The haptic device
    DeviceControl myDeviceControl = null;
    CanvasGroup[] thisMenu = null;  //[wb]: The Canvas group of the current canvas;
    LEDcolor myLEDcolor = null;
    GameObject myCube = null;
    GameObject myBucket_left = null;
    GameObject myBucket_right = null;
    Vector3 initialPos = new Vector3();
    Vector3 initialScale = new Vector3();
    Vector3 initialScale_myBucket = new Vector3();
    int processControl = 0; 


     void OnEnable()
    {
        //[wb]: Check required components and scripts.

        if (GameObject.Find("HapticDevice") == null)
        {
            Debug.LogError("Can't find the GameObject: HapticDevice");
        }
        else
        {
            if (GameObject.Find("HapticDevice").GetComponent<HapticPlugin>() == null)
            {
                Debug.LogError("The script <HapticPlugin> is not attached to the HapticDevice");
            }

            if (GameObject.Find("HapticDevice").GetComponent<DeviceControl>() == null)
            {
                Debug.LogError("The script <DeviceControl> is not attached to the HapticDevice");
            }
        }

        // [wb]: Memory recollect
        GC.Collect();
    }




    private void Start()
    {

        testCube = GameObject.Find("Cube");

        myHapticDevice = GameObject.Find("HapticDevice").GetComponent<HapticPlugin>();
        myDeviceControl = GameObject.Find("HapticDevice").GetComponent<DeviceControl>();


        thisMenu = GameObject.Find("Canvas").GetComponentsInChildren<CanvasGroup>();
        if (thisMenu == null)
        {
            Debug.LogError("Missing required GameObject: Canvas and/or its children.");
        }

        for (int i = 0; i < thisMenu.Length; i++)
        {
            thisMenu[i].alpha = 0.0f;
        }
        thisMenu[0].alpha = 1.0f; 


        myLEDcolor = GameObject.Find("Mat").GetComponent<LEDcolor>();
        if (myLEDcolor == null)
        {
            Debug.LogError("Missing required component: Gameobject<Mat> and/or Script<LEDcolor>.");
        }


        myCube = GameObject.Find("Cube");
        if (myCube == null)
        {
            Debug.LogError("Missing required component: Gameobject<Cube>.");
        }

        initialPos = myCube.transform.position;
        initialScale = myCube.transform.localScale;

        myBucket_left = GameObject.Find("LeftBucket");
        myBucket_right = GameObject.Find("RightBucket");
        if (myBucket_left == null || myBucket_right == null)
        {
            Debug.LogError("Missing required component: Gameobject<RightBucket/LeftBucket>.");
        }

        initialScale_myBucket = myBucket_left.transform.localScale;

    }



    private void Update()
    {
        switch (processControl)
        {
            case 0:
                processControl = Math.Abs(myHapticDevice.stylusVelocityRaw.magnitude - 0.0) > currentThreshold ? 1 : 0; 
                break;


            case 1:
                thisMenu[0].alpha = Math.Max(0, thisMenu[0].alpha - Time.deltaTime * menuChangeSpeed);
                thisMenu[1].alpha = Math.Min(1, thisMenu[1].alpha + Time.deltaTime * menuChangeSpeed);
                processControl = myDeviceControl.myHapticTouchTheCube ? 2 : 1; 
                break;



            case 2:
                thisMenu[0].alpha = 0.0f;
                thisMenu[1].alpha = Math.Max(0, thisMenu[1].alpha - Time.deltaTime * menuChangeSpeed);
                thisMenu[2].alpha = Math.Min(1, thisMenu[2].alpha + Time.deltaTime * menuChangeSpeed);
                processControl = myDeviceControl.myHapticGrabTheCube ? 3 : 2;
                break;


            case 3:
                thisMenu[1].alpha = 0;
                thisMenu[2].alpha = Math.Max(0, thisMenu[2].alpha - Time.deltaTime * menuChangeSpeed);
                thisMenu[3].alpha = Math.Min(1, thisMenu[3].alpha + Time.deltaTime * menuChangeSpeed);  
                processControl = (myLEDcolor.left_colorChangeCollision && (!myLEDcolor.right_colorChangeCollision)) ? 4 : 3;
                break;



            case 4:
                thisMenu[2].alpha = 0.0f;
                thisMenu[3].alpha = Math.Max(0, thisMenu[3].alpha - Time.deltaTime * menuChangeSpeed);
                thisMenu[4].alpha = Math.Min(1, thisMenu[4].alpha + Time.deltaTime * menuChangeSpeed);
                processControl = myLEDcolor.right_colorChangeCollision ? 5 : 4;
                break;



            case 5:
                thisMenu[3].alpha = 0.0f;
                thisMenu[4].alpha = Math.Max(0, thisMenu[4].alpha - Time.deltaTime * menuChangeSpeed);
                thisMenu[5].alpha = Math.Min(1, thisMenu[5].alpha + Time.deltaTime * menuChangeSpeed);
                if (Input.GetButtonDown("Jump"))
                {
                    myLEDcolor.UpdateLED(); 
                    UpdateCube(myCube.transform);
                    UpdateBucket(myBucket_left.transform);
                    UpdateBucket(myBucket_right.transform);
                    processControl = 6;
                }
                break;



            case 6:
                thisMenu[4].alpha = 0.0f;
                thisMenu[5].alpha = Math.Max(0, thisMenu[5].alpha - Time.deltaTime * menuChangeSpeed);
                thisMenu[6].alpha = Math.Min(1, thisMenu[6].alpha + Time.deltaTime * menuChangeSpeed);

                processControl = (myLEDcolor.left_colorChangeCollision && myLEDcolor.right_colorChangeCollision) ? 7 : 6;
                break;



            case 7:
                thisMenu[5].alpha = 0.0f;
                thisMenu[6].alpha = Math.Max(0, thisMenu[6].alpha - Time.deltaTime * menuChangeSpeed);
                thisMenu[7].alpha = Math.Min(1, thisMenu[7].alpha + Time.deltaTime * menuChangeSpeed);

                processControl = Input.GetButtonDown("Jump") ? 8 : 7;         
                break;


            case 8:
                SceneManager.LoadScene(1);
                break;


            default:
                Debug.LogError("GameSeeting_PracticePage is not correctly run!");
                break;
        }

    }

  

    void UpdateCube(Transform transform)
    {
        transform.position = initialPos;
        transform.eulerAngles = new Vector3(0.0f, 0.0f, 0.0f);
        transform.localScale = new Vector3(secondTrialScale, secondTrialScale, secondTrialScale);   
    }

    void UpdateBucket (Transform transform)
    {
        transform.localScale = new Vector3(initialScale_myBucket[0]*(secondTrialScale/initialScale[0]),
            initialScale_myBucket[1] * (secondTrialScale / initialScale[1]),
            initialScale_myBucket[2] * (secondTrialScale / initialScale[2]));
    }
}



         