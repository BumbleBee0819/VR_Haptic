using UnityEngine;
using System.Collections;
using UnityEngine.EventSystems;
using UnityEngine.UI;

public class CUI_ChangeValueOnHold_exp : MonoBehaviour
{

    [HideInInspector] public int total_rating = 0;
    [HideInInspector] public bool pressed = false;

    [SerializeField]
    Image bg;

    [SerializeField]
    Color NormalColor;

    [SerializeField]
    CanvasGroup IntroCG;

    Text myText;

    #region LifeCycle
    private void Start()
    {
        myText = GameObject.FindGameObjectWithTag("myText").GetComponent<Text>();
    }
    void Update()
    {
        if (Input.GetKeyDown("up") && total_rating < 100)
        {
            total_rating += 10;
            this.GetComponent<Slider>().normalizedValue = ((float)total_rating) / 100.0f;
            myText.text = total_rating.ToString();
            pressed = true;
        }

        if (Input.GetKeyDown("down") && total_rating > 0)
        {
            total_rating -= 10;
            this.GetComponent<Slider>().normalizedValue = ((float)total_rating) / 100.0f;
            myText.text = total_rating.ToString();
            pressed = true;

        }

        if (Input.GetKeyDown("left") && total_rating > 0)
        {
            total_rating -= 1;
            this.GetComponent<Slider>().normalizedValue = ((float)total_rating) / 100.0f;
            myText.text = total_rating.ToString();
            pressed = true;

        }

        if (Input.GetKeyDown("right") && total_rating < 100)
        {
            total_rating += 1;
            this.GetComponent<Slider>().normalizedValue = ((float)total_rating) / 100.0f;
            myText.text = total_rating.ToString();
            pressed = true;

        }
    }
    #endregion



    public void UpdateSlider()
    {
        total_rating = 0;
        pressed = false;
        this.GetComponent<Slider>().normalizedValue = 0;
        myText.text = total_rating.ToString();
    }
}
