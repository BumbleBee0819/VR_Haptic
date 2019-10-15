using System.IO;
using System.Collections;
using UnityEditor;
using UnityEngine;
using GameTexturesToolkit;
using LitJson;
namespace EditorCoroutines {
    public class gt_toolkit : EditorWindow {
        private readonly string[] mat_toggle_array = new string[] { "PBR Metallic", "PBR Specular" };
        [SerializeField]
        private int mat_index = 0;
        [SerializeField]
        private bool mat_toggle = false;
        private static gt_toolkit gt;
        private bool import_material = false;
        private bool is_metallic = false;
        private bool is_specular = false;
        private bool is_user = false;
        private static bool debug = false;
        private string email_field = "";
        private string password_field = "";
        private string incorrect_login = "";
        private int login_spacer = 200;
        private string import_string = "Import Material";
        private string batch_string = "Batch Import Materials";
        // Check for Previous Login
        private void Awake() {
            // Validate file extentsion is set up
            Toolkit.GTFileRegistry();
            try {
                if (File.Exists(Application.dataPath + "/GT_Toolkit/resources/data.json")) {
                    string json_data = File.ReadAllText(Application.dataPath + "/GT_Toolkit/resources/data.json");
                    JsonData user_data = JsonMapper.ToObject(json_data);
                    is_user = Toolkit.ValidateLogin(user_data["token"].ToString());
                }
            }
            catch {
                is_user = false;
            }
        }
        private static bool[] QueryWorkflowMethod(string process_method) {
            int option = EditorUtility.DisplayDialogComplex(process_method, "Please choose the PBR Workflow:", "PBR Metallic", "PBR Specular", "Cancel");
            bool[] workflow = new bool[2];
            switch (option) {
                case 0:
                    workflow[0] = true;
                    workflow[1] = false;
                    break;
                case 1:
                    workflow[0] = false;
                    workflow[1] = true;
                    break;
                case 2:
                    workflow[0] = false;
                    workflow[1] = false;
                    break;
            }
            return workflow;
        }
        // - INTERFACE - GT TOOLKIT
        [MenuItem("GameTextures/GameTextures Toolkit", priority = -1000)]
        public static void ShowWindow() {
            // Show existing window instance. If one does not exist, create one.
            gt = (gt_toolkit)EditorWindow.GetWindow(typeof(gt_toolkit), true, "GT Toolkit");
            gt.maxSize = new Vector2(300, 400);
            gt.minSize = gt.maxSize;
        }
        private Texture2D gt_logo;
        private void OnGUI() {
            gt_logo = AssetDatabase.LoadAssetAtPath<Texture2D>("Assets/GT_Toolkit/resources/gt_toolkit_logo.png");
            GUILayout.Space(20);
            GUILayout.BeginHorizontal();
            GUILayout.Space(60);
            GUILayout.Label(gt_logo);
            GUILayout.EndHorizontal();
            GUILayout.Space(10);
            
            GUIStyle foldout_style = new GUIStyle(EditorStyles.foldout);
            Color text_color = Color.black;
            foldout_style.fontStyle = FontStyle.Bold;
            foldout_style.normal.textColor = text_color;
            foldout_style.onNormal.textColor = text_color;
            foldout_style.active.textColor = text_color;
            foldout_style.onActive.textColor = text_color;
            foldout_style.hover.textColor = text_color;
            foldout_style.onHover.textColor = text_color;
            foldout_style.focused.textColor = text_color;
            foldout_style.onFocused.textColor = text_color;
            import_material = EditorGUILayout.Foldout(import_material, "Import Material", true, foldout_style);

            // TOOLKIT
            if (import_material) {
                // GUILayout.Label("Import Material", EditorStyles.boldLabel);
                GUILayout.Space(5);
                GUILayout.BeginHorizontal();
                // Create Material
                GUILayout.Label("Workflow:");
                this.mat_index = (EditorGUILayout.Popup(this.mat_index, mat_toggle_array, GUILayout.MaxWidth(250)));
                GUILayout.EndHorizontal();
                GUILayout.BeginHorizontal();
                GUILayout.Space(70);
                mat_toggle = GUILayout.Toggle(mat_toggle, "Create Material");
                GUILayout.EndHorizontal();
                GUILayout.Space(10);
                GUILayout.BeginVertical();
                GUILayout.BeginHorizontal();
                // Import Button
                if (GUILayout.Button(import_string, GUILayout.MaxWidth(300), GUILayout.MinHeight(30))) {
                    if (mat_index == 0) {
                        is_metallic = true;
                        is_specular = false;
                    }
                    else if (mat_index == 1) {
                        is_metallic = false;
                        is_specular = true;
                    }
                    else {
                        is_metallic = false;
                        is_specular = false;
                    }
                    this.StartCoroutine(Process(false));
                    // Toolkit.CreateMaterialFromFile(Toolkit.GetFilePath("Import GameTextures Material", "gtex"), is_metallic, is_specular);
                }
                GUILayout.EndHorizontal();
                GUILayout.Space(5);
                GUILayout.BeginHorizontal();
                // Import Button
                if (GUILayout.Button(batch_string, GUILayout.MaxWidth(300), GUILayout.MinHeight(30))) {
                    if (mat_index == 0) {
                        is_metallic = true;
                        is_specular = false;
                    }
                    else if (mat_index == 1) {
                        is_metallic = false;
                        is_specular = true;
                    }
                    else if (mat_index == 2) {
                        is_metallic = true;
                        is_specular = true;
                    }
                    else {
                        is_metallic = false;
                        is_specular = false;
                    }
                    this.StartCoroutine(Process(true));
                    // Toolkit.CreateMaterialFromBatch(Toolkit.GetFolderPath("Import GameTextures Material - BATCH"), is_metallic, is_specular);
                }
                GUILayout.EndHorizontal();
                GUILayout.Label("NOTE: Batch Importing Materials may take a while");
                debug = GUILayout.Toggle(debug, "debug");
                GUILayout.EndVertical();
            }
        }
        IEnumerator Process(bool batch = false) {
            if (!batch) {
                yield return this.StartCoroutine(Toolkit.CreateMaterialFromFile(Toolkit.GetFilePath("Import GameTextures Material", "gtex"), is_metallic, is_specular, mat_toggle, debug));
            }
            else {
                yield return this.StartCoroutine(Toolkit.CreateMaterialFromBatch(Toolkit.GetFolderPath("Import GameTextures Material - BATCH"), is_metallic, is_specular, mat_toggle, debug));
            }
        }
    }

    // ------------------------------------------------------------------------------------
    // ASSET POST PROCESSOR ---------------------------------------------------------------
    // ------------------------------------------------------------------------------------
    class GTTextureProcessor : AssetPostprocessor {
        void OnPreprocessTexture() {
            // Only postprocess textures if they are in or child of GameTextures/Textures
            // or a sub folder of it.
            string localAssetPath = assetPath.ToLower();
            if (localAssetPath.IndexOf("/GameTextures/Textures") == -1) {
                PreProcessTexture();
            }
        }
        void PreProcessTexture() {
            string[] texture_conversion = { "specular", "gloss", "metallic", "roughness", "height", "emissive", "opacity", "ambientocclusion" };
            string ap = assetPath.ToLower();
            TextureImporter importer = (TextureImporter)assetImporter;
            if (ap.Contains("normal")) {
                importer.textureType = TextureImporterType.NormalMap;
            }
            else {
                foreach (string texture_type in texture_conversion) {
                    if (ap.Contains(texture_type)) {
                        importer.sRGBTexture = false;
                        break;
                    }
                }
            }
        }
    }
}

