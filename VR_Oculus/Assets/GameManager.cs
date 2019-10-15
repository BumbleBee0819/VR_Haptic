/** 
 * Game Manager for SAP18 experiment. 
 * 
 * @author:   Wenyan Bi <wb1918a@student.american.edu>
 * @date:   2018-03-22 
 * 
 * @ Editted by Wenyan Bi on 2019-04-08 to work with Oculus Rift.
 *
 */

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using System.IO;


public class GameManager : MonoBehaviour
{
    static public GameManager gm;    // [wb]: static game manager, the only manager in this game

    public GameObject touchable;    // [wb]: the touchable object (i.e. the cube to be picked up)

    public Text GUI_currentTrial;        // [wb]: GUI, used to show the current trial
    public Text GUI_totalTrial;          // [wb]: GUI, used to show the total trial


    public enum GameState {Playing, GameOver};   // [wb]: game state
    public GameState gameState; //[wb]: current game state

    public int current_trial;
    public int total_trial;


    public TextAsset CupMass;
    public TextAsset CupMaterial;
    public TextAsset CupPosition;
    public TextAsset CupRotation;
    public TextAsset CupScale;


    public List<string> my_cupMass;
    public List<string> my_cupMaterial;
    public string[,] my_cupPosition;
    public string[,] my_cupRotation;
    public string[,] my_cupScale;

    public bool move_to_next_trial_check_LED1 = false;  // check whether LED1 light has turned green
    public bool move_to_next_trial_check_LED2 = false;  // check whether LED 2 light has turned green

    // for output
    public string outputPath;
    public string outputFolderName;
    public string outputName_currentTrial;
    public string outputFullPath_currentTrial;
    System.IO.StreamWriter currentDataLogFile;

    public float timer = 0.0f;



    // Use this for initialization, get relevent component, and initialize parameters
    void Start()
    {

        // wb: initialize game manager
        gm = GetComponent<GameManager>();


        // wb: initialize move to next trial checker: move to the next trial only when the two lights turn green
        move_to_next_trial_check_LED1 = false;
        move_to_next_trial_check_LED2 = false;


        // wb: get GameObject based on the tag
        if (touchable == null)
        {
            touchable = GameObject.FindGameObjectWithTag("Touchable");
        }


        // wb: Initialize current trial;
        // Because game managetr will first run; The first trial will be the Practice; 
        // Wait participant to press a "R" key to start the experiment.
        current_trial = -1;



        // wb: Read-in data files;
        my_cupMass = TextAssetToList(CupMass);   // index from 0 ~ 3: my_cupMass[0]
        my_cupMaterial = TextAssetToList(CupMaterial);
        total_trial = my_cupMaterial.Count; // int



        List<string> tmp_cupPosition = TextAssetToList(CupPosition);  
        my_cupPosition = ParseListStringToString(tmp_cupPosition); // index: my_cupPosition[0,0]

        List<string> tmp_cupRotation = TextAssetToList(CupRotation);
        my_cupRotation = ParseListStringToString(tmp_cupRotation);


        List<string> tmp_cupScale = TextAssetToList(CupScale);
        my_cupScale = ParseListStringToString(tmp_cupScale);


        // If the participant didn't input the name, use default name = "User_" + date time
        if (PlayerPrefs.GetString("UserName") == "")
        {
            PlayerPrefs.SetString("UserName", "User");
        }


        // Initialize for data save: check whether the directory containing the output data exist
        outputFolderName = PlayerPrefs.GetString("UserName") + "_" + 
            System.DateTime.Now.ToString("yyyy_MM_dd") 
            + "_" + System.DateTime.Now.ToString("hh_mm_ss");


        outputPath = Path.Combine(Application.dataPath, "Z_Trials");
        outputPath = Path.Combine(outputPath, "Output");
        outputPath = Path.Combine(outputPath, outputFolderName);

        if (!Directory.Exists(outputPath))
        {
            Directory.CreateDirectory(outputPath);
        }



        // initialize the output .txt file to empty.
        outputFullPath_currentTrial = System.String.Empty;

    }










    // Update is called once per frame
    void Update()
    {
        switch (gameState)
        {
                
            // when plyaing
            case GameState.Playing :
                // wb: GUI: show current trial and total trial
                
                GUI_currentTrial.text = (current_trial+1).ToString();   // current trial == 0 means the practice trial
                GUI_totalTrial.text = total_trial.ToString();



                // wb: Participants press "R" to move to the next trial
                if (Input.GetKeyDown(KeyCode.R) && GameManager.gm.move_to_next_trial_check_LED1 && GameManager.gm.move_to_next_trial_check_LED2)
                {
                    if (current_trial < total_trial)
                    {
                        current_trial = current_trial + 1;

                        // create name for data log file
                        outputName_currentTrial = PlayerPrefs.GetString("UserName") + "_" + current_trial + "_" + System.DateTime.Now.ToString("hh_mm_ss") + ".txt";
                        outputFullPath_currentTrial = Path.Combine(outputPath, outputName_currentTrial);

                    }

                    if (current_trial == total_trial)
                    {
                        gm.gameState = GameState.GameOver;
                    }
                }




                // wb: Participants press "P" to redo the current trial
                else if (Input.GetKeyDown(KeyCode.P))
                {
                    if (current_trial > total_trial)
                    {
                        gm.gameState = GameState.GameOver;
                        return;
                    }

                    // create name for data log file
                    outputName_currentTrial = PlayerPrefs.GetString("UserName") + "_" + current_trial + "_" + System.DateTime.Now.ToString("hh_mm_ss") + "_" + ".txt";
                    outputFullPath_currentTrial = Path.Combine(outputPath, outputName_currentTrial);



                }
                break;



            
            // when game over
            case GameState.GameOver:
                {
                    SceneManager.LoadScene(2);
                    break;
                }
        }

    }








    //
    // change text asset to list
    private List<string> TextAssetToList(TextAsset mytext)
    {
        return new List<string>(mytext.text.Split('\n'));
    }





    //
    // change the List<string> -> string[,]
    private string[,] ParseListStringToString(List<string> myListString)
    {
        int rowN = myListString.Count;
        string[,] output = new string[rowN, 3];   //column N == 3

        string tmp_row;
        string[] newtmp_row;


        for (int i = 0; i != rowN; i++)
        {
            tmp_row = myListString[i].ToString();
            newtmp_row = tmp_row.Split(' ');


            for (int j = 0; j != 3; j++)   // three columns: used to store x, y, z value
            {
                output[i,j] = newtmp_row[j];
            }

        }

        return output;
    }




}