/** 
 * Game Manager for SAP18 experiment. 
 * 
 * @author Wenyan Bi <wb1918a@student.american.edu>
 * @date 2018-03-22 
 * 
 * @ Editted by Wenyan Bi on 2019-04-08 to work with Oculus Rift.
 *
 */


using UnityEngine;
using UnityEngine.SceneManagement;
//using System.Collections;
//using UnityEngine.UI;

public class GameSetting_WelcomePage : MonoBehaviour
{
    void Update()
    {

        if (GameObject.FindGameObjectWithTag("Icon_left").GetComponent<CurvedUI.CUI_ZChangeOnHover>().left_pressed)  
        {
            SceneManager.LoadScene(2);
        }

        if (GameObject.FindGameObjectWithTag("Icon_right").GetComponent<CurvedUI.CUI_ZChangeOnHover>().right_pressed) 
        {
            SceneManager.LoadScene(3);
        }
    }
    }
