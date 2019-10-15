/*
 * Control the UI overflow of the Experiment page.
 * 
 * Author: Wenyan Bi 
 * Date: 2019/04/24
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


public class GameSetting_VisualOnly : MonoBehaviour
{
    public enum GameState {Playing, GameOver};
    public GameState gameState;

    [DisplayOnlyAttribute] public int current_trial = 0;
    [DisplayOnlyAttribute] public int total_trial = 0;

    GameObject myCube = null;
    GameObject myCube_right = null;


    public TextAsset CupMaterial = null;
    public TextAsset CupMaterial_right = null;

    CanvasGroup[] thisMenu = null; 

    public List<string> my_cupMaterial = null;
    public List<string> my_cupMaterial_right = null;


    private bool myFlag = true;
    public string inputPath;
    public string outputPath;
    public string outputFolderName;
    public string outputName_currentTrial;
    public string outputFullPath_currentTrial;
    System.IO.StreamWriter currentDataLogFile;



    void Start()
    {
        outputFolderName = "VisualOnly_Data_" + System.DateTime.Now.ToString("yyyy_MM_dd") + "_" + System.DateTime.Now.ToString("hh_mm_ss");

        outputPath = Path.Combine(Application.dataPath, "Z_Trials");
        inputPath = Path.Combine(outputPath, "Input");
        outputPath = Path.Combine(outputPath, "Output");
        outputPath = Path.Combine(outputPath, outputFolderName);

        if (!Directory.Exists(outputPath))
        {
            Directory.CreateDirectory(outputPath);
        }

        outputFullPath_currentTrial = System.String.Empty;

        outputName_currentTrial = current_trial + "_" + System.DateTime.Now.ToString("hh_mm_ss") + ".txt";
        outputFullPath_currentTrial = Path.Combine(outputPath, outputName_currentTrial);


        if (!(CupMaterial && CupMaterial_right))
        {
            Debug.LogError("Need assign the input .txt files.");
        }


        my_cupMaterial = TextAssetToList(CupMaterial);
        my_cupMaterial_right = TextAssetToList(CupMaterial);
        total_trial = my_cupMaterial.Count; // int


        myCube = GameObject.Find("Cube");
        myCube_right = GameObject.Find("Cube_right");

        if (myCube == null || myCube_right == null)
        {
            Debug.LogError("Missing required component.");
        }



        thisMenu = GameObject.FindGameObjectWithTag("MainCanvas").GetComponentsInChildren<CanvasGroup>();
        thisMenu[0].alpha = 1.0f;
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

                    myCube_right.SetActive(false);
                    GameObject.Find(my_cupMaterial_right[current_trial].TrimEnd()).transform.GetChild(0).gameObject.SetActive(true);
                    myCube_right = GameObject.Find("Cube_right");


                    myFlag = false;
                    }

                if (Input.GetButtonDown("Jump"))
                {
                    current_trial += 1;
                    myFlag = true;
                    outputName_currentTrial = current_trial + "_" + System.DateTime.Now.ToString("hh_mm_ss") + ".txt";
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







    


    private List<string> TextAssetToList(TextAsset mytext)
    {
        return new List<string>(mytext.text.Split('\n'));
    }


}

