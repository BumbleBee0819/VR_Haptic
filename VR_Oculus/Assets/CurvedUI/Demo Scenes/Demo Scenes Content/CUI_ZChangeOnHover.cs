/*
 * Show the pop-up effect of the image when the user stares at it
 * Wenyan Bi 2019/04/21
 */

using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;



namespace CurvedUI
{
    public class CUI_ZChangeOnHover : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler
    {
        public float restZ = 0;
        public float OnHoverZ = -50;
        bool Zoomed = false;

        [HideInInspector]  //[wb]: Hide the public property in inspector
        public bool left_pressed = false;  // [wb]: Whether the left image has been stared at + selected; [start the practice page]

        [HideInInspector]
        public bool right_pressed = false; // [wb]: Whether the right image has been stared at + selected; [start the true experiment]

        private GameObject leftIconImage;
        private GameObject rightIconImage;

        // Update is called once per frame
        void Update()
        {
            (transform as RectTransform).anchoredPosition3D = (transform as RectTransform).anchoredPosition3D.ModifyZ(Mathf.Clamp((Zoomed ?
                (transform as RectTransform).anchoredPosition3D.z + Time.deltaTime * (OnHoverZ - restZ) * 6 :
                (transform as RectTransform).anchoredPosition3D.z - Time.deltaTime * (OnHoverZ - restZ) * 6), OnHoverZ, restZ));


            leftIconImage = GameObject.FindGameObjectWithTag("Icon_left");
            rightIconImage = GameObject.FindGameObjectWithTag("Icon_right");

            if ((leftIconImage.transform as RectTransform).anchoredPosition3D.z == OnHoverZ) // [wb]: If the left image is started at
            {
                if (Input.GetButtonDown("Jump"))  //[wb]: If the button is pressed
                {
                    left_pressed = true;
                }
                //if (Input.GetButtonDown("Jump")){}
            }
            else if ((rightIconImage.transform as RectTransform).anchoredPosition3D.z == OnHoverZ) // [wb]: If the right image is started at
            {
                if (Input.GetButtonDown("Jump"))
                {
                    right_pressed = true;
                }
            }


        }



        public void OnPointerEnter(PointerEventData eventData)
        {
            Zoomed = true;
        }

        public void OnPointerExit(PointerEventData eventData)
        {

            Zoomed = false;
        }
    }
}
