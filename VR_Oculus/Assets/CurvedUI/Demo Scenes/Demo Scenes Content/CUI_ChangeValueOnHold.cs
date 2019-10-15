using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;
using UnityEngine.UI;

namespace CurvedUI
{
    public class CUI_ChangeValueOnHold : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IPointerEnterHandler, IPointerExitHandler
    {

        bool pressed = false;

        [SerializeField]
        Image bg;
        [SerializeField]
        Color SelectedColor;
        [SerializeField]
        Color NormalColor;

        [SerializeField]
        CanvasGroup IntroCG;
        [SerializeField]
        CanvasGroup MenuCG; //[wb]: will show up after the introCG

        #region LifeCycle
        // Update is called once per frame
        void Update()
        {
            ChangeVal();

            if (Input.GetButtonDown("Jump"))  //[wb]: The space bar is pressed;
            {
                pressed = true;
            }

            if (Input.GetButtonUp("Jump"))
            {
                pressed = false;
            }
        }
        #endregion


        void ChangeVal()
        {

            if (this.GetComponent<Slider>().normalizedValue == 1) //[wb]: If the slider is totally filled up (i.e., value = 1);
            {
                IntroCG.alpha -= Time.deltaTime;   // [wb]: Initially, the alpha is 1 (seeable);
                MenuCG.alpha += Time.deltaTime;   // [wb]: Initially, the alpha is 0（hidden);
            }
            else {
                this.GetComponent<Slider>().normalizedValue += pressed ? Time.deltaTime : -Time.deltaTime;  // [wb]: The space bar must be in the pressed state
            }


            if (IntroCG.alpha > 0)  //[wb]: When the into is seeable;
            {
                IntroCG.blocksRaycasts = true;
            }
            else {
                IntroCG.blocksRaycasts = false;
            }
        }


        //
        public void OnPointerDown(PointerEventData data)
        {
            pressed = true;
        }

        public void OnPointerUp(PointerEventData data)
        {
            pressed = false;
        }

        public void OnPointerEnter(PointerEventData data)   // [wb]: Change color when the pointer enters the interest zone
        {
            bg.color = SelectedColor;
            bg.GetComponent<CurvedUIVertexEffect>().TesselationRequired = true;
        }

        public void OnPointerExit(PointerEventData data)
        {
            bg.color = NormalColor;
            bg.GetComponent<CurvedUIVertexEffect>().TesselationRequired = true;
        }

        //	public void OnSubmit(BaseEventData data){
        //		pressed = true;
        //	}
    }
}
