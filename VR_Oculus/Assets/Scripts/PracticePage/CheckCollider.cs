/*
 * Check whether the cube has touched the collider of the mat.
 *
 * @author:  Wenyan Bi <wb1918a@student.american.edu> 
 * @date:   2019-04-21
 */



using UnityEngine;
//using System.Collections;
//using System.Collections.Generic;


public class CheckCollider : MonoBehaviour
{
    public bool colliderTouched = false;



    // [wb]: Collided?
    void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Touch")
        {
            colliderTouched = true;
        }

    }


    // [wb]: Reset the collider. Will be used in other script.
    public void UpdateCollider()
    {
        colliderTouched = false;
    }
}
