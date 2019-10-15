/*
 * Control the LED light.
 *
 * @author:  Wenyan Bi <wb1918a@student.american.edu> 
 * @date:   2019-04-21
 */


using UnityEngine;
//using System.Collections;
//using System.Collections.Generic;

public class LEDcolor: MonoBehaviour
{
    [DisplayOnlyAttribute]  public Color altColor = new Color();
    [DisplayOnlyAttribute]  public Color originalColor = new Color();

    [HideInInspector] public Renderer leftLED_Rend = null;
    [HideInInspector] public Renderer rightLED_Rend = null;

    [HideInInspector] public bool left_colorChangeCollision = false;
    [HideInInspector] public bool right_colorChangeCollision = false;

    [HideInInspector] public CheckCollider myCheckCollider_left = null;
    [HideInInspector] public CheckCollider myCheckCollider_right = null;

    //
    void Start()
    {
        //[wb]: Get the renderer of the led light
        if (GameObject.Find("LeftLED") == null)
        {
            Debug.LogError("Missing required component: GameObject<LeftLED>.");
        }

        if (GameObject.Find("RightLED") == null)
        {
            Debug.LogError("Missing required component: GameObject<RightLED>.");
        }

        leftLED_Rend = GameObject.Find("LeftLED").GetComponent<Renderer>();
        rightLED_Rend = GameObject.Find("RightLED").GetComponent<Renderer>();



        ColorUtility.TryParseHtmlString("#04724d", out altColor);
        ColorUtility.TryParseHtmlString("#ba0028", out originalColor);
        leftLED_Rend.material.color = originalColor;
        rightLED_Rend.material.color = originalColor;



        myCheckCollider_left = GameObject.Find("LeftMat").GetComponent<CheckCollider>();
        myCheckCollider_right = GameObject.Find("RightMat").GetComponent<CheckCollider>();

        if (myCheckCollider_left == null)
        {
            Debug.LogError("The required script <CheckCollider> is not attached to the GameObject <LeftMat>.");
        }

        if (myCheckCollider_right == null)
        {
            Debug.LogError("The required script <CheckCollider> is not attached to the GameObject <RightMat>.");
        }

    }



    //
    void Update()
    {
        CheckColorChange();

    }




    void CheckColorChange()
    {
        
        if (myCheckCollider_left.colliderTouched)
        {
            left_colorChangeCollision = true;
            leftLED_Rend.material.color = altColor;
        }

        if (myCheckCollider_right.colliderTouched)
        {
            if (!left_colorChangeCollision)
            {
                myCheckCollider_right.colliderTouched = false;
            }
            else
            {
                right_colorChangeCollision = true;
                rightLED_Rend.material.color = altColor;
            }
        }

    }



    
    public void UpdateLED() 
    {
        myCheckCollider_left.UpdateCollider();
        myCheckCollider_right.UpdateCollider();

        leftLED_Rend.material.color = originalColor;
        rightLED_Rend.material.color = originalColor;

        left_colorChangeCollision = false;
        right_colorChangeCollision = false;
    }
}

