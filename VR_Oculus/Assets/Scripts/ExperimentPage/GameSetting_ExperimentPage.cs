/*
 * Control the UI overflow of the Experiment page.
 * 
 * @author:  Wenyan Bi <wb1918a@student.american.edu> 
 * @date:   2019-04-21
 */

using UnityEngine;
using System;
using UnityEngine.SceneManagement;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine.UI;
using System.IO;
//using System.Collections;
//using UnityEngine.EventSystems;
//using UnityEngine.UI;


public class GameSetting_ExperimentPage : MonoBehaviour
{
    public enum GameState { Playing, GameOver };   // [wb]: game state
    public GameState gameState; //[wb]: current game state

    [DisplayOnlyAttribute] public int current_trial = 0;
    [DisplayOnlyAttribute] public int total_trial = 0;

    GameObject myCube = null;
    GameObject whiteCube = null;
    GameObject blackCube = null;
    GameObject myBucket_left = null;
    GameObject myBucket_right = null;

    public TextAsset CupMass = null;
    public TextAsset CupMaterial = null;
    public TextAsset CupScale = null;

    CanvasGroup[] thisMenu = null;  

    public List<string> my_cupMass = null;
    public List<string> my_cupMaterial = null;
    public string[,] my_cupScale = null;
    Vector3 initialPos = new Vector3(); 
    Vector3 initialRot = new Vector3(); 
    Vector3 initialScale_myBucket = new Vector3();
    Vector3 initialScale_myCube = new Vector3();
    Vector3 initialPos_whiteCube = new Vector3();
    Vector3 initialRot_whiteCube = new Vector3();
    Vector3 initialPos_blackCube = new Vector3();
    Vector3 initialRot_blackCube = new Vector3();


    private bool move_to_next_trial_check_LED1 = false;  
    private bool move_to_next_trial_check_LED2 = false; 
    private bool myFlag = true;
    private KeyCode[] desiredKeys = {KeyCode.Q};
    public string inputPath;
    // for output
    public string outputPath;
    public string outputFolderName;
    public string outputName_currentTrial;
    public string outputFullPath_currentTrial;
    System.IO.StreamWriter currentDataLogFile;



    void Start()
    {
        outputPath = Path.Combine(Application.dataPath, "Z_Trials");
        inputPath = Path.Combine(outputPath, "Input");
        if (!(CupMass && CupMaterial && CupScale))
        {
            Debug.LogError("Need assign the input .txt files.");
        }

        my_cupMass = TextAssetToList(CupMass); 
        my_cupMaterial = TextAssetToList(CupMaterial);
        my_cupScale = ParseListStringToString(TextAssetToList(CupScale));
        total_trial = my_cupMaterial.Count; // int


        outputFolderName = "Data_" + System.DateTime.Now.ToString("yyyy_MM_dd") + "_" +
            System.DateTime.Now.ToString("hh_mm_ss") + "_" +
            my_cupMaterial[current_trial].TrimEnd() + "_" +
            my_cupScale[current_trial, 0] + "_" +
            my_cupMass[current_trial].TrimEnd() ;


        outputPath = Path.Combine(outputPath, "Output");
        outputPath = Path.Combine(outputPath, outputFolderName);


        if (!Directory.Exists(outputPath))
        {
            Directory.CreateDirectory(outputPath);
        }


        outputFullPath_currentTrial = System.String.Empty;
        outputName_currentTrial = current_trial + "_" + System.DateTime.Now.ToString("hh_mm_ss") + "_" +
                        my_cupMaterial[current_trial].TrimEnd() + "_" +
                        my_cupScale[current_trial, 0] + "_" +
                        my_cupMass[current_trial].TrimEnd() + ".txt";
        outputFullPath_currentTrial = Path.Combine(outputPath, outputName_currentTrial);




        myCube = GameObject.Find("Cube");
        whiteCube = GameObject.Find("WhiteCube");
        blackCube = GameObject.Find("BlackCube");
        myBucket_left = GameObject.Find("LeftBucket");
        myBucket_right = GameObject.Find("RightBucket");

        if (myCube == null || whiteCube == null || blackCube == null || myBucket_left == null || myBucket_right == null)
        {
            Debug.LogError("Missing required component: GameObject<Cube, whiteCube, whiteCube, LeftBucket, RightBucket>.");
        }


        initialPos = myCube.transform.position;
        initialRot = myCube.transform.eulerAngles;
        initialScale_myCube = myCube.transform.localScale;
        initialScale_myBucket = myBucket_left.transform.localScale;
        initialPos_whiteCube = whiteCube.transform.position;
        initialPos_blackCube = blackCube.transform.position;
        initialRot_whiteCube = whiteCube.transform.eulerAngles;
        initialRot_blackCube = blackCube.transform.eulerAngles;

        thisMenu = GameObject.FindGameObjectWithTag("MainCanvas").GetComponentsInChildren<CanvasGroup>();
        thisMenu[0].alpha = 0.0f;
    }



