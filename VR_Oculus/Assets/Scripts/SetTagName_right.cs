/*
 * Set the tag name of the right image
 * @author:  Wenyan Bi <wb1918a@student.american.edu> 
 * @date:   2019-04-21
 */



using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;

public class SetTagName_right : MonoBehaviour
{
    string currentTag = "";
    string targetTag = "Icon_right";

    void Awake()
    {
        currentTag = transform.tag;

        if (currentTag != targetTag)
        {
            transform.tag = targetTag;
        }
    }


}

