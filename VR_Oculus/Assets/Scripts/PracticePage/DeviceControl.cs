/*
 * Check the interaction status of the haptic device.
 *
 * @author:  Wenyan Bi <wb1918a@student.american.edu> 
 * @date:   2019-04-21
 */


using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeviceControl: MonoBehaviour
{
    [HideInInspector] public HapticPlugin myHaptic = null;
    [HideInInspector] public bool myHapticTouchTheCube = false;
    [HideInInspector] public bool myHapticGrabTheCube = false;



    // Start is called before the first frame update
    void Start()
    {
        myHaptic = gameObject.GetComponent(typeof(HapticPlugin)) as HapticPlugin;
        if (myHaptic == null)
        {
            Debug.LogError("This script (DeviceControl) must be attached to the same object as the HapticPlugin script.");
        }


        // [wb]: Check grabber
        if (GameObject.Find("Grabber") == null)
        {
            Debug.LogError("Missing required component: GameObject<Grabber>.");
        }

        if (GameObject.Find("Grabber").GetComponent<HapticGrabber>() == null)
            {
                Debug.LogError("The script <HapticGrabber> is not attached to the Grabber.");
            }
           

        //[wb]: Check the cube
        if (GameObject.Find("Cube") == null)
        {
            Debug.LogError("Missing required component: GameObject<Cube>.");
        }

    }






    // Update is called once per frame
    void Update()
    {
        
        if (GameObject.Find("Grabber").GetComponent<HapticGrabber>().getCurrentlyTouchedObject() == "Cube")
        {
            myHapticTouchTheCube = true;
        }


        if (GameObject.Find("Grabber").GetComponent<HapticGrabber>().isGrabbing() && GameObject.Find("Grabber").GetComponent<HapticGrabber>().isPressedButton())
        {
            myHapticGrabTheCube = true;
        }

    }



}