    private void Update()
    {
        switch (gameState)
        {
            case GameState.Playing:

                if (current_trial == total_trial)
                {
                    gameState = GameState.GameOver;
                }


                if (myFlag)
                {
                    myCube.SetActive(false);
                    GameObject.Find(my_cupMaterial[current_trial].TrimEnd()).transform.GetChild(0).gameObject.SetActive(true);

                    myCube = GameObject.Find("Cube");

                    UpdateTheScene(myCube, myBucket_left, myBucket_right, initialScale_myBucket, initialScale_myCube,
                        my_cupScale, my_cupMass[current_trial], current_trial,
                        whiteCube, blackCube);

                    myFlag = false;
                }

                if (GameObject.Find("Mat").GetComponent<LEDcolor>().left_colorChangeCollision
                  && GameObject.Find("Mat").GetComponent<LEDcolor>().right_colorChangeCollision)
                {
                  thisMenu[0].alpha = 1.0f;
                }


                if (Input.GetButtonDown("Jump")
                    && GameObject.Find("Mat").GetComponent<LEDcolor>().left_colorChangeCollision
                    && GameObject.Find("Mat").GetComponent<LEDcolor>().right_colorChangeCollision
                    && GameObject.Find("Slider").GetComponent<CUI_ChangeValueOnHold_exp>().pressed
                   )
                {
                    GameObject.Find("Slider").GetComponent<CUI_ChangeValueOnHold_exp>().UpdateSlider();
                    thisMenu[0].alpha = 0.0f;
                    current_trial += 1;
                    myFlag = true;
                    outputName_currentTrial = current_trial + "_" + System.DateTime.Now.ToString("hh_mm_ss") + "_" +
                        my_cupMaterial[current_trial].TrimEnd() + "_" +
                        my_cupScale[current_trial, 0] + "_" +
                        my_cupMass[current_trial].TrimEnd() + ".txt";
                    outputFullPath_currentTrial = Path.Combine(outputPath, outputName_currentTrial);

                }
                else if (HasQLetterBeenPressed())
                {
                    thisMenu[0].alpha = 0.0f;
                    myFlag = true;
                    outputName_currentTrial = current_trial + "_" + System.DateTime.Now.ToString("hh_mm_ss") +"_" +
                        my_cupMaterial[current_trial].TrimEnd() + "_" +
                        my_cupScale[current_trial, 0] + "_" +
                        my_cupMass[current_trial].TrimEnd() + ".txt";
                    outputFullPath_currentTrial = Path.Combine(outputPath, outputName_currentTrial);

                }
                break;



            case GameState.GameOver:
                {
                    SceneManager.LoadScene(1);
                    break;
                }

        }


    }



    private void UpdateTheScene(GameObject myCube, GameObject myBucket_left, GameObject myBucket_right, 
        Vector3 initialScale_myBucket, Vector3 initialScale_myCube,
        string[,] newScale, string newMass, int current_trial,
        GameObject whiteCube, GameObject blackCube)
    {

        whiteCube.transform.position = initialPos_whiteCube;
        whiteCube.transform.eulerAngles = initialRot_whiteCube;
        blackCube.transform.position = initialPos_blackCube;
        blackCube.transform.eulerAngles = initialRot_blackCube;
        myCube.transform.position = initialPos;
        myCube.transform.eulerAngles = initialRot;
        myCube.transform.localScale = new Vector3((float)Convert.ToDouble(newScale[current_trial, 0]),
            (float)Convert.ToDouble(newScale[current_trial, 1]),
            (float)Convert.ToDouble(newScale[current_trial, 2]));

        myCube.transform.GetComponent<Rigidbody>().mass = (float)Convert.ToDouble(newMass);



        myBucket_left.transform.localScale = new Vector3(initialScale_myBucket[0] * ((float)Convert.ToDouble(newScale[current_trial, 0]) / initialScale_myCube[0]),
            initialScale_myBucket[1] * ((float)Convert.ToDouble(newScale[current_trial, 1]) / initialScale_myCube[1]),
            initialScale_myBucket[2] * ((float)Convert.ToDouble(newScale[current_trial, 2]) / initialScale_myCube[2]));

        myBucket_right.transform.localScale = new Vector3(initialScale_myBucket[0] * ((float)Convert.ToDouble(newScale[current_trial, 0]) / initialScale_myCube[0]),
                                                          initialScale_myBucket[1] * ((float)Convert.ToDouble(newScale[current_trial, 1]) / initialScale_myCube[1]),
                                                                initialScale_myBucket[2] * ((float)Convert.ToDouble(newScale[current_trial, 2]) / initialScale_myCube[2]));

        GameObject.Find("Mat").GetComponent<LEDcolor>().UpdateLED();


    }



    
    public bool HasQLetterBeenPressed()
    {
        foreach (KeyCode keyToCheck in desiredKeys)
        {
            if (Input.GetKeyDown(keyToCheck))
                return true;
        }
        return false;
    }

    private List<string> TextAssetToList(TextAsset mytext)
    {
        return new List<string>(mytext.text.Split('\n'));
    }



    private string[,] ParseListStringToString(List<string> myListString)
    {
        int rowN = myListString.Count;
        string[,] output = new string[rowN, 3];
        string tmp_row;
        string[] newtmp_row;


        for (int i = 0; i < rowN; i++)
        {
            tmp_row = myListString[i].ToString();
            newtmp_row = tmp_row.Split(' ');

            if (newtmp_row.Length != 3) break;
           
            for (int j = 0; j < 3; j++)
            {
                output[i, j] = newtmp_row[j];
            }

        }

        return output;
    }
}

